# 0015 — openBIM standards as separate crates behind a facade

- **Status:** Accepted
- **Date:** 2026-08-24
- **Deciders:** Friedrich, nehirde
- **Amended:** 2026-08-25 — canonical STEP substrate; direct XML/ZIP mechanics
- **Supersedes:** —

## Context

`packages/` held four doc-only crates: `ids`, `bcf`, `clash`, `diff`.
Two problems.

**1. Two of them are not openBIM standards.** Clash detection and semantic diff
are *capabilities*. Keeping them in a directory named for a standards family
implies a status they do not have, and invites the same directory to accrete
anything IFC-adjacent.

**2. The remaining standards share mechanics but not domain policy.** BCF, IDS,
IDM, LOIN and ICDD are all XML; BCF, ICDD and IFCZIP are all ZIP. XML families
use `quick-xml` directly and archive families use `zip` directly while retaining
their safety, selection, and version policy locally. Generic STEP/EXPRESS syntax
is substantial enough to form the independent `openbim-step` substrate below
IFC.

A third force appeared during design: several of these standards reuse a single
XML namespace across incompatible versions. IDS is the extreme case — every
published version from 0.2 to 1.0 declares a byte-identical `targetNamespace`,
and the differences are in attribute *names* and cardinality rather than element
names. A reader that guesses wrong does not fail; it silently produces a
different specification.

Prior art was available and inspected: `../vendor/solibri/crates/codec` (82k
LOC) solves the same problem with `container/{zip,bare,xml}` plus one module per
format, detecting containers by magic bytes rather than file extension.

## Decision

We will structure openBIM support as **one crate per standard**, plus a thin
facade. STEP/EXPRESS syntax lives below IFC; XML and ZIP mechanics are direct
third-party dependencies rather than public wrappers.

```
packages/
  step/openbim-step/  ISO 10303-11/21 syntax, no IFC dependency
  ifc/                 IFC graph adapters, schema lowering, and policy
  openbim/              facade; features are pure re-exports
  openbim-core/         shared DOMAIN vocabulary (not XML, not ZIP)
  openbim-{dt,ids,bcf,icdd,idm,loin}/
packages/      clash, diff — capabilities, not standards
packages/         icdd, idmxml, loin — `pub use` aliases
```

Key points:

- **Separate packages, not features of one crate.** Cargo features are additive
  across the entire dependency graph. In a single crate, any dependency
  anywhere enabling `icdd` would make every consumer compile an RDF stack —
  including one that only reads `.ids` files. Separate packages make that
  structurally impossible.
- **The facade defaults to no standards.** Depending on `openbim` costs only
  `openbim-core`.
- **`loin` implies `dt`**, because the ISO 7817-3 schema imports the ISO 23387
  namespace. That is a property of the standards, not a design choice.
- **`openbim-core` holds domain vocabulary only** — `Outcome`, `ElementRef`,
  `Detected`. Format mechanics and sniffing do not belong there.
- **No ISO/CEN schema is vendored.** Types are written from the schemas, which
  are referenced out of tree — the same discipline `ifc-schema` applies to the
  EXPRESS schemas.

## Alternatives considered

| Option | Why not |
| --- | --- |
| One `openbim` crate, one feature per standard | Feature unification is graph-wide: an `icdd` feature enabled by any dependency imposes RDF on every consumer. This is the decisive argument. |
| Shared XML/ZIP inside `packages/` | Would force `packages/` to depend on `openbim/`, violating the one-way rule that keeps the IFC core from accreting every standard. |
| Add a shared RDF wrapper beside XML/ZIP mechanics | ICDD is the only RDF consumer. A wrapper created now would be a one-consumer abstraction; defer it until another implementation justifies it. |
| Keep `clash`/`diff` under `openbim/` | They are not openBIM standards. Misfiling them is how the directory loses its meaning. |
| Delete `clash`/`diff` | Both are on the roadmap, and `clash` is the stress test for kernel-agnosticism. Moved, not deleted. |
| Short crate names (`ids`, `bcf`, `dt`) | All taken on crates.io by unrelated projects. Verified 2026-08-24. |

## Consequences

**Positive**

- A consumer needing only IDS compiles only IDS. Provable with `cargo tree`,
  and gated in `scripts/gate.sh` rather than asserted in prose.
- Each XML/ZIP family can use maintained mechanics crates without depending on
  another standard family.
- The version-detection trap is encoded once, in `openbim_core::Detected`,
  with an explicit `Conflict` variant instead of a silent guess.
- Adding a standard is additive: a new leaf crate plus one facade feature.

**Negative / costs**

- Twelve new crates where there were four. More manifests to maintain, more
  publish steps.
