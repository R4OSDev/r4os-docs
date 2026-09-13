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

HDA 0.3.16 parks an exhausted hardware ring after a bounded three-period
codec postroll. It preserves the open logical stream and conversion state;
new PCM restarts the ring. Partial tails are emitted once without padding
each normal write. Idle source exhaustion has its own close-log counters;
missing periods despite already queued PCM remain backend underruns. The
parked ring produces no periodic completion IRQs or audio worker jobs.

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
