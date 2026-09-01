# packages/ instructions

Applies to `packages/**`. Read a deeper `AGENTS.md` before editing a tracked
package or an independent repository checked out here.

## Local checkout convention

Each standard family is canonical in `github.com/openbimrs/<family>` and is
developed, tested, versioned, and released there. The parent `openbim`
repository does not track family directories as files or Git submodules.

For convenience, clone independent repositories into their conventional local
paths:

```bash
git clone https://github.com/openbimrs/loin.git packages/loin
git clone https://github.com/openbimrs/pkl.git packages/pkl
```

Those paths are ignored by the parent. Run Git commands from the child
repository and never stage child content in `openbim`.

The integration manifest uses canonical Git revisions rather than local path
dependencies. A local checkout therefore cannot silently change integration
results.

## Tracked integration packages

The remaining parent-owned directories are integration-level packages, not
standard-family source:

| Directory | Role |
| --- | --- |
| `core/` | Shared integration vocabulary pending an independent boundary |
| `facade/` | Feature-gated `openbim` facade |
| `analysis/` | Cross-family capabilities such as clash and diff |

## Canonical family repositories

| Repository | Standard or role |
| --- | --- |
| `openbimrs/ifc` | ISO 16739 IFC |
| `openbimrs/step` | ISO 10303-11 EXPRESS and ISO 10303-21 syntax substrate |
| `openbimrs/ids` | buildingSMART IDS |
| `openbimrs/gaeb` | GAEB DA XML |
| `openbimrs/citygml` | OGC CityGML |
| `openbimrs/openbimrl` | OpenBIM.rs namespace |
| `openbimrs/bsdd` | buildingSMART Data Dictionary |
| `openbimrs/cde` | buildingSMART Foundation/Documents APIs |
| `openbimrs/epd` | ISO 22057 EPD data templates |
| `openbimrs/bcf` | buildingSMART BCF-XML |
| `openbimrs/icdd` | ISO 21597 |
| `openbimrs/idm` | ISO 29481-3 |
| `openbimrs/loin` | ISO 7817-3 / EN 17412-3 |
| `openbimrs/dt` | ISO 23387 data templates |
| `openbimrs/mvd` | buildingSMART mvdXML |
| `openbimrs/mmc` | Multi-model containers |
| `openbimrs/pkl` | Apple Pkl schemas for developed OpenBIM.rs families |

## Dependency rule

```text
step/   ->  nothing        (generic STEP/EXPRESS substrate)
core/   ->  nothing        (shared domain vocabulary)
ifc/    ->  step           NEVER a standard family
<std>/  ->  core, step, ifc
facade/ ->  the standards it re-exports
analysis/ -> ifc, core, bcf
```

`ifc` must never depend on another standard family. If an IFC crate needs
something from one, move the shared abstraction down into `core` or `step`,
never the dependency up.

Architecture tests must select crates by name as well as location and assert a
minimum match count. A directory-only filter can silently match nothing after a
layout change and falsely pass.
