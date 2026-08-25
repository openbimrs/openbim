# HERMES.md — openbim

OpenBIM.rs is the pure-Rust IFC and openBIM integration superproject. The
format-agnostic geometry kernel is developed separately at
<https://github.com/axiolid/axiolid-kernel>.

## Repository model

Standard-family repositories are canonical sources and are pinned beneath
`packages/` as Git submodules. The extracted families are:

- `packages/ids` → <https://github.com/openbimrs/ids>
- `packages/icdd` → <https://github.com/openbimrs/icdd>
- `packages/loin` → <https://github.com/openbimrs/loin>
- `packages/cde` → <https://github.com/openbimrs/cde>
- `packages/epd` → <https://github.com/openbimrs/epd>
- `packages/gaeb` → <https://github.com/openbimrs/gaeb>
- `packages/ifc` → <https://github.com/openbimrs/ifc>

Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/openbimrs/openbim.git
```

If an existing checkout is missing a family:

```bash
scripts/init-family-submodules.sh
```

Use the helper rather than deleting an occupied submodule directory. It
signal-safely shelters and restores existing local
`packages/{icdd,loin}/references/` corpora while Git initializes or advances the
children, then verifies every family pin and exactly one canonical URL at each
configured transport boundary.

Change a family in its own repository first. Run its standalone gate, publish or
push the child commit, then update and validate the superproject pin. Never make
an unpushed submodule commit the parent dependency.

## Dependency direction

```text
codec/core -> IFC and standards -> facade/apps/bindings
Axiolid     -> explicit IFC geometry bridges only
IFC         -X-> IDS or another standard family
```

Standalone families use versioned registry dependencies. The root
`[patch.crates-io]` table substitutes local integration packages so one build
cannot accidentally contain registry and local identities for the same shared
type crate.

Only the explicit IFC bridge crates (`ifc-geometry`, `ifc-georef`,
`ifc-alignment`) may depend on Axiolid representation crates. No IFC crate may
depend on Axiolid algorithms, kernel contracts, or backends; applications
choose execution providers.

## Commands

```bash
scripts/init-family-submodules.sh
cargo build --workspace
cargo test --workspace
scripts/gate.sh
```

Run a standard family's own `scripts/gate.sh` inside its submodule before
updating the parent pin. Run Axiolid's kernel-specific feature, layering, and
mutation gates in the Axiolid repository.

## Git

`master` is shared and hot. Stage narrowly, re-read HEAD, and use a
compare-and-swap update when landing a detached-worktree commit.
