# 0016 — Standard-family repositories pinned as submodules

- **Status:** Accepted
- **Date:** 2026-08-25
- **Deciders:** Friedrich Schrödter
- **Supersedes:** —

## Context

ADR 0015 separates openBIM standards into independently publishable crates. The
family directories also need independent issue tracking, documentation, CI,
ownership, and release cadence without losing a reproducible whole-ecosystem
integration point.

Copying or mirroring family source would create two editable authorities. Moving
all source out without integration pins would make it difficult to reproduce a
known-compatible ecosystem revision. Git submodules can express an exact child
commit while preserving the child repository as the canonical source.

Cargo permits packages beneath a nested workspace to participate in the parent
workspace. A spike also showed an important hazard: `version.workspace = true`
resolved to the parent workspace version when invoked from the superproject and
to the child workspace version when invoked standalone. Release-critical
metadata therefore cannot remain ambiguously inherited across this boundary.

## Decision

Each extracted standard family is canonical in its own `openbimrs/<family>`
repository and is pinned beneath `packages/<family>` as a Git submodule.
`openbimrs/openbim` remains the integration superproject.

The rules are:

1. Extract relevant history rather than copying a snapshot.
2. Give each child an independent Cargo workspace, README, license, changelog,
   progressive context, and CI gate.
3. Declare child package metadata and cross-repository dependencies explicitly;
   do not inherit release-critical values from the parent workspace.
4. Use versioned registry dependencies in child repositories.
5. Use the superproject's `[patch.crates-io]` table to substitute local shared
   packages during integration, preventing duplicate package identities.
6. Push and verify a child commit before updating the parent gitlink.
7. Require recursive checkout and fail closed when a submodule is missing,
   modified away from its pin, conflicted, or configured with the wrong URL.
8. Keep public superproject submodules public. A private child must remain in the
   superproject until it can be cloned anonymously.

IDS was the pilot. ICDD was the second extracted family and also preserves a
pure short-name package alias. IFC is the third and largest extraction: its 19
packages retain their relevant history and run the same architecture gates both
standalone and under this superproject.

## Alternatives considered

| Option | Why not |
| --- | --- |
| Keep one monorepo only | Does not provide independent family repositories, issue tracking, or release ownership. |
| Editable mirrors via subtree automation | Creates ambiguous contribution and merge direction unless one side is declared read-only. |
| Git dependencies without source pins in the tree | Reproducible, but makes whole-ecosystem browsing and coordinated local development less direct. |
| Copy the current directory into an empty repository | Loses the family history and creates two editable copies. |
| Private `codec` submodule in the public superproject | Anonymous recursive clones would fail. |

## Consequences

**Positive**

- Each standard receives a focused repository and top-level documentation.
- The superproject records an exact compatible set of child commits.
- Standalone and integrated behavior are both executable gates.
- GitHub displays each family under `packages/` as a link to its canonical
  repository and pinned revision.

**Negative / costs**

- Cross-family changes require ordered commits across repositories.
- Contributors must clone recursively or initialize submodules.
- CI and release automation exist at both child and integration levels.
- Workspace metadata cannot be centralized blindly across the repository
  boundary.

**Follow-ups / risks to watch**

- Validate every extraction with a fresh anonymous recursive clone.
- Keep dependency changes ordered from lower-level repositories to consumers.
- Keep `codec` in the superproject while `openbimrs/codec` is private.
- Apply the hardened extraction workflow to the remaining standard families.

## Relation to existing code

- `packages/ids` — IDS pilot submodule.
- `packages/icdd` — ICDD canonical and short-name packages, pinned together.
- `packages/ifc` — IFC workspace and test fixtures, pinned at its canonical commit.
- `.gitmodules` — canonical child URLs.
- `Cargo.toml` — local integration patches.
- `scripts/check-submodules.sh` — fail-closed pin and initialization gate.
- `.github/workflows/ci.yml` — recursive checkout.
- `packages/AGENTS.md` — family ownership and dependency direction.
