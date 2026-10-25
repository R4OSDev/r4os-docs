R4OS Audio
==========

R4AUDIO is the public platform group for PCM streams, hardware status and
synthesizer access. Applications request it through `module.R4MF` and use the
SDK facade; optional functions are guarded with `hasFn`.

Hardware output is provided by loadable R4D drivers such as AC97 and HDA.
SID, MIDI and OPL3 are separate driver/protocol components. The kernel keeps
only the common timing, routing and backend mechanisms required by the
platform contract.

The normal ownership chain is:

```text
R4X application -> R4AUDIO -> audio service/core -> active R4D backend
```

Drivers advertise capabilities and own hardware-specific conversion,
DMA, interrupts, stop and recovery. Applications must use the announced
stream format and close every stream they open.

For native 48 kHz stereo S16LE, the PCM adapters copy complete bounded
blocks directly into their owned ring or DMA storage. A single stream at
unity gain also bypasses sample accumulation in the kernel mixer, including
ring wrap. Fractional resampler phase, foreign formats, non-unity gain and
multiple active sources keep conversion/scaling/mixing. Partial acceptance,
backend Busy and stream lifetime remain governed by the existing owners.

AUDSVC binds each logical stream to both the client ID and its program
generation. One bounded paged inventory traversal serves all open sessions
in a cleanup round. An incomplete or changed inventory defers cleanup;
a reused ID cannot keep a stream from the previous generation alive.

Backend status without system diagnostics (0.87.16)
--------------------------------------------------
AUDSVC0.1.14 derives backend presence directly from its existing selected,
available output. Normal MasterState/Status requests, stream materialization
and session reaping no longer call the system-wide R4DEV performance summary.
The unused Devices context and module R4DEV import are removed. Kernel384,
the platform contract and the explicit Spectra SUMMARY collector are unchanged.

There is no second backend-presence cache. The existing output catalog has
a500ms refresh interval, service epoch and revision. Output changes also
advance the service status revision; master revision still describes gain
and mute. An incomplete/failed catalog keeps its old display data but cannot
confirm an active backend. An actual stream NoEndpoint clears the current
active route and forces the next catalog refresh, preserving the desired
selection. Removal and a later provider with the same persistent ID publish
fresh catalog revisions. Availability is a bounded status observation, never
a stream or driver lease; the kernel still validates exact live owners at
Open/Write/Close and excludes closing backends from its output catalog.

The existing owner step passes9 cases, including the real output consumer
through its R4AUDIO facade: pending/ready outputs, fallback and preferred
output return,499 cached observations without extra queries, failed catalog
and cached failure, removal/re-registration, NoEndpoint invalidation and
recovery. No physical HDMI, audible output or latency result follows from
these host cases.

The final KVM4 guest runs the original AUDSVC /SELFTEST: master volume/mute,
two streams, common gain fanout, lazy/silent/active behavior, persistence over
the real service restart and restoration pass with ERRORLEVEL0. Explicit
SPECTRA METRICS SUMMARY remains complete with a stable clock,1 registered/
active backend and0 open kernel streams afterward. Normal poweroff exits0.
Installed AUDSVC bytes match the final artifact, SHA256
c56566305a77675b0b831ebc508789b518b7efac0601ef7ac5b4ecc0c8df13a4;
BOOT matches unchanged Kernel384,
d554519cbcc15a13a4dbb1eb013a7df513a3672a563fb4acc147f2958e8552ca.
Private guest/source copies are removed. Desktop166/Spectra60, public
Full/Slim14 and native OssiPC12 are unchanged by this service release.

Exactly one final Suite3 STANDARD a2e00867-7406-4bf9-9199-c90758d4f92c
passes with30 samples,4 completed workers each and6 valid scores
(overall150.495837). Original run.json SHA256
25282c06fd7ffed7e4305e13ef1c393921e75396ea3895ae637c5239887ef071
was uploaded unchanged; the complete normalized DevCenter readback matches
all fields and all six score areas validate. STANDARD has no Desktop workload
and establishes no isolated audio/UI latency or physical playback improvement.

Output selection (0.78.17)
-------------------------

