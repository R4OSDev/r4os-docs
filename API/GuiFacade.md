# GUI facade

R4DESK supplies window, input and desktop operations; WindowService and the
Desktop coordinate exact window identity and lifecycle. Controls and dialogs
belong to the SDK. R4DRAW supplies drawing, text, images and frame commands.
The GUI facade combines them without hiding group availability.

## Lifecycle

A normal GUI host creates and binds the window before R4X entry. The hosted
application opens its facade, polls or waits, draws in the paint/frame phase
and returns normally for host retirement. A Desktop host has a separate role
and does not need a pre-existing application window.
Window IDs and event payloads are borrowed observations; application-owned
state remains in the application.

Hosted applications use the complete client width and height reported by the
desktop for their window metrics, layout and Canvas. An application may enforce
a functional minimum, but must not clamp the reported size to a fixed maximum
such as 1600x1000. Resize and maximize events must update those metrics so the
content can fill the client area at Full HD and larger desktop resolutions.

Controls, menus, dialogs, clipboard and timers are optional capabilities.
The application checks the corresponding field before use. Failure to create
or draw remains a visible typed result.

## Threading

Windows, event dispatch and drawing are owner-thread-only. Worker threads may
prepare application data but must hand it to the UI thread before mutating a
window or frame. The desktop activity producer publishes its state before
signalling the wait queue so wakeups cannot be lost.

## Buffered Canvas frames

Draw-heavy GUI applications should attach a caller-owned `FrameCanvas` to an
open `PaintContext`. Existing `Canvas` controls and widgets then use the
buffer automatically; individual clear, rectangle, text, raster, Alpha8 and
prebuilt shape operations do not need app-specific batch logic.

```zig
var paint = switch (window.beginPaint()) {
    .paint => |value| value,
    .failure => return,
};
defer paint.discard();

var commands: [64]r4os.abi.GuiFrameCommand = undefined;
var resources: [8 * 1024]u8 = undefined;
var frame: r4os.FrameCanvas = undefined;
const canvas = paint.bufferedCanvas(&frame, commands[0..], resources[0..]);

_ = canvas.clear(0xC0C0C0);
_ = canvas.button(.{ .rect = button_rect, .text = "OK" }, scratch);
_ = paint.present();
```

Both slices and the builder remain owned by the caller and must live through
`present()` or `discard()`. Full buffers are flushed as bounded
`gui_frame_append` chunks. Resource offsets are rebased per chunk, XRGB words
are normalized and strided Alpha8 masks are compacted. A resource too large
for the provided scratch buffer is submitted through one ordered direct
chunk, or through the established single-operation path where conversion is
required.

Commands without resource bytes always use `resource_offset = 0`, even after
text or raster commands have advanced the batch resource cursor. Inheriting
that cursor would make the command invalid and discard the entire frame.

All chunks remain private until the `PaintContext` commits. The first append,
conversion or commit error is latched and cancels the complete transaction;
no successful prefix becomes visible. Since SDK0.64.91, Zig and C beginPaint
also require all six current frame callbacks, matching the shared Rust/C
window-paint entry. A missing callback refuses admission; no older
paint/present transaction is synthesized. Direct current drawing operations
inside an admitted transaction and explicit immediate FrameCanvas use remain.
`Canvas.frameCommand()` lets a prebuilt `gui_shapes` resource participate in
the same ordering; shape commands require the current frame contract.

`FrameCanvas.stats` reports logical commands, resource bytes, buffered
flushes, direct chunks, append calls, legacy calls and failures for that one
frame. `drawTransitions()` and `frameMutationEntries()` count the actual draw
ABI entries, excluding begin, commit and present. These counters are passive
and add no platform call.

## Text layouts and truncation

`textAreaLayout` traverses the current document once and returns at most 128
visible row ranges, the caret position and both scroll extents. Drawing uses
those ranges directly. Notepad shares the same result with its scrollbars;
TextArea uses one traversal for cursor visibility and scroll clamping.
The result belongs to that text, cursor, wrap width and viewport only. It is
recomputed after edits or geometry changes, so no persistent line cache needs
invalidation. R4Code delegates visibility updates to TextArea; clipboard cuts
explicitly update it once.

