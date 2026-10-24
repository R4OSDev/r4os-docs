R4OS Desktop
============

The desktop is an R4X application in `Repositories/Apps/Desktop/`. It owns
window composition, focus, z-order, taskbar, desktop items and user-facing
input dispatch. The kernel provides the privileged display and event
mechanisms but does not own desktop policy.

Current source and OssiPC update (0.87.10)
--------------------------------------
R4DESK0.1.162 keeps the provisional1280x720 layout during the native boot-
display hold and adopts the actual dimensions through its topology owner.
Its native capture admits an available backbuffer while the visible front
remains retained; preparation, visibility, Engine/Readledger/Session checks
and exact close/retirement barriers remain with their owners. Output-manager
ownership also covers held/retiring targets and known native routes without
a ready layout, preventing a second private native renderer during that gap.
Legitimate software-policy and hardware CPU paths remain available.
The productive cursor coordinator now checks the canonical gfx_output_ok=1.
The Rust port had checked0, forcing software cursor drawing despite available
hardware. The existing cursor owner keeps latest-position coalescing and the
exact clean-frame, image, position and close barriers. The shared0.87.6 proof
and the NVIDIA331 packet/section change with its native/host limits belong to
Repositories/Drivers/NVIDIA/DOCUMENTATION.de.txt.

The existing SNES context records actual composition selection, exact target
and native-owner identity, admitted render jobs and real provider frame
receipts. Lifetime counters include background/warmup work and do not grant
per-window GPU or optical receipts. Stable detail task/raster observations
remain with R4SNES23; the normal path adds no task-observation queries.
The SNES control boundary retains the exact active child and idempotent final
report/retirement acknowledgements with matching Spectra60.

The last SNES comparison0.87.5 used OssiPC Kernel384/NVIDIA326 and the normal
native Desktop; the user confirmed its TV picture. The driver builds its initial
private framepool before optional mode enumeration can consume the first
console-upload deadline. The final SNES run keeps one managed native-GR
choice with real owner completion/visibility, and the normal Desktop returns
afterward. Native remains slower than software in that measured0.87.5 profile.
Original comparisons, exact versions and bounded qualifications are recorded
once in Diagnostics/SnesBenchmark.txt, section0.87.5.
The packaged Full/Slim release described below remains0.86.94.

Incremental GUI work (0.87.8)
----------------------------
Owners: R4DESK162 and EXPLORER27. Kernel384, Contract and R4GFX38 are unchanged.
Explorer publishes selection label/status deltas after a successful complete
frame, at most eight before a complete frame. Scroll, resize, Select All,
menus/dialogs, folder changes and refresh retain complete publication. Failure
preserves the old immutable frame and forces complete publication next time.

The native recorder groups compatible primitives across at most16 disjoint
write footprints, preserving all overlapping/alpha order and exact sample
grids. Resident layer comparison limits raster work to changed old/new command
and asset footprints. Changed command counts may use the existing exact output
damage on the same resident image. Capacity growth preserves the old complete
snapshot. New images, view invalidation and absent damage/snapshots require
full raster work. Staging waits for real retirement; separate layer writers
have separate fence chains. Linear composition joins all primitive completion
before its own ordered writes. External producer/read/consumer leases retain
their exact physical receipts. No parallel GR execution is claimed.

The existing native runner passes20 focused Desktop cases plus3 original
R4GFX geometry and1 SDK clock case. This includes the original GPU/pool/cancel,
FIFO/readback, two-reader/grid/rotation/alpha, GUI-generation and complete-scene
pixel oracles, plus one changed-footprint/count/disjoint-batch gap. Its first
scene needs2 primitive jobs for4 draws; the same image changing one pixel
needs2 draws, an added command inside2x2 damage needs3, unchanged alpha texture
upload stays zero. The Explorer dialog/text owner and both artifact builds
also pass. Native models do not prove a physical frame or latency.

