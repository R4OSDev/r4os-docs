R4OS Desktop
============

The desktop is an R4X application in `Repositories/Apps/Desktop/`. It owns
window composition, focus, z-order, taskbar, desktop items and user-facing
input dispatch. The kernel provides the privileged display and event
mechanisms but does not own desktop policy.

Since 0.78.8, Desktop keeps one WINSVC endpoint handle for window and tray
operations. Drag/resize changes retain the latest geometry and publish it at
bounded 50-ms intervals; release publishes the final pointer position
immediately. Lifecycle operations supersede pending geometry, and removal
cannot carry a pending record into a reused window slot. A failed endpoint
call drops the handle and both mirrors; an idle retry opens the new service
generation and registers all live windows before restoring tray state.

Idle waiting follows the actual tray, clock, blink and retry deadlines.
The normal tray interval remains 50 ms; a valid revision no longer forces
10-ms sleeps. Clock reads are capped at once per second, with immediate
refresh after a timezone/format change. AppDefaults, Appearance,
DeviceManager, Explorer, LogCenter, NetConfig, Services, TimeSettings,
MemView, R4Code, Notepad and Paint use the SDK EventLoop. Only MemView and
LogCenter's enabled live view retain a one-second refresh timer. Shared
desktop activity can still wake unrelated windows; no timer-free app adds
its own periodic polling deadline.

The focused 0.78.8 SMP4 check covers final drag/resize coordinates, the stale
endpoint after WINSVC restart, re-registration and immediate Close of both
AppDefaults and MemView. In its two-second idle interval, AppDefaults kept
its frame revision while MemView advanced; Desktop recorded 46 activity
timeouts. The host burst fixture publishes 100 positions with 17 geometry
calls and one held connection instead of 100 open/call/close sequences.

R4DESK is the public window and desktop group. R4DRAW is the drawing and
raster group. Applications request only the groups they use and guard
optional functions with `hasFn`.

Desktop links are visible `.LNK` files under `C:\R4OS\DESKTOP`. Layout is
stored in `C:\R4OS\CONFIG\DESKLAY.R4S`. Application resources, including
program icons, normally live in the application's R4M0 container.

Notification area
-----------------

The system-volume popup also offers audio output selection (R4DESK 0.1.39 /
AUDSVC 0.1.9). It shows the active output, saved preference, availability and
fallback reason. Four device rows are visible at once; arrow buttons page
through the list. Unavailable receivers remain visible. Automatic clears
the preference and lets AUDSVC choose a connected supported HDMI receiver
or an available analog output. Volume and mute remain independent controls.
Saving and persistence failures are shown in the popup. Device state is
refreshed only while the popup is open, using the existing volume poll.

The bounded /SMOKE-AUDIO-OUTPUT path reuses the volume contract check and
exercises real popup hit targets, selection through AUDSVC, automatic mode,
and preservation of volume/mute before shutting down. It is intended for a
private SMP4 image with two available HDA outputs.

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

The same acceptance now covers R4SNES through ID-only `.sfc`/`.smc`
associations. Because those formats have no universal fixed-position magic,
catalog selection performs one metadata lookup and zero content reads; the
R4SNES process remains the sole full-image validator. Two original generated
cartridges run concurrently for at least 60 seconds of guest time with all
twelve physical port-1 keys, native XRGB32 generations, SPC700/S-DSP
App-Audio, SRAM/Epson-RTC persistence, pause/resume/reset/mute and independent
witness/close endings. Invalid-header and missing-DSP-firmware fixtures remain
visible in hosted error windows before cooperative teardown. Private SMW data
is never opened by this automatic path.

Directory views (0.78.26)
-------------------------
Explorer selects each globally ordered page from the entire typed directory
enumeration, with at most 64 retained entries. Next/previous use the boundary
entry in the selected name/type/size/date order; full paths break equal-title
ties. Name/type scans load full file information only for the visible page.
A new sort starts at the first page. Refresh retains the selected path when
present. Failed enumeration or required sort metadata keeps the old view.

