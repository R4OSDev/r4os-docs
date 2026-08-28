# Audio and device facades

The SDK exposes typed views over R4AUDIO and R4DEV. They do not implement a
second audio engine, hardware inventory or driver path.

## Audio

`app.audio()` opens PCM streams with an explicit sample format, rate and
channel count. A successful stream owns one handle and must be closed. Writes
retain the caller's buffer only for the duration defined by the generated
operation contract. `app_audio.WriteResult` reports bytes accepted before
Busy, timeout, or failure; `app_audio.WriteCursor` validates that progress
against the remaining frame-aligned client block without converting the
terminal result into success. Retry timing remains the caller's decision.
Volume, status, MIDI, SID and OPL3 operations are available only when their
table fields exist.

An AUDSVC open initially owns a logical client stream only. The first
non-silent PCM write materializes the kernel/backend stream. A complete zero
block is reported as consumed without a backend payload and closes an active
backend stream once; later signal may materialize it again. Status version 2
exposes materialized sessions, lazy opens, suppressed silence bytes/writes and
idle closes without enlarging the fixed status record.

`app.audio().masterState()` and `setMasterState()` are the bounded typed view
of AUDSVC's append-only master contract. The state distinguishes selected and
effective unsigned 16.16 gain, explicit mute, last audible gain, revision,
service epoch and persistence diagnostics. A positive explicit master volume
unmutes; the legacy set-volume operation deliberately preserves mute. AUDSVC
alone fans the effective master gain out to active streams and persists it,
so UI clients must not keep a second mixer truth.

The active R4D backend owns hardware conversion, DMA, interrupts and recovery.
An SDK facade never calls a kernel hardware path directly.

`midiRender(handle, frames)` requests 1 to 1024 frames from the selected
synth engine. The productive format is 48 kHz stereo signed 16-bit
little-endian PCM. Explicit engine names are exact and must provide a PCM
render callback; event-only MIDI.R4D is therefore not a renderer. Backend
backpressure and hard errors are returned to the application, which retries
the unchanged block only for backpressure.

SID operations use the same productive backend path. The SID driver delegates
model and register classification to AudioSid.R4P through DriverApi v18;
protocol, emulation and backend errors are observable through the facade.

## Devices and diagnostics

`app.devices()` exposes read-only device, driver, protocol, boot and
performance views. Enumerations use explicit counts/cursors and report stale
or incomplete snapshots. Diagnostic self-tests are bounded operations, not a
general fault-injection interface.

`PerformanceView.driverWork(owner)` exposes Driver Work snapshot version 2.
Besides the normal fair IRQ/task FIFO it reports the isolated audio EDF lane,
deadline queue and worker state, queue ticks, start misses, callback-budget
overruns and admission rejections globally or for one selected R4D owner.

Zig and C use the same generated layouts, result domains and buffer rules.
The SDK repository tests validate both facades and their negative lifecycle
states.
