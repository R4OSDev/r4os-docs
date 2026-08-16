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
