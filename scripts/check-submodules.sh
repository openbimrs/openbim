#!/usr/bin/env bash
# Verify that required family submodules are initialized at the pinned commit.
set -euo pipefail

cd "$(dirname "$0")/.."

expected_url="https://github.com/openbimrs/ids.git"
actual_url="$(git config -f .gitmodules --get submodule.packages/ids.url)"
if [ "$actual_url" != "$expected_url" ]; then
    printf 'packages/ids URL mismatch: expected %s, got %s\n' "$expected_url" "$actual_url" >&2
    exit 1
fi

status="$(git submodule status -- packages/ids)"
case "$status" in
    " "*) ;;
    -*) printf 'packages/ids is not initialized; run git submodule update --init --recursive\n' >&2; exit 1 ;;
    +*) printf 'packages/ids is not at the pinned commit: %s\n' "$status" >&2; exit 1 ;;
    U*) printf 'packages/ids has unresolved submodule conflicts: %s\n' "$status" >&2; exit 1 ;;
    *) printf 'unexpected packages/ids submodule status: %s\n' "$status" >&2; exit 1 ;;
esac

test -f packages/ids/Cargo.toml
test -f packages/ids/openbim-ids/Cargo.toml
