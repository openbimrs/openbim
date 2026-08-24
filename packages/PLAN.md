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

- [ ] `PKG-PORT` - port the working idmXML and LOIN codecs out of the private
      poing repository into `idm/` and `loin/`, without vendoring ISO schemas
- [ ] `PKG-CONSUME` - make poing and vendor/solibri depend on these crates
      instead of carrying their own copies

## Completion log

Nothing completed yet. Record the proof command and its result here when an
item above is checked off.
