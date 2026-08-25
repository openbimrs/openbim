#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

prefix='openbim-co''dec-'
rust_prefix='openbim_co''dec_'
retired_dir='packages/co''dec'
retired_repo='openbimrs/co''dec'

if [[ -e "$retired_dir" ]]; then
    printf 'retired wrapper directory remains: %s\n' "$retired_dir" >&2
    exit 1
fi

for pattern in \
    "${prefix}step" "${prefix}xml" "${prefix}zip" \
    "${rust_prefix}step" "${rust_prefix}xml" "${rust_prefix}zip" \
    "$retired_dir" "$retired_repo"; do
    if matches="$(git grep -n -I -F -- "$pattern" -- . 2>/dev/null)"; then
        printf 'retired wrapper reference remains:\n%s\n' "$matches" >&2
        exit 1
    fi
done