OssiPC was updated through SYSUPD and a fresh regular boot to the final pair,
with NVIDIA331 and actual native-renderer readiness; no restartwake was used.
The same normal Run-launched C: Explorer selection sequence had131 commands
and31221-31225 resource bytes per old full frame. Final ordinary deltas have7
commands and26-30 bytes; the ninth action's bounded full frame still has131/31225. Across
the identical ten actions this is1310->194 commands and312230->31475 resource
bytes, including that full frame. Initial publication and refresh retain the
same complete content. D:/C: navigation produces complete generations; End/
Home produce bounded deltas. Another384 mouse positions and final refresh
complete; Desktop retires the exact new child without forced kill. The final
external observer reports that Desktop reaped first, and does not invent an
Exit receipt it did not observe. The prior unchanged0.87.7 normal GUI case
also passed once readiness meant a published frame, resolving the earlier
revision2 observation as insufficient evidence of a driver stall.

These are publication/work and completion observations. They do not measure
folder-I/O latency, private Desktop GPU timings, TV pixel correctness or input
latency. Original host pixel/geometry/retirement oracles qualify those code
boundaries separately. The quiet original SPECTRA CHECK DESKTOP passes with cleanup acknowledged.
Afterward native state has no fallback error and zero pending allocation,
destruction or retained BO bytes. Complete installed Desktop/Explorer readbacks
match the built artifacts. Hardware cursor234/234 stays visible without an
error; the driver has no stop-work entry. Final KVM4 STANDARD0b7384c3-cb3c-4b69-8677-97e6b4b78bb4 passes suite3
with30 raw samples, four workers each and six valid scores (overall149.286173).
The unchanged original export has a complete DevCenter raw-data readback
with all six score areas valid;
this headless phase measures no physical NVIDIA/GUI latency. No new Full/Slim publication is claimed here.

GPU pacing (0.87.9)
--------------------
NVIDIA332 binds native BO/VA notifications to the existing coalesced pacing
wake and keeps pending cursor/display/RM/native-consumer work out of the
quiet interval. Dormant caches/fronts remain quiet. Kernel384 already wakes
Desktop after exact queue fence/resource publication; Desktop162/Explorer27
are unchanged. Qualification and limits are recorded once in
Repositories/Drivers/NVIDIA/DOCUMENTATION.de.txt, section0.87.9.

Shared BSP work (0.87.10)
------------------------
NVIDIA333 limits each normal owned callback to8 device steps and a soft250us
check between indivisible steps. Boot RAM shadow copies use16KB per phase.
The exact completion and ticket release precede requeue behind other normal
owners. Kernel384, Desktop162 and Explorer27 remain unchanged. OssiPC boots
normally and passes the original Explorer/file-I-O overlap and full GPU/long
mouse/resource-retirement cases. Host owner cases and the one KVM4 STANDARD
with full DevCenter readback pass. Evidence and the observed408109ns budget
checkpoint, including the absence of a hard phase latency promise, are recorded
once in Repositories/Drivers/NVIDIA/DOCUMENTATION.de.txt, section0.87.10.

Current released implementation (0.86.94)
-----------------------------------------
R4DESK 0.1.153 is implemented in modular Rust with no_std and alloc. Its
manifest and Cargo graph belong to r4os-app-desktop; general platform and
library operations remain with the SDK and their original owners. The two
small C companions provide BLAKE3 and compiler floating point intrinsics.
The owner README describes current source boundaries, builds and focused
checks: Repositories/Apps/Desktop/README.md. Migration and subsequent
optimizations are qualified in Desktop/RustMigration08686.json and
Desktop/RustOptimierungen086.json.

Full and Slim 0.86.94 contain this Desktop and start in software graphics:
https://github.com/R4OSDev/r4os-distribution/releases/tag/v0.86.94
Both actual packaged images passed KVM/SMP4 desktop, GUI Terminal/VER and
regular shutdown checks. Historical native/physical qualifications retain
their original artifact and hardware scope. The Windows check was explicitly
skipped by the user; the port does not renew that qualification.

