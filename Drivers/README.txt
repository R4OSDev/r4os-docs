R4OS Drivers
============

Loadable drivers are independent R4D repositories under
`Repositories/Drivers/`. Current storage, USB, network, audio and synthesizer
drivers are listed in `Docs/Inventory/AllModules.json`.

An R4D driver is an R4M0 module with `DriverInit` and `DriverShutdown`
exports. It imports the R4DEV driver interface, registers its backend and
owns its hardware resources. Runtime cleanup tracks IRQ, deferred work, DMA
and registered backends, but this is a stability mechanism rather than a
security boundary.

Boot-critical memory, interrupt, early display and storage paths remain in
the kernel until a proven preload or early-load path exists. Once a loadable
driver owns a non-critical production path, a parallel built-in fallback must
not remain silently active.

Drivers are fully trusted. PCI/MMIO/port access is validated for obvious
technical errors only. A faulty driver can still crash or corrupt the system.
