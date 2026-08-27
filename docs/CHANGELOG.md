# Changelog

All notable changes to **openbim** are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

One entry per change under `## [Unreleased]` as you land work; cut a version
section on release.

## [Unreleased]

### Added
- **ISO 23387 DT family.** Extracted the preserved `packages/dt` history into
  the independently documented and gated `openbimrs/dt` repository, pinned its
  exact public revision at `packages/dt`, and published `openbim-dt 0.1.1` with
  corrected repository metadata. The release remains a namespace-only scaffold;
  no model, codec, schema validation, or conformance behavior is claimed, and
  local ISO/DIN/CEN references remain untracked.
- **CityGML, openBIMRL, and bSDD family reservations.** Added independently
  gated canonical repositories, exact-version short aliases, exact superproject
  pins, and isolated facade features for `openbim-citygml`/`citygml`,
  `openbim-openbimrl`/`openbimrl`, and `openbim-bsdd`/`bsdd`. These `0.1.0`
  packages reserve ownership only; no parser, language, API client, or
  conformance implementation is claimed.
- **GAEB crates.io release.** Published `openbim-gaeb 0.1.0` and its exact-version
  pure alias `gaeb 0.1.0`, then advanced the family pin to the release-verified
  child commit.
- **ISO 22057 EPD family.** Added the independently gated `openbimrs/epd`
  repository at `packages/epd`, the `openbim-epd` crate, and an isolated `epd`
  facade feature. The scaffold models the standard edition and all 18
  information-module codes (including aggregated `A1-A3`) without inventing
  an XML namespace or parser; restricted local standards material remains
  untracked.
- **GAEB DA XML family.** Added the independently gated `openbimrs/gaeb`
  repository at `packages/gaeb`, canonical `openbim-gaeb` crate, exact-version
  `gaeb` alias, and isolated facade feature. It performs content-based 3.1–3.4
  beta detection, namespace-resolved evidence diagnostics, lossless unchanged-byte
  round trips, common BoQ item extraction, and fail-closed quantity edits for one
  safely replaceable value range. Full XSD validation and complete generated
  bindings remain explicitly out of scope.
- **First crates.io release: 13 crates at `0.1.0`.** The openBIM standards ship
  as separate crates rather than features of one, so a consumer that wants IDS
  compiles IDS and nothing else. Verified against the published artifacts, not
  the workspace: `openbim` with `default-features = false` resolves to
  `openbim-core` alone, and `--features ids` adds exactly `openbim-ids`.

  | Published | |
  | --- | --- |
  | `openbim` | facade, one feature per standard |
  | `openbim-core` | shared vocabulary |
  | `openbim-ids`, `openbim-bcf`, `openbim-icdd`, `openbim-idm`, `openbim-loin`, `openbim-dt` | standards |
  | `icdd`, `idmxml`, `loin` | alias crates, pure re-exports |

  These are **reserved scaffolds**: the names, boundaries, and dependency
  isolation are real and gated; the codecs are not implemented yet.

- **`scripts/publish-remaining.sh`** — crates.io rate-limits new crate names to
  roughly one per 10 minutes, so publishing a family in one pass fails partway
  with HTTP 429. Retries on 429, walks crates in dependency order, and skips
  anything already on the registry, so it is safe to re-run.

### Changed
- Advanced ICDD to `openbim-icdd`/`icdd` `0.2.0`, making the standalone
  `openbimrs/icdd` repository the sole ISO 21597 implementation boundary. The
  canonical crate now owns bounded ZIP/RDF reading, typed index and linkset
  views, deterministic writing, safe extraction, and federation extensions;
  downstream Solibri and Poing migrations remain separate changes.
- Advanced the DT family pin to connect its complete pre-standalone lineage and
  make the deployed Pages artifact match the validated documentation tree.
- Retired the public sniff-only XML and ZIP wrapper packages. XML format
  families use `quick-xml` directly; GAEB now pins the published
  `openbim-gaeb`/`gaeb` `0.1.2` pair and owns BOM/content detection locally.
  ZIP-based families will own their archive policy over the maintained `zip`
  crate when implemented. `packages/step` is now the canonical
  `openbimrs/step` submodule and contains `openbim-step 0.3.2`, the reusable
  ISO 10303-11 EXPRESS and ISO 10303-21 syntax layer consumed by IFC adapters.
  It parses strictly by default and offers opt-in malformed-record recovery,
  which `ifc-step` surfaces as `StepCodec::lenient()` plus
  `Model::diagnostics()` so a consumer can load a damaged export and report
  exactly what was dropped.