Ellipsizing measures complete UTF-8 candidates including the three periods.
It uses a binary search within logical lines under R4DRAW's nonnegative
rendered advances and treats newline boundaries separately. Proportional
widths and spacing between the retained suffix and periods remain in the
measurement. Even a partial ellipsis is measured, avoiding oversized periods
when only one or two fit. UTF-8 boundary lookup examines at most four bytes.

The bounded host fixtures compare row ranges, caret and scroll extents with
the previous helpers, including wrapping, editing and malformed-byte fallback.
A 65535-byte document requires one 65535-byte traversal for a rendered layout,
plus one for edit visibility. The 256-character clipped-label fixture requires
11 font measurements and measures 797 bytes, versus 258 calls previously.
These are work counts, not frame-rate measurements.

## Shared raster resources

R4DRAW v9 optionally exposes generation-bound shared XRGB32, Indexed8 and
Alpha8 resources. A producer creates one bounded resource, maps a currently
free backing buffer, fills it and publishes an immutable generation. Frames
refer to that generation through fixed descriptors instead of copying the
pixel payload into frame storage. A consumer acquires every distinct
generation before publishing its own snapshot and releases the exact lease
after replacement.

The SDK exposes the six operations without hiding ownership or capability
checks. `r4os.subsystem_host` uses three backing buffers and falls back for
the affected frame to the established copied representation when the v9
slots are absent, allocation fails or all buffers remain referenced. Destroy
closes future writes; process teardown, replacement and reader release retain
immutable bytes until the final frame or lease reference disappears.

The complete function tables are in `R4DESK.md` and `R4DRAW.md`; frame shape
serialization is summarized in `GuiShapeContract.txt`.

## Shared C and Rust access

SDK0.64.75 exposes the same GUI, text/input, widget/dialog, shape/chart,
Canvas/FrameCanvas and clipboard owners through `<r4os/gui_bridge.h>` and
Rust `gui`/`gui::raw`. Compiler reflection supplies typed calls, native opaque
storage, field/union access and a checked layout/dispatch fingerprint. There
is one widget/Unicode/raster implementation. Float data crosses by pointer;
this does not qualify a new Rust scalar floating-point ABI.
The new window-paint entry requires current frame callbacks. Missing whole-
glyph/revision callbacks remain unavailable and zero revisions remain zero;
explicit immediate FrameCanvas work and missing fonts keep their own meaning.

Rust `gui::Session` pins caller-owned storage and borrows timers. `Paint`
exclusively borrows the session and scratch buffers until commit or discard;
dropping it cancels. Semantic `EventKind` differs from raw `GuiEventKind`.
Borrowed `TextField`/`TextArea` and input queues execute the same algorithms
as Zig's fixed arrays. Raw native storage remains `MaybeUninit` in Rust;
padding and inactive union bytes must not be read as initialized data.

`Role::DesktopHost` and C role1 admit without querying an app window. The
technical host claim validates the exact process generation and WINSVC epoch.
Transport failure closes the endpoint; reopening is explicit. Closing that
connection does not revoke the live process's host binding. Desktop startup,
output recovery and retry policy stay with the application. Native graphics
queue/output facades are a separate group. Usage and qualification limits:
`../SDK/LanguageParity.txt` and SDK `Rust/README.txt`.
The native process-inventory class byte uses 0/1/2; R4XStart class values use
1/2/3. Host eligibility follows the exact WindowService process view.


Grafikintegration 0.79.44
-----------------------
Der gemeinsame Fensterweg bleibt R4DRAW/PaintContext mit begrenzter FrameCanvas,
WINSVC und Desktop. SDK/Examples/Canvas.zig zeigt einen vollständigen Einstieg.
Native Fensterbilder, EGL/Vulkan, Ressourcenbesitz, Fehlerbehandlung und aktuelle
Softwarekosten sind in ../Desktop/GrafikIntegration07944.txt zusammengeführt.

## Native pointer capture and physical mouse-look (0.88.28)

Functional source and private-guest qualification is recorded below. Physical
input/display/hardware and Windows qualification remain explicitly separate.

R4DESK19 appends four callbacks after the unchanged 584-byte v18 prefix (new
size616): gui_pointer_capture_info, gui_pointer_capture_acquire,
gui_pointer_capture_release and gui_pointer_capture_host. GuiEvent remains
40bytes; raw kinds0..12 retain their values. Appended kinds13/14/15 carry wheel,
physical relative motion and reliable capture-state changes.

