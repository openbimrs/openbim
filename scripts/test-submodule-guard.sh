#!/usr/bin/env bash
# Mutation probes for the fail-closed family-submodule guard.
set -euo pipefail

cd "$(dirname "$0")/.."

checker="scripts/check-submodules.sh"
children=(packages/ids packages/icdd packages/cde packages/ifc packages/gaeb packages/citygml packages/openbimrl packages/bsdd packages/epd)

# Fail before installing any cleanup that could touch a pre-existing state.
"$checker"

probe_root="$(mktemp -d "${TMPDIR:-/tmp}/openbim-submodule-guard.XXXXXX")"
probe_out="$probe_root/checker.out"
modules_backup="$probe_root/gitmodules"
cp .gitmodules "$modules_backup"

child=""
probe_file=""
probe_file_active=0
declared_active=0
head_active=0
original_head=""
original_symbolic_ref=""
parent_config_active=0
parent_config_key=""
parent_config_snapshot="$probe_root/parent-config"
origin_active=0
origin_snapshot="$probe_root/origin-config"
parent_rewrite_active=0
parent_rewrite_key=""
parent_rewrite_snapshot="$probe_root/parent-rewrite"
child_rewrite_active=0
child_rewrite_key=""
child_rewrite_snapshot="$probe_root/child-rewrite"

snapshot_config() {
    local repo="$1"
    local key="$2"
    local destination="$3"
    : >"$destination"
    if [ "$repo" = . ]; then
        git config --get-all "$key" >"$destination" || [ "$?" -eq 1 ]
    else
        git -C "$repo" config --get-all "$key" >"$destination" || [ "$?" -eq 1 ]
    fi
}

restore_config() {
    local repo="$1"
    local key="$2"
    local source="$3"
    if [ "$repo" = . ]; then
        git config --unset-all "$key" >/dev/null 2>&1 || true
        while IFS= read -r value; do
            git config --add "$key" "$value"
        done <"$source"
    else
        git -C "$repo" config --unset-all "$key" >/dev/null 2>&1 || true
        while IFS= read -r value; do
            git -C "$repo" config --add "$key" "$value"
        done <"$source"
    fi
}

restore_head() {
    git -C "$child" checkout --detach --quiet "$original_head"
    if [ -n "$original_symbolic_ref" ]; then
        git -C "$child" symbolic-ref HEAD "$original_symbolic_ref"
    fi
}

cleanup() {
    local cleanup_status=0
    if [ "$probe_file_active" -eq 1 ]; then
        rm -f -- "$probe_file" || cleanup_status=1
    fi
    if [ "$head_active" -eq 1 ]; then
        restore_head >/dev/null 2>&1 || cleanup_status=1
    fi
    if [ "$origin_active" -eq 1 ]; then
        restore_config "$child" remote.origin.url "$origin_snapshot" >/dev/null 2>&1 || cleanup_status=1
    fi
    if [ "$parent_config_active" -eq 1 ]; then
        restore_config . "$parent_config_key" "$parent_config_snapshot" >/dev/null 2>&1 || cleanup_status=1
    fi
    if [ "$parent_rewrite_active" -eq 1 ]; then
        restore_config . "$parent_rewrite_key" "$parent_rewrite_snapshot" >/dev/null 2>&1 || cleanup_status=1
    fi
    if [ "$child_rewrite_active" -eq 1 ]; then
        restore_config "$child" "$child_rewrite_key" "$child_rewrite_snapshot" >/dev/null 2>&1 || cleanup_status=1
    fi
    if [ "$declared_active" -eq 1 ]; then
        cp "$modules_backup" .gitmodules >/dev/null 2>&1 || cleanup_status=1
    fi
    rm -rf -- "$probe_root" || cleanup_status=1
    return "$cleanup_status"
}
trap cleanup EXIT
trap 'exit 130' HUP INT TERM

must_reject() {
    local label="$1"
    if "$checker" >"$probe_out" 2>&1; then
        printf 'submodule guard accepted mutation: %s\n' "$label" >&2
        return 1
    fi
}

