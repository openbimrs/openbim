#!/usr/bin/env bash
# Verify that required family submodules are initialized, clean, and pinned.
set -euo pipefail

cd "$(dirname "$0")/.."

check_submodule() {
    local path="$1"
    local expected_url="$2"
    shift 2

    local declared_path
    declared_path="$(git config -f .gitmodules --get "submodule.${path}.path" || true)"
    if [ "$declared_path" != "$path" ]; then
        printf '%s path mismatch: expected %s, got %s\n' \
            "$path" "$path" "${declared_path:-<unset>}" >&2
        return 1
    fi

    local declared_url
    declared_url="$(git config -f .gitmodules --get "submodule.${path}.url" || true)"
    if [ "$declared_url" != "$expected_url" ]; then
        printf '%s declared URL mismatch: expected %s, got %s\n' \
            "$path" "$expected_url" "${declared_url:-<unset>}" >&2
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

    local configured_url
    configured_url="$(git config --get "submodule.${path}.url" || true)"
    if [ "$configured_url" != "$expected_url" ]; then
        printf '%s configured URL mismatch: expected %s, got %s\n' \
            "$path" "$expected_url" "${configured_url:-<unset>}" >&2
        return 1
    fi

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

    local child_origin_url
    child_origin_url="$(git -C "$path" config --get remote.origin.url || true)"
    if [ "$child_origin_url" != "$expected_url" ]; then
        printf '%s child origin mismatch: expected %s, got %s\n' \
            "$path" "$expected_url" "${child_origin_url:-<unset>}" >&2
        return 1
    fi

    local child_transport_url
    child_transport_url="$(git -C "$path" remote get-url origin)"
    if [ "$child_transport_url" != "$expected_url" ]; then
        printf '%s child transport URL is rewritten: expected %s, got %s\n' \
            "$path" "$expected_url" "$child_transport_url" >&2
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
    packages/epd \
    https://github.com/openbimrs/epd.git \
    Cargo.toml openbim-epd/Cargo.toml scripts/gate.sh
