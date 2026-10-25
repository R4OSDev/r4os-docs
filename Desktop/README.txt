R4OS Desktop
============

The desktop is an R4X application in `Repositories/Apps/Desktop/`. It owns
window composition, focus, z-order, taskbar, desktop items and user-facing
input dispatch. The kernel provides the privileged display and event
mechanisms but does not own desktop policy.

Complete lifecycle snapshot reuse (0.87.24)
-----------------------------------------
Desktop168 renews its last complete process snapshot when the cheap lifecycle
Begin reports exactly the same nonzero program_epoch. It issues no pages in
that case, including for an empty complete list. The key is the registry's
epoch, not the separate generation of a full diagnostic snapshot. A changed
epoch starts the original bounded acquisition (at most8restarts); only EOF
publishes the staging rows. Begin/Page Busy, failure, invalid/changing cursor,
mixed generation, zero progress or allocation failure revoke both authority
and reuse. Old rows remain visible only. A later equal epoch still requires
a fresh complete acquisition after failure. Current handles and close/reap/
retirement checks are unchanged.

The Tasks dialog keeps its explicit full inventory and250ms cadence; each
due diagnostic capture reads all pages even at an unchanged lifecycle epoch.
Dynamic memory values are not inferred from that epoch. Normal progress still
checks the current epoch on every refresh; it adds no timer, wake or polling
task. Cache validity is the Begin observation, not a promise that no process
can change immediately afterwards; exact process operations retain their own
generation/status validation.

Kernel389 closes three missing publication paths: GUI window bindings (both
handle and ID APIs), console host changes and desktop_requested. A visible
change and epoch increment share Registry admission. Repeating a value does
not invalidate the cache. Window setters retain an exact lease, allocate GUI
storage before Registry, then revalidate the live slot and take Guard(0).
Registry is never acquired while Guard(0) is held. Desktop requests copy the
exact redirected/current console handle before pinning; no cooperative raw
pointer crosses the new wait. Notification occurs after Registry release,
with the target still pinned. The existing input wait shares that handle
selection without changing its keyboard/close semantics.

Publication/activation, close, exit, completion readiness and removal already
advance the epoch under Registry. Role/class/task/desktop-host initialization
precedes publication. Retired rows come from the completion owner, so releasing
private GUI/console payloads does not silently mutate cached live metadata.
No public ABI/SDK change, independent registry mirror or new Kernel subsystem.

Native owner qualification:7Desktop inventory cases,3original geometry cases
and1SDK precise-clock case pass.1000unchanged Begins make no Page calls;
full diagnostic refresh at the same epoch still updates memory fields. Tests
also cover changed/empty snapshots, Busy/restart recovery, invalid/mixed
cursors, partial pages and stale generation lookup. Kernel build/Clippy,
Desktop and Spectra65 builds pass. The focused real KVM4/1GB guest verifies
the exact installed BOOT/Spectra/Desktop and unchanged APPDEF11/CLOCK7 bytes.
CHECK LIFECYCLE /METADATAEPOCH passes both window setters, console host,
Desktop request, same-value stability, atomic old-cursor restart and true
Close/Done/Reap/stale-handle rejection. Its private console and GUI children
finish/reap normally; no repeated global-memory benchmark is embedded.

The original CHECK DESKTOP /HOST /RESTART also passes drag/resize/focus,
idle GUI revision7->7 while CLOCK advances5->7 with137idle timeouts, tray
event/Remove, WINSVC11->13, both fixture completions/reaps, RemoteFrame's
immutable-reader cleanup and exact Desktop completion/reap. All exit codes0,
SMP/CLOCK/LOCK probes pass (4CPUs/12owner classes, no order/stress error),
regular QEMU poweroff0. The initial private image-plan attempt exceeded the
catalog's explicit-include limit before any guest ran; the corrected plan
uses only differences from the automatic Test set plus its2Full fixtures.
No production profile or module catalog was changed for that fixture.

Installed artifact SHA256 values:
  Kernel389 88c22d5d289cdff5030b7cb8809a8e0f475d00f3b5fb9ebb27656019cc8a6635
  Desktop168 80528d142476934b456da3637ff554f160da613624a2423a3fd9e6edee8e2521
  Spectra65 873b55ef45361bbbc8ada347a2264d48de3ecc88022465972f5a8fed97faeead
  Desktop export 423a556137be81754444f0c6c01f7449f8bf7165215842c4ae8ef978208df9da
  Serial 4bf7caa59aa3d42bc5bbc049e8083cb00ddce051b510515360b2f0e8d19dbee1