AUDSVC owns the desired output independently from the actually active
hardware route. The appended Outputs/SelectOutput endpoint operations expose
eight hardware records per page from a bounded 256-output catalog, including
disconnected endpoints, stable physical IDs, the service epoch, revision and
fallback reason. Incomplete or duplicate inventories retain the previous
snapshot. Existing stream and master-volume messages are unchanged.

A usable saved ID wins over automatic policy. Otherwise a connected supported
HDMI receiver is preferred, followed by an available analog output. Returning
receivers restore the saved preference. Refresh is limited to 500 ms and is
driven by active sessions, incoming PCM or an open Desktop volume popup;
an idle service adds no permanent output-polling timer. A failed activation
retains a usable previous route; when none exists, at most four candidates
are attempted in one pass. Kernel stream identities, queued source PCM,
stream gain, master gain and mute survive a successful output switch.

C:\R4OS\CONFIG\AUDIO.R4S stores OUTPUT_ID beside the existing master state.
An empty or absent key means automatic selection, so older configuration
files remain valid. AUDSVC uses its existing atomic file replacement and
coalesced persistence worker; an odd/even publication sequence keeps the
gain, mute and 64-byte output identity in one consistent worker snapshot.
Failed manual selection does not replace the saved ID. BDF-based HDA IDs
survive enumeration changes but may change after hardware relocation.

The output controls require the R4AUDIO output functions from Kernel 0.1.104;
older providers report the feature unavailable. Selection cannot make an
unavailable receiver ready. In 0.79.15 the native NVIDIA owner supplies
confirmed HDMI ELD/audio state and HDA checks exact physical readback against
its current display revision. A stopped old route must be reactivated even
when its stable output ID is unchanged. The existing AUDSVC consumer and
Desktop status/selection already handle this transition and preserve an
explicit analog preference. Hardware tone/receiver qualification is pending
in ExFiles/Reports/OssiGPU.txt; see Drivers/GrafikAudio07915.txt/.json.
Synth engines render productively into the common 48 kHz, stereo, signed
16-bit little-endian PCM path. A render request contains 1 to 1024 frames;
the audio core writes the complete block to the active R4D backend. Backend
backpressure is returned to the caller and preserves the same pending block
for retry. An explicitly requested synth name is exact: event-only engines
such as MIDI.R4D are not accepted as renderers, while OPL3.R4D supplies the
normal MIDI PCM implementation.

SID.R4D owns its emulation state and reaches the installed AudioSid.R4P
through DriverApi v18 protocol dispatch. SID frame rendering uses the same
backend and retry rules; protocol, runtime and backend failures remain
visible to applications instead of being converted into success.

The generic subsystem runtime uses the application audio facade rather than
a direct kernel path. Its default transport is 48 kHz stereo signed 16-bit
little endian in 480-frame quanta with caller-owned buffering. It opens no
service/backend stream until the first non-silent quantum. Empty, silent,
paused and muted cycles submit no full zero payload; an active sink is closed
once and may be materialized again by later signal. If the service or stream
fails, audio becomes degraded, clears its queued PCM once and leaves the audio
deadline schedule; guest time and video continue at their normal paced rate
without repeated PCM generation, scratch submission or a zero-wait loop.
Open, write and deferred close are limited to one service operation per host
cycle and occur only after a pending video publication. Prefill and late
resync therefore interleave with input, VM and presentation cycles instead of
forming a synchronous multi-write burst. Busy preserves the exact source PCM
and uses an independent 10 ms retry deadline. Source-frame feedback separates
AudioService acceptance, deliberate silence suppression and explicit discard.
The current platform contract exposes no per-stream hardware playback cursor;
callers must report that state as unavailable rather than deriving played
frames from accepted frames or guest time.

HDA and AC97 submit refill/status/recovery passes through DriverApi v20. Each
request declares a 10 ms absolute deadline, a bounded callback budget and a
stable device key. A separate EDF queue and one `r4d-audio` short-completion
worker isolate those passes from normal Driver Work while globally
serializing them. Normal admission reserves deadline capacity and the
scheduler demotes the worker after its four-tick/four-dispatch boost, so audio
cannot form an unbounded priority lane. The current HDA and AC97 DMA geometry
is intentionally unchanged: the available cursor, queue, underrun and
deadline evidence did not justify a period or segment-DMA change.

