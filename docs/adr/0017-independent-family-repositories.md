# 0017 — Independent family repositories without source mounts

- **Status:** Accepted
- **Date:** 2026-09-01
- **Deciders:** Friedrich Schrödter
- **Supersedes:** [ADR 0016](0016-standard-family-repositories-as-submodules.md)

## Context

ADR 0016 made each standard family independently owned and releasable, then
mounted every canonical repository back into `openbim` as a Git submodule. This
preserved an exact source snapshot, but it combined polyrepo release overhead
with monorepo checkout and integration overhead.

Crate consumers do not observe parent Git links. Cargo resolves published
manifest dependencies and application lockfiles. The parent pins therefore
benefited maintainers while imposing recursive checkout, detached-child,
ordered-pin, duplicate-CI, and dirty-worktree mechanics on every family.

Several families are not yet published at their current revision, so registry
versions alone cannot currently reproduce the integration build.

## Decision

Standard-family source is canonical only in the corresponding
`github.com/openbimrs/<family>` repository. `openbimrs/openbim` does not track,
mirror, or mount those source trees.

The rules are:

1. Remove all family gitlinks and `.gitmodules` from `openbim`.
2. Remove submodule initialization, validation, and mutation machinery.
3. Keep exact canonical Git revisions in Cargo integration dependencies while a
   required revision is unavailable from crates.io.
4. Prefer released registry dependencies once the required capabilities are
   published; use `Cargo.lock` for the exact integration resolution.
5. Keep optional local child clones at `packages/<family>/`. Parent Git ignores
   those paths; the layout creates no source or release relationship.
6. Commit, gate, push, and release family changes from the family repository.
7. Change the integration repository only for facade/apps/bindings changes or
   to advance a compatibility dependency.
8. Do not reintroduce local path overrides for ignored family checkouts: a
   developer's local child state must not silently affect the integration gate.

Parent-owned facade, core, analysis, apps, and bindings remain temporarily in
this repository. They can be extracted independently when they have a clear
canonical repository and release boundary; this decision does not invent those
repositories or discard their history.

## Consequences

**Positive**

- A normal clone is complete; recursive Git operations are unnecessary.
- Family repositories are truly standalone development and release units.
- Local child worktrees cannot make parent CI differ from a clean clone.
- Pinning uses Cargo's dependency model, the same graph exercised by Rust builds.
- Adding non-Cargo families such as Apple Pkl does not expand the parent
  workspace.

**Negative / costs**

- Whole-ecosystem source browsing requires separate local clones.
- Unpublished compatibility revisions still require explicit Git dependencies.
- Cross-family changes remain ordered across repositories.
- The parent no longer runs each child's standalone gate; each child CI owns it.

## Alternatives considered

| Option | Why not |
| --- | --- |
| Keep submodules | Retains the operational complexity this decision removes. |
| Move all family source back into `openbim` | Removes independent repository ownership and release boundaries. |
| Depend only on crates.io immediately | Current IFC and MVD packages and some required revisions are not published. |
| Use unpinned Git branches | Makes clean integration builds change without a parent commit. |
| Copy family source into ignored directories in CI | Recreates an undeclared submodule system. |

## Migration and rollback

Removing a gitlink does not delete the canonical child repository. Existing
local child directories are preserved as ignored nested repositories. Rollback
is a single revert of the migration commit, provided every restored gitlink
still names a public reachable commit.
