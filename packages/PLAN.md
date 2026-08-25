# packages implementation plan

Status: family directories established; standard crates are reserved scaffolds.
Last updated: 2026-08-25

This is task state, not ambient context. Follow `AGENTS.md`; claim one task ID,
record blockers/decisions under it, and check it off only with evidence.

## Established boundary

One directory per standard family, mirroring `github.com/openbimrs`. Crate
names are `openbim-*` on crates.io; short aliases exist only where the name was
still free.

## Planned file map

Family directories are containers, not crates. Their contents are planned in
each crate's own `PLAN.md`.

- (no owned source files at this level)

## Work queue

- [x] `PKG-IDS-SPLIT` - extract the IDS family with history into
      `openbimrs/ids`, make it independently buildable, and pin its verified
      commit as the first standard-family submodule.
- [x] `PKG-ICDD-SPLIT` - extract canonical and alias ICDD packages with history
      into `openbimrs/icdd`, preserve local restricted references outside Git,
      and pin a standalone-verified child commit.
- [x] `PKG-CITYGML-RESERVE` - publish `openbim-citygml` and `citygml` as an
      honest reservation scaffold in `openbimrs/citygml`, then pin the verified
      child repository.
- [x] `PKG-OPENBIMRL-RESERVE` - publish `openbim-openbimrl` and `openbimrl` as
      an implementation-neutral reservation scaffold in `openbimrs/openbimrl`,
      then pin the verified child repository.
- [x] `PKG-BSDD-RESERVE` - publish `openbim-bsdd` and `bsdd` as an honest bSDD
      client-namespace scaffold in `openbimrs/bsdd`, then pin the verified child
      repository.
- [ ] `PKG-PORT` - port the working idmXML and LOIN codecs out of the private
      poing repository into `idm/` and `loin/`, without vendoring ISO schemas
- [ ] `PKG-CONSUME` - make poing and vendor/solibri depend on these crates
      instead of carrying their own copies

## Completion log

`PKG-IDS-SPLIT` completed 2026-08-25:

- `openbimrs/ids` exact commit `1d163a21474cba2d25f8227b8dc4e78e56bbd778`:
  `scripts/gate.sh` passed on its declared Rust 1.85 MSRV, including clean
  `cargo package` verification.
- Superproject guard mutations for wrong commit, declared URL, effective URL,
  and a dirty child worktree all failed, then the restored pin passed.
- A fresh `git clone --recurse-submodules` initialized the public child at the
  exact pin and its complete `scripts/gate.sh` passed.

`PKG-ICDD-SPLIT` completed 2026-08-25:

- `openbimrs/icdd` exact commit `a68f50deba5cac68002088641590c1e5685b7bbe`
  preserves every family path change through extraction and passes its standalone
  gate, including clean package verification for both `openbim-icdd` and `icdd`.
- The short package is mutation-verified through Cargo's effective metadata as a
  one-target, one-dependency, exact-version pure re-export; textual TOML decoys,
  alternate active library paths, alias-owned source files, target gates, and
  feature overrides are rejected.
- The superproject resolves both packages through the child gitlink and its full
  integration gate. Mutation probes reject wrong commits, dirty children, and
  missing, duplicated, poisoned, or transport-rewritten URLs while signal-safe
  cleanup preserves pre-existing worktree, URL, and branch state.
- The 25-file local standards corpus is excluded by the child `references/`
  ignore boundary and was preserved against a SHA-256 manifest during migration.

`PKG-CITYGML-RESERVE`, `PKG-OPENBIMRL-RESERVE`, and `PKG-BSDD-RESERVE`
completed 2026-08-25:

- `openbimrs/citygml` exact commit
  `3cbcd79b8dc3f07a15dd520a2b1e08b5e1c6ea9a`.
- `openbimrs/openbimrl` exact commit
  `744f44a56e5da7b7265745cf480425f13cedbc0c`.
- `openbimrs/bsdd` exact commit
  `7f25b3f8c615953f11c59d7dd21f3a7c67579920`.
- Each child passes Rust 1.85 build, test, Clippy, rustdoc, exact alias-purity,
  two mutation probes, and full canonical plus alias package verification.
