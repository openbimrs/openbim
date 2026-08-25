# openbim

[![CI](https://github.com/openbimrs/openbim/actions/workflows/ci.yml/badge.svg)](https://github.com/openbimrs/openbim/actions/workflows/ci.yml)
[![crates.io](https://img.shields.io/crates/v/openbim.svg)](https://crates.io/crates/openbim)
[![docs.rs](https://img.shields.io/docsrs/openbim)](https://docs.rs/openbim)
[![license](https://img.shields.io/crates/l/openbim.svg)](LICENSE)

Pure-Rust IFC and openBIM infrastructure. No C++ in the dependency graph.

One integration workspace, many independently published crates. Take a single
standard, or the facade with the features you need — the cost of what you do
not use is zero, because each standard is its own crate rather than a feature
of a monolith.

Standard-family repositories are progressively becoming canonical standalone
repositories pinned here as Git submodules. IDS is the first completed pilot.

## Clone for development

Clone recursively so every pinned family source is present:

```bash
git clone --recurse-submodules https://github.com/openbimrs/openbim.git
cd openbim
scripts/gate.sh
```

For an existing checkout, run `git submodule update --init --recursive`.

## Crates

### openBIM standards

| Crate | Docs | Source | Standard |
| --- | --- | --- | --- |
| [`openbim`](https://crates.io/crates/openbim) | [docs.rs](https://docs.rs/openbim) | [src](packages/facade/openbim) | Facade; one feature per standard |
| [`openbim-core`](https://crates.io/crates/openbim-core) | [docs.rs](https://docs.rs/openbim-core) | [src](packages/core/openbim-core) | Vocabulary shared across standards |
| [`openbim-ids`](https://crates.io/crates/openbim-ids) | [docs.rs](https://docs.rs/openbim-ids) | [repository](https://github.com/openbimrs/ids) | buildingSMART IDS |
| [`openbim-bcf`](https://crates.io/crates/openbim-bcf) | [docs.rs](https://docs.rs/openbim-bcf) | [src](packages/bcf/openbim-bcf) | BCF (BIM Collaboration Format) |
| [`openbim-icdd`](https://crates.io/crates/openbim-icdd) | [docs.rs](https://docs.rs/openbim-icdd) | [src](packages/icdd/openbim-icdd) | ISO 21597 ICDD |
| [`openbim-idm`](https://crates.io/crates/openbim-idm) | [docs.rs](https://docs.rs/openbim-idm) | [src](packages/idm/openbim-idm) | ISO 29481-3 idmXML |
| [`openbim-loin`](https://crates.io/crates/openbim-loin) | [docs.rs](https://docs.rs/openbim-loin) | [src](packages/loin/openbim-loin) | ISO 7817-3 / EN 17412-3 LOIN |
| [`openbim-dt`](https://crates.io/crates/openbim-dt) | [docs.rs](https://docs.rs/openbim-dt) | [src](packages/dt/openbim-dt) | ISO 23387 data templates |

Three standards were also free under their short names and ship as alias
crates — pure re-exports, so the standard is reachable as practitioners name
it: [`icdd`](https://crates.io/crates/icdd),
[`idmxml`](https://crates.io/crates/idmxml) and
[`loin`](https://crates.io/crates/loin).

### IFC

`openbim-ifc` is the facade (its lib target is named `ifc`, so call sites read
`use ifc::…`). Beneath it sit the `ifc-*` crates: `ifc-model` is the codec-free
entity graph, `ifc-step` and `ifc-xml` are codecs, and the domain crates are
borrowed projections over the model.

### Substrate

`openbim-codec-xml` and `openbim-codec-zip` carry the encoding substrate. They
sit below both layers, which is what lets the IFC layer and the standards share
XML and ZIP handling without the IFC layer depending on a standard.

## Status

**Reserved — published, not yet implemented.** All 13 crates are on crates.io
at `0.1.0`, and the structure, boundaries and gates behind them are real. The
codecs are not written yet: today these crates give you the names, the layering
and the dependency isolation, not a working IFC or IDS reader.

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
- [ADR 0016](docs/adr/0016-standard-family-repositories-as-submodules.md) — why
  standalone family repositories are pinned here as submodules.
- `packages/AGENTS.md` — the layering rules and the one-way dependency rule.

Architecture is enforced by tests, not convention: `scripts/gate.sh` builds
every standard in isolation and proves that enabling one does not drag in
another's dependencies.

## License

MIT
