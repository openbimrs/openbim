#!/usr/bin/env bash
# Initialize/update family submodules without risking local ICDD references.
set -euo pipefail

cd "$(dirname "$0")/.."

references="packages/icdd/references"
shelter=""
sheltered=0

restore_references() {
    if [ "$sheltered" -ne 1 ]; then
        return 0
    fi

    # The flag is armed before `mv`, so interruption on either side of the
    # atomic rename is recoverable. A missing shelter is safe only when the
    # original path still exists.
    if [ ! -e "$shelter" ] && [ ! -L "$shelter" ]; then
        if [ -e "$references" ] || [ -L "$references" ]; then
            sheltered=0
            return 0
        fi
        printf 'cannot restore local references: both %s and %s are missing\n' \
            "$references" "$shelter" >&2
        return 1
    fi

    mkdir -p packages/icdd
    if [ -e "$references" ] || [ -L "$references" ]; then
        printf 'cannot restore local references: %s already exists; preserved copy remains at %s\n' \
            "$references" "$shelter" >&2
        return 1
    fi
    mv -- "$shelter" "$references"
    sheltered=0
}

cleanup() {
    restore_references
}
trap cleanup EXIT
trap 'exit 130' HUP INT TERM

preflight_url() {
    local path="$1"
    local expected_url="$2"
    local key="submodule.${path}"
    local superproject
    local -a declared_paths=() declared_urls=() configured_urls=() transport_urls=()

    mapfile -t declared_paths < <(git config -f .gitmodules --get-all "${key}.path" || true)
    mapfile -t declared_urls < <(git config -f .gitmodules --get-all "${key}.url" || true)
    if [ "${#declared_paths[@]}" -ne 1 ] || [ "${declared_paths[0]:-}" != "$path" ] ||
        [ "${#declared_urls[@]}" -ne 1 ] || [ "${declared_urls[0]:-}" != "$expected_url" ]; then
        printf '%s must have exactly one canonical .gitmodules path and URL\n' "$path" >&2
        return 1
    fi

    mapfile -t configured_urls < <(git config --get-all "${key}.url" || true)
    if [ "${#configured_urls[@]}" -gt 1 ] ||
        { [ "${#configured_urls[@]}" -eq 1 ] && [ "${configured_urls[0]}" != "$expected_url" ]; }; then
        printf '%s has non-canonical or multiple configured URLs: %s\n' \
            "$path" "${configured_urls[*]:-<unset>}" >&2
        return 1
    fi

    mapfile -t transport_urls < <(
        git -c "remote.openbim-submodule-init-guard.url=${expected_url}" \
            ls-remote --get-url openbim-submodule-init-guard
    )
    if [ "${#transport_urls[@]}" -ne 1 ] || [ "${transport_urls[0]:-}" != "$expected_url" ]; then
        printf '%s transport URL is rewritten before initialization: %s\n' \
            "$path" "${transport_urls[*]:-<unset>}" >&2
        return 1
    fi

    superproject="$(git -C "$path" rev-parse --show-superproject-working-tree 2>/dev/null || true)"
    if [ -n "$superproject" ]; then
        local -a child_origins=() child_transports=()
        mapfile -t child_origins < <(git -C "$path" config --get-all remote.origin.url || true)
        mapfile -t child_transports < <(git -C "$path" remote get-url --all origin 2>/dev/null || true)
        if [ "${#child_origins[@]}" -ne 1 ] || [ "${child_origins[0]:-}" != "$expected_url" ] ||
            [ "${#child_transports[@]}" -ne 1 ] || [ "${child_transports[0]:-}" != "$expected_url" ]; then
            printf '%s initialized child must have exactly one canonical origin and transport URL\n' \
                "$path" >&2
            return 1
        fi
    fi
}

# Reject redirected or poisoned transport before Git fetches any child data.
preflight_url packages/ids https://github.com/openbimrs/ids.git
preflight_url packages/icdd https://github.com/openbimrs/icdd.git
preflight_url packages/loin https://github.com/openbimrs/loin.git
preflight_url packages/cde https://github.com/openbimrs/cde.git
preflight_url packages/ifc https://github.com/openbimrs/ifc.git
preflight_url packages/gaeb https://github.com/openbimrs/gaeb.git
preflight_url packages/citygml https://github.com/openbimrs/citygml.git
preflight_url packages/openbimrl https://github.com/openbimrs/openbimrl.git
preflight_url packages/bsdd https://github.com/openbimrs/bsdd.git
preflight_url packages/epd https://github.com/openbimrs/epd.git

# A tracked directory from an older revision must be converted by Git first.
read -r mode _ _ _ < <(git ls-files -s -- packages/icdd)
if [ "$mode" != "160000" ]; then
    printf '%s\n' \
        'packages/icdd is not a gitlink; update the superproject revision before initializing submodules' >&2
    exit 1
fi

# Shelter the restricted/local corpus atomically on the same filesystem while
# Git creates or checks out the child worktree. The EXIT trap restores it after
# both success and ordinary failure.
if [ -e "$references" ] || [ -L "$references" ]; then
    shelter="packages/.icdd-references-migration.${BASHPID}.${RANDOM}"
    if [ -e "$shelter" ] || [ -L "$shelter" ]; then
        printf 'migration shelter already exists: %s\n' "$shelter" >&2
        exit 1
    fi
    # Arm cleanup before the atomic rename. If a signal arrives before `mv`,
    # restoration recognizes that the original path is still authoritative;
    # if it arrives after, the shelter is moved back.
    sheltered=1
    mv -- "$references" "$shelter"
fi

git submodule sync --recursive
git submodule update --init --recursive

restore_references
trap - EXIT HUP INT TERM

if [ -d "$references" ] && ! git -C packages/icdd check-ignore -q references; then
    printf '%s\n' 'packages/icdd/references is not ignored by the child repository' >&2
    exit 1
fi

scripts/check-submodules.sh