- Advanced the EPD family pin to the independently gated documentation commit,
  publishing searchable project pages, generated Rust API documentation, and
  single-source changelog and roadmap pages without redistributing local
  standards references.
- Hardened the GAEB, CityGML, openBIMRL, and bSDD alias release contracts to
  reject conditional/default-feature-altered dependencies, extra dependencies,
  features, targets, build scripts, source APIs, loose versions, and unexpected
  package payloads. All four children now pin CI action inputs and kill 19
  semantic mutations before clean canonical and alias package verification.
- Serialized submodule-guard reads and mutations through shared/exclusive locks
  in the common Git directory. Recursive checks now require an inherited,
  inode-validated descriptor that demonstrably holds the exclusive flock, so a
  forged environment marker cannot bypass serialization.

- Enforced facade feature isolation from actual `cargo tree` dependency closures;
  every isolated standard feature, including CityGML, openBIMRL, and bSDD, now
  fails the root gate if it pulls any other standard family. Permanent mutation
  probes cover each feature, with LOIN's normative DT dependency as the explicit
  exception.
- Advanced the openBIMRL and bSDD family pins to documentation corrections that
  record the completed alias release and replace a retired upstream API link.
- Updated the EPD family pin and workspace dependency to `openbim-epd 0.1.1`,
  whose public examples use the corrected `InformationModuleGroup::group()` API
  and are compile-tested as crate documentation.
- **IFC now has a canonical standalone repository.** `packages/ifc` is pinned
  from `github.com/openbimrs/ifc` and contains all 19 IFC packages plus their
  curated test fixtures. Relevant Git history, explicit package metadata, and
  standalone/integration gates are preserved across the repository boundary.
- **ICDD now has a canonical standalone repository.** `packages/icdd` is a
  pinned submodule of `github.com/openbimrs/icdd`, containing both the canonical
  `openbim-icdd` implementation and the exact-version `icdd` pure re-export.
  The child has preserved family history, explicit release metadata, standalone
  CI/package gates, and an ignored local `references/` boundary for restricted
  standards material.
- **LOIN now has a canonical standalone repository.** `packages/loin` pins
  `github.com/openbimrs/loin`, containing the canonical `openbim-loin` package
  and exact-version `loin` pure re-export. The child preserves family history,
  documents the implemented namespace-only boundary, and runs standalone CI,
  package verification, and semantic alias mutation gates.
- **IDM now has a canonical standalone repository.** `packages/idm` pins
  `github.com/openbimrs/idm`, containing the lossless ISO 29481-3 engine, CLI,
  PyO3 package, generated semantic catalog, and exact-version `idmxml` pure
  re-export. Standalone gates verify Rust/Python round trips, packaging, docs,
  alias purity, superproject-safe metadata, and standards-material leakage.
- Hardened the standard-family submodule gate to reject dirty child worktrees
  and poisoned or duplicated declared, configured, child-origin, or
  transport-rewritten URLs, with signal-safe, state-preserving mutation probes
  for each failure mode. Existing checkouts can run
  `scripts/init-family-submodules.sh` to signal-safely shelter and restore local
  restricted `packages/{icdd,idm,loin,dt}/references/` corpora during
  initialization.
- Updated GitHub Actions checkout to `actions/checkout@v7`, removing the
  deprecated Node 20 runtime warning and using current fork-safety behavior.
- Raised the integration workspace MSRV from Rust 1.85 to 1.88, the minimum
  required by the currently locked geometry dependencies; CI now exercises
  that exact toolchain.
- **IDS now has a canonical standalone repository.** The `packages/ids`
  directory is a pinned submodule of `github.com/openbimrs/ids`, with preserved
  family history, explicit release metadata, versioned cross-repository
  dependencies, its own README and CI gate, and a parent integration patch that
  prevents duplicate `openbim-core` package identities. Recursive checkout and
  pin integrity are enforced by the superproject gate.
- **Repository is now `openbim`** (`github.com/openbimrs/openbim`), freeing the
  name `nehirde` for the application built on top of these crates.
- **`packages/` groups one directory per standard family**, mirroring the
  repositories under `github.com/openbimrs`, so extracting a family to its own
  repository later is a directory move. `ifc/` keeps its 18 crates plus the
  `openbim-ifc` facade grouped, sitting beside `ids/`, `bcf/`, `icdd/`, `idm/`,
  `loin/` and `dt/`.