Exactly one final Suite3 STANDARD, a125cb94-9d07-43e8-8990-f16a83610230,
passes on the same Kernel389/Spectra65 and Release0.87.24 in fresh KVM4.
The unchanged original run.json SHA256 is
13bdabced88b6309096a9996079a10c255d53d30b519a3a473b776d28ffcbee8.
The complete normalized DevCenter readback matches all5metrics/30samples,
4/4workers per sample and6valid score areas. Scores: scheduler36.955472,
memory230.844735, IPC780.387619, lifecycle610.899442, filesystem149.532353,
overall227.406460. This general run has no Desktop: neither the overall
score nor its difference from .23 measures an isolated inventory/GUI gain.
No new physical OssiPC/NVIDIA/input/audio/latency or Windows evidence,
SDK package publication or Full/Slim release is implied.

Monotonic progress and calendar refresh (0.87.20)
-----------------------------------------------
Desktop167 reads ticks and the admitted monotonic clock for each progress
round; Environment::Time carries no calendar. SDK96 exposes the existing
MonotonicClockInfo through Clock::monotonic with the same positive/VALID/
nanosecond-frequency admission as precise_instant. event_requested_hz is
the current logical ticks()/TimeState scale, not a permanently cached rate
or the rounded physical event_effective_hz. No new platform ABI or kernel
artifact; coarse Clock::instant retains its existing separate contract.

The taskbar owner reads calendar and TIME.R4S only at its own monotonic
one-second due. It retains presentation and a deadline, not another
wallclock anchor. Kernel386 owns that anchor (Core/CalendarClock.txt).
Clock setting, date changes and invalidity become visible at the next due;
invalid/unavailable calendars display --:--. Actual R4STD timezone/DST and
12/24-hour formatting remain in use. The activity wait includes the clock
term converted with the current tick rate. Source regression admits a fresh
sample immediately. Scheduling/blocked work can still delay execution;
this is not a physical one-second response-time guarantee.

The SDK C service timeout helper and its existing Rust binding now read the
admitted monotonic event scale directly. Invalid/unavailable sources reject
finite waits; Poll and Forever retain their existing frequency-independent
meaning. No TimeState fallback or assumed constant-frequency cache. Other
calendar consumers and resource/GUI facades remain separate owners.
CNETD2 embeds the same changed C service wrapper; it is an explicit network
diagnostic with IMAGE_SCOPE=none. No new module or runtime background test.

Focused native qualification passes three actual Desktop clock-owner cases,
three original geometry cases and the SDK precise-clock case. A thousand
progress calls before the deadline invoke neither calendar nor configuration
callbacks. Midnight/date jumps, invalid calendars, source regression, live
1000/250-Hz waits and actual R4STD Berlin DST/12-hour formatting are covered.
Original C/Zig service checks and the C-backed Rust service case pass;
17,000,001ns maps to18 ticks at1000Hz and5 at250Hz with no calendar callback.
SDK source evidence and the659-owner-file/35-scope/180-export drift check
belong to SDK/LanguageParity.txt;656 watched inputs remain unchanged.
Both Desktop167 and the explicitly selected CNETD2 build successfully.

The original KVM4 CHECK DESKTOP /HOST /RESTART passes drag/resize/focus,
unchanged idle GUI revision7 with132 activity timeouts while CLOCK advances
5->7, tray event/Remove, WINSVC handle10->12, both child completions/reaps,
RemoteFrame immutable-reader cleanup and exact Desktop completion/reap.
All exit codes are0 and QEMU shuts down normally. Installed BOOT bytes match
unchanged Kernel386 and the installed Desktop matches the final artifact:
  R4DESK SHA256 d2013e823ad5095ade6f37c8520bcebe1501468356af70ee7b2250ff064ca58a
  Kernel SHA256 81952cf82d750dbbd104ef712952fe456be1d0a5eba4b0802cf10b6e4fd3d7d1
  Serial SHA256 b65ccdd47471a9cf1bd74d7dc17afbfbffc847f82a7802c058add2ec4ea5ba73
