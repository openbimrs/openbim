# packages implementation plan

Status: family directories established; standard crates are reserved scaffolds.
Last updated: 2026-08-24

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
- [ ] `PKG-PORT` - port the working idmXML and LOIN codecs out of the private
      poing repository into `idm/` and `loin/`, without vendoring ISO schemas
- [ ] `PKG-CONSUME` - make poing and vendor/solibri depend on these crates
      instead of carrying their own copies

## Completion log

`PKG-IDS-SPLIT` completed 2026-08-25:

- `openbimrs/ids` exact commit `35e0c3c84e56916f86cf2c3e2698f3654f1b4c2a`:
  `scripts/gate.sh` passed, including clean `cargo package` verification.
- Superproject pin mutations for wrong commit and wrong URL both failed, then
  the restored pin passed.
- A fresh `git clone --recurse-submodules` initialized the public child at the
  exact pin and its complete `scripts/gate.sh` passed.
