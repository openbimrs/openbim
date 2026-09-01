# `ifc-cli`

Integration CLI that consumes independently released OpenBIM crates.

- Entry point: `src/main.rs`
- Shared implementation: `src/lib.rs` and `src/mesh.rs`
- `tests/fixtures/ifclite-geometry/` is the application-owned integration corpus. Its provenance and pinned source revision are recorded in that directory's `README.md`.

Do not reference family source checkouts under root `packages/`; this app must build and test from declared Cargo dependencies plus its own fixtures.
