# openbim

[![CI](https://github.com/openbimrs/openbim/actions/workflows/ci.yml/badge.svg)](https://github.com/openbimrs/openbim/actions/workflows/ci.yml)
[![crates.io](https://img.shields.io/crates/v/openbim.svg)](https://crates.io/crates/openbim)
[![docs.rs](https://img.shields.io/docsrs/openbim)](https://docs.rs/openbim)
[![license](https://img.shields.io/crates/l/openbim.svg)](LICENSE)

Pure-Rust IFC and openBIM infrastructure. No C++ in the dependency graph.

One integration workspace, many independently developed repositories and
published crates. Take a single standard, or the facade with the features you
need—the cost of what you do not use is zero because each standard is its own
crate rather than a feature of a monolith.

Standard-family source is canonical only in its `openbimrs/<family>` repository.
This integration repository consumes exact Git revisions; it does not mount,
mirror, or own family source. Optional local clones may live under
`packages/<family>/`, where the parent repository ignores them.

## Clone for development

The integration repository is a normal, non-recursive clone:

```bash
git clone https://github.com/openbimrs/openbim.git
cd openbim
scripts/gate.sh
```

Develop a family in its own repository. Keeping the checkout below `packages/`
is only a local filesystem convention, not a Git relationship:

```bash
git clone https://github.com/openbimrs/loin.git packages/loin
git clone https://github.com/openbimrs/pkl.git packages/pkl
```

A family change is tested and released from that repository. Update this
integration repository only when its facade, apps, bindings, or compatibility
pins need the new revision.

## Crates

### openBIM standards

| Crate | Docs | Source | Standard |
| --- | --- | --- | --- |
| [`openbim`](https://crates.io/crates/openbim) | [docs.rs](https://docs.rs/openbim) | [src](packages/facade/openbim) | Facade; one feature per standard |
| [`openbim-core`](https://crates.io/crates/openbim-core) | [docs.rs](https://docs.rs/openbim-core) | [src](packages/core/openbim-core) | Vocabulary shared across standards |
| [`openbim-step`](https://crates.io/crates/openbim-step) | [docs.rs](https://docs.rs/openbim-step) | [repository](https://github.com/openbimrs/step) | ISO 10303-21 STEP + ISO 10303-11 EXPRESS syntax |
| [`openbim-ids`](https://crates.io/crates/openbim-ids) | [docs.rs](https://docs.rs/openbim-ids) | [repository](https://github.com/openbimrs/ids) | buildingSMART IDS |
| [`openbim-gaeb`](https://crates.io/crates/openbim-gaeb) | [docs.rs](https://docs.rs/openbim-gaeb) | [repository](https://github.com/openbimrs/gaeb) | GAEB DA XML 3.1–3.4 beta |
| [`openbim-citygml`](https://crates.io/crates/openbim-citygml) | [docs.rs](https://docs.rs/openbim-citygml) | [repository](https://github.com/openbimrs/citygml) | OGC CityGML; reserved scaffold |
| [`openbim-openbimrl`](https://crates.io/crates/openbim-openbimrl) | [docs.rs](https://docs.rs/openbim-openbimrl) | [repository](https://github.com/openbimrs/openbimrl) | reserved OpenBIM.rs namespace |
| [`openbim-bsdd`](https://crates.io/crates/openbim-bsdd) | [docs.rs](https://docs.rs/openbim-bsdd) | [repository](https://github.com/openbimrs/bsdd) | buildingSMART Data Dictionary; reserved scaffold |
| [`openbim-cde`](https://github.com/openbimrs/cde) | API docs pending first release | [repository](https://github.com/openbimrs/cde) | buildingSMART Foundation API 1.1 + Documents API 1.0 |
| [`openbim-epd`](https://crates.io/crates/openbim-epd) | [docs.rs](https://docs.rs/openbim-epd) | [repository](https://github.com/openbimrs/epd) | ISO 22057 EPD data templates |
| [`openbim-bcf`](https://crates.io/crates/openbim-bcf) | [docs.rs](https://docs.rs/openbim-bcf) | [repository](https://github.com/openbimrs/bcf) | buildingSMART BCF-XML 2.0/2.1/3.0; corpus-verified reader, writing not implemented |
| [`openbim-icdd`](https://crates.io/crates/openbim-icdd) | [docs.rs](https://docs.rs/openbim-icdd) | [repository](https://github.com/openbimrs/icdd) | ISO 21597 ICDD |
| [`openbim-idm`](https://crates.io/crates/openbim-idm) | [project docs](https://openbimrs.github.io/idm/) | [repository](https://github.com/openbimrs/idm) | ISO 29481-3 idmXML; lossless Rust/Python engine, publication blocked pending schema rights |
| [`openbim-loin`](https://crates.io/crates/openbim-loin) | [docs.rs](https://docs.rs/openbim-loin) | [repository](https://github.com/openbimrs/loin) | ISO 7817-3 / EN 17412-3 LOIN |
| [`openbim-mvd`](https://crates.io/crates/openbim-mvd) | [project docs](https://openbimrs.github.io/mvd/) | [repository](https://github.com/openbimrs/mvd) | buildingSMART mvdXML 1.1 typed codec, rules, and validation |
| [`openbim-dt`](https://crates.io/crates/openbim-dt) | [docs.rs](https://docs.rs/openbim-dt) | [repository](https://github.com/openbimrs/dt) | ISO 23387 data templates |

Seven families were also free under their short names and ship as alias crates —
pure re-exports, so the standard is reachable as practitioners name it:
[`gaeb`](https://crates.io/crates/gaeb),
[`citygml`](https://crates.io/crates/citygml),
[`openbimrl`](https://crates.io/crates/openbimrl),
[`bsdd`](https://crates.io/crates/bsdd),
[`icdd`](https://crates.io/crates/icdd),
[`idmxml`](https://crates.io/crates/idmxml) and
[`loin`](https://crates.io/crates/loin).

### IFC

`openbim-ifc` is the facade (its lib target is named `ifc`, so call sites read
`use ifc::…`). Beneath it sit the `ifc-*` crates: `ifc-model` is the codec-free
entity graph, `ifc-step` and `ifc-xml` are codecs, and the domain crates are
borrowed projections over the model.

### STEP substrate

`openbim-step` is the schema-independent ISO 10303-21/11 substrate beneath IFC.
`ifc-step` converts its generic syntax model into the IFC graph and `ifc-schema`
lowers its generic EXPRESS AST into IFC registries. XML and ZIP format families
use the maintained `quick-xml` and `zip` crates directly and keep domain policy
in their own adapters.

## Status

The foundational crates remain published as reserved scaffolds; `openbim-epd`
and `openbim-dt` are at `0.1.1`, while the remaining original scaffold release
set stays at `0.1.0`. Their structure, boundaries, and gates are real, but they
do not yet provide working IFC, IDS, or EPD readers. `openbim-step 0.2.1` and
`openbim-gaeb 0.1.3` are implemented libraries rather than namespace-only
scaffolds. The new `openbim-cde` family is also different: its
Foundation/Documents wire models are implemented and exercised, while
HTTP/OAuth execution and full schema validation are explicitly not. GAEB is
also implemented beyond scaffold: it recognizes DA XML 3.1–3.4 beta, resolves
GAEB element namespaces, extracts common BoQ item views, preserves unchanged
bytes exactly, and supports atomic quantity edits only for unique, non-empty IDs
and one safely replaceable value range; mixed-content values fail closed. Full
XSD validation and complete generated bindings are not claimed. See each family
README and `docs/ROADMAP.md` for the exact capability boundary.

The isolation is checkable rather than promised. Against the *published*
crates:

```console
$ cargo tree -p openbim          # default-features = false
openbim v0.1.0
└── openbim-core v0.1.0

$ cargo tree -p openbim          # --features ids
openbim v0.1.0
├── openbim-core v0.1.0
└── openbim-ids v0.1.0
    └── openbim-core v0.1.0
```

Enabling IDS costs you IDS. That is the whole reason each standard is its own
crate rather than a feature of a monolith.

`docs/ROADMAP.md` tracks what is implemented versus what is scaffolded —
capability claims here are meant to be checkable, not aspirational.

## Design

- [ADR 0015](docs/adr/0015-openbim-standards-as-separate-crates.md) — why one
  crate per standard rather than features of one crate.
- [ADR 0016](docs/adr/0016-standard-family-repositories-as-submodules.md) —
  superseded record of the former submodule model.
- [ADR 0017](docs/adr/0017-independent-family-repositories.md) — why family
  repositories are now consumed independently without source mounts.
- `packages/AGENTS.md` — the layering rules and local-checkout convention.

Architecture is enforced by tests, not convention: `scripts/gate.sh` exercises
the facade, apps, and bindings against the declared family revisions and proves
that enabling one facade feature does not drag in another standard.

## License

AGPL-3.0-or-later
