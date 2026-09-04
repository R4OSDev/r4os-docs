# GUI facade

R4DESK owns windows, events, controls and desktop lifecycle. R4DRAW owns
drawing, text, images, surfaces and frame commands. The SDK GUI facade
combines them into owner-thread objects without hiding group availability.

## Lifecycle

A GUI application creates a window, polls or waits for events, draws only in
the appropriate paint/frame phase and destroys the window before exit.
Window IDs and event payloads are borrowed observations; application-owned
state remains in the application.

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

All chunks remain private until the `PaintContext` commits. The first append,
conversion or commit error is latched and cancels the complete transaction;
no successful prefix becomes visible. On an older R4DRAW table the same
Canvas transparently uses the previous draw calls and `gui_present`.
`Canvas.frameCommand()` lets a prebuilt `gui_shapes` resource participate in
the same ordering; shape commands require the current frame contract.

`FrameCanvas.stats` reports logical commands, resource bytes, buffered
flushes, direct chunks, append calls, legacy calls and failures for that one
frame. `drawTransitions()` and `frameMutationEntries()` count the actual draw
ABI entries, excluding begin, commit and present. These counters are passive
and add no platform call.

The complete function tables are in `R4DESK.md` and `R4DRAW.md`; frame shape
serialization is summarized in `GuiShapeContract.txt`.