The private Test guest explicitly includes the two unchanged Full-only
APPDEF11/CLOCK7 fixtures and verifies their bytes before boot. The initial
attempt omitted them; its repeated original export confirms exactly
RequiredFullFixtureMissing with host exit0/cleanup. The runner now exports
before checking ERRORLEVEL. Only the corrected complete check qualifies;
no product code changed to resolve this fixture error. Private images and
source copies are removed after the retained small exports.

One final Suite3 STANDARD355fc176-fdd5-4f4b-8d2a-e06013dda08d passes with
30 raw samples,4/4 workers per sample and6 valid scores (overall207.556011).
The unchanged original run.json, SHA256
ac0a937aa5d270a80a541e81c968c24b9be5405b637990d97b967228c4d2525d,
has a complete matching normalized DevCenter readback and six valid score
areas. STANDARD runs without a Desktop, so this score does not measure the
omitted calendar calls or an isolated GUI speedup. No new physical
NVIDIA/input/audio/RTC evidence, SDK package publication, Full/Slim release
or OssiPC update is implied by these source/artifact changes.

Tray visibility publication (0.87.15)
-----------------------------------
R4DESK0.1.166 publishes tray visibility only when its copied registry or
layout changes, after the current layout has been applied. A receipt binds
the registry revision, provider process/generation, item ID/revision/local
identity and visible state. Geometry-only changes reuse matching receipts.
Unchanged input/GPU rounds make no visibility RPCs. The normal20Hz WINSVC
snapshot/mailbox poll remains available for tray, diagnostics and DESKRUN.

Each changed item invalidates its previous receipt before sending: a timed
out request may already have changed WINSVC. A later layout returning to an
old state therefore cannot reuse an ambiguous old receipt. Confirmed earlier
items survive a later failure. Failed publication remains dirty and retries
at most once per20Hz interval, using the latest layout. A new registry or
service reset invalidates receipts; removed items are never sent again from
the replacement snapshot. WINSVC's existing wire, activation/event ownership
and exact process cleanup are unchanged. No kernel or contract change.

Native owner checks cover unchanged nonempty rounds, partial failure, lost
responses followed by layout reversal, stale registry/desktop/visibility
responses, removal, registration and service reset. They prove RPC omission
and owner behavior; they do not measure physical input or folder latency.

Final native selection shell::tray passes6 Desktop cases,3 original geometry
cases and1 SDK clock case. The original KVM4 software check
SPECTRA CHECK DESKTOP /HOST /RESTART confirms the exact tray event/Remove,
100 drag updates and resize, unchanged idle content and progressing CLOCK,
new WINSVC handle, both child completions/reaps, RemoteFrame cleanup and exact
Desktop completion/reap. Every result succeeds; normal QEMU poweroff exits0.
The installed R4DESK bytes match the final artifact, SHA256
abf91174dc750c349cbdfcf364c7285bfb51f207975f1530629461c85444a383.
The BOOT readback matches unchanged Kernel384, SHA256
d554519cbcc15a13a4dbb1eb013a7df513a3672a563fb4acc147f2958e8552ca.
The private guest and source image are removed after export. WINSVC18 and
Spectra60 are unchanged; public Full/Slim14 and OssiPC12 remain separate.

The host STANDARD runner now regenerates the Test plan before freezing image
inputs: a later Full/Slim plan can replace the shared generated MODULES.JSON.
The first local run22bbfac2-db4d-425e-8ef9-442c692e04ce used that Full catalog
after the functional guest and is not the final qualification or uploaded
comparison. This concrete image-input mismatch requires a corrected final
run; the guest benchmark workloads and scoring algorithm are unchanged.
Direct NTFS readback of the corrected source image confirms the exact current
Test catalog with120 entries before QEMU. No second functional guest is needed.

Final STANDARD aae6db9b-5b13-481f-ad11-e900dc72d75c passes Suite3 with30
samples,4 completed workers each and6 valid scores (overall149.371984).
Unchanged run.json SHA256
799b827fb3203385df02e8b0dd2bbcde93b72d578b2342d892bfe21c26243cdc
was imported into DevCenter; the complete normalized readback matches every
field and all six score areas are valid. This no-Desktop benchmark does not
measure the eliminated tray RPCs or establish a GUI/NVIDIA latency speedup.

OssiPC source and update (0.87.12)
--------------------------------------
R4DESK0.1.164 keeps the provisional1280x720 layout during the native boot-
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

