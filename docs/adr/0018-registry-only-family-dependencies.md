# 0018 — Standard families only as released crates.io versions

- **Status:** Accepted
- **Date:** 2026-09-24
- **Deciders:** Friedrich Schrödter
- **Supersedes:** rule 3 of [ADR 0017](0017-independent-family-repositories.md)

## Context

ADR 0017 retired the family submodules but kept one escape hatch (rule 3):
while a revision was unavailable from crates.io, `Cargo.toml` could pin a
family by exact Git revision. In practice that became the normal state. On
2026-09-24 every family and every Axiolid crate was pinned by Git revision,
53 pins in all, most of them weeks behind the families' own releases (IFC at
its 0.1 line while `openbim-ifc` 0.4.0 was published, `openbim-step` 0.4.0
against a published 0.7.0).

Git pins made the parent a second, unannounced consumer of unreleased family
states. A family could not know which of its revisions the parent relied on,
and the parent kept testing code no user can install.

## Decision

We will consume standard families and Axiolid only as released crates.io
versions. `Cargo.lock` is the exact integration resolution.

1. No `git` or `path` dependency on a family or Axiolid crate, and no
   `[patch]` onto one. ADR 0017 rule 8 (no local path overrides) still holds.
2. A capability that exists only on a family's `main` is not available to the
   parent until the family releases it. The parent withdraws the integration
   (feature, test expectation) and records it; it does not pin around it.
3. Advancing a family is a version bump plus `cargo update`, gated like any
   other change.
4. Parent-owned crates (`openbim-core`, the facade, analysis, apps, bindings)
   stay path members. The existing `[patch.crates-io] openbim-core` onto the
   parent's own copy stays: it keeps a single `openbim-core` type identity
   between the facade and the published families, and it is parent code, not
   a family checkout.

## Alternatives considered

| Option | Why not |
| --- | --- |
| Keep rule 3 (Git pins while unreleased) | The exception became the rule; the parent tested revisions no user can install. |
| Pin Git revisions but require them to be tagged | Still bypasses the family's release and crates.io metadata; a tag is not a release. |
| `[patch]` onto local clones | Rejected by ADR 0017 rule 8: local state would change integration results. |

## Consequences

**Positive**

- The parent tests exactly what a user of the published crates gets.
- A family's `main` never becomes an implicit parent dependency.
- `grep 'git = ' Cargo.toml` and `grep 'source = "git+' Cargo.lock` are empty,
  which is checkable in the gate.

**Negative / costs**

- Features waiting on a family release disappear from the parent until the
  release lands. At adoption: the `mvd` facade feature (no `openbim-mvd` on
  crates.io).
- Tests pinned to unreleased behaviour are re-pinned to the published
  behaviour, with the reason and the pending release recorded beside them.
  At adoption: the `ifc-cli` corpus expectations, whose last two closed
  solids and one compiled sweep depend on ifc `main` fixes not yet in
  `ifc-geometry` 0.3.0.

**Follow-ups / risks to watch**

- Release `openbim-mvd`, then restore the `mvd` facade feature.
- Release `ifc-geometry` with the composite-sweep parameter fix (ifc
  `971cee9`) and the axiolid 0.3.2 requirements, then restore the corpus
  expectations in `apps/ifc-cli/tests/fixture_corpus.rs`.

## Relation to existing code

- `Cargo.toml` `[workspace.dependencies]`: every family and Axiolid entry is a
  plain version requirement.
- `packages/facade/openbim`: `mvd` feature withdrawn.
- `scripts/check-facade-isolation.py`, `scripts/test-facade-isolation.py`,
  `scripts/gate.sh`: `mvd` removed; `epd` isolation matches published
  `openbim-epd` 0.1.1.
- `apps/ifc-cli`: moved to the published Axiolid 0.3 crate names.
