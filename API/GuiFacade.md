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

The complete function tables are in `R4DESK.md` and `R4DRAW.md`; frame shape
serialization is summarized in `GuiShapeContract.txt`.
