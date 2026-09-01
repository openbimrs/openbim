# IFC CLI integration fixtures

These public IFC fixtures are copied from `openbimrs/ifc` revision
`e86d55e403ced459259e2c4244c8b97058247e91`, matching the exact IFC Git
revision in this repository's `Cargo.lock` when the corpus was adopted.

They are retained here because they test this integration application's complete
IFC-to-Axiolid pipeline. Keeping the app-owned corpus beside the tests makes the
root gate hermetic and removes its former dependency on an untracked family
source checkout under `packages/ifc`.

When the IFC dependency revision changes, compare this corpus with
`test/fixtures/ifclite-geometry/` at the new immutable revision and update this
file if fixtures are intentionally refreshed.

License: AGPL-3.0-or-later, matching `openbimrs/ifc` and this repository.
