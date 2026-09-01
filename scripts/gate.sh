#!/usr/bin/env bash
# Full gate for openbim. Trusts EXIT CODES, not parsed output.
#
# Why this exists: an earlier ad-hoc `cargo test ... | grep "test result" | awk`
# pipeline reported "0 failed" while a test was in fact failing. Two bugs:
#   1. piping cargo into grep discards cargo's exit status ($? is grep's);
#   2. `awk -F'[ ;]'` on "ok. 4 passed; 0 failed" puts the failed count in $7,
#      not $6 -- $6 is the empty field between ';' and ' '.
# Never parse counts to decide pass/fail. Check the exit code.
set -uo pipefail
export PATH="$HOME/.cargo/bin:$PATH"
# This parent facade has no vendored OpenCDE conformance corpus. The standalone
# CDE repository verifies the exact pinned external corpus in its own CI.
export OPENCDE_CORPUS_OPTIONAL="${OPENCDE_CORPUS_OPTIONAL:-1}"
cd "$(dirname "$0")/.."

gate_out="$(mktemp "${TMPDIR:-/tmp}/openbim-gate.XXXXXX")" || exit 1
trap 'rm -f "$gate_out"' EXIT

fail=0
step() {
    local name="$1"; shift
    printf '%-46s' "$name"
    if "$@" >"$gate_out" 2>&1; then
        echo "ok"
    else
        echo "FAIL (exit $?)"
        tail -25 "$gate_out" | sed 's/^/    /'
        fail=1
    fi
}

echo "=== openbim integration gate ==="
step "mechanics retirement"    scripts/check-mechanics-retirement.sh
step "facade dependency isolation" scripts/check-facade-isolation.py
step "facade isolation mutations" scripts/test-facade-isolation.py
step "fmt --check"            cargo fmt --all -- --check
step "build --workspace"      cargo build --workspace
step "test --workspace"       cargo test --workspace
step "test --all-features"    cargo test --workspace --all-features
step "clippy"                 cargo clippy --workspace --all-targets -- -D warnings
step "clippy --all-features"  cargo clippy --workspace --all-targets --all-features -- -D warnings
step "doc"                    env RUSTDOCFLAGS="-D warnings" cargo doc --workspace --no-deps

# The openbim facade must build and lint under each standard in isolation.
# This is the executable form of ADR 0015's central claim: enabling one
# standard must not drag in another's dependencies.
for f in "--no-default-features" \
         "--no-default-features --features dt" \
         "--no-default-features --features ids" \
         "--no-default-features --features gaeb" \
         "--no-default-features --features citygml" \
         "--no-default-features --features openbimrl" \
         "--no-default-features --features bsdd" \
         "--no-default-features --features epd" \
         "--no-default-features --features bcf" \
         "--no-default-features --features icdd" \
         "--no-default-features --features idm" \
         "--no-default-features --features loin" \
         "--no-default-features --features mvd" \
         "--no-default-features --features full"; do
    # shellcheck disable=SC2086
    step "openbim build $f"  cargo build -p openbim $f
    # shellcheck disable=SC2086
    step "openbim clippy $f" cargo clippy -p openbim $f --all-targets -- -D warnings
done

# Standalone family gates run in their canonical repositories.

# Geometry-kernel feature and layering gates live in the separate Axiolid repository.

echo
if [ "$fail" -eq 0 ]; then
    echo "GATE PASSED"
else
    echo "GATE FAILED"
fi
exit "$fail"
