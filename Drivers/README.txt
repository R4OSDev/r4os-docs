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

DriverApi 17 adds address-constrained DMA regions and explicit MSI rollback.
Drivers whose descriptors cannot address above 4 GiB must request a maximum
physical address of 0xFFFFFFFF instead of truncating an unrestricted address.
MSI allocations are owner-tracked by the kernel and are disabled before IRQ,
work and DMA owner cleanup; drivers still stop their hardware and explicitly
release MSI on normal shutdown. A failed hardware stop or work join vetoes
resource release and leaves the owner quarantined.

Boot-critical memory, interrupt, early display and storage paths remain in
the kernel until a proven preload or early-load path exists. Once a loadable
driver owns a non-critical production path, a parallel built-in fallback must
not remain silently active.

The built-in xHCI path frees per-slot DMA only after a successful Disable Slot
or after the whole controller is proven halted. Partial allocations are rolled
back immediately. Reprobe first halts the previous controller, clears its DMA
registers, frees retained runtimes and controller rings, and restores the PCI
command; a failed halt retains the old resources and rejects the reprobe.

Drivers are fully trusted. PCI/MMIO/port access is validated for obvious
technical errors only. A faulty driver can still crash or corrupt the system.
