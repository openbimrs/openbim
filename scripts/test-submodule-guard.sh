#!/usr/bin/env bash
# Mutation probes for the fail-closed family-submodule guard.
set -euo pipefail

cd "$(dirname "$0")/.."

checker="scripts/check-submodules.sh"
child="packages/ids"
probe_file="$child/README.md"
expected_url="$(git config --get submodule.packages/ids.url)"
probe_out="$(mktemp "${TMPDIR:-/tmp}/openbim-submodule-guard.XXXXXX")"

cleanup() {
    git -C "$child" restore --worktree -- README.md >/dev/null 2>&1 || true
    git config submodule.packages/ids.url "$expected_url" >/dev/null 2>&1 || true
    rm -f "$probe_out"
}
trap cleanup EXIT HUP INT TERM

# Starting clean is what makes restoring the tracked probe file safe.
"$checker"

printf '\nsubmodule-guard-dirty-probe\n' >>"$probe_file"
if "$checker" >"$probe_out" 2>&1; then
    printf 'submodule guard accepted a dirty child worktree\n' >&2
    exit 1
fi
git -C "$child" restore --worktree -- README.md

# A local config override wins over .gitmodules during future fetches.
git config submodule.packages/ids.url "https://example.invalid/openbimrs/ids.git"
if "$checker" >"$probe_out" 2>&1; then
    printf 'submodule guard accepted a poisoned effective URL\n' >&2
    exit 1
fi
git config submodule.packages/ids.url "$expected_url"

"$checker"
cleanup
trap - EXIT HUP INT TERM
