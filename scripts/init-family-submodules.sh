#!/usr/bin/env bash
# Initialize/update family submodules without risking local standards references.
set -euo pipefail

cd "$(dirname "$0")/.."

reference_paths=(
    packages/icdd/references
    packages/idm/references
    packages/loin/references
    packages/dt/references
)
sheltered_paths=()
shelters=()

restore_references() {
    local status=0 index destination shelter
    for ((index=${#shelters[@]} - 1; index >= 0; index--)); do
        destination="${sheltered_paths[$index]}"
        shelter="${shelters[$index]}"

        # Each cleanup entry is armed before mv. If interruption happens before
        # the rename, the original is still authoritative and needs no action.
        if [ ! -e "$shelter" ] && [ ! -L "$shelter" ]; then
            if [ -e "$destination" ] || [ -L "$destination" ]; then
                continue
            fi
            printf 'cannot restore local references: both %s and %s are missing\n' \
                "$destination" "$shelter" >&2
            status=1
            continue
        fi

        if [ -e "$destination" ] || [ -L "$destination" ]; then
            printf 'cannot restore local references: %s already exists; preserved copy remains at %s\n' \
                "$destination" "$shelter" >&2
            status=1
            continue
        fi
        mkdir -p "${destination%/references}"
        mv -- "$shelter" "$destination" || status=1
    done
    if [ "$status" -eq 0 ]; then
        sheltered_paths=()
        shelters=()
    fi
    return "$status"
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

preflight_url packages/ids https://github.com/openbimrs/ids.git
preflight_url packages/icdd https://github.com/openbimrs/icdd.git
preflight_url packages/idm https://github.com/openbimrs/idm.git
preflight_url packages/loin https://github.com/openbimrs/loin.git
preflight_url packages/dt https://github.com/openbimrs/dt.git
preflight_url packages/cde https://github.com/openbimrs/cde.git
preflight_url packages/ifc https://github.com/openbimrs/ifc.git
preflight_url packages/step https://github.com/openbimrs/step.git
preflight_url packages/gaeb https://github.com/openbimrs/gaeb.git
preflight_url packages/citygml https://github.com/openbimrs/citygml.git
preflight_url packages/openbimrl https://github.com/openbimrs/openbimrl.git
preflight_url packages/bsdd https://github.com/openbimrs/bsdd.git
preflight_url packages/epd https://github.com/openbimrs/epd.git

# A tracked directory from an older revision must be converted by Git first.
for path in packages/icdd packages/idm packages/loin packages/dt; do
    read -r mode _ _ _ < <(git ls-files -s -- "$path")
    if [ "$mode" != "160000" ]; then
        printf '%s is not a gitlink; update the superproject revision before initializing submodules\n' \
            "$path" >&2
        exit 1
    fi
done

# Shelter each corpus atomically on the same filesystem while Git creates or
# advances child worktrees. Arm cleanup before mv so signals on either side of
# the rename remain recoverable.
for references in "${reference_paths[@]}"; do
    if [ -e "$references" ] || [ -L "$references" ]; then
        family="${references#packages/}"
        family="${family%/references}"
        shelter="packages/.${family}-references-migration.${BASHPID}.${RANDOM}"
        if [ -e "$shelter" ] || [ -L "$shelter" ]; then
            printf 'migration shelter already exists: %s\n' "$shelter" >&2
            exit 1
        fi
        sheltered_paths+=("$references")
        shelters+=("$shelter")
        mv -- "$references" "$shelter"
    fi
done

git submodule sync --recursive
git submodule update --init --recursive

restore_references
trap - EXIT HUP INT TERM

for references in "${reference_paths[@]}"; do
    family_root="${references%/references}"
    if [ -d "$references" ] && ! git -C "$family_root" check-ignore -q references; then
        printf '%s/references is not ignored by the child repository\n' "$family_root" >&2
        exit 1
    fi
done

scripts/check-submodules.sh