Both SDK audio writers keep packet lengths as usize before adding their
request header. Zig's narrowed @min result alone cannot represent a complete
1024-byte legacy or 4096-byte App-Audio message; explicit widening prevents
those boundary requests from wrapping to zero length.

HDA parks an exhausted analog/DisplayPort ring after a bounded three-period
codec postroll. HDA 0.3.26 keeps a selected, available HDMI output clocked
through its cleared ring instead: completion IRQs are disabled, with no
periodic refill work or artificial application stream. The optional v4 Idle
callback in Kernel 0.1.259 separates normal PCM completion from physical
Stop; route replacement, disconnect and shutdown still stop DMA. Older
backends retain Stop fallback. An HDMI physical start allows one second for
receiver acquisition before accepting PCM; subsequent tones resume at the
actual ring position with two silent lead periods. That acquisition bound
comes from the Hisense short-tone probe, not a universal receiver guarantee.
The quiet carrier still consumes 192,000 DMA bytes/s while HDMI is selected.
Partial tails are emitted once without padding each normal write. Source
exhaustion has its own counters; gaps despite queued PCM remain underruns.

PCM clients retain frame-aligned progress reported before Busy, timeout or a
hard error. R4Synth sends matching stereo S16LE WAV data directly and paces
only accepted frames after a 160-ms prefill. Beep uses 960-frame, 3840-byte
single-request blocks; its ten-block self-test reaches the HDA start window
and represents a complete 200-ms short tone.

Current modules are listed in `Docs/Inventory/AllModules.json`; diagnostics
and their tests are listed in the corresponding inventories.

The current HDA stream geometry, ownership, IRQ and lifecycle rules are in
`Docs/Drivers/HdaStreamContract.txt`. `AudioDiagnostics.txt` documents the
deterministic AudioDiag patterns, QEMU WAV analysis and 60-second ring test.

Kernel PCM ownership (0.81.17)
-----------------------------

The global stream mutex covers only bounded metadata and ring publication.
Each writer/closer holds a per-stream transaction reservation plus a task
unwind token. Conversion runs on a local resampler snapshot and at most one
16-KB output buffer outside that mutex; only a complete chunk commits its
phase and bytes. Stream format and program generation remain stable for the
reservation. Consumers can drain already published bytes in parallel.

The output owner is a resident semaphore permit with an unwind token. It
serializes backend registry/selection, callbacks and callback lifetime without
a held stream mutex. A producer only attempts immediate output ownership;
contention schedules the existing progress worker. Every mix quantum borrows
at most 1920 bytes from each of eight rings and snapshots volume. The rings
remain read-reserved until the backend acknowledges the complete output; Busy
consumes nothing. Close/owner cleanup retries an active producer/read lease.
Open and last-stream Stop share output ownership, so a new stream cannot race
the last-stream decision. The internal closeAllStreams reports retry as bool.

Driver cleanup drains current output ownership and closes that backend's
callback admission before DriverShutdown. A cancelled preparation reopens
admission; failed shutdown or unregister retains context and generic owner
resources for retry/quarantine. Status/selection avoid callbacks into a closing
backend. Recursive public entry from an output callback reports Busy. A
contended performance summary still supplies stream data but omits callback
status until a later observation can acquire output ownership.

Synth policy, driver-specific conversion/DMA and the physical device remain
with their existing owners. This change does not qualify physical audio or
the excluded AMD/NVIDIA adapters.

Native kernel audio since0.83.24
-------------------------------
Rust/audio owns PCM conversion, mixing, streams, backend/output admission,
progress and audio boot status; Rust/program/r4audio.rs owns the table calls.
AUDSVC, HDA/AC97 and MIDI/SID/OPL3 modules retain their current contracts and
artifacts. Ordinary Idle may retain a silent carrier; route/owner teardown
still requires Stop. Scoped original cases, one SMP4 audio guest and one
STANDARD/DevCenter result, with physical/hearing/timeout limits, are bound in
Core/KernelRustAudio.txt and KernelRustAudio08324.json.