Subsystem launch correction (0.87.1)
-----------------------------------
R4DESK0.1.154 resolves installed /R4OS/... image targets on C: at its
program-start boundary, then uses the unchanged strict SDK FilePath parser.
The Rust port had passed these catalog targets directly to that parser,
which rejects a leading separator without a drive. Explorer requests then
failed before classification or loader admission. BASIC, Game Boy and SNES
shared this regression. MODULES.JSON and ASSOC.R4S retain their contracts;
guest paths and R4SUBSYS1 envelopes remain byte-exact, including spaces.

Desktop keeps path, header-classification, window-capacity, loader and
attachment failures distinct. Only genuine loader errors use the general
loader message. Classification's -1/missing and -2/invalid-header contract
stays separate from process-handle error codes; error reporting performs no
second file classification. The Kernel and subsystem artifacts are unchanged.

Three focused launch-owner cases and the existing association/editor case
passed through the original native SDK provider and RustNative.ps1, with its
shared geometry3/clock1 checks. No full native suite or new runner was added.

Runtime acceptance used the same production artifact in a private KVM/SMP4
Test installation with software graphics, the canonical product ASSOC.R4S
and the generated catalog. Original Explorer Enter opened the DOS Calculator
control and spaced BASIC/GB/SNES guest names. Original owner ROM fixtures
were used; the static GB image was not required to publish changing frames.
SNES continued publishing frames. After closing the first Explorer, a fresh
Explorer's Open With launched a second distinct SNES generation while the
first remained alive. Closing the second preserved the first; both SNES
hosts and the remaining Explorer retired. The owned Desktop completed/reaped with exit0 and
QEMU shut down normally with exit0. No installed catalog workaround was used.

Exactly one final Spectra STANDARD suite3 run on KVM/SMP4 passed:
49aff1c6-abba-4422-8a24-0d4778176c5f. The unchanged original export was uploaded
to DevCenter and fully read back: five areas, 30 raw samples, four completed
workers per sample and six valid score areas. No baseline was changed.

OssiPC received the targeted Desktop R4U through SYSUPD. Post-boot
RESUME-BATCH reported installed; the entire installed R4DESK.R4X matched
the accepted 5136271-byte artifact, SHA256
e5f5994ce8182ce0631252fffdff091679a7a9e4c236a2d7a0c35ad45d0be9fc.
Only its R4DESK record changed in the 109-entry schema4 Full catalog.
Original Explorer opened D:\Roms\SNES\Super Mario World (Europe).sfc:
R4SNES - SUPER MARIOWORLD, exact host27/generation27, with continuing guest
frames. Explorer26/generation26 retired; the game window was left open.
This qualifies real ROM startup/execution, not physical picture or audio
quality, native NVIDIA graphics or an updated emulator. The public Full/Slim
images remain0.86.94; OssiPC's targeted installation is release0.87.1.

Current direct entries are normal startup, /CHECK-ISOLATED, /INPUTTEST and
/HEADLESS-SUBSYSTEM. Former embedded /SMOKE variants are retired; useful
original native/offscreen/pixel/output oracles remain in Tests/Original and
Tests/RustNative. The historical acceptance sections below describe their
original versions, rather than additional current command-line entries.

Explicit functional diagnostics are orchestrated by SPECTRA CHECK DESKTOP
since 0.86.75. Spectra owns its two GUI children, tray item, deadlines,
assertions and completion/reap; Desktop keeps only scene operations and the
productive screenshot worker. The bounded byte contract is
Repositories/Apps/Desktop/Contract/desktop_check_v2.zig, carried by the existing WINSVC
tray exchange. SPECTRA CHECK REMOTEFRAME owns the single public snapshot
oracle; the RFDIAG module/build is retired since0.86.77. /CANCEL tests real
cooperative child cleanup. Restart, master-audio and synthetic-capture
variants require an explicitly isolated Desktop boot. Checks return to their
caller. Protocol, migration boundaries and qualification are documented once
in Docs/Diagnostics/Spectra.txt.

