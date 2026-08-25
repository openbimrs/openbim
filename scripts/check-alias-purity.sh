#!/usr/bin/env bash
# Alias crates must be PURE re-exports of one canonical openbim-* crate.
#
# Why this is a gate and not a review convention: if an alias defined its own
# type, a dependency graph containing both the alias and the canonical crate
# would hold two structurally identical but DISTINCT types. No Cargo version
# resolution can unify those, and the error surfaces in the consumer's code,
# not here. Guard the invariant structurally instead.
#
# The alias list is explicit rather than globbed: a
# glob would sweep in every crate in the workspace.
set -uo pipefail
cd "$(dirname "$0")/.."

# <family-dir>/<crate-name>
ALIASES="gaeb/gaeb icdd/icdd idm/idmxml loin/loin"
fail=0

for crate in $ALIASES; do
    lib="packages/$crate/src/lib.rs"
    manifest="packages/$crate/Cargo.toml"
    name="${crate##*/}"

    if [ ! -f "$lib" ]; then
        echo "  $name: missing $lib"
        fail=1
        continue
    fi

    # Every non-comment, non-blank line must be a re-export.
    offending=$(grep -vE '^\s*(//|$)' "$lib" | grep -vE '^\s*pub use [a-z0-9_]+::\*;\s*$')
    if [ -n "$offending" ]; then
        echo "  $name: alias must contain only 'pub use <crate>::*;'"
        echo "$offending" | sed 's/^/      /'
        fail=1
    fi

    if ! grep -qE '^\s*pub use [a-z0-9_]+::\*;' "$lib"; then
        echo "  $name: lib.rs has no re-export at all"
        fail=1
    fi

    # '=' pin: a caret range would let the alias drift behind the canonical crate.
    if ! grep -qE 'version = "=[0-9]' "$manifest"; then
        echo "  $name: canonical dependency must be pinned with '=' (found no '=' version)"
        fail=1
    fi
done

exit "$fail"
