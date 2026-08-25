# packages/ instructions

Applies to `packages/**`. Each subdirectory is one **standard family** and
holds the crates that implement it. Read the deeper `AGENTS.md` before editing
inside a family; deeper files add local rules and do not repeat this one.

## Layout

One directory per standard, mirroring the repositories under
`github.com/openbimrs`. A family holds its canonical crate, and where the
short name was still free on crates.io, its alias crate too.

Extracted families are Git submodules whose canonical source is the matching
`openbimrs/<family>` repository. `ids/`, `icdd/`, `cde/`, `ifc/`, and
`epd/` are extracted. Make family changes in the child repository, pass its
standalone gate, push the child commit, and only then update the superproject
pin. The root integration gate must pass at the exact pin before it lands.

| Directory | Crates | Standard |
| --- | --- | --- |
| `ifc/` | `ifc-*` (18) + `openbim-ifc` facade | ISO 16739 IFC |
| `ids/` | `openbim-ids` | buildingSMART IDS |
| `cde/` | `openbim-cde` | buildingSMART Foundation/Documents APIs |
| `epd/` | `openbim-epd` | ISO 22057 EPD data templates |
| `bcf/` | `openbim-bcf` | BCF |
| `icdd/` | `openbim-icdd`, `icdd` | ISO 21597 |
| `idm/` | `openbim-idm`, `idmxml` | ISO 29481-3 |
| `loin/` | `openbim-loin`, `loin` | ISO 7817-3 / EN 17412-3 |
| `dt/` | `openbim-dt` | ISO 23387 data templates |
| `core/` | `openbim-core` | shared vocabulary |
| `codec/` | `openbim-codec-xml`, `openbim-codec-zip` | encoding substrate |
| `facade/` | `openbim` | feature-gated facade |
| `analysis/` | `clash`, `diff` | capabilities, NOT standards |

## The dependency rule

```
codec/  ->  nothing        (encoding substrate)
core/   ->  nothing        (shared domain vocabulary)
ifc/    ->  codec          NEVER a standard family
<std>/  ->  core, codec, ifc
facade/ ->  the standards it re-exports
analysis/ -> ifc, core, bcf
```

`ifc/` must never depend on a standard family. If an IFC crate needs something
from one, the abstraction is in the wrong place: move the shared piece down
into `core/` or `codec/`, never the dependency up. That is what stops the IFC
core accreting every standard that happens to read IFC.

## Directory is not the boundary

The architecture tests select crates by **name** (`ifc-*`, `openbim-*`) as well
as by directory. That redundancy is deliberate: a directory-only filter silently
matches nothing after a layout change, and a test that matches nothing PASSES.
Both restructures in this repo's history broke exactly that way. Any new
architecture test must assert a minimum crate count so it fails loudly instead
of passing vacuously.
