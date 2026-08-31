# openbim-core

The vocabulary every openBIM standard shares, in pure Rust.

Three things, each shared by more than one standard:

- **`Outcome`** — the applicable-passed / applicable-failed / **not-applicable**
  trichotomy. IDS *produces* it, BCF *consumes* it, so it is defined once. An
  audit that reports "data missing" as "check passed" launders absence into
  compliance; this type makes that impossible to do by accident.
- **`ElementRef`** — "this element, in this document". BCF viewpoint components
  and ICDD linkset endpoints are the same idea with different vocabulary.
- **`Detected<V>`** — a version *and how it was determined*, with an explicit
  `Conflict` variant. Several openBIM schemas reuse one XML namespace across
  incompatible versions, so a reader that guesses wrong does not fail — it
  silently produces a different document. `resolved()` returns `None` on a
  conflict rather than picking one.

This crate holds **domain** concepts only. Format families depend on maintained
XML and ZIP ecosystem crates directly and keep format-specific policy in their
canonical family crate.

## Status

**Scaffold.** These shared types are real and tested. This core crate does not
implement any standard's parser, writer, or conformance behavior.

## Part of nehirde

A pure-Rust IFC and openBIM toolchain: <https://github.com/GeneralPawz/nehirde>

Design rationale: `docs/adr/0015`.

## License

AGPL-3.0-or-later
