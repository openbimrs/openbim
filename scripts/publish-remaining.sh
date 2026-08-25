#!/usr/bin/env bash
# Publish the remaining openbim crates.
#
# crates.io rate-limits NEW crate names to roughly one per 10 minutes, so a
# straight loop fails with HTTP 429 partway through. This retries on 429 and
# keeps going, in dependency order: a crate cannot be published until every
# crate it depends on is already on the registry.
#
# Safe to re-run. An already-published crate reports "already uploaded" and is
# skipped rather than treated as a failure.
set -uo pipefail
cd "$(dirname "$0")/.."

# Canonical crates first, then the facade, then the remaining aliases -- an
# alias `=`-pins its canonical crate, so that crate must already be on the
# registry.
#
# `openbim-ifc` is deliberately NOT in this list. It depends on the 18 `ifc-*`
# crates, none of which are published, so it cannot be published until they
# are. Publishing the IFC family is a separate decision from securing the
# openBIM standard names.
ORDER="openbim idmxml loin"

for c in $ORDER; do
    for attempt in 1 2 3 4 5 6 7 8 9 10; do
        out="$(cargo publish -p "$c" 2>&1)"
        if grep -q "Published $c" <<<"$out"; then
            echo "$(date -u +%H:%M:%S)  published  $c"
            break
        fi
        if grep -q "already uploaded\|already exists" <<<"$out"; then
            echo "$(date -u +%H:%M:%S)  skipped    $c (already on registry)"
            break
        fi
        if grep -q "429 Too Many Requests" <<<"$out"; then
            echo "$(date -u +%H:%M:%S)  rate-limit $c (attempt $attempt), waiting 11m"
            sleep 660
            continue
        fi
        echo "$(date -u +%H:%M:%S)  FAILED     $c"
        grep -A4 "Caused by" <<<"$out" | head -5
        exit 1
    done
done

echo "all remaining crates published"