Appearance, Notepad, Paint and R4Code use the shared SDK dialog page, keeping
93 files/directories plus parent and navigation rows. Each row owns its path
and kind; selection performs no second enumeration. Appearance filters BMPs
through the full directory. A failed page leaves directory and selection
unchanged. Terminal DIR and HELP /S visibly report incomplete enumeration and
return failure instead of treating an I/O error as normal end.

Desktop captures directory changes before its first folder load. The normal
activity wait wakes on mutations; a RAM-only cursor check coalesces changes.
The folder is reloaded only after a change, outside active pointer/drag and
modal actions. Complete loads retain selected paths and in-session positions,
reset old double-click targets and replace the item array together. Failed
loads preserve it and show an error once; another change can retry. The
existing 32-icon display limit remains; enumeration still reaches the true
end so an error beyond those icons cannot publish a partial view.


APPDEF: Bestand und Speicherergebnis ab 0.78.63
---------------------------------------------
ASSOC.R4S wird vor dem Einlesen ueber R4STD CONFIG_V1 wiederhergestellt.
Fehlende und leere Dateien aktivieren Defaults; ein Lese-, Groessen-, Format-
oder Wiederherstellungsfehler sperrt Speichern bis zum erfolgreichen neuen
Laden. Die App importiert CONFIG_V1 jetzt ausdruecklich. OK verwendet
saveDocument statt direktem Ueberschreiben und ungeprueftem Rueckbau.
Bei Fehler bleiben Fenster und Aenderungen offen. Eine ausstehende
Wiederherstellung wird als solche angezeigt, nicht als abgeschlossen.

Appearance: Konfiguration ab 0.78.63
---------------------------------
Vor einer Aenderung von DESKTOP.R4S wird R4STD-Recovery abgeschlossen und
der wiederhergestellte Inhalt gelesen. Lese-/Groessenfehler verhindern das
Speichern. Die vier Appearance-Werte werden gemeinsam komponiert; andere
Schluessel wie TASKBAR_CLOCK und UI_FONT bleiben erhalten. Publikation
verwendet weiterhin R4STD CONFIG_V1 saveDocument.

Desktop-Defaults ab 0.78.63
-------------------------
Desktop- und Zeitkonfiguration werden beim Start zuerst wiederhergestellt.
Nur ausdruecklich fehlende Dateien erhalten neue Defaultdateien. Leere,
nicht lesbare, zu grosse oder ungueltige vorhandene Dateien werden dabei
nicht ueberschrieben; der Desktop behaelt seine Arbeitseinstellungen und
meldet Fehler. Neue Defaultdateien verwenden R4STD CONFIG_V1 saveDocument.

APPDEFs vorhandener /SELFTEST verwendet nur vorher abwesende private Dateien
C:\TEMP\APPDEF.R4S/.TMP/.BAK und meldet OK erst nach erfolgreicher
Bereinigung. Die kanonische ASSOC.R4S bleibt auch bei Lesefehlern unberuehrt.
Der bereits vorhandene BAS-Default wird im Test wiederverwendet.


Notepad document loading (0.78.68)
----------------------------------
Notepad0.1.10 retains the origin of a truncated load across typing, cut and
paste. Direct Save remains blocked. Save As can turn this prefix into a new
document only at a missing target; an existing file, alias or failed target
lookup is rejected. Successful creation publishes the new path and clears
the prefix origin and Dirty together. Ordinary save replacement is addressed
separately in0.78.69.

Loading stages at most32KB of source bytes, including a one-byte EOF probe,
before changing the visible editor, path, directory, Dirty or prefix state.
It does not infer completion from optional file metadata. Any read failure
preserves the old document including selection, view and pending recent-file
state. Discarding a save prompt before opening another file does not mark the
old document clean while the new file is still unconfirmed. Only successful
load, New or a successful Save As to a fresh file resets load provenance.
Counting raw input also bounds files made of filtered text-control bytes;
the normal editor retains its32KB buffer with32767 usable text bytes.

Three focused host groups cover editing and Save As guards, a failure after
the first512-byte read, state preservation, normalization and the exact EOF
boundary. A short SMP4 console probe uses the actual document methods with
a private40000-byte file, checks the retained full original and fresh copy,
and verifies a failed subsequent open. No manual visual check or large
editor/graphics profile is required.