The Desktop owns routing, focus/WM arbitration, cursor policy and display
coordinates. Native support supplies exact identity, nonconsuming physical
motion snapshots, terminal receipts and lifecycle cancellation. WINSVC keeps
its existing window/frame role. There is one pending or active capture for the
registered Desktop process generation; no task, image, frame or VM pointer is
retained by the capture token.

A GuiPointerWindowIdentity binds the complete process handle (including its
64-bit generation), native window incarnation epoch and window ID. A
GuiPointerCaptureHandle adds a nonreused 64-bit serial. The caller obtains and
retains its intended window identity before requesting capture; an old token
cannot release or replace a newer lease. Querying a fresh identity after an
explicit window rebind deliberately selects that new incarnation. Repeated
release of the exact last terminal token succeeds without changing a newer
capture. Other stale/foreign identities fail, without changing output buffers.

Acquire returning0 accepts PENDING. The Desktop checks the exact live client,
visibility, minimize/close state, keyboard focus, blocking shell UI and a
competing WM drag/resize before GRANT. Only the matching ACTIVE notification
starts captured input. A pending request can be rejected by these checks;
acquire is not an activation or exclusivity claim. Capture does not prevent
keyboard focus changes. Native focus loss, window detach/close/minimize,
process exit and Desktop/WINSVC changes terminate the exact lease. Additional
cancel reasons distinguish WM conflict, unsupported input source and input
queue overflow. Applications clear held interaction state on cancellation.

DRAG routes motion and button changes to the captured client even outside its
client rectangle or above another window. Signed client coordinates can be
negative. Source packets are delivered in motion/down/up/wheel order, retaining
Up when wheel data is in the same packet. Physical and remote button histories
remain independent; releasing one source does not release a button still held
by the other. The application explicitly releases capture, normally after Up.

RELATIVE supplies wrapping-difference physical dx/dy from the PS/2/USB motion
sums before output/desktop clamping, with no OS pointer acceleration or warp.
It needs no held button and continues beyond client and screen boundaries.
The visible Desktop pointer freezes and is hidden on software, hardware and
remote-capture cursor paths. Absolute remote motion is not a raw source: such
a move cancels RELATIVE. Remote button/wheel packets do not invent motion.
Missing physical relative input also cancels. A normal software desktop uses
the same native motion query; relative support is not restricted to a managed
GPU output.

Explicit native release stops captured delivery immediately. Cursor restoration
follows the Desktop activity wake. The local host restores the saved entry
point, clamped to the current topology, and rebases ordinary pointer motion at
a nonconsuming physical counter fence. SNAPSHOT with
GUI_POINTER_HOST_FLAG_MOTION_SNAPSHOT returns that current fence; zero flags
keeps the state-only idle fast path and the grant baseline. BIND/CANCEL/UNBIND
also return current restoration counters; GRANT and owner info retain the grant
baseline. These reads do not clear button latches, wheel or input queues. New
physical movement after that fence remains ordinary pointer movement. A new
Desktop after a crashed host uses its normal initialized pointer position;
it does not adopt the previous host's active policy. WINSVC rebinding in the
same Desktop cancels, restores and refreshes the native window incarnations. The Desktop lazily binds the exact broker process through a native completion observation; a stop/start between successful RPCs is still detected. This does not consume the Service Manager's owner wait/reap.

ACTIVE and terminal notices use two per-window control slots separate from the
ordinary63-event ring. Barriers preserve their order relative to queued input,
including move coalescing/eviction. A new acquire returns BUSY until prior control
notices have been consumed. Ordinary captured-input overflow cancels explicitly
instead of silently claiming successful delivery. This does not change the
general GUI queue/loss contract scheduled separately in0.88.32.

Public access:

- C: <r4os/app_gui.h>, r4_window_pointer_identity/capture/status/release;
  R4_MESSAGE_POINTER_CAPTURE, R4_MESSAGE_MOUSE_RELATIVE and
  R4_MESSAGE_MOUSE_WHEEL. Retain the full identity/token, and wait for ACTIVE.
- Zig: app_gui.Window.pointerIdentity/pointerCapture/pointerStatus/pointerRelease;
  wheel/relative/pointer_capture messages.