The final same-artifact SNES comparison0.87.12 uses Kernel384/Desktop164/
NVIDIA333 on OssiPC16. Both original five-batch exports and complete DevCenter
readbacks pass, with matching fixed work/state/frame/PCM/geometry. Native
median4.772280697s versus Software3.045325763s remains56.7084% longer;
the native0.87.5 reference was7.572001748s (36.9746% less wall time now).
One actual managed native-GR owner has real completion/visibility receipts;
the original normal native configuration and Desktop return afterward.
Output-backend conditions differ; there is no same-condition score, isolated
GPU causality or new optical/input-latency receipt. The user-confirmed TV
picture belongs to0.87.5. Original data, exact versions and remaining bounds
are recorded once in Diagnostics/SnesBenchmark.txt, section0.87.12.
The current public Full/Slim release is0.87.14; exact package qualifications
are in Deployment/Release08714.txt. The older package sections below retain
their historical scope. OssiPC remains on the qualified0.87.12 artifacts.

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

Local GPU admission budget (0.87.11)
-----------------------------------
R4DESK163 samples its own monotonic entry before presentation/completion
polling. Engine.advance no longer accepts the earlier Desktop round clock.
Input/topology/service work cannot consume the GPU turn's local250us budget;
its initial completion scan does count. The64-step limit, actual absolute
job deadline, hardware/owner Busy and physical Drain/consumer receipts remain.
Budget exhaustion still requests immediate coordinated continuation; actual
hardware waiting does not become productive work or an unbounded yield loop.

The extended original1536-command scheduling case reproduces exactly1 rather
than64 steps before this fix when the round clock is1 and actual GPU entry
is1000001ns. Afterwards it admits64 at a stationary local clock. The original
100us-per-clock case still reaches the time bound, asynchronous hardware and
finite24-receipt-pool cases retain their own waits/retirement. An actual model
completion arriving on the first GPU clock is collected by the introductory
scan; an entry at the original1000000000ns deadline admits no new render job
and drains with Deadline. Seven affected Desktop owner cases plus the three
shared geometry cases and one SDK precise-clock case pass; no original pixel,
resource or deadline oracle was loosened. The artifact builds successfully.
OssiPC installs the completely read-back5158218-byte package (SHA256
385cccb9c1da8bd05c798fd3d7f779ad4a8c1b2b9d893b13d9ef394d63bdc242), then
boots normally with Kernel384/NVIDIA333 and actual native-renderer readiness.
The installed R4DESK163 file matches the built artifact byte for byte; compact
receipt Temp/08711-native-receipt.json. Normal Run-launched Explorer completes
its15 selection/refresh/folder/navigation actions,384 mouse positions and
exact child retirement. Quiet original Desktop check passes with cleanup ACK;
cursor197/197 remains visible/error0, BO allocation/destruction/retained0 and
no stop-work entry. These are finite progress/ownership cases, no optical or
input/folder-latency measurements. Exactly one final KVM4 STANDARD9f4b0978-89ce-43f5-97d9-0490b8206f9f passes
suite3/30 samples/four workers each/six valid scores, overall147.413615.
Original export SHA25671d9d1f5ffb4fdc50b51d4b2b5055a7136859a2c07edd5fccfdeaff5ed22419b,
unchanged full DevCenter readback and all six score areas verified. This
headless phase supplies no physical GPU/input measurement. Kernel384,
NVIDIA333, Explorer27, R4GFX38 and R4NV19 retain their existing versions.

Compatible opaque SDR composition (0.87.12)
---------------------------------------------------------------------
R4DESK164 uses the existing R4GFX38/R4NV19 contracts. It may compose straight
into an XR24 output only when its entire participating layer set is proven
opaque and the output exactly matches the default full-range8-bit sRGB color
description, including white/peak/black, alpha and flags. External images
additionally require XRGB and that same opaque description. HDR, nondefault
profiles/transfers/ranges/precision and unproven/translucent layers keep the
original linear FP16 and output-transform/dither path. The proof is deliberately
conservative: a genuinely opaque shell layer without a complete captured
coverage proof can still retain FP16; a global native performance gain is not
promised by this gate.

