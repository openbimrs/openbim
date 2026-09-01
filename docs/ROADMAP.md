# Roadmap

**Mission:** keep the independently released OpenBIM.rs standard families interoperable without re-centralizing their source development.

This repository owns integration evidence, the thin `openbim` facade, cross-family applications, and release compatibility. Family-specific parser, codec, schema, geometry, and format roadmaps belong in their canonical repositories under [`openbimrs`](https://github.com/openbimrs).

Every completed item requires executable evidence. Performance claims require a reproducible benchmark and recorded environment.

## 1. Independent family releases

- [x] Develop standard families in independent `github.com/openbimrs/<family>` repositories.
- [x] Consume families through published crate versions or immutable Git revisions; do not mount their source trees into this repository.
- [x] Keep `packages/` available as an ignored local-clone area only.
- [ ] Publish every facade dependency on crates.io and remove temporary Git revisions once equivalent releases exist.
- [ ] Automate a release-health report covering registry availability, license metadata, minimum supported Rust version, and family gate status.

## 2. Facade compatibility

- [x] Keep facade features additive and opt-in.
- [x] Keep the default facade dependency surface minimal.
- [ ] Gate each feature independently against the exact dependency versions in `Cargo.lock`.
- [ ] Add a public compatibility matrix for facade release versus family release.
- [ ] Add semver checks for the facade's public re-export surface.

## 3. Cross-family integration

- [x] Build the root workspace without family source checkouts.
- [x] Preserve the `ifc-cli` geometry corpus as explicit root-owned integration fixtures under `apps/ifc-cli/tests/fixtures/`.
- [ ] Add cross-family workflows only where a behavior genuinely spans standards, such as IFC object selection combined with IDS auditing or LOIN requirements.
- [ ] Make unsupported combinations fail explicitly rather than silently dropping data.
- [ ] Keep fixture provenance and exact upstream revision recorded beside every copied integration corpus.

## 4. Application surfaces

- [x] Keep application code separate from family parser/model implementations.
- [ ] Stabilize `ifc-cli` commands around released `openbim-ifc` and Axiolid APIs.
- [ ] Publish deterministic differential benchmark inputs and outputs for the root integration CLI.
- [ ] Add Python and WebAssembly consumers only after their upstream family bindings have stable ownership.

## 5. Documentation and governance

- [x] Record the source-mount retirement in ADR 0017.
- [ ] Link each family to its canonical documentation site and capability matrix.
- [ ] Distinguish implemented, tested, published, and planned capabilities throughout the docs.
- [ ] Archive or relocate family-local implementation plans when a canonical family repository owns them.

## Family roadmaps

Use the canonical repository for implementation work:

- [BCF](https://github.com/openbimrs/bcf)
- [buildingSMART Data Dictionary](https://github.com/openbimrs/bsdd)
- [CDE APIs](https://github.com/openbimrs/cde)
- [CityGML](https://github.com/openbimrs/citygml)
- [Data Templates / ISO 23387](https://github.com/openbimrs/dt)
- [EPD](https://github.com/openbimrs/epd)
- [GAEB](https://github.com/openbimrs/gaeb)
- [ICDD](https://github.com/openbimrs/icdd)
- [IDM](https://github.com/openbimrs/idm)
- [IDS](https://github.com/openbimrs/ids)
- [IFC](https://github.com/openbimrs/ifc)
- [LOIN](https://github.com/openbimrs/loin)
- [MMC](https://github.com/openbimrs/mmc)
- [MVD](https://github.com/openbimrs/mvd)
- [OpenBIMRL](https://github.com/openbimrs/openbimrl)
- [STEP](https://github.com/openbimrs/step)
