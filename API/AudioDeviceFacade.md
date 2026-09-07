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

R4AUDIO v2 additionally exposes `audioOutputInfo()` and `audioSelectOutput()`
through the low-level facade for AUDSVC and targeted diagnostics. The bounded
catalog includes disconnected connectors, their capability/availability state
and a stable physical identity. Selection takes that identity in a 64-byte
NUL-terminated buffer and preserves the application stream queues and master
gain. Existing table slots and AudioBackend v2 descriptors retain their
layouts; the new output callbacks occupy a version-3 driver descriptor tail.
Normal desktop selection and persistent user preference remain AUDSVC's
responsibility. A successful hardware selection or DMA write does not by
itself prove sound at the connected receiver.

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

`app.audio().outputs(request, timeout, out)` and `selectOutput(...)` use
AUDSVC's appended output operations. Requests support optional service-epoch
and revision checks; selection uses a fixed stable ID, with an empty ID for
automatic policy. The response separates desired and active outputs,
explains fallback, reports persistence state and returns up to eight physical
records per page. All endpoint payloads belong to the generated Contract;
old master/stream operations keep their layouts. Hardware activation remains
in R4AUDIO/HDA, while user preference and persistence belong to AUDSVC.

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
