# IFC geometry plan (superseded)

Status: superseded on 2026-08-19 by progressive `ifc-geometry` plans and moved with the IFC family to [`openbimrs/ifc`](https://github.com/openbimrs/ifc).

The original plan was useful while the IFC-local primitive contract was being
built. The geometry package now owns a format-neutral exact `GeometryGraph`, and
`ifc-geometry` lowers into that graph rather than owning a kernel/request model.
Several stages recorded here as pending were also completed, so retaining the
old queue would misdirect future agents.

Use the canonical IFC repository for current work:

- [`ifc-geometry/AGENTS.md`](https://github.com/openbimrs/ifc/blob/main/ifc-geometry/AGENTS.md) for the stable bridge contract;
- [`ifc-geometry/PLAN.md`](https://github.com/openbimrs/ifc/blob/main/ifc-geometry/PLAN.md) for crate-wide task order;
- paired plans under `ifc-geometry/src/input`, `lower`, `resource`, `curve`,
  `surface`, `solid`, `constraint`, `select`, and `rules` for bounded
  implementation work;
- the declaration inventory and coverage test under
  `ifc-geometry/references/ifc4-add2-tc1-geometry-declarations.tsv`.

Do not add implementation progress here. Update the nearest owning `PLAN.md` in
`openbimrs/ifc`.