- **Published names are `openbim-*`.** `ifc`, `bcf`, `ids`, `idm`, `dt` and
  `codec` are all taken on crates.io by unrelated crates. Only `icdd`, `loin`
  and `idmxml` were free, and those ship as alias crates. The IFC facade keeps
  `ifc` as its **lib target name**, so consumers still write `use ifc::…`.

### Fixed
- **Architecture tests no longer pass vacuously after a layout change.** Four
  tests selected crates by parent directory; restructuring made each match zero
  crates, so they reported success while proving nothing. Every architecture
  test now selects by crate name as well as directory and asserts a minimum
  crate count, and each was re-verified by mutation — introduce the violation,
  watch the gate fail, restore, watch it pass.
- **Published path dependencies carry a version requirement.** `cargo publish`
  strips the path and resolves by version, so a path-only dependency cannot be
  published. Not caught by the gate: `--dry-run` on a leaf crate passes, because
  a leaf has no path dependency of its own.

### Added
- **Geometry-kernel capability audit and implementation recommendation.**
  `docs/research/geometry-kernel-capability-comparison.md` distinguishes CGAL,
  Manifold, OCCT, IfcOpenShell passthrough, OpenUSD, and Nehirde by executed
  capability rather than API vocabulary. It recommends curve evaluation,
  world-space adaptive sampling, and swept-disk execution as the next vertical
  slice, with corpus and mutation gates.
- **Differential harness vs IfcOpenShell** (`tools/differential/`, `ifc differential`).
  Both sides emit the same JSON schema; `compare.py` joins on `(file, entity id)`
  and publishes `docs/benchmarks/differential-ifcopenshell.md`. Found and fixed
  two real defects: products were compiled without their `ObjectPlacement`
  (every opening landed at the origin, leaving the `issue_098_wall_W` wall at
  42.107 instead of 32.419), and the divergence-theorem volume formula was
  uncentred, losing ~8% on survey coordinates. 28/42 products now agree to
  1e-9 relative; the remainder are documented tessellation-density
  differences on curved B-reps and swept disks.
- **`subtract_many` batch override.** `axiolid-boolmesh` groups mutually
  disjoint cutters by AABB and removes each group with a single boolean,
  resting on `(S \ A) \ B == S \ (A union B)`. Measured **9.2x** at n=64 on
  the IFC-dominant layout (66.47 ms -> 7.22 ms) and 0.99x on a complete
  overlap graph, so it is enabled unconditionally. Benchmarked by
  `axiolid-boolmesh/benches/subtract_many.rs`, which reproduces the ADR 0014
  sequential baseline in-process; gated by volume equality against the
  sequential path across hand-picked and randomised layouts.
- **Certified predicate suite in `axiolid-scalar`.** `orient3d`, `incircle`, and
  `insphere` join `orient2d` as filtered cascades that escalate to exact
  expansion arithmetic, plus `StaticFilter` for callers that can declare a
  coordinate range. Each is differentially gated against an independent i128
  oracle over 20k inputs, half of them constructed exactly degenerate.
- **Degeneracy benchmark harness.** `cargo bench -p axiolid-scalar` reports
  throughput and escalation rate together at 0%, 0.01%, 1%, and 10% degenerate
  inputs. Measured: `orient2d` is flat (93 M/s clean, 90 M/s at 10%);
  `orient3d` costs 2.3x at 10% (72 -> 32 M/s). Escalation tracks the injected
  rate to four decimals, asserted in `tests/degeneracy.rs`.
- **`axiolid-compile::extrude::outward_orientation`.** Decides mesh orientation by
  summing tetrahedron volumes in exact expansion arithmetic, so a thin plate on
  survey coordinates -- where the naive f64 sum loses the sign entirely -- is
  still judged correctly. ADR 0016 records why the predicates are ours even
  though the boolean and triangulator are adopted.
- **End-to-end IFC geometry: `ifc mesh <file.ifc>`.** The CLI lowers a model's
  representation items through `ifc-geometry`, compiles them with
  `axiolid-compile`'s `ScalarCompiler`, and applies `IfcRelVoidsElement` openings
  with `axiolid-boolmesh`. `ifc capabilities` now lists real providers instead of
  reporting `none (scaffold only)`. Gated across the committed fixture corpus:
  every lowered item compiles, every produced solid is edge-manifold and
  outward-oriented, and the net wall volume for
  `issue_2019_wall_two_overlapping_openings.ifc` matches the independent
  Monte-Carlo oracle from ADR 0014 (2.0807).