- Rust: gui::Session.pointer_identity/pointer_capture/pointer_info/pointer_release;
  gui::EventKind::MouseWheel/MouseRelative/PointerCapture, with the complete raw
  record retained in Event.raw. Semantic event numbers differ from raw kinds.
- Low-level public C r4desk_gui_pointer_capture_* and equivalent Zig/typed Rust
  projections expose the same contract. The host operation belongs to the
  Desktop coordinator. This is functional ownership in R4OS's trusted system,
  not an OS permission or sandbox model.

SDK Examples/MouseLook.c is the public C consumer: actual left Down requests a
drag, Up releases, key2 requests FPS mouse-look, Escape releases and Q exits.
It handles typed focus and capture changes, keeps full64-bit tokens, counts
physical deltas and demonstrates stale-request/old-release probes. Its
Tests/Build/MouseLook manifest is image_scope=none; it is not an installed app.
SDK gui.MouseCapture remains local widget bookkeeping and never captures an OS
pointer. Building an example or passing a callback simulation alone does not
qualify outside-client dragging, cursor visibility or real relative input.

### Functional qualification 0.88.28

Kernel421/Desktop184, SDKsource110/Contract58/Librarysource37. R4DESK19/616;
release source advances to0.88.28 for the final build/benchmark, not a hardware
installation or standalone SDK/package publication. Contract58 is pinned at
3ca7511634005ba4663d9416baad473a2a86ab46; SDK110 source commit
20b12655431bfe814e3fbc415418dcca9ab34ce2. Old ABI slots/payloads/results remain
unchanged. Contract16/16 with26negative mutations and native C/Rust GUI
regressions pass; the Desktop suite reports244 native cases plus3geometry cases.

Actual private KVM4 software Desktop1280x720 runs public C MouseLook.316 normal
C checks report0failures, complete available retained text and process0; two
explicit owner kills retain actual exit-9 without a fabricated finish marker.
Real Down inside leads to Move/Up at signed(-328,-90) and outside(462,240),
including over a second actual C window. That contender gets BUSY with an
unchanged token and0mouse events. Fullwidth callbacks, wrong window/process
generations, old release during newer capture and real native window-slot reuse
are separately checked. Releasing an observer reference is acknowledged.

Unheld PS/2 QMP input delivers exactly20x(+200,+200) and20x(-200,-200) in
separate runs; the stable routing also delivers10positive and10negative vectors
in one owner. Counts remain physical before screen/client clamping. Physical
buttons and actual remote-input wheel1 work; absolute remote movement cancels
with reason8 and is never represented as raw motion. Actual software-display
screenshots show hidden mouse-look, restored entry position and subsequent
ordinary(+10,+15) movement. This is virtual software-display evidence, not a
physical mouse, GPU cursor, USB, Windows or physical-latency measurement.
Physical PS/2 wheel input was not observed; the wheel proof explicitly uses the
real remote-input pipeline. Optional remote-frame snapshot diagnostics were
unavailable in this profile and supply no cursor-snapshot claim.

The real WINSVC quick stop/start initially exposed a missing reset dependency.
The corrected Desktop uses its exact native broker completion observation,
not an RPC-success/connection-handle assumption. WINSVC instance11/gen11->instance25/gen25 with Desktop instance14
unchanged causes cancel6, window epoch2->5 and successful renewed capture;
an old release leaves it active. Native owner kill restores the pointer and
permits new capture after slot reuse. Desktop end delivers cancel6 to the live
C owner before its external close; the Desktop then becomes unavailable.
A WM caption drag rejects pending capture with reason7 and normal activation
works after Up. Actual ordinary-queue exhaustion produces ordered cancel9.
The receiver's old frame can remain visible while earlier input is drained;
it does not imply a still-active native capture.

Window Close also exposed an ordering gap. The final hosted close path cancels
the exact native token before the close flag/message, so public C receives
cancel3 before normal Close. This final path and post-kill replacement run on
Desktop SHA256 ec180e511e6e27d91f2e69c436e317b9818233868052398005264f6b1b5d0357.
Earlier motion/competition/broker phases use their recorded source artifacts;
the close-only delta is separately rerun. Kernel SHA256 is unchanged across
those phases:6f21cdf686c5fa0337d2f4763bfa430c4706691df6cd03bdbb5926450eac2d7b.
No32bit PID wrap,64bit token exhaustion or hardware success is inferred.

