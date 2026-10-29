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