- **`ScalarCompiler`: the first working `GeometryCompiler`.** Walks the
  geometry DAG iteratively (a 50k-deep instance chain compiles without stack
  overflow) with memoisation, so a shared subtree is compiled once per batch
  rather than once per reference. Handles `TriMesh`, `Instance`, `Collection`,
  `Extrusion`, and `Boolean`; every other family returns `Unsupported` naming
  the capability it needs. Generic over the boolean provider, so the adopted
  `axiolid-boolmesh` is swappable. Wall-minus-opening compiles to exact volume
  2.16 through Profile -> Extrusion -> Instance -> Boolean.
- **`axiolid-compile`: profile triangulation and linear extrusion.** Rectangle
  (solid and hollow) and circle (disk and annulus) profiles flatten under an
  explicit chord budget; holes are triangulated by the adopted `earcut`
  (ADR 0015) and extruded into closed solids. Output is gated on exact volume,
  **directed-edge manifoldness**, disk convergence from below, a differential
  comparison against `axiolid-scalar`'s certified triangulator, and end-to-end
  acceptance by `axiolid-boolmesh` — an extruded wall minus an opening yields
  exactly 2.16 and partitions conservatively.
- **ADR 0015: `earcut` adopted for polygon triangulation.** A hand-rolled ear
  clipper passed simple polygons, reflex vertices, and one hole but stalled on
  two holes; earcut triangulates the same case exactly (area 175). Licence
  MIT OR Apache-2.0, dependency graph `num-traits` + `autocfg`, pure Rust.
- **`axiolid-boolmesh`: the `boolmesh`-backed `MeshBoolean` provider.** Owns
  `TriMesh` <-> `Manifold` conversion and contract enforcement; the algorithm is
  upstream's. Orientation is gated on input per argument, because an inside-out
  mesh is structurally valid and manifold and would turn `Difference` into
  `Union` silently. Input faults blame the caller, result faults blame the
  backend. `boolmesh` is not re-exported and reaches neither `axiolid-kernel` nor
  `ifc-geometry`, verified by `cargo tree`. First real consumer of
  `ScratchRequirement` and `MeshBooleanRegistry`.
### Added
- **ADR 0014: `boolmesh` adopted as the mesh boolean**, resolving the open
  evaluation in ADR 0003. Measured against the two hard fixtures: exact volume
  conservation on a wall minus three mutually overlapping rotated openings
  (error 0.000e0, cross-checked against a 4M-sample Monte-Carlo oracle), and no
  flyaway on a millimetre-scale halfspace clip with a 2e-9 off-axis normal.
  Transitive dependency graph is `glam` alone; zero `unsafe`; f64 by default.
  Adopted as an unmodified dependency, never vendored, so MPL-2.0 file-level
  copyleft imposes nothing on the MIT workspace.
- **`axiolid-scalar`: the scalar reference implementation begins (ADR 0012).**
  Error-free transformations (`two_sum`, `two_diff`, `two_product`) and a
  certified `orient2d` that filters in f64 and escalates to exact expansion
  arithmetic when the determinant falls inside its own error bound. This is the
  first producer of `Certified`, so that contract is now validated against real
  numerics rather than test doubles. Verified by a differential gate against an
  independent i128 oracle over 40,000 inputs -- including mixed-magnitude
  coordinates where the f64 subtraction genuinely rounds -- and by three
  searched triples where the naive determinant reports collinear and is
  provably wrong.
- **Certified predicates and the precision escalation ladder.**
  `axiolid_kernel::certainty` adds `Sign`, `Certified`, and `EscalationLadder`:
  a filtered predicate reports `Uncertain` when its value lies within its own
  error bound, so an undecided floating-point sign cannot reach a topology
  decision. `Precision` gains an `Exact` tier and the ladder steps
  f32 -> f64 -> exact (`Mixed` is a strategy, not a rung).
- **Output bounds and a batch destination seam.** `OutputBound::write_offsets`
  is the exclusive prefix scan that turns per-element output counts into
  disjoint write offsets, so a batching provider needs no global atomic counter
  and no dynamically growing vector. `GeometryCompiler::compile_batch_into`
  writes into a caller-owned buffer; the GPU adapter overrides that seam so both
  batch call shapes reach the device in a single submission.
