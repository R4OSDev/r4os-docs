# Audio and device facades

The SDK exposes typed views over R4AUDIO and R4DEV. They do not implement a
second audio engine, hardware inventory or driver path.

## Audio

`app.audio()` opens PCM streams with an explicit sample format, rate and
channel count. A successful stream owns one handle and must be closed. Writes
retain the caller's buffer only for the duration defined by the generated
operation contract. Volume, status, MIDI, SID and OPL3 operations are
available only when their table fields exist.

The active R4D backend owns hardware conversion, DMA, interrupts and recovery.
An SDK facade never calls a kernel hardware path directly.

## Devices and diagnostics

`app.devices()` exposes read-only device, driver, protocol, boot and
performance views. Enumerations use explicit counts/cursors and report stale
or incomplete snapshots. Diagnostic self-tests are bounded operations, not a
general fault-injection interface.

Zig and C use the same generated layouts, result domains and buffer rules.
The SDK repository tests validate both facades and their negative lifecycle
states.
