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
    local declared_path declared_url configured_url transport_url superproject

    declared_path="$(git config -f .gitmodules --get "${key}.path" || true)"
    declared_url="$(git config -f .gitmodules --get "${key}.url" || true)"
    if [ "$declared_path" != "$path" ] || [ "$declared_url" != "$expected_url" ]; then
        printf '%s has a non-canonical .gitmodules path or URL\n' "$path" >&2
        return 1
    fi

    configured_url="$(git config --get "${key}.url" || true)"
    if [ -n "$configured_url" ] && [ "$configured_url" != "$expected_url" ]; then
        printf '%s has a non-canonical configured URL: %s\n' "$path" "$configured_url" >&2
        return 1
    fi

    transport_url="$(
        git -c "remote.openbim-submodule-init-guard.url=${expected_url}" \
            ls-remote --get-url openbim-submodule-init-guard
    )"
    if [ "$transport_url" != "$expected_url" ]; then
        printf '%s transport URL is rewritten before initialization: %s\n' \
            "$path" "$transport_url" >&2
        return 1
    fi

    superproject="$(git -C "$path" rev-parse --show-superproject-working-tree 2>/dev/null || true)"
    if [ -n "$superproject" ]; then
        local child_origin child_transport
        child_origin="$(git -C "$path" config --get remote.origin.url || true)"
        child_transport="$(git -C "$path" remote get-url origin 2>/dev/null || true)"
        if [ "$child_origin" != "$expected_url" ] || [ "$child_transport" != "$expected_url" ]; then
            printf '%s initialized child has a non-canonical origin or transport URL\n' "$path" >&2
            return 1
        fi
    fi
}

# Reject redirected or poisoned transport before Git fetches any child data.
preflight_url packages/ids https://github.com/openbimrs/ids.git
preflight_url packages/icdd https://github.com/openbimrs/icdd.git
preflight_url packages/cde https://github.com/openbimrs/cde.git
preflight_url packages/ifc https://github.com/openbimrs/ifc.git
preflight_url packages/gaeb https://github.com/openbimrs/gaeb.git
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
    mv -- "$references" "$shelter"
    sheltered=1
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
