#!/usr/bin/env bash
# Verify that required family submodules are initialized at their pinned commits.
set -euo pipefail

cd "$(dirname "$0")/.."

check_submodule() {
    local path="$1"
    local expected_url="$2"
    shift 2

    local actual_url
    actual_url="$(git config -f .gitmodules --get "submodule.${path}.url")"
    if [ "$actual_url" != "$expected_url" ]; then
        printf '%s URL mismatch: expected %s, got %s\n' \
            "$path" "$expected_url" "${actual_url:-<unset>}" >&2
        return 1
    fi

    local status
    status="$(git submodule status -- "$path")"
    case "$status" in
        " "*) ;;
        -*) printf '%s is not initialized; run git submodule update --init --recursive\n' "$path" >&2; return 1 ;;
        +*) printf '%s is not at the pinned commit: %s\n' "$path" "$status" >&2; return 1 ;;
        U*) printf '%s has unresolved submodule conflicts: %s\n' "$path" "$status" >&2; return 1 ;;
        *) printf 'unexpected %s submodule status: %s\n' "$path" "$status" >&2; return 1 ;;
    esac

    local effective_url
    effective_url="$(git config --get "submodule.${path}.url" || true)"
    if [ "$effective_url" != "$expected_url" ]; then
        printf '%s effective URL mismatch: expected %s, got %s\n' \
            "$path" "$expected_url" "${effective_url:-<unset>}" >&2
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
    packages/ifc \
    https://github.com/openbimrs/ifc.git \
    Cargo.toml openbim-ifc/Cargo.toml ifc-model/Cargo.toml scripts/gate.sh