The reusable public C source/observer/contender and bounded workflow live under
SDK Tests/Build/MouseLook. They are image_scope=none, have no installed module
or periodic product instrumentation. The final normal source build and one
STANDARD28 are recorded separately below; no isolated speed/latency claim is
made from these functional tests.

### Final normal source build and STANDARD 0.88.28

The clean SDK110/Contract58 source export has technical=false. The regular
Desktop build with its existing owner settings produces exactly the final
qualified ec180e51... artifact; the canonical STANDARD image independently
reads back the same qualified Kernel421 6f21cdf6... . Release context0.88.28.
Exactly one final STANDARD:57c5757d-e273-40b1-ab97-1141738695ec,
Suite3/primary metric2/KVM4/30samples/4actual workers/5metric contracts/6valid
scores. Original SHA256:
ecb1bc94f9bc0ddfa38b481f0ef5b42c7e79d771923f237fcc7cbbde67ade9e9.
All sample workers, batches, operation/byte counts, clock/warmup/median/MAD and
scores are validated without uint64/decimal loss against frozen reference
28b326e2-4323-4a4c-a0d2-4c1bab4958c0; original bytes remain unchanged.
Overall158.193681 is ordinary system-workload validation, not capture-specific
throughput or physical mouse-look latency. Full original and compact validation:
ExFiles/Reports/Benchmarks/57c5757d-e273-40b1-ab97-1141738695ec/.
Status: lokal validiert; R4OS Server ausstehend (import and remote readback).
No benchmark repeat for scores. No hardware installation or standalone SDK
binary distribution is implied. Inventories:141modules/1063tests/483documents.

## 0.88.32: bounded ordinary GUI input and explicit cancellation

R4DESK20/624 appends `gui_host_input` at byte616; the19/616 prefix and
raw event kinds0..15 remain intact. `GuiHostInputRequest` is80bytes: exact
32-byte process/window identity, the unchanged40-byte event, operation and
reason. QUERY0 resolves the current native window epoch for an exact process
handle and Desktop window index. POST1 and RESET2 require that exact epoch.
The registered Desktop is the native host caller; GUI applications consume
input and cannot use this operation to become another window's input host.
C exposes `r4desk_gui_host_input`; Zig `guiHostInput` and the generated
C/Rust GUI Desktop context transport preserve the same native results.
Errors are Invalid-1, Stale-2, Busy-3 and Context-4; failed calls leave output
untouched. The current Desktop requires this provider at startup.

Desktop187 retains a rejected suffix in the bound client's lazy bounded
queue128 and posts at most16 acknowledgements per flush. Only acknowledged
records leave the front. GUI ownership remains true for a Busy/cancelled GUI
record, preventing Shell dispatch of that record. The main loop never waits
inside a retry loop. A rejected native post arms one space/progress wake;
ordinary successful GUI polls add no Desktop wake or measurement counter.
MouseMove coalescing moves the newest position to the suffix end without
crossing key/button order. Resource admission and work stay bounded.

Finite overload, focus loss, window close, Desktop change and process end
have reset reasons1..5. RESET cancels unread ordinary input and retains the
metadata/capture-control ordering; its coalesced control slot cannot be
blocked by the63-entry data ring. New ordinary admission waits for that
control to be consumed. Exact process/window rebind cannot replay the old
suffix into a new incarnation. Capture terminal notices keep their separate
priority, including the existing terminal-before-hosted-Window-Close contract.

Raw `input_reset` is16; public C `R4_MESSAGE_INPUT_RESET` is15 and the native
C/Rust GUI session semantic kind is17. The message carries window, reason
and the full64-bit tick. Clients clear held keys, repeat, pressed controls,
selection/drawing drags and pending activations. They do not synthesize a
click, save, install, or release activation. The shared subsystem input owner
releases held physical keys once; lifecycle reset also changes focus through
the existing focus path. Current GUI consumers handle cancellation; Fonts
requires a fresh Down before activating on Up. Stateless DeviceManager is
rebuilt against the appended exhaustive raw enum. Documents and user data
remain application-owned.

