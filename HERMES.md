# HERMES.md — openbim

OpenBIM.rs is the pure-Rust IFC and openBIM **integration repository**. Standard
families are developed in independent `github.com/openbimrs/<family>`
repositories. The format-agnostic geometry kernel is developed at
<https://github.com/axiolid/axiolid-kernel>.

## Repository model

This repository does not own, mirror, or mount standard-family source.
Integration manifests consume exact canonical Git revisions so a clean clone is
reproducible without recursive Git operations.

Optional local clones belong below `packages/<family>/` only as a filesystem
convention. These paths are ignored by the parent repository. For example:

```bash
git clone https://github.com/openbimrs/loin.git packages/loin
git clone https://github.com/openbimrs/pkl.git packages/pkl
```

Commit, gate, push, and release a family from its own repository. Then advance
any affected integration dependency in this repository. Never copy family source
into the parent repository.

The canonical family repositories include `ids`, `icdd`, `loin`, `idm`, `dt`,
`cde`, `epd`, `gaeb`, `citygml`, `openbimrl`, `bsdd`, `ifc`, `step`, `bcf`,
`mvd`, `mmc`, and `pkl`.

## Dependency direction

```text
step/core -> IFC and standard families -> facade/apps/bindings
Axiolid   -> explicit IFC geometry bridges only
IFC       -X-> IDS or another standard family
```

Only explicit IFC bridge crates (`ifc-geometry`, `ifc-georef`, and
`ifc-alignment`) may depend on Axiolid representation crates. No IFC crate may
depend on Axiolid algorithms, kernel contracts, or backends; applications
choose execution providers.

## Commands

```bash
cargo build --workspace
cargo test --workspace
scripts/gate.sh
```

Run a standard family's own gate in its repository before advancing an
integration dependency. Run Axiolid's kernel-specific feature, layering, and
mutation gates in the Axiolid repository.

## Git

`master` is shared and hot. Stage narrowly, re-read `HEAD`, and use a
compare-and-swap update when landing a detached-worktree commit.
