# R4OS software structure

R4OS source code is split into repositories by ownership. The workspace
checkout is normally rooted at `D:\R4OS`.

| Component | Workspace location | Responsibility |
| --- | --- | --- |
| Platform contract | `Repositories/Contract/` | Shared API, ABI, R4M0 and manifest contracts |
| SDK | `Repositories/SDK/` | Zig/C startup, facades, templates and module builds |
| Kernel | `Repositories/Kernel/` | Boot-critical and privileged system mechanisms |
| Runtime libraries | `Repositories/Libraries/` | Independent R4L contracts and implementations |
| Applications | `Repositories/Apps/` | User-facing and system R4X programs |
| Services | `Repositories/Services/` | Long-running R4X services |
| Diagnostics | `Repositories/Diagnostics/` | Test and inspection R4X programs |
| Drivers | `Repositories/Drivers/` | Loadable R4D hardware drivers |
| Protocols | `Repositories/Protocols/` | Loadable R4P protocol modules |
| Distribution | `Repositories/Distribution/` | Image plans, overlays, QEMU configuration and releases |

Each canonical module owns a `module.R4MF`, a local `Build.bat`, sources and
tests. `Docs/Inventory/AllModules.json` is the manually maintained overview
of all modules; generated profile inventories describe only a concrete
image.

Installed system layout
-----------------------

R4X programs, R4L libraries, R4D drivers and R4P protocol modules are R4M0
containers. Their target paths are defined by `module.R4MF` and selected by
the Distribution profile. Typical roots are `C:\R4OS\SOFTWARE`,
`C:\R4OS\SERVICES`, `C:\R4OS\LIBS`, `C:\R4OS\DRIVERS` and
`C:\R4OS\PROTOCOLS`.

The exact current module set belongs in the inventory, not in this document.