- **ADR 0013** recording deferred performance techniques (SoA/AoSoA, GPU shared
  memory, atomics vs. block-aggregated scan, compaction, SVE/SVE2, quantisation,
  Morton codes, divergence queues) each with the trigger that should un-defer
  it, and rejecting tensor cores outright with the FP64-rate rationale.
- **Execution policy contracts for determinism, residency, and scratch.**
  `Determinism` is now three distinct contracts (`Topological`,
  `NumericallyBounded`, `Bitwise`) compared by strength rather than equality, so
  two backends can no longer both claim "deterministic" and disagree.
  `DataResidency`/`Residency` make data location part of the execution plan, and
  the GPU adapter refuses undeliverable output before dispatch.
  `ScratchRequirement` lets hot-path providers declare bounded scratch, and
  `MeshBooleanRegistry` enforces `memory_budget_bytes` *before* invoking a
  provider instead of carrying an unenforced field.
- **ADR 0012** assigning the scalar reference to a dedicated `axiolid-scalar` crate
  and requiring the scalar implementation of an operation to land before any
  optimized one; supersedes ADR 0002's stale crate topology and oracle owner.
- **Versioned PSD/QTO template catalogs (`ifc-template-catalog`)** with a
  committed IFC4 ADD2 TC1 artifact, official/corrected profiles,
  provenance-bearing overlays, bounded XML import, schema-aware applicability,
  and format-neutral application/compliance APIs.
- **ifcXML codec (`ifc-xml`)** implementing the same `Codec` trait as
  `ifc-step`, proving serialization is genuinely pluggable: the model crate did
  not change to accommodate it. Schema-aware attribute naming is optional, with
  a positional fallback so files from unknown schemas still round-trip.
- **EXPRESS schema parser (`ifc-schema`)** reading the official `.exp` files.
  Verified against all three shipped schemas: IFC2x3 TC1 (653 entities),
  IFC4 ADD2 TC1 (776 entities, 397 types), IFC4x3 ADD2 (876 entities).
  Provides `is_a` subtype queries and STEP-positional attribute names.
- **`ifc` facade features** for codecs (`step`, `ifcxml`), `schema`, and each
  domain, plus `codecs` / `domains` / `full` bundles. `default = ["step"]`.
- **`Codec::detect`** (defaulting to `false`) so `ifc::read_path` selects a
  codec by content sniffing, then extension.
- **Native-accelerator readiness for the geometry data plane** (ADR 0011):
  pure-Rust GPU stays the first path, while a native CUDA/HIP backend remains a
  later out-of-tree addition behind the existing `GpuGraphExecutor` seam.
  `BackendId` now stores fixed-capacity inline UTF-8, so driver-enumerated
  identities (`cuda:0`, `hip:1`) are constructible at runtime without leaking
  and are rejected rather than truncated when over-long. Two executable gates
  keep the option open: the representation crates must stay FFI-transferable,
  and the executor seam must stay satisfiable with published API only.
- **Layered geometry package scaffold** with one immutable neutral DAG,
  typed-handle B-rep topology, exact curve/surface/profile values, narrow
  operation-provider traits, separate CPU execution/GPU adapter crates, and a
  feature-gated `axiolid` facade. Core-only resolves 3 unique packages; default
  resolves 5, including the facade itself.
- **Authoritative IFC geometry support ledger** covering all 163 IFC4 ADD2 TC1
  declarations: 112 entities (23 abstract, 89 concrete), 13 selects, seven
  enums, three defined types, and 28 functions. Coverage and ownership gates are
  mutation-verified.
- Costing fixture `packages/ifc/test/fixtures/costing/costing_schedule.ifc` with cost
  schedules, items, values, quantities, property sets, and an entity type from
  no IFC schema.

### Changed
- Active `ifc-geometry` lowering uses the canonical profile, primitive, CSG, and
  backend-neutral `axiolid-model` vocabulary. The pre-DAG request values remain
  warning-clean source-compatibility shims and are rejected from active lowering.
- Local `target-cpu=native` flags are scoped to x86_64 so AArch64 cross-checks do
  not inherit invalid x86 features.

### Fixed
- Geometry graph handles are graph-owned; semantic references preserve
  Curve2/Curve3 dimensionality through instances and relation chains.