Asset conversion records actual opacity per interned source rectangle while
already producing its pixels. A cache hit retains that exact entry's proof;
transparent unused pixels on the same atlas page do not revoke it. Ordered
captured full opaque fills establish layer coverage; over preserves it, an
unproven replacement revokes it. Geometry, overlapping order and exact sample
grids remain unchanged. A separate opaque color view explicitly binds this
proof to R4GFX's native color/alpha validation; a raw electrical-alpha ARGB
resource cannot be relabeled by simply choosing a blit. No R4GFX validator or
pixel oracle was relaxed, and no Library/Contract/Kernel/NVIDIA artifact changes.

The admitted path draws to the existing output images, skips FP16 allocation
and the final encode job, and keeps the original producer/layer/composition/
Present/consumer fence chains. Mode changes wait for the existing physical
Drain, release unused working images and invalidate output generations before
reuse. Both color views retain their actual parent until their own releases.
Precise unchanged-asset and dirty-region staging from0.87.8 remains in force;
there is no new per-frame scan of image pixels or unconditional upload.

Fourteen focused original Desktop cases plus three geometry cases and one
SDK clock case pass. The existing changed-footprint scene keeps every pixel,
unchanged-asset upload and partial-raster oracle while requiring one composition
job per frame (primitive jobs separate), an actual Present and no FP16 image.
The previous path required composition plus encode. A separately translucent
layer returns to FP16 and the independent0xbcbcbc linear-alpha pixel; returning
to opacity releases the workspace and reproduces all64 pixels. Nondefault
transfer/profile flags/white/range deny direct admission. Atlas entry/cache-hit
opacity distinguishes ARGB and XRGB sharing the same page. The existing
original two-reader case now also exercises coherent XRGB/opaque producer
metadata through its actual broker, all four150-scale rotations, pending
producer fences, retained imports, lost Return and exact final zero resources.
The translucent ARGB variant keeps its unchanged0xbcbcbc oracle; opaque XRGB
expects0x808080 from its same underlying bytes. No shader/sample formula or
original deadline/retirement/pixel tolerance changed. External identity grids
use the existing COLOR_GRID operation with zero transform flags and opaque
replace semantics directly into the output, preserving its validated native
color contract. The final artifact build passes; source/versions are frozen.
OssiPC installs the fully read-back5166547-byte package (SHA256
78132874113d1345bb0040add138e6c579cf91266175dfd0187abe2dd468d3e5), then
boots regularly to actual native renderer readiness with164/Kernel384/NVIDIA333.
The quiet original Desktop/Cleanup check passes, no BO allocation/destruction/
retained remainder. Its normal-shell device charge remains98566144 bytes;
no measured whole-shell memory reduction is claimed. The gate retains its
conservative eligibility and no optical qualification is inferred. Software comparison uses explicit GRAPHICS=SOFTWARE and no NVIDIA load line;
all other current configuration bytes are retained. Its2304-position mouse
case and normal15-action Explorer/384-position/retirement sequence pass, as
does the quiet Desktop/Cleanup check. Direct GUI probes now pair guiPushEvent
with desktopActivityNotify, exactly as the existing kernel acceptance caller.
The earlier helper omitted this separate notification: even with an empty
input queue its second selection stayed asleep in software; native GPU wakes
had hidden that harness defect. The corrected helper keeps the original10s
frame oracle and all actions. No product/Kernel/Explorer change was needed.
The matching native2304-position/15-action Explorer/384-position/retirement
and quiet Desktop cases also pass. Both modes have identical per-action
publication counts; first ten actions201commands/31487resource bytes with the
same current full-frame138-command content. The actual native cursor is
1438/1438 visible/error0, BO pending0 and no stop-work entry. Exactly one final
SNES pair is fully read back from DevCenter, with real native owner execution
and exact restoration of the original native configuration. Results and
remaining overhead are recorded once in Diagnostics/SnesBenchmark.txt,0.87.12.
Exactly one final KVM4 STANDARD3a6a43f7-61c0-4e50-9f9b-6841e0f75059 passes
suite3/30 raw samples/four completed workers each/six valid scores, overall
130.333195. Original export SHA256034c6c6b7fa14f2c59af0400919064288a829e6d9038537f469aaf583c8b6618,
unchanged full DevCenter payload readback and all six valid score areas.
BOOT kernel hashd554519cbcc15a13a4dbb1eb013a7df513a3672a563fb4acc147f2958e8552ca
matches Kernel384. No native NVIDIA timing is measured by this headless phase.
Current Full/Slim0.86.94 and Recovery65 remain separate from this source/
remote-update qualification; Windows/HDR/VRR/other receivers are not renewed.

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
