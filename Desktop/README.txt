R4OS Desktop
============

The desktop is an R4X application in `Repositories/Apps/Desktop/`. It owns
window composition, focus, z-order, taskbar, desktop items and user-facing
input dispatch. The kernel provides the privileged display and event
mechanisms but does not own desktop policy.

R4DESK is the public window and desktop group. R4DRAW is the drawing and
raster group. Applications request only the groups they use and guard
optional functions with `hasFn`.

Desktop links are visible `.LNK` files under `C:\R4OS\DESKTOP`. Layout is
stored in `C:\R4OS\CONFIG\DESKLAY.R4S`. Application resources, including
program icons, normally live in the application's R4M0 container.

Notification area
-----------------

R4DESK owns the notification area's visual mirror, layout, rendering, damage
tracking and input dispatch. Providers never draw into the taskbar and a tray
item is neither a window nor a separate process. Providers use the versioned
tray operations on the existing `WINSVC` userland endpoint through the public
SDK facade. WINSVC only copies the bounded provider state and mediates events;
there is no kernel tray API and no separate tray service module.

The clock remains at the far right. Desktop-owned system entries are placed
immediately to its left and external entries farther left in stable
registration order. The first contract supports at most 16 registered items,
has no overflow menu and preserves system entries under space pressure by
hiding external entries deterministically. Window buttons use only the space
left of the resulting area.

Every item is identified by the provider's exact process generation and a
provider-local nonzero ID. An update carries a monotonically increasing
revision, status and visibility flags, a bounded UTF-8 tooltip, and one copied
16x16 straight-alpha ARGB32 icon. WINSVC publishes only complete revisioned
snapshots to the exact Desktop generation; stale revisions and identities
cannot replace newer state. Process exit/reap removes all items and queued
events for that generation. A Desktop restart starts a new epoch with an empty
broker registry, so providers detect the changed epoch and register their
current state again.

Primary, double, context and wheel activations are delivered as monotonically
sequenced bounded events. A click is accepted only when press and release hit
the same still-current item identity. Each owner may have one finite event
wait; a full queue reports dropped events without blocking the Desktop.

Subsystem guests use the same hosted GUI windows as applications. Explorer
resolves a guest file to a stable installed subsystem ID and sends an
`R4SUBSYS1` request; R4DESK only starts and hosts the resulting independent
R4X process. Video, input, guest time and audio remain owned by the subsystem
process and its SDK host/runtime layers, so two guest files have distinct
window, process and runtime state.

The headless product acceptance exercises this boundary for R4GB through the
same installed catalog, ID-only `.gb`/`.gbc` associations, bounded probe, Open
With selection, and `R4SUBSYS1` launch used by Explorer. Two generated free
cartridges run concurrently with separately focused physical keyboard input,
video, App-Audio, battery SRAM/RTC persistence, and cooperative Close. A third
CGB-only fixture must expose its concrete rejection in a valid hosted window
before it closes. The test never opens a commercial ROM.