- GPU adapters validate executor-specific policy before submission and report
  wrong result cardinality as a backend contract violation. Mesh-boolean batch
  dispatch reaches provider overrides and only retries unsupported/unavailable
  providers. CPU feature behavior is covered in each feature combination.
- Active IFC lowering isolation now parses Rust paths, aliases, globs, and macro
  tokens instead of relying on bypassable source substrings. The pre-scaffold IFC
  boolean enum namespace remains warning-clean and source-compatible.
- ifcXML wrote numeric-looking strings (`IfcApplication.Version = "0.1"`) as
  plain XML attributes, so re-reading inferred `Real(0.1)` and silently changed
  the value's kind. Such strings now become typed child elements.

### Added
- **Working STEP codec and entity model.** `ifc-model` holds the entity graph
  (`Value`, `Entity`, `Model`, GUID codec, type index, dangling-reference
  detection); `ifc-step` implements lexer, parser and writer over it. All 19
  committed fixtures parse (7,920 entities across IFC2x3, IFC4 and IFC4X3_ADD2)
  and round-trip structurally intact.
- **`Codec` trait in `ifc-model`**, so serialization is pluggable: STEP today,
  ifcXML and IFC-JSON as future crates implementing the same trait. The model
  depends on no codec.
- **`ifc` facade crate** exposing every domain as a cargo feature. A thin
  (`step`) build resolves 26 crates; `full` resolves 51, and the thin build
  links no geometry kernel and no `glam`.
- **`ifc-cost` as the worked example of a domain view** — borrows `&Model`,
  owns no storage, therefore optional at compile time with no data loss.
- `ifc-cli`: `info` and `types` commands over real files.
- ADR 0006 recording the model/domain and model/serialization separations.

### Fixed
- Two architectural tests found to be passing vacuously, caught by mutation
  testing: the feature-gating test never checked the `default` feature set, and
  nothing checked `Model::insert` id reuse (dropping its guard duplicated the
  entity in export order while all tests stayed green).
- An earlier dependency test read `cargo metadata`'s package list, which lists
  every workspace member regardless of features; it now reads `cargo tree`.

### Added
- **Official IFC schemas as reference material** (`references/ifc-spec/`, 249 MB
  on `/mnt/backup`, symlinked, never committed): EXPRESS schemas for IFC2x3 TC1,
  IFC4 ADD2 TC1 and IFC4x3 ADD2, the IFC4 ifcXML `.xsd`, 737 property-set
  definition XMLs, and the full IFC4 HTML documentation. Documented in
  `references/AGENTS-ifc-spec.md`, including the browser-User-Agent requirement
  that otherwise 403s every download.
- **8 geometry crates**, sized from the schema rather than guessed:
  `axiolid-profile` (23 `IfcProfileDef` subtypes), `axiolid-curve` (36 curve
  entities), `axiolid-surface` (37 surface entities), `axiolid-sweep` (11 swept-solid
  forms), `axiolid-topology` (~37 topology entities), `axiolid-tessellate`,
  `axiolid-spatial`, `axiolid-measure`.
- **9 IFC crates**, each backed by an entity count: `ifc-style` (48),
  `ifc-structural` (39), `ifc-systems` (23), `ifc-material` (22),
  `ifc-resource` (21), `ifc-classification` (12), `ifc-georef` (8),
  `ifc-alignment` (IFC4x3 linear referencing), `ifc-validate` (47 schema
  functions + 2 global rules).
- ADR 0005 recording the spec-driven expansion and the evidence behind it.