- The alias crates (`icdd`, `idmxml`, `loin`) must stay pure `pub use`. If one
  ever defines a type, a graph holding both it and its canonical crate carries
  two structurally identical but non-unifiable types. They pin with `=` for the
  same reason.
- `openbim-core` risks becoming a dumping ground. The rule — used by more than
  one standard, or it belongs in the standard's own crate — must be enforced in
  review.

**Follow-ups / risks to watch**

- The LOIN namespace is **not final**: the draft schema says so in a comment,
  and an earlier draft used a different one. Namespace migration must stay a
  first-class concern in `openbim-loin`.
- `ifc-zip` (an `IFCZIP` decorator generic over `Codec`) is deferred; when it
  lands it must use `zip` directly with IFC-owned limits and deterministic
  entry policy.
- Working ISO 29481-3 and ISO 7817-3 codecs exist in the private `poing`
  repository. Porting them here is Phase 2 and is deliberately not part of the
  first release.

## Relation to existing code

- `Cargo.toml` — workspace members gain `packages/{wire,analysis,alias}/*`.
- `packages/{ids,bcf}` → `packages/openbim-{ids,bcf}`.
- `packages/{clash,diff}` → `packages/{clash,diff}`.
- `scripts/gate.sh` — adds the openbim feature matrix and per-crate isolated
  builds that make the isolation claim executable.
- Follows the boundary discipline of `../vendor/solibri/crates/codec`, whose
  `container`/`formats` split addresses the same problem in one crate.

## Amendment, 2026-08-24 — repository split and publish names

The workspace became the `openbim` infrastructure repository
(`github.com/openbimrs/openbim`), freeing the name `nehirde` for the
application that consumes these crates. Three consequences:

**`packages/` is flat.** Grouping directories (`ifc/`, `openbim/`, `wire/`,
`analysis/`, `alias/`) are gone; every crate sits directly under `packages/`.
The layer a crate belongs to is carried by its NAME, and the architecture tests
now select on the name. This is the one genuinely load-bearing detail of the
change: three existing gates filtered crates by parent directory and would have
silently matched **zero** crates after the move — passing vacuously rather than
failing. Each was rewritten to select by name, and each was re-verified with a
mutation probe (introduce a violation, confirm the gate fails, restore).
A gate that cannot fail is worse than no gate.

**Publish names are `openbim-*`.** `ifc`, `bcf`, `ids`, `idm`, `dt`, `codec`
and `cde` are all taken on crates.io by unrelated crates. Only `icdd` and
`loin` were free, and those two are published as alias crates. The IFC facade
is published as `openbim-ifc` but keeps `ifc` as its **lib target name**, so
consumer code still reads `use ifc::…` — the ergonomic name survives even
though the registry name could not.

**Shared sniff-only wrappers were retired.** Their mechanics were too small to
justify public package boundaries. Generic STEP/EXPRESS moved to the canonical
`openbimrs/step` family because it provides a substantial reusable language and
syntax model; XML/ZIP families depend directly on maintained ecosystem crates.

## Amendment, 2026-08-24 — one directory per standard family

The workspace was briefly flattened so every crate sat directly under
`packages/`. That is now reverted: each standard gets a directory holding its
crates, mirroring the repositories under `github.com/openbimrs` so a family can
later be extracted to its own repository as a directory move.

```
packages/ifc/     ifc-* (18) + openbim-ifc      packages/dt/      openbim-dt
packages/ids/     openbim-ids                   packages/core/    openbim-core
packages/bcf/     openbim-bcf                   packages/step/    openbim-step
packages/icdd/    openbim-icdd + icdd           packages/facade/  openbim
packages/idm/     openbim-idm + idmxml          packages/analysis/ clash, diff
packages/loin/    openbim-loin + loin
```

An alias crate sits beside the canonical crate it re-exports, so the `=` version
pin is a sibling path and the pair moves as a unit.

### What the flatten-then-regroup taught us

Four architecture tests selected crates by **parent directory**. Flattening made
each match zero crates — so they did not fail, they passed **vacuously**. A gate
that proves nothing while reporting success is worse than no gate.

The fix is redundant selection (name AND directory) plus a minimum-count
assertion in every architecture test, so a filter that stops matching fails
loudly. Both invariants are now enforced by:

- `ifc-model/tests/package_architecture.rs` — layering, `>= 18` crates
- `ifc-model/tests/module_reachability.rs` — reachability, `>= 18` crates
- `ifc-model/tests/progressive_context.rs` — per-crate AGENTS.md + PLAN.md
- `ifc-geometry/tests/no_backend_dependency.rs` — geometry allowlist
- `scripts/check-alias-purity.sh` — aliases stay pure re-exports

Each was re-verified by mutation after the move: introduce the violation, watch
the gate fail, restore, watch it pass.
