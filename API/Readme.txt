R4OS API reference
==================

Start with `ArchitekturUndEinstieg.md`. `APIArchitektur.svg` provides the
same high-level relationship as a diagram.

Platform groups
---------------

All six groups are built-in Kernel providers. Their `Query:1` import names
remain public ABI, but no group is built, installed or updated as an R4L file.

- R4SYS: console, files, programs, services, memory and registry.
- R4DESK: windows, input, desktop and remote frames.
- R4DRAW: drawing, fonts, images, surfaces, frame commands and display control.
- R4NET: adapters, sockets, DNS/DHCP and network service views.
- R4AUDIO: PCM, synthesizers and audio status.
- R4DEV: hardware, modules, boot and diagnostics.

Independent libraries
---------------------

R4STD, R4IMG and R4FONT are file-based Runtime-R4Ls with no platform group ID.
Each owns its contract, bindings and versioned function tables in its library
repository and remains independently installable and updatable.

Generated truth
---------------

`Repositories/Contract/API/ApiContract.json` generates the platform ABI,
group tables, payload layouts, operation semantics and language-conformance
fixtures. The authoritative generated files live in
`Repositories/Contract/Generated/`. The copies in this directory are kept in
sync for readers:

- `PayloadTypes.md`
- `OperationContracts.md`
- the generated table region in each platform-group document
- `ZigCParity.json`

Normal Contract builds check generated drift. Intentional schema changes use
the explicit generator write workflow and update the compatibility baseline
only when the ABI decision requires it.

Brightness (0.80.16)
-------------------
Optional output brightness calls use normalized 0..65535 values and exact
output generations. Admission and driver completion are separate; current
means confirmed programmed intensity, not measured luminance. Hardware
remains in the R4D owner, persistence in Desktop/Appearance. Missing APIs
or panel control remain explicitly unavailable. AMDPanel08016.txt under
Docs/Drivers records the first native backend and its validation boundary.