### Changed
- `axiolid-brep` renamed to `axiolid-topology` (the standard's own vocabulary); its
  `Tessellate` trait and `ChordTolerance` moved to `axiolid-tessellate`, tests
  intact.
- **The architecture gate is now an allowlist.** "Only `ifc-geometry` may touch
  geometry" was too narrow once `ifc-georef` and `ifc-alignment` existed —
  alignment geometry is deliberately not part of the building-shape pipeline.
  `MAY_USE_GEOMETRY` names the three permitted crates; a fourth requires editing
  the list and saying why. Three tests, each mutation-verified: non-allowlisted
  crate gaining geometry, allowlisted crate enabling a backend feature, and the
  allowlist naming a crate that does not exist.

### Deferred
- **WASM bindings.** `bindings/wasm` → `bindings/_deferred-wasm`, removed from
  workspace members and added to `exclude`, so it is not built, tested or
  linted. Kept rather than deleted because its constraints (no threads, no
  `is_x86_feature_detected!`, size budget) are an argument for the runtime
  backend selection already in `axiolid-kernel`.

### Changed
- **Restructured into role-grouped packages.** `axiolid/` and `ifc/` became
  `../axiolid/` and `packages/`, joined by `packages/`
  (`ids`, `bcf`, `clash`, `diff`), `bindings/` (`python`, `wasm`), and `apps/`
  (`ifc-cli`). Dependency direction is one-way:
  `geometry → ifc → openbim → {bindings, apps}`. 17 crates total.
- **Backends are now cargo features of `axiolid-kernel`, not separate crates.**
  `axiolid-cpu`/`axiolid-simd`/`axiolid-gpu`/`axiolid-dispatch` became
  `axiolid_kernel::backend::{scalar,simd,gpu,Dispatcher}` behind features
  `scalar` + `simd` (default) and `gpu` (off). The swap boundary is now expressed
  as a feature constraint: `packages/*` take `default-features = false`,
  applications opt in. See ADR 0004.
- **`TriMesh` moved from `axiolid-core` to the new `axiolid-mesh` crate**; `axiolid-core`
  is now data-and-tolerance only.
- Renamed `ifc-parser` → `ifc-step`, `ifc-shape` → `ifc-geometry`.

### Fixed
- **`default-features = false` was being silently ignored**, which would have
  made the kernel swap boundary cosmetic. Cargo drops it on a member dependency
  unless the root `[workspace.dependencies]` entry also sets it — it only emits a
  warning. Fixed at the workspace entry; applications now opt in explicitly. The
  architecture test covers this case.

### Added
- **`axiolid/` + `ifc/` package architecture.** Ten crates across two package
  groups: `axiolid/{core,kernel,cpu,simd,gpu,dispatch}` and
  `ifc/{schema,parser,model,shape}`. `axiolid/` is an IFC-agnostic shared geometry
  kernel; `ifc/` is pure IFC logic.
- **Swappable geometry kernel.** `axiolid-kernel` holds traits only
  (`MeshBoolean`, `Capabilities`, `GeomError`); `ifc/` depends on the contract
  and never on a backend, so the geometry implementation can be replaced without
  touching the IFC layer. Enforced by `ifc/shape/tests/no_backend_dependency.rs`,
  which reads the manifests and fails the build on violation — mutation-verified
  to actually fail when a backend dependency is added.
- **Hardware abstraction.** Scalar (`axiolid-cpu`, the correctness oracle), SIMD
  (`axiolid-simd`, runtime `is_x86_feature_detected!` for AVX2/AVX-512), and
  optional GPU (`axiolid-gpu`, off by default) backends behind one contract, with
  `axiolid-dispatch` selecting the most specialized available backend at runtime.
  *(Superseded: those crate names never shipped. The crates are
  `axiolid-backend-cpu` — an execution context, explicitly not the oracle — and
  `axiolid-backend-gpu`; the scalar reference is owned by `axiolid-scalar`. See
  `docs/adr/0012`.)*
- `axiolid-brep` — reserved crate for exact topology, with the `Tessellate` bridge
  to `axiolid-mesh`. This is the capability OpenCascade provides to IfcOpenShell;
  scope is deliberately limited to the surfaces IFC actually uses.
- `apps/ifc-cli` — working binary. `ifc capabilities` reports detected backends
  and the selected boolean implementation (currently: none, honestly).
- `packages/{ifc-properties,ifc-cost,ifc-schedule}` and
  `packages/{ids,bcf,clash,diff}` — reserved, documented crates.
- ADR 0001 (axiolid/ifc split + kernel contract), ADR 0002 (hardware abstraction),
  ADR 0003 (pure-Rust mesh boolean instead of OpenCascade), ADR 0004 (package
  layout + backends as features).
- Repo scaffold: `docs/` (roadmap, ADRs, this changelog), `references/`
  symlinks to IfcOpenShell + ifc-lite clones on `/mnt/backup/`,
  `packages/ifc/test/fixtures/` with 19 edge-case `.ifc` files pulled from those two repos,
  `target` symlinked to `/mnt/backup/build-cache/` (sparse root disk),
  progressive `AGENTS.md` context files.

### Notes
- No C++ geometry dependency anywhere in the graph — the premise of the project.
  The mesh boolean currently returns `Unsupported` rather than emitting a wrong
  mesh; a real implementation is Stage 2 in `docs/ROADMAP.md`.