Since 0.86.76, SPECTRA BENCH DESKTOP runs the original software-output RAM
fixture, and SPECTRA BENCH SNES /WINDOW controls the existing SNES-v2 owner
through the same bounded Desktop/WINSVC channel. Desktop prepares the exact
Small or Maximized geometry before attaching the owned SNES process and
records its actual copied generations. Spectra waits for real completion
and reap without sampling IPC during the workload. Original owner JSON,
global presents, copy receipts and unknown physical visibility remain
distinct. /OWN-DESKTOP explicitly creates and closes only an otherwise
absent private host; ordinary commands return without powering off.
The original generation trace stays in the structured Desktop JSON report;
the redundant SNES-PRESENT.TXT writer and Desktop PERF forwarders are retired
since0.86.77. No removed marker or executable is needed by the current host.
The native Core benchmark remains in the SNES host runner. Measurement
contracts and qualification are in Docs/Diagnostics/Spectra.txt and
Docs/Diagnostics/SnesBenchmark.txt.

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

Output-selection hit targets, automatic mode and volume/mute preservation
retain their original owner oracles in Tests/Original and Tests/RustNative.
The current explicit master-volume/mute/restore check is SPECTRA CHECK DESKTOP
/AUDIO and requires an isolated host. There is no current standalone
/SMOKE-AUDIO-OUTPUT entry.

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
the prefix origin and Dirty together. Atomic save replacement is described below for 0.78.69.

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


Document saving (0.78.69)
--------------------------
Notepad 0.1.11 and Paint 0.1.7 share the SDK document_save.Saver policy.
Save and Save As first create a private 8.3 sibling (DSxxxxxx.TMP), write
bounded chunks and confirm the final stream flush. Only then does the
existing Files.replaceAtomic facade publish the target. An old document is
never passed to fileWrite. Path, Dirty and recent-file history change only
after confirmed replacement. A truncated Notepad load also requires the
target to remain absent at the atomic publication boundary.

A failure before replacement aborts only the exact owned stream. An
unconfirmed replacement retains the stage and backup for recovery, while
the app keeps its edited document. A confirmed save with failed backup
cleanup stays successful and reports the retained backup. The temporary
names remain in the target directory; there is no direct-write fallback.
Existing FAT long names can be replaced, but creation of a new FAT long
name is not supported by the current atomic storage primitive. Such a
request fails without falling back to an unsafe overwrite.

One host case injects a single short stage write and checks unchanged
Notepad text, selection, path, Dirty and pending history, no replacement,
and cleanup of the owned stage. One short SMP4 console probe calls the real
Notepad methods on private FAT files and the real Paint methods on private
NTFS files: Save and Save As over existing targets, exact saved bytes,
metadata and sibling cleanup. It also confirms fresh Save As of a Notepad
prefix through the create-only atomic path. Both product modules build.


Historical contract cleanup and diagnostic handoff (0.86.73)
----------------------------------------------------------
Desktop138 removes the three preparation_query/preparation_busy_queries/
preparation_changed_queries fields: the current full owner/caller search
found only declarations and writes. presentation_info, exact Busy/geometry/
device/reset identities, the original deadlines and retirement stay operational.
No speedup is inferred from fewer fields or source lines.

Current R4SYS service_open/call/close, R4DESK remote_frame_publish_regions and
R4DRAW display_blit_xrgb32_stride are required before the process handle is
opened. Host admission checks the complete current WINSVC color exchange for
the exact generation, with nonzero initial revision and no active output/mode
request. Unknown color opcode is a clear failure. The old color truncation,
missing-region full-frame substitute and missing-stride row-loop substitute
are removed. Real full snapshots after a valid delta failure, software/bootfb,
optional native backends, reconnect/retry and exact cleanup remain supported.

