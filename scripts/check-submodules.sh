#!/usr/bin/env bash
# Verify that required family submodules are initialized, clean, and pinned.
set -euo pipefail

cd "$(dirname "$0")/.."

check_submodule() {
    local path="$1"
    local expected_url="$2"
    shift 2

    local -a declared_paths=()
    mapfile -t declared_paths < <(
        git config -f .gitmodules --get-all "submodule.${path}.path" || true
    )
    if [ "${#declared_paths[@]}" -ne 1 ] || [ "${declared_paths[0]:-}" != "$path" ]; then
        printf '%s path mismatch: expected exactly %s, got %s value(s): %s\n' \
            "$path" "$path" "${#declared_paths[@]}" "${declared_paths[*]:-<unset>}" >&2
        return 1
    fi

    local -a declared_urls=()
    mapfile -t declared_urls < <(
        git config -f .gitmodules --get-all "submodule.${path}.url" || true
    )
    if [ "${#declared_urls[@]}" -ne 1 ] || [ "${declared_urls[0]:-}" != "$expected_url" ]; then
        printf '%s declared URL mismatch: expected exactly %s, got %s value(s): %s\n' \
            "$path" "$expected_url" "${#declared_urls[@]}" "${declared_urls[*]:-<unset>}" >&2
        return 1
    fi

    local status
    status="$(git submodule status -- "$path")"
    case "$status" in
        " "*) ;;
        -*) printf '%s is not initialized; run scripts/init-family-submodules.sh\n' "$path" >&2; return 1 ;;
        +*) printf '%s is not at the pinned commit: %s\n' "$path" "$status" >&2; return 1 ;;
        U*) printf '%s has unresolved submodule conflicts: %s\n' "$path" "$status" >&2; return 1 ;;
        *) printf 'unexpected %s submodule status: %s\n' "$path" "$status" >&2; return 1 ;;
    esac

    local -a configured_urls=()
    mapfile -t configured_urls < <(
        git config --get-all "submodule.${path}.url" || true
    )
    if [ "${#configured_urls[@]}" -ne 1 ] || [ "${configured_urls[0]:-}" != "$expected_url" ]; then
        printf '%s configured URL mismatch: expected exactly %s, got %s value(s): %s\n' \
            "$path" "$expected_url" "${#configured_urls[@]}" "${configured_urls[*]:-<unset>}" >&2
        return 1
    fi
    local configured_url="${configured_urls[0]}"

    # `url.*.insteadOf` can redirect a canonical-looking URL at transport time.
    # Resolve a synthetic parent remote so local/global rewrite rules are applied.
    local parent_transport_url
    parent_transport_url="$(
        git -c "remote.openbim-submodule-guard.url=${configured_url}" \
            ls-remote --get-url openbim-submodule-guard
    )"
    if [ "$parent_transport_url" != "$expected_url" ]; then
        printf '%s parent transport URL is rewritten: expected %s, got %s\n' \
            "$path" "$expected_url" "$parent_transport_url" >&2
        return 1
    fi

    local -a child_origin_urls=()
    mapfile -t child_origin_urls < <(
        git -C "$path" config --get-all remote.origin.url || true
    )
    if [ "${#child_origin_urls[@]}" -ne 1 ] || [ "${child_origin_urls[0]:-}" != "$expected_url" ]; then
        printf '%s child origin mismatch: expected exactly %s, got %s value(s): %s\n' \
            "$path" "$expected_url" "${#child_origin_urls[@]}" "${child_origin_urls[*]:-<unset>}" >&2
        return 1
    fi

    local -a child_transport_urls=()
    mapfile -t child_transport_urls < <(
        git -C "$path" remote get-url --all origin || true
    )
    if [ "${#child_transport_urls[@]}" -ne 1 ] || [ "${child_transport_urls[0]:-}" != "$expected_url" ]; then
        printf '%s child transport URL mismatch: expected exactly %s, got %s value(s): %s\n' \
            "$path" "$expected_url" "${#child_transport_urls[@]}" "${child_transport_urls[*]:-<unset>}" >&2
        return 1
    fi

    local gitlink_mode pinned_commit child_head
    read -r gitlink_mode pinned_commit _ _ < <(git ls-files -s -- "$path")
    if [ "$gitlink_mode" != "160000" ] || [ -z "$pinned_commit" ]; then
        printf '%s is not a parent gitlink\n' "$path" >&2
        return 1
    fi
    child_head="$(git -C "$path" rev-parse HEAD)"
    if [ "$child_head" != "$pinned_commit" ]; then
        printf '%s HEAD mismatch: expected %s, got %s\n' \
            "$path" "$pinned_commit" "$child_head" >&2
        return 1
    fi

    local dirty
    dirty="$(git -C "$path" status --porcelain=v1 --untracked-files=all)"
    if [ -n "$dirty" ]; then
        printf '%s worktree is dirty:\n%s\n' "$path" "$dirty" >&2
        return 1
    fi

    local required
    for required in "$@"; do
        if [ ! -f "$path/$required" ]; then
            printf '%s is missing required file %s\n' "$path" "$required" >&2
            return 1
        fi
    done
}

check_submodule \
    packages/ids \
    https://github.com/openbimrs/ids.git \
    Cargo.toml openbim-ids/Cargo.toml scripts/gate.sh

check_submodule \
    packages/icdd \
    https://github.com/openbimrs/icdd.git \
    Cargo.toml openbim-icdd/Cargo.toml icdd/Cargo.toml scripts/gate.sh

check_submodule \
    packages/loin \
    https://github.com/openbimrs/loin.git \
    Cargo.toml openbim-loin/Cargo.toml loin/Cargo.toml scripts/gate.sh

check_submodule \
    packages/cde \
    https://github.com/openbimrs/cde.git \
    Cargo.toml openbim-cde/Cargo.toml scripts/gate.sh

check_submodule \
    packages/ifc \
    https://github.com/openbimrs/ifc.git \
    Cargo.toml openbim-ifc/Cargo.toml ifc-model/Cargo.toml scripts/gate.sh

check_submodule \
    packages/gaeb \
    https://github.com/openbimrs/gaeb.git \
    Cargo.toml openbim-gaeb/Cargo.toml gaeb/Cargo.toml scripts/gate.sh

check_submodule \
    packages/citygml \
    https://github.com/openbimrs/citygml.git \
    Cargo.toml openbim-citygml/Cargo.toml citygml/Cargo.toml scripts/gate.sh

check_submodule \
    packages/openbimrl \
    https://github.com/openbimrs/openbimrl.git \
    Cargo.toml openbim-openbimrl/Cargo.toml openbimrl/Cargo.toml scripts/gate.sh

check_submodule \
    packages/bsdd \
    https://github.com/openbimrs/bsdd.git \
    Cargo.toml openbim-bsdd/Cargo.toml bsdd/Cargo.toml scripts/gate.sh

check_submodule \
    packages/epd \
    https://github.com/openbimrs/epd.git \
    Cargo.toml openbim-epd/Cargo.toml scripts/gate.sh
