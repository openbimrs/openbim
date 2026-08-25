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
   modified away from its pin, conflicted, or has zero or multiple declared,
   parent-local, child-origin, or effective transport URLs instead of exactly one
   canonical public URL.
8. Keep public superproject submodules public. A private child must remain in the
   superproject until it can be cloned anonymously.
9. Preserve occupied local-only family paths during migration. The initialization
   helper must arm cleanup before each rename and signal-safely shelter and
   restore restricted ICDD, IDM, LOIN, or DT references rather than asking
   users to delete or clean an occupied directory.

IDS was the pilot. ICDD was the second extracted family and also preserves a
pure short-name package alias. IFC was the third and largest extraction: its 19
packages retain their relevant history and run the same architecture gates both
standalone and under this superproject. CDE, EPD, and GAEB now follow the same
canonical-child and exact-gitlink model.

CityGML, openBIMRL, and bSDD establish the same repository and exact-pin
boundaries before implementation work begins. Their initial releases reserve
both canonical and short package names and make no parser or conformance claims.
LOIN likewise pins its canonical and pure short-alias packages together while
keeping its current namespace-only capability boundary explicit.

IDM pins the extracted lossless ISO 29481-3 engine and its pure `idmxml` alias
together. Public source and artifacts carry only generated semantic metadata;
lawfully obtained standards and Annex B schemas remain in the ignored
`references/` boundary.

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
- `packages/idm` — IDM canonical engine and `idmxml` alias, pinned together.
- `packages/loin` — LOIN canonical and short-name packages, pinned together.
- `packages/ifc` — IFC workspace and test fixtures, pinned at its canonical commit.
- `packages/cde`, `packages/epd`, and `packages/gaeb` — independently gated
  canonical family repositories pinned at reviewed commits.
- `packages/{citygml,openbimrl,bsdd}` — reservation workspaces with canonical
  and short-name packages.
- `.gitmodules` — canonical child URLs.
- `Cargo.toml` — workspace membership and local integration patches.
- `packages/facade/openbim` — optional per-standard facade dependencies.
- `scripts/check-submodules.sh` — fail-closed pin and initialization gate.
- `scripts/test-submodule-guard.sh` — mutation tests for submodule failures.
- `scripts/check-facade-isolation.py` — dependency-closure enforcement for each
  isolated facade feature.
- `scripts/check-alias-purity.sh` — structural canonical/alias type-identity gate.
- `scripts/init-family-submodules.sh` — safe initialization and local-reference
  migration helper.
- `.github/workflows/ci.yml` — recursive checkout.
- `packages/AGENTS.md` — family ownership and dependency direction.