The33 Desktop inventory entries of that version retained their useful scope.
At that stage, /SMOKE and /SMOKE-R4X exercised menu/app/terminal lifecycles
against the then-current Full paths; /SMOKE-KLICKIFAX additionally needed
the on-demand browser explicitly staged. Those embedded entries were later
retired by the Rust migration; they are not current startup options.
The general window/idle check is now SPECTRA CHECK DESKTOP and requires
Full-only AppDefaults and CLOCK.R4X; Test omits both. CLOCK is its timer
producer. The77 handoff temporarily retained /SMOKE-WINDOW-IDLE only for
distinct native /OUTPUTS, /CURSOR, /SWAPCHAIN or /SCREEN-POWER purposes.
Their useful original assertions now remain as owner oracles.
The SDK APPZCON /TRAYSMOKE path stays because it checks the console facade
and an intentionally abandoned item after real process exit and WINSVC sweep;
the common Spectra tray event/Remove check does not replace that assertion.

Live HEADLESS-SUBSYSTEM, Terminal INPUTTEST, normal SNES-v2 Small/Maximized/
OutputAnalysis readers and existing pixel/generation/Busy/lifecycle/native
reference oracles remain. SPECTRA BENCH DESKTOP controls the original explicit
background comparison, including productive coverage metadata and independent
original painter pixels. SPECTRA BENCH SNES /WINDOW controls the fixed v2
owner plus exact JSON generation trace; Core retains its native host runner.
Those current commands replace removed /SOFTWARE-PROFILE-/PERF names for
Rust and later cost comparisons. The current handoff is Spectra.txt/77.

Only13 completed0.79.44 run-output files/140677Bytes were removed from Desktop/
Distribution Tests/Reports. The professional summary/hashes in existing
GrafikIntegration07944.txt/.json remain historical; no new archive copy.
The coordination owner also refreshes its ModuleCatalog through the selected
cache-aware SDK build, avoiding stale admission after grammar changes.
Final acceptance: existing render-test and normal Desktop138 build exit0.
A private normal Full/KVM4 /SMOKE-WINDOW-IDLE confirms current slot/color
admission, exact drag/resize geometry, two producers, empty idle, WINSVC
restart/reconstruction, color/ICC/shared-CMM pixels, resources and cooperative
Close, then regular POWEROFF/actual QEMU exit0. The final guest image's
R4DESK bytes equal the normal artifact, SHA256
d3d635c9fea5bd47916f8d4b1a742898439183159615bca995eaf97c2d55b1f8.
BOOT equals unchanged Kernel381/e06111b9363b44712fe69ded9ddfc3edb1f60c5c271c59a42238a816b0882340.
The initial probe caught a missing nonzero status revision in the new startup
mailbox; fixed before final acceptance. Another attempt used Test without
Full-only actors; the final scenario uses the correct profile. No success
or clean stop is attributed to the failed startup attempt.

Exactly one final normal spectra-standard-3 SMP4:
2e186a4a-5fa4-4bb1-9ccb-cc9c3aae6415, unchanged run.json SHA256
fe517f268f034c99bd83a7d367f6cb79a9971273b81ebda5f6f0f46f25c46f11.
DevCenter PUT201 and full normalized GET agree on every payload field,
all5metrics/30raw samples/6scores; all six score areas valid. STANDARD uses
its original no-Desktop boot contract and is no isolated Desktop speed claim.
Product73/Desktop138; Kernel381/SDK90/Libraries27/Spectra50 remain. Reports,
metadata, inventory and root cached-catalog fix belong to their owners;
completed guest/image/source copies removed. Full/Slim42/OssiPC unchanged.
Handoff to Spectra74–77: retain the listed current assertions/owner oracles
until qualified replacements exist; Rust86 receives that released scope.