# Probe every declared family. This catches a later checker edit that validates
# one submodule correctly while accidentally omitting or weakening another.
for child in "${children[@]}"; do
    parent_config_key="submodule.${child}.url"
    expected_url="$(git config -f .gitmodules --get "$parent_config_key")"
    original_head="$(git -C "$child" rev-parse HEAD)"
    original_symbolic_ref="$(git -C "$child" symbolic-ref -q HEAD || true)"

    # Use a unique untracked file; never rewrite a tracked user file.
    probe_file="$child/submodule-guard-probe.$$.${RANDOM}"
    relative_probe_file="${probe_file#${child}/}"
    if git -C "$child" check-ignore -q -- "$relative_probe_file"; then
        printf 'dirty probe path is unexpectedly ignored: %s\n' "$probe_file" >&2
        exit 1
    fi
    printf 'submodule guard dirty probe\n' >"$probe_file"
    probe_file_active=1
    must_reject "$child dirty worktree"
    rm -f -- "$probe_file"
    probe_file_active=0

    # Parent-local submodule URL overrides .gitmodules for future updates.
    snapshot_config . "$parent_config_key" "$parent_config_snapshot"
    git config --replace-all "$parent_config_key" "https://example.invalid/${child}.git"
    parent_config_active=1
    must_reject "$child poisoned configured URL"
    restore_config . "$parent_config_key" "$parent_config_snapshot"
    parent_config_active=0

    # The declaration itself is the public recursive-clone contract.
    git config -f .gitmodules "$parent_config_key" "https://example.invalid/${child}.git"
    declared_active=1
    must_reject "$child poisoned declared URL"
    cp "$modules_backup" .gitmodules
    declared_active=0

    git config -f .gitmodules "submodule.${child}.path" "packages/invalid-${BASHPID}"
    declared_active=1
    must_reject "$child poisoned declared path"
    cp "$modules_backup" .gitmodules
    declared_active=0

    # The initialized child's own origin must remain canonical.
    snapshot_config "$child" remote.origin.url "$origin_snapshot"
    git -C "$child" config --replace-all remote.origin.url "https://example.invalid/${child}.git"
    origin_active=1
    must_reject "$child poisoned child origin"
    restore_config "$child" remote.origin.url "$origin_snapshot"
    origin_active=0

    # Detect transport rewriting in both the parent and initialized child config.
    parent_rewrite_key="url.https://example.invalid/openbim-parent-guard-${BASHPID}-${RANDOM}/.insteadOf"
    snapshot_config . "$parent_rewrite_key" "$parent_rewrite_snapshot"
    git config --add "$parent_rewrite_key" "https://github.com/openbimrs/"
    parent_rewrite_active=1
    must_reject "$child parent insteadOf rewrite"
    restore_config . "$parent_rewrite_key" "$parent_rewrite_snapshot"
    parent_rewrite_active=0

    child_rewrite_key="url.https://example.invalid/openbim-child-guard-${BASHPID}-${RANDOM}/.insteadOf"
    snapshot_config "$child" "$child_rewrite_key" "$child_rewrite_snapshot"
    git -C "$child" config --add "$child_rewrite_key" "https://github.com/openbimrs/"
    child_rewrite_active=1
    must_reject "$child child insteadOf rewrite"
    restore_config "$child" "$child_rewrite_key" "$child_rewrite_snapshot"
    child_rewrite_active=0

    # Actions may provide a one-commit shallow child, so synthesize a local
    # wrong commit from the pinned tree instead of relying on HEAD^.
    probe_head="$(
        printf 'submodule guard wrong-pin probe\n' |
            env \
                GIT_AUTHOR_NAME='OpenBIM gate' \
                GIT_AUTHOR_EMAIL='gate@openbim.invalid' \
                GIT_AUTHOR_DATE='2000-01-01T00:00:00Z' \
                GIT_COMMITTER_NAME='OpenBIM gate' \
                GIT_COMMITTER_EMAIL='gate@openbim.invalid' \
                GIT_COMMITTER_DATE='2000-01-01T00:00:00Z' \
                git -C "$child" commit-tree "${original_head}^{tree}" -p "$original_head"
    )"
    git -C "$child" checkout --detach --quiet "$probe_head"
    head_active=1
    must_reject "$child wrong commit"
    restore_head
    head_active=0

    "$checker"
done

cleanup
trap - EXIT HUP INT TERM
