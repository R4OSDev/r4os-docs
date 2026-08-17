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

Subsystem guests use the same hosted GUI windows as applications. Explorer
resolves a guest file to a stable installed subsystem ID and sends an
`R4SUBSYS1` request; R4DESK only starts and hosts the resulting independent
R4X process. Video, input, guest time and audio remain owned by the subsystem
process and its SDK host/runtime layers, so two guest files have distinct
window, process and runtime state.