Binding qualification: Contract generated/layout/negative/interop gates,
seven original Zig GUI cases,52 subsystem cases, current public C/Rust GUI
pixel/lifecycle/negative-usage cases and Desktop252+3geometry pass. The same
original C guest artifact on KVM4/software fills native queue63 and sleeps2s:
Kernel422/Desktop186 loses Up (Down1/Up0,exit7); Kernel423/Desktop187 preserves
it (Down1/Up1,63drained,exit0,complete78-byte output and observer release0).
This comparison ran with the locally matched development tool export.
The additional native lifecycle/overload matrix and normal SDK source/tool
publication are qualified below. Final STANDARD32 is recorded separately.
No physical mouse/wheel/GPU, Windows, latency or isolated speedup claim.

### Native qualification of 0.88.32

The normal SDK111/Contract59/Library-source38 export has technical=false.
The regular Desktop project build is byte-identical to the tested187 artifact:
e3f04972d9adfd289d1fe4843d80ca52b6b67eb8f014ecde3e732f7bbd0a5b84.
Kernel423 is738b5636a2b15159fd488b532b34df44f095a04d170cbcdea8eeb4d141eba808.
Current GUI artifacts are rebuilt, including transient-state consumers and
stateless raw exhaustive-enum consumers; SNES/GB use the changed shared input
decoder. Module versions remain authoritative in their owner manifests.

The public C consumer fills the actual native ring with63 non-Move records,
then sleeps2s while the Desktop continues. Real Remote Up/Escape and emulated
PS/2 A Down/Up are retained: Down1/Up1,63 records drained, logical A1,
Escape1, physical Down1/Up1, held0, exit0, complete307-byte output.
Burst300 causes explicit overflow reset1, discards the cancelled unread input,
and ends with held0/clicks0. A second real GUI moves focus: reset2 precedes
focus-lost, with Up0/drained0/held0/clicks0. A real caption Close produces
reset3 before Close, likewise without a click or remaining held input.

With native outside-drag Capture active and the ring full, real focus loss
provides one Capture terminal notice before generic reset2 and the following
Close; the C owner exits0 with held0 and no click. An exact forced GUI kill
ends-9 with complete81-byte partial-lifetime text and no invented finish
marker. The next GUI reuses native window1 with a new process generation and
epoch13->14, receives no old key/button suffix, and exits0.

The public program inventory independently identifies the registered Desktop
host14/generation14. Ending that exact host while a GUI's final Up is pending
produces native Desktop-change reset4: Up0/drained0/held0/clicks0, exit0,
complete309-byte output. All nine normal GUI completions and the forced GUI
completion have exact external retained readbacks and observation release0.
The killed Desktop host has separate exit-9/release0 evidence; its own text
read is unavailable and is not claimed complete. The guest shuts down normally.
Actual process-ID wrap/reuse, physical-key-reset IRQ overflow, real hardware,
Windows and isolated latency/speedup are not qualified by these cases.

A broker-only WINSVC restart leaves the ordinary Desktop identity unchanged;
it is not the Desktop-end reset scenario. The actual Desktop-end case above
uses the exact publicly resolved native host. Host/source Pending and SDK
input-owner cases separately cover physical-reset retention and once-only
held-key release; the guest PS/2 case observes an ordinary physical A pair.

Additional finding0.88.77 remains open: external cooperative process-close
with Capture still active, without earlier focus or hosted-window cancellation,
can synthesize Close without the terminal notice. The negative C readback is
complete309bytes/exit11, ACTIVE1/terminal0/held1. This additional process path
was not the hosted Window-Close qualification of0.88.28 and is not silently
included in the successful32 cases. Its exact evidence and reusable modeP
consumer are retained for the planned separate correction.

Final STANDARD32: run5780c0c4-3848-4ce8-8607-10cfd1842bd8,
Suite3/primary metric2/KVM4, all30 samples/four worker work contracts and
six valid scores checked losslessly; frozen reference28b326e2-4323-4a4c-a0d2-
4c1bab4958c0. Overall161.257548 is the observed complete-suite score, not an
isolated GUI latency/speedup claim. Exact original SHA256:
ddb4aea40f83e280ad2e741b490d35e69217f8e7c2564faa9b94c82cbeab2a06.
The complete unchanged export and separate validation are archived under
ExFiles/Reports/Benchmarks/5780c0c4-3848-4ce8-8607-10cfd1842bd8/.
BOOT readback confirms the same423 kernel. Exactly one final STANDARD32;
lokal validiert; R4OS Server ausstehend (Import/Readback). No new measurement
was created for publication. Inventory141modules/1069tests/483documents.
