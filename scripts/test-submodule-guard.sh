#!/usr/bin/env bash
# Mutation probes for the fail-closed family-submodule guard.
set -euo pipefail

cd "$(dirname "$0")/.."

checker="scripts/check-submodules.sh"
probe_out="$(mktemp "${TMPDIR:-/tmp}/openbim-submodule-guard.XXXXXX")"
modules_backup="$(mktemp "${TMPDIR:-/tmp}/openbim-gitmodules.XXXXXX")"
cp .gitmodules "$modules_backup"

child=""
probe_file=""
config_key=""
expected_url=""
original_head=""

cleanup() {
    if [ -n "$child" ] && [ -n "$probe_file" ]; then
        git -C "$child" restore --worktree -- "${probe_file#${child}/}" >/dev/null 2>&1 || true
    fi
    if [ -n "$child" ] && [ -n "$original_head" ]; then
        git -C "$child" checkout --detach --quiet "$original_head" >/dev/null 2>&1 || true
    fi
    if [ -n "$config_key" ] && [ -n "$expected_url" ]; then
        git config "$config_key" "$expected_url" >/dev/null 2>&1 || true
    fi
    cp "$modules_backup" .gitmodules >/dev/null 2>&1 || true
    rm -f "$probe_out" "$modules_backup"
}
trap cleanup EXIT HUP INT TERM

must_reject() {
    local label="$1"
    if "$checker" >"$probe_out" 2>&1; then
        printf 'submodule guard accepted mutation: %s\n' "$label" >&2
        return 1
    fi
}

# Probe every declared family. This catches a later checker edit that validates
# one submodule correctly while accidentally omitting or weakening another.
for child in packages/ids packages/icdd; do
    probe_file="$child/README.md"
    config_key="submodule.${child}.url"
    expected_url="$(git config -f .gitmodules --get "$config_key")"
    original_head="$(git -C "$child" rev-parse HEAD)"

    # Starting clean makes all byte-for-byte restorations below safe.
    "$checker"

    printf '\nsubmodule-guard-dirty-probe\n' >>"$probe_file"
    must_reject "$child dirty worktree"
    git -C "$child" restore --worktree -- README.md

    # Local config overrides .gitmodules for future fetches.
    git config "$config_key" "https://example.invalid/${child}.git"
    must_reject "$child poisoned effective URL"
    git config "$config_key" "$expected_url"

    # The declaration itself is part of the public clone contract.
    git config -f .gitmodules "$config_key" "https://example.invalid/${child}.git"
    must_reject "$child poisoned declared URL"
    cp "$modules_backup" .gitmodules

    # The child worktree must resolve to the exact commit recorded by the parent.
    # Build a local synthetic commit from the pinned tree instead of relying on
    # `HEAD^`: Actions checks submodules out shallowly, so the pinned commit may
    # be the only object with reachable history.
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
    must_reject "$child wrong commit"
    git -C "$child" checkout --detach --quiet "$original_head"

    "$checker"
done

cleanup
trap - EXIT HUP INT TERM
