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
DriverApi 19 additionally maps existing resident buffers into at most 64 hard
DMA segments with explicit coherent/streaming ownership and bounded bounce
fallback. Drivers whose descriptors cannot address above 4 GiB must use an
inclusive maximum address of 0xFFFFFFFF instead of truncating an unrestricted
address. Mapping teardown precedes pin teardown and both are owner- and
generation-checked.

StorageBackend 2 separates nonblocking submit and exact completion. Cancel is
advisory; only completion or a successful quiescing reset releases an accepted
buffer. The block core owns waiting slots and ordered flush barriers, while
`queue_depth` limits actual hardware in-flight requests. Old and null-submit
backends remain synchronous at depth one.

MSI allocations are owner-tracked by the kernel and are disabled before IRQ,
work and DMA owner cleanup; drivers still stop their hardware and explicitly
release MSI on normal shutdown. A failed hardware stop, active storage request
or work join vetoes resource release and leaves the owner quarantined.

Boot-critical memory, interrupt, early display and storage paths remain in
the kernel until a proven preload or early-load path exists. Once a loadable
driver owns a non-critical production path, a parallel built-in fallback must
not remain silently active.

XHCI.R4D is the activation and registry owner of exactly one kernel-resident
xHCI implementation. The module owns no parallel PCI/MMIO/DMA path. Only when
that activation is absent may the kernel start one built-in fallback owner.
DriverApi v21 and UsbHostController v2 make port, control, bulk, interrupt,
reset, clear-halt and poll/completion operations productively dispatchable.
The host status reports capabilities, queue depth, maximum transfer size,
active transfers, completions, IRQs, poll fallbacks, cancellations and errors.

The canonical xHCI path frees per-slot DMA only after a successful Disable
Slot or after the whole controller is proven halted. Partial allocations are
rolled back immediately. Reprobe and unload first mask the event interrupt,
halt the previous controller, clear its DMA registers, free retained runtimes
and controller rings, and restore the PCI command. A failed halt retains the
old resources and vetoes reprobe or unload.

Root-port changes have one controller-owned runtime path. Port Status Change
Events are drained even when no command or transfer is waiting, retained in a
per-port pending set, then acknowledged only after targeted debounce, slot
reclaim and optional re-enumeration. Repeated events for the same port are
coalesced with counters instead of being reported as stale completions. USB-HID
bindings are reconciled from the resulting USB device catalog.

After scheduler start, the shared event ring is woken by the cached legacy
INTx route and drained outside IRQ context. A bounded 10-ms poll remains the
fallback for missing routing and deadlines. Up to 32 generation-safe transfer
objects bind the exact slot, endpoint and TD pointers. HID may therefore keep
one interrupt transfer pending while USB storage owns another endpoint.
Bulk transfers use page-bounded TRB chains up to 64 KiB; a chain crossing the
producer wrap carries ownership through the Link TRB.

USB keyboards publish only through the canonical input queue. The HID poller
does not own a second character ring and pauses before accepting a report until
the complete worst-case decoded report fits. Queue fill, high-water and drops
remain visible through the input diagnostics.

Drivers are fully trusted. PCI/MMIO/port access is validated for obvious
technical errors only. A faulty driver can still crash or corrupt the system.
