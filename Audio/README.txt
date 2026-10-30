R4OS Audio
==========

R4AUDIO is the kernel platform group for PCM streams, hardware status and
synthesizer access. Normal application PCM uses the SDK Audio facade and
AUDSVC over R4SYS service IPC. AUDSVC owns the corresponding kernel streams;
advanced direct platform functions are requested through `module.R4MF` and
optional functions are guarded with `hasFn`.

Hardware output is provided by loadable R4D drivers such as AC97 and HDA.
SID, MIDI and OPL3 are separate driver/protocol components. The kernel keeps
only the common timing, routing and backend mechanisms required by the
platform contract.

The normal ownership chain is:

```text
R4X application -> SDK AudioStream/R4AudioSink -> R4SYS IPC -> AUDSVC
AUDSVC -> R4AUDIO stream admission -> audio-progress worker -> R4D backend
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
Since0.87.53 a generation-bound per-stream cursor can report known backend
acceptance, DMA submission and consumed canonical frames separately. Missing
or reset-spanning device evidence remains unavailable/unconfirmed; acceptance
and guest time never become playback receipts. See PlaybackProgress.txt.
Since0.87.54 SDK102/AUDSVC16 also retain active discrete null PCM on the
same stream: only initial unmaterialized discrete silence stays lazy.
Confirmed producer idle/stop or explicit Close owns the original asynchronous
retirement and HDA drain. AudioDiag13 /GAP checks signal/null/signal, exact
1440 consumed frames and true final resource release. No new timer/thread,
kernel/HDA/ABI change or audible/physical speed claim.

HDA and AC97 submit refill/status/recovery passes through DriverApi v20. Each
request declares a 10 ms absolute deadline, a bounded callback budget and a
stable device key. A separate EDF queue and one `r4d-audio` short-completion
worker isolate those passes from normal Driver Work while globally
serializing them. Normal admission reserves deadline capacity; the ordinary
role boost remains four ticks/four dispatches. Since0.87.51, copied actual
ticket/device/task-generation metadata also informs safe CPU selection near
the deadline. Extra priority has a2ms window per10ms and cannot be renewed by
ticket changes; expired/missing work owes an actual Ready FIFO opportunity.
Input/rank-zero donation precedes it. The original elapsed callback budget,
including waits, is retained. This is soft bounded urgency, not a hard CPU-
share, callback interruption or physical audio deadline guarantee. See
Core/Parallelitaet.txt,0.87.51, for actual native order/retirement and limits. The current HDA and AC97 DMA geometry
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

0.87.49 — asynchronous stream transport (SPEED-017)
-------------------------------------------------
SDK100 R4AudioSink submits/polls one owned native Async Service request.
Input, guest slices and frame publication continue while it is pending.
The existing two-quantum PCM budget stays; the copied in-flight prefix is
still owned by the frozen queue head, not an additional backlog. Header,
response and PCM storage survive terminal publication until actual ioClose.
Aligned accepted prefixes advance once. BUSY keeps the remainder, unknown
timed-out write acceptance is not replayed; Open/Close and generations are
validated separately. Final shutdown drains buffers and requires real Close
acknowledgement. A failed Close never reports resources=closed.

Kernel409 write only performs bounded input conversion/ring admission and
wakes its existing dedicated mixer. Backend dispatch stays on that worker.
Close/tail/owner teardown holds existing exact stream transactions and drains
the required streams; continuing unrelated PCM cannot prolong their Close.
Output ownership, common mixing, read reservations and real Stop remain.

The explicit AUDIOD producer now handles legal partial/BUSY admission using
the existing frame cursor with a bounded retry. Its original8280frames/
33120bytes, zero-loss/error, actual IRQ/deadline work and real drain remain
required. Worker coalescing produces18 backend calls for21 input packets.
The original WAV analyzer recognizes exactly7607 continuous frames at44100Hz,
the expected resampling of8280frames, and no old480/544gap pattern. Analysis
uses the unchanged contiguous first2seconds of the QEMU WAV; source length/
SHA256 and selection are bound in the context, not physical hearing evidence.

48 SDK owner cases, original C/Rust host interop with5 negatives, full SDK
build113steps, Kernel build/fmt/Clippy and current real KVM4 artifacts pass.
Original Async Service/pool caller-end and performance cases, SDK smoke,
BASIC, both long GB/SNES pairs, persistence/close/reap and original full report
contracts pass. Modeled native tables in3 transport cases are host models;
they do not prove native IRQ timing. Details: Core/KernelRustAudio.txt.

Genau ein finaler Spectra77 STANDARD3/KVM4: cf47d735-2d08-4ff6-ba58-c6304fb26a6b.
30 Rohsamples, je4 vollstaendige Worker,5 neu berechnete Aggregate und6
gueltige Scores; lokal und R4OS Server vollstaendig validiert. Der gesamte
normalisierte Originalexport und die echte feste Referenz sind gleich dem
Server-Readback. Original-SHA256: 015f174810950bfa54fde8e64722372ee3187933fc5e6bdc4fe62bc3ce1dd3d4.
Kompakter Quellen-/Arbeits-/Artefakt-/Vergleichskontext und Rohdaten:
ExFiles/Reports/Benchmarks/cf47d735-2d08-4ff6-ba58-c6304fb26a6b/.
Gesamt239.749078, IPC769.315636 gegen48 Gesamt207.466609/IPC395.237827;
gleicher Vergleichsschluessel, unisolierter VM-Vergleich. Keine isolierte
Audioverbesserung oder geklaerte IPC-/FS-Ursache daraus ableiten. READERS37
overlap=no/data=yes bleibt bei55/57 offen; kein Score-Rerun.
Keine OssiPC-Aktion, SDK-/Paketpublikation oder neue physische NVIDIA-,
Audio-, Eingabe- oder Ordnerlatenzquittung. Full/Slim14 und OssiPC12 bleiben
getrennte Staende; die integrierte Hardwareabnahme bleibt66.


0.87.52: HDA-Control und PCM-/DMA-Streambesitz
--------------------------------------------
SPEED-016: HDA0.3.42 besitzt ELD-/Codec-Control im bestehenden normalen
r4d-work-Kanal, getrennt vom Audio-Deadlineworker. Hoechstens ein physischer
HDMI-Pin pro Callback, danach endliche Fortschreibung durch Produzent oder
Ausgangsabfrage;250ms nach kompletter Runde. Kein periodischer Thread,
keine PCM-/DMA-Sperre ueber Codec-I/O und keine neue API/ABI oder Kernelaenderung.
Kernel410/Spectra78/Desktop172/Explorer32 und alle anderen Module bleiben.

Control besitzt rohe Sinkbeweise, der Streambesitzer publiziert einen
geprueften vollstaendigen Katalogsnapshot. Doppelte Zuordnungen zerstoeren
keine Rohdaten; ELD-/Receiver-/Port-/Source-/Revision-/Head-/Device-Entry-
Aenderungen sperren die alte aktive Route. Echte Wechsel stoppen DMA und
reservieren die Route, bevor Codecprogrammierung ohne Streamlock beginnt.
Explizite Auswahl prueft den aktuellen Receiver vor und nach Programmierung.
PCM, Status und Refill nutzen nur den freigegebenen Zustand.

Kontendierte Refiller warten auf echte Freigabe oder neue IRQ-Generation.
Waiter vor Pending-Freigabe plus Owner-Recheck verhindert Lost-Wake-Rennen;
kein sofortiger Nachfolger allein wegen desselben gehaltenen Locks. Stop
und Shutdown joinen/releasen beide Arbeitsklassen. Cancel ohne Callback
loescht dessen Pending-Claim erst nach der tatsaechlichen Quieszenz.
Gemeinsam beobachtete Transport-/Fehlerzaehler sind atomar. Keine proVerb-/
proWrite-/proIRQ-Logs oder Hintergrundsampler; neue HDA.CONTROL-Quittung
nur im vorhandenen expliziten Close-/Shutdown-Diagnosepfad. Unveraenderte
PCM-Geometrie, Fristen/Budgets, Drain, Timeouts und Hardwarebesitzgrenzen.

66/66Owner-Hostfaelle einschliesslich Generation/Receiver/Port/Mehrdeutigkeit
und Refill-Freigabe-/IRQ-/Stoprennen gruen. EchtesKVM4/Kernel410/HDA41/
AudioDiag11: PCM8280Frames33120Bytes, Originalmaster-/Mute-/Restart-/
2Stream- und4Close-Generationsfaelle, reale Audio-Deadlinearbeit,
keine Dropped-/Underrun-/Treiber-/Backend-/Silencefehler, Miss/Overrun/
Rejected0, regulaerer Shutdown0. Originaler44100Hz-WAV-Pruefer bestaetigt
7607/7607Signaldauer, Continuous=true, kein480/544-Muster. BOOT und beide
tatsaechlichen HDA-/AudioDiag-Dateien im Image bytegleich zur Quelle;
Poolprobe/Export ebenfalls gruen. Temp/08752-kvm-readback.json.
Die temporaere KVM-Zeile verwendete versehentlich /OUT: statt /OUT=;
dadurch lief der regulaere AudioDiag-Fall ohne optionalen Dateiexport.
Serial/WAV und Pool sind echte Nachweise; kein AudioDiag-Export behauptet.
Die finalen42-Nachweise folgen nach der dokumentierten Zwischenkorrektur.

Native Zwischenprobe41: echte PCM-/Master-/2Stream-/4Close- und IRQ-/
Deadlinefaelle bestanden mit allen Fehlerdeltas0. Der ausdruecklich angeforderte
Export blieb aber rot: candidates=0 trotz vorhandener Selection/Core/Runtime.
Das seit unabhaengiger Controllerregistrierung unbefuellte Kandidatenarray
wird in42mit den echten PCI-/Transport-/Codec-/Pin-/Konverter-/Routenbeweisen
der jeweiligen Instanz befuellt; auch HDMI-Quiet-Idle wiederholt diese
Beweise und HDA.CONTROL.41wird nicht als finaler Gesamtbeleg verwendet,
AudioDiag11 und seine Pflichtpruefungen bleiben unveraendert. Neue finale
KVM-/Native-Probe war erforderlich; der einzige STANDARD folgte erst danach.

Finaler Stand42,26.10.2026
-------------------------
HDA.R4D2464168Bytes,
SHA2562533aca578c98969b7bc34bcf42ccb6b0ceca8023dcabec8cbc06babdbf3992b.
Alle150anderen Modulartefakte und Kernel410 unveraendert.66/66Hostfaelle
erneut gruen. Finale echteKVM4-Dateien/BOOT52-410 vollstaendig geprueft;
AudioDiag11 inklusive korrekt angefordertem /OUT= exportiert alle vier
Pflichtklassen, Kandidaten6/Selection6/Core7/Runtime6. WAV7607/7607,
4Close-Generationen,2Streams, Master/Mute, IRQ/Deadline/Pool und Shutdown0
bestanden; alle Audiofehler-/Miss-/Overrun-/Rejektionsdeltas0.

OssiPC tatsaechlich Release52/Kernel410/HDA42,16konfigurierte und16
schedulierbareCPUs. Vorhandene NVIDIA333/R4NV19 und automatische native
Grafikkonfiguration unveraendert. Neues HDA-Paket nur ueber Inbox/SYSUPD,
vollstaendiger Transport- und installierter Dateireadback bytegleich.
FinaleR4U2465331Bytes,
SHA2560d7ade0e7bdb013cc7bdca38ca62bd9e0fe36de6b4f97a86b90f662dcd104826.
FinalBatch3installed/Journalcleanup/transaction3/generation35/applied3/3;
echter neuer Boot nach56.392s, kein restartwake. Alter COMMIT-SSH-Kanal
endete124 mit nur teilweiser Fortschrittsausgabe; der echte neue Boot,
installierte Dateihash und terminale Status belegen den Erfolg unabhaengig
vom verlorenen Abschlusskanal. Kein COMMIT wiederholt.

NativeAudioDiag: echter NVIDIA-HDMI-Controller09:00.1/10DE:228E,
Codec0/10DE009F, Route6>8/HDMI/Stereo48k-S16/fmt0011, MSI undDMA+LPIB.
PCM8280Frames33120Bytes, Master/Mute/2Streams/4Close-Generationen und
vollstaendiger Export bestanden; alle Dropped-/Underrun-/Treiber-/Backend-/
Silence-/FIFO-/Descriptor-/Position-/Recovery-/Timeout-/Drain-/Workdrop-
Deltas0, AudioDeadline submitted1/started1/miss0/overrun0/rejected0.
User bestaetigt Testton hoerbar und Desktop normal.

Echter Hotplug: User zieht HDMI amTV etwa5s ab und steckt wieder ein;
Desktop sichtbar. Derselbe echte Treiberport2048 liefert Receivergeneration
9->22 bei Devicegeneration2. HDA.CONTROL revoked0->1: alte Route wirklich
gesperrt. Danach erneute frische Wiedergabe/Master/4Close/IRQ/Deadline und
vollstaendiger Export wieder gruen, alle Fehlerdeltas0. Native Runtime-
Workbesitzbit ist nach Close frei; Systemhardware-/Backendbesitz bleibt
beabsichtigt registriert. DISPLAYD reason=none/pending0/keineBO-Nachlaeufe,
Desktop verfuegbar, Konfiguration bytegleich. Keine physische Latenz- oder
integrierte SNES-/Desktopqualifikation vorweggenommen. Erfolgreiche native
ELD-Antworten hatten Timeout0; gemessene PCM/Control-Ueberlappungs- und
Parkzaehler0 sind kein beobachteter blockierter I/O-/Kontentionsfall.
Die zugehoerigen Rennen pruefen die produktiven Host-Policyfaelle und
Besitzgrenzen; kein Hard-Realtimeversprechen.

Genau1finaler Spectra78 STANDARD3/KVM4:
e747503f-801b-4cd3-896f-120953151828.30Originalsamples/je4vollstaendige
Worker/5neuberechneteAggregate/6gueltigeScores. Vollstaendig lokal und in
R4OSServer validiert, kompletter normalisierter Original- und echter
ReferenzGET gleich. OriginalSHA256
2a252feca69d174ee3a2d45ece9152aad35b5609bf279e83775b12647a8e3204.
Gesamt206.017554/IPC474.951502 gegen51 222.194637/573.388903;
gleicher Arbeitsvertrag, unisolierter VM-Vergleich. Keine isolierte
HDA-Beschleunigung, Rauscheneinordnung oder geklaerte Regression behauptet;
kein Score-Rerun. Vollstaendiger Original-/Referenz-/Artefakt-/Hardwarekontext:
ExFiles/Reports/Benchmarks/e747503f-801b-4cd3-896f-120953151828/.
Kompakte Qualifikation Temp/08752-qualification.json. OeffentlichesFull/Slim
bleibt51, nativerOssiPCjetzt52; alsnaechstes53Wiedergabefortschritt/
Quellfristen. READERS37/IPC55/FS57 und integrierte66-Abnahme bleiben offen.

Application PCM, SDK transport and pacing review (0.88.9)
-------------------------------------------------------
Reviewed boundaries: app_audio Audio/AudioStream/WriteCursor; async subsystem
Audio Transport ordinary/tracked/discover/configure/progress/close paths;
AudioPump acceptance/queue/pacing/retirement; canonical streaming PCM conversion
and common native/C/Rust owner projections. No driver DMA/audio acceptance here.

0.88.42 owns a source-confirmed asymmetric reply check. Synchronous validResponse
checks magic/version/action; writeBounded checks bytes and frame alignment but
not the returned stream identity or result==accepted bytes. Control accepts any
nonnegative result without checking own stream and can clear ownership on Close.
Open's positive result is its stream ID in the service contract; consistency
with that ID must be checked, not replaced by a zero-success rule. Async decode
already checks own stream,
accepted-byte/result agreement and zero control success. Malformed/lateral
replies must not turn into own completion or PCM progress. No real AUDSVC bad
reply, audible duplication or provider fault was reproduced in this analysis.

0.88.43 owns an unnecessary terminal wait: drain polls, waits on actual I/O,
then sleeps one tick whenever request_id remains, before polling/retiring even
a completed wait. Only the next poll clears the ID. This is terminal finish/
close/fence work; ordinary interactive pumping remains nonwaiting. Real ioClose
BUSY/retirement and transient waits still need their exact acknowledgement and
bounded retry behaviour. A finite remote budget never permits premature buffer
reuse. No real close-time/latency benefit is measured from this source sequence.

Preservation findings: one async request per transport owns copied PCM/header/
response storage until genuine I/O close succeeds. BUSY status defers inspection;
an uncertain Open is fenced on its original endpoint before reuse. Discovery,
flow and tracked Write consume one absolute chain budget. Exact service epoch,
stream generation and source deadline remain bound; accepted source frames are
not consumed/DMA/audible frames. AudioPump drops only a confirmed frame-aligned
accepted prefix, retains remaining queued bytes through pending operation and
keeps invalid/unconfirmed work separate. Silence in a materialized continuous
stream still owns timeline; producer pause/stop, not zero sample values, owns
Close. Progress/real work/counters consumed by pacing and explicit original
reports are not removable bookkeeping. No second backlog/worker is proposed.

Native48kHz stereo S16LE already has a bounded direct-copy converter path.
Fractional phase/remainder and the final previous-sample tail preserve streaming
partition identity; finish handles end-of-stream instead of inventing boundary
samples between chunks. Copied async payloads preserve source lifetime; they
cannot be removed solely because another copy exists at the IPC boundary.
PCM sample work instrumentation is comptime-gated by builtin.is_test or explicit
root.audio_work_counters; normal unrequested sample counting was not found.
Public Rust uses the native owner and requires explicit Close; Drop is no native
close receipt. Bounds/format/owner checks remain functional.

Existing SDK subsystem-runtime-test and platform-parity-test passed72/72:
58 runtime/transport owner cases,9 Audio/Device cases,3 PCM cases and2 power
cases;10/10 build steps succeeded. These original controlled native tables and
PCM oracles do not prove actual endpoint scheduling, asynchronous cancellation,
current live driver/audio or physical sound/latency. The new negative reply/
wait-order injections remain obligations of42/43. No source/artifact/test gate
changed; docs/status/release marker only, no STANDARD or new guest image.

AUDSVC, IPC and session review (0.88.10)
---------------------------------------
Reviewed boundaries: request dispatcher and typed replies, lazy/materialized
sessions, copied pending Close keys and tracked progress, current client-owner
cleanup, master/mute/output policy, asynchronous debounced persistence and
status/selftest activation. Kernel resource retirement and hardware remain
deeper independent boundaries; service exit0 is not new physical-drain proof.

0.88.44 owns private Session.writes/bytes_written without any product reader.
These are distinct from the publicly exported state.bytes_written. It also owns
obsolete clientIsRunning/runningRecordMatches helpers used only by their own
ID-only test; current product Open/Reap uses collectRunning with exact generation
and conservative paged inventory. Its current generation/partial/reused-ID/
duplicate-owner oracles remain, as do matches and actual silence detection.
The old before/after informational AUDSVCWORK print duplicates asserted native
work counts and causes misleading Zig stderr text; it can go without removing
those assertions. No normal OS polling cost is attributed to test-only helpers.

0.88.45 owns unrequested full diagnostic acquisition for owner checks. The actual
ClientInventory calls ProgramInventoryBegin into an unused large summary, then
reads full ProgramInstanceSnapshot pages, but consumes only handle/generation
and running state. Open and each200ms cleanup with open sessions pay this cost.
The kernel begin path captures program/task/thread/heap statistics, up to eight
stability attempts; full pages select diagnostic instance information. Existing
programLifecycleBegin/Programs provide the real minimal data and epoch without
that summary. Reuse this current mandatory API, preserving collectRunning and
all Unknown/Busy/restart/absence rules; do not add a second owner cache.

Protocol refinement for0.88.42: this service returns Open result=stream_id, a
legitimate positive value. Require consistency with the returned ID according
to that contract, never a zero-Open-success rule. Write result is accepted bytes;
Control success is zero. The common SDK source description above is clarified;
no SDK/product correction is silently included in this analysis.

Preservation findings: owner cleanup already has one traversal for all sessions;
incomplete/changed inventory cannot authorize absence. Empty sessions do not
schedule a cleanup deadline, although ServiceLoop keeps its separate stop check.
Output state caches discovery for500ms and avoids systemwide R4DEV diagnostics;
incomplete data cannot certify a live backend, and NoEndpoint invalidates the
route without losing desired selection. Lazy initial discrete zero PCM and
materialized continuous silence retain different timeline meanings.
Pending legacy Close is serviced by the normal loop with copied client/stream/
generation/request/deadline; dispatcher never blocks waiting for DMA. Duplicate
requests cannot replace or extend it. Real kernel close progress remains the
quittung, and timeout/Busy/hard errors do not become successful absence. The
tracked path keeps its separate finite response/progress contract. Normal
service-stop delegation to kernel process resource collection is not qualified
as already completed DMA by the service message or its reset local table.

Master persistence is debounced, coalesces identical snapshots and runs in a
joined worker; atomically published generation/values and a final exact join
protect storage lifetime. Save verification/atomic replacement and recoverable
failure reporting are functional, not disposable diagnostic reads. Public
request/write elapsed counters and status/silence/global byte/persist fields
have real IPC consumers. Selftest/status polling helpers are explicit CLI work,
not automatic per-block diagnostics. No additional proven service logic bug
or measured wait/gain is claimed in the bounded review.

Existing owner Build.sh test passed13/13 cases and16/16 steps, exit0: four pending
Close, four owner and five master/output-policy cases (including the actual
output-control check invoked by the master roundtrip case). R4M0 container build/
inspection also passed into Temp only; that completed temporary module was
removed, productive artifacts unchanged. The Zig stderr informational marker
printed a misleading failed-command line despite the successful summary/exit;
this is not a failed owner case. These host cases do not establish current live
AUDSVC restart/persistence/audio/DMA/physical sound. No new gate/full catalog or
STANDARD; docs/status and release marker only.

HDA/AC97 DMA, interrupt and lifecycle review (0.88.12)
----------------------------------------------------
Bounded review: actual HDA/AC97 PCM callbacks, copied queues/descriptors,
stream/command/control Work, CORB/RIRB and codec route programming, IRQ/cursor/
position recovery, coherency configuration and drain/stop/unregister ownership.
No new physical profile, native register trace, live guest or hearing acceptance.

0.88.49 owns unrequested HDA close diagnostics. Both physical Stop and successful
IdleCloseWork format large control/controller/core/runtime/idle (and carrier)
blocks without a detail guard. In the async path this occurs after stream unlock
but before callback return and terminal Work publication. Static PCI/codec data
is repeated too. Suppressed kernel Info output still pays driver formatting.
Gate requested detail acquisition/formatting and keep coherent short snapshots,
genuine errors and complete actual backend status/receipt semantics. No measured
serial delay or previous starvation cause is inferred from log-call order.

0.88.50 owns AC97's synchronous normal idle/close boundary. It has no distinct
nonwaiting Idle callback: Stop acquires stream up to100ms, drains with repeated
status reads/tick waits up to its original2000ms, then waits retained Work up to
100ms per handle. The first AUDSVC close can block here before it can retain a
Pending response. Preserve these real drain/retirement obligations in an
independently progressing resident owner rather than shorten waits or free DMA
early. HDA's existing asynchronous last-stream state is a lifecycle reference,
not proof that HDA carrier/PCM/IRQ details apply to AC97. Two seconds is an
existing bound, not an observed elapsed duration of a current run.

0.88.51 owns AC97's unproven INTx extra registrations. If MSI is absent/fails,
setup registers a representable PCI line then all GSI16..23. Every accepted
extra route counts as admission and can cause own port reads for unrelated IRQs.
Only actual proven routes should count. The existing HDA line/pin evidence
helper demonstrates the intended distinction; real AC97 shared routing needs
its own actual provider evidence. No measured lost IRQ or real hang claimed.

Preservation findings: HDA command bursts are already bounded and return to
tick pacing after the short response burst; unsolicited/mismatched replies
remain distinct. Capability/codec/topology/route preparation is tied to actual
initialization or control transitions, not decoded on every PCM sample. Native
PCM takes a bounded direct copy; foreign formats retain the canonical streaming
phase and complete reservation before DMA publication. Queue/CIV/period ownership
keeps exact descriptors and does not infer completion outside its own window.
Position-DMA/LPIB source validity, movement-based freeze and impossible-jump
checks are functional. A repeated position read cannot itself advance consumed.

IRQ handlers acknowledge own status and defer non-IRQ work; HDA coalesces a busy
refill owner with its release wake and keeps the independent control lane.
MMIO/DMA barriers, BDL/RUN/reset/position coherency and owned PCI-bit restore
remain. Actual HDA idle Close retains its absolute deadline, output/reset epoch,
postroll, real caller PCM and pending Work handles until completion/release.
Route/reset changes and timeout cannot certify old work. Physical Stop/Unregister
has distinct shutdown/IRQ/work/DMA obligations; HDMI silent carrier is an
intentional option, not an unconditional stopped descriptor. AC97 reset's tight
bounded port polling is not declared a universally removable wait without actual
controller timing evidence; its asynchronous close follow-up must preserve the
real reset/quiescence result. No blind sleep/barrier/cursor-check deletion.

Current existing driver owner steps passed: HDA80/80 cases,41/41 build steps;
AC977/7 cases,13/13 steps. Includes independent queue, Work, codec/command,
coherency, route/cursor/recovery/lifecycle/idle-drain helpers as selected by each
owner build. Actual caller/main/integration hardware is not covered merely by
those helper cases. R4M0 module builds/inspection succeeded into Temp, completed
temporary R4Ds removed; productive artifacts unchanged. No full system test,
new suite/gate, STANDARD, actual IRQ/PCI hardware/hot-unload/audio latency claim.
Only docs/status and release marker advance for this source analysis.

0.88.14 - Device, output and graphics/power lifecycle review (2026-10-29)
Scope: AUDSVC output_control/output_policy, kernel audio/core/outputs and display/audio_routes/output_state/power_state, HDA output/control/ELD, NVIDIA gsp_native_audio/output/power and AMDGPU display_audio/power. Source review only except the selected existing NVIDIA host test below.
Discovery/policy: the ordinary output cache has a 500 ms budget. Incomplete, duplicate or failed discovery cannot certify a new backend; selection retains an available previous route when possible. Unchanged active selection does not repeatedly activate the device. HDA control probes have bounded per-turn work and original deadlines. Receiver revisions and source generations invalidate availability before later PCM admission; ELD physical identity/revalidation must remain. A metadata snapshot or idle completion is not a DMA, IRQ, worker-retirement or physical-stop receipt.
Findings: 0.88.55 replaces repeated indexed prefix scans with coherent bound acquisition: for one backend with 32 outputs, AUDSVC enumeration including its terminal query causes 560 provider queries. No measured normal-load latency or reproduced mixed snapshot is claimed. 0.88.56 moves physically waiting output selection out of the service dispatcher, preserving exact request/owner/target and terminal receipts. Existing 0.88.49 covers verbose close summaries before terminal work completion; 0.88.50 covers synchronous AC97 idle. Private unused r4os_rust_display_audio_routes joins 0.88.48 after a definition-only active-source search; real Store logic and current driver publish/query entrypoints remain.
Graphics/power: kernel metadata requires exact source/receiver/output identities and monotonic revisions. NVIDIA serializes actual RM audio command completion before ready publication and does not reprogram a settled unchanged route. AMDGPU withdraws availability before stopping its audio transport and publishes ready after actual enable following the confirmed video receipt; metadata removal is separate from joined physical teardown. Power receipt validation and retained graphics resources cannot be replaced by timer success or an empty table.
Validation: unchanged NVIDIA Build.sh unit-test -Downer-test-filter='GSP transport orders range publication' -j1 --summary all: exit 0, 4/4 steps, 1/1 test. Its original reference-packet audio and power checks ran inside the existing transport case. The Zig runner also printed a misleading 'failed command' after deliberate test stderr; the actual summary and exit code are successful. AUDSVC policy/output oracles already passed in 0.88.10; HDA output/ELD/receiver cases in 0.88.12 were not rerun without a changed concern. No GPU module installation, R4OS execution, physical hotplug/reset/suspend/resume, audible continuity or native unload qualification was performed. Release metadata advances to 0.88.14 only; no product artifact, test inventory or benchmark changed.

0.88.15 - Audio producers, Desktop and shared-load review (2026-10-29)
Scope: BEEP/R4Synth PCM pacing and synth control; SDK subsystem_runtime/audio transport; actual SNES/GB/Basic production, presentation, persistence and audio feedback; Desktop asynchronous control. Review of current sources, not a new mixed-load experiment.
The chain retains distinct accounting for generated/queued source PCM, accepted service prefixes, kernel/backend admission, generation-bound DMA progress and unconfirmed retirement. Silence, mute, pause, source shortage, service delay and physical DMA underrun cannot be merged into one counter or inferred from a successful app exit. SID stop/ownership findings remain 0.88.52/.53; service/driver findings retain their original scope.
Findings: 0.88.57 addresses BEEP and R4Synth PlaybackPacer sleeps which count accepted PCM duration without subtracting already elapsed conversion/write/Busy/pause time. Prefill and real terminal close remain required. 0.88.58 addresses Runtime.run applying the relative nextWait calculated from the old cycle-start tick after guest work, persistence, presentation and audio operations; absolute deadlines can already have elapsed. New relative polling/Busy intervals must retain their semantics. Both are source/time-accounting findings, without a measured present-day audible or starvation claim.
Existing bounds: guest slices and catch-up admission remain bounded; no guest clock or work may be erased to improve the score. The runtime presents before issuing audio service operations, retires completed progress I/O before source refill, and limits per-cycle service operations. Basic feedback distinguishes accepted/suppressed/discarded PCM; application-side counts are not speaker receipts. SNES/GB persistence already uses AsyncStore. In SNES, checkpoint drain protects the durable base/delta ordering and cannot simply be removed as an unnecessary wait. Real close/persistence failures remain terminal evidence.
Measurement: detailed performance-host stage clocks belong to explicitly requested runs; normal FPS display defaults off. The SNES post-close diagnostic preparation remains 0.88.41. Existing SDK runtime/transport tests passed 72/72 in 0.88.9; no unchanged suite or STANDARD was repeated for this source analysis. Earlier native software/NVIDIA measurements, twenty older observations and the first mixed-load failure remain separate historical evidence. No new QEMU, hardware, hearing/latency or concurrent Desktop/audio qualification is claimed. Release metadata0.88.15 only; no product artifact or inventory count changed.

0.88.16 - Audio tests, instrumentation and diagnostic cost (2026-10-29)
Scope: explicit AudioDiag normal/LONG/PROGRESS/GAP and WAV host analysis, Spectra Desktop /AUDIO and performance checks, SDK runtime/transport oracles, kernel PCM/progress worker and HDA/AC97 counters/tests. The existing inventory identifies 27 direct AudioService/HDA/AC97/AudioDiag source entries; this is a bounded cross-review using 0.88.9-15, not execution of the whole test inventory.
Activation and cost: AudioDiag is a requested application; PROGRESS/GAP and WAV interpretation are separate checks. Spectra /AUDIO requires an isolated test Desktop, rather than a background production check. Host WAV fixtures/analyser run outside the measured playback window. Detailed SNES performance stage timing is explicitly instrumented, while source/accepted/backend/DMA/unconfirmed counts retain different meanings. The kernel progress task parks until actual work/due events and performs PCM progress; it is not merely a diagnostic observer. Transport progress informs pacing/backpressure and releases exact I/O storage.
Findings: 0.88.59 makes pure WriteTiming/backend-write and HDA/AC97 write/refill total/max/last duration sampling demand-dependent. These ticks and stores currently occur on every relevant operation even without a diagnosis. The known explicit AudioDiag/Spectra consumers mostly test duration consistency; no scheduling/PCM admission decision uses those duration fields. They are nevertheless public today: current contract/SDK/generic export readers must be checked, and inactive measurement must not silently mean zero latency. No measured aggregate speedup is claimed.
Related work remains 0.88.41 (post-close SNES report preparation), .44 (private AUDSVC counters/obsolete helpers/test print), .48 (unused private migration/test adapters), .49 (verbose synchronous close logs). Required accepted-prefix, source shortage, consumed/unconfirmed, real IRQ, DMA, exact generations, deadline and drain/close proofs remain. Existing hardware options and original fixtures are not obsolete OS fallbacks. Removing a metric must not remove its remaining useful oracle without evidence.
Validation: unchanged AudioDiag/Tests/Analyze-QemuWav.ps1 -SelfTest exited0: continuous signal accepted; legacy480/544 and injected sample loss rejected; diagnostic signal selected despite unrelated louder mixed audio. This is host analyser validation, not a new guest WAV, speaker or hardware receipt. The existing SDK72, AUDSVC13, HDA80 and AC977 cases already passed in the preceding analyses and were not repeated. No new gate, benchmark, test count, artifact or hardware qualification; only release metadata0.88.16 and this inventory status change. Historical original exports retain their actual versions, samples and limits.

0.88.42: bind audio replies to their stream and acknowledged PCM
----------------------------------------------------------------
SDK0.64.113 uses one stateless owner, r4os/audio_stream_reply.zig, for
ordinary synchronous and asynchronous reply acceptance. The complete120-byte
reply, magic/version/action and operation-specific values must agree before
any caller advances its confirmed PCM prefix or retires its stream ownership.
Open success retains the actual AUDSVC contract: positive result==stream_id;
a negative Open result has stream_id=0 and bytes=0. Existing-stream replies
must name the nonzero owned stream. Successful Write requires result==bytes,
nonzero bytes no larger than the submitted chunk and complete PCM frames.
Successful Volume/Close requires result=0 and bytes=0. Negative replies
contribute no new bytes. A malformed reply returns Invalid without silently
replaying possibly accepted audio or accepting an unrelated Close.

The public safe Rust owner delegates to the Zig audio owner. The legacy C
transport now calls the generated SDK data adapter for this same validation;
it no longer owns independent acceptance rules. Its header-only compatibility
predicate remains available. The existing typed Open/control buffer-length
errors and raw Write Invalid behavior are retained. Data projection contains
185types/169functions, private fingerprint17614999946340117096; the C facade
projection was regenerated and the GUI projection remained unchanged.
decodeProgress, drain, submit and poll method bodies are byte-identical to
the predecessor. Request/fence generations, deadlines, uncertain Open,
I/O-close BUSY and genuine resource retirement keep their existing semantics.

Before the fix, the actual native SDK table fixture failed four intended
checks: wrong-stream Write/control and inconsistent sync/async Open pairs.
After the fix76/76 owner cases pass. The C and safe Rust fixture matrices
cover stream/result/bytes/header/version/action/short/long errors, zero or
inconsistent Open pairs, ordinary positive IDs1/91/i32max, negative replies,
zero/oversized/unaligned writes, positive control replies, partial prefixes4
and4076 at the second RPC, preserved owner state and a subsequent valid Close.
There is no implicit third Write. Existing BUSY/timeout/negative prefix tests
remain. These malformed replies are host-fixture injections; the actual
AUDSVC was not observed returning such a reply.

Four native C/Rust platform groups plus four real compiler safety negatives,
49 data-owner cases, five original C/Rust data groups plus five ownership
compiler negatives, and279Desktop+3Geometry+1SDKclock cases pass. Linux and
Windows host tools, freestanding helpers and technical SDK113 export were
rebuilt. LanguageParity checks670files/35scopes/180root exports; its finalized
review digest is pinned by the export and actual Desktop receipt. The export
has547 input records for533 unique SDK paths, all checked against source.

Exactly eight changed module artifacts were versioned after comparison with
the141-module baseline: Desktop195, R4SNES34, R4GB22, R4Basic45, AudioDiag16,
R4Synth7, Beep8 and NetworkFacadeCDiag3. Their source changes are SDK inputs
and their own manifest versions. The other132 existing artifacts remain
byte-identical, including SysInfo12 and CStartSmoke4; RecoveryMenu is unbuilt.
Kernel423/WINSVC27/Contract59/Library source38 remain unchanged. Desktop's
SDK/library native helpers were rebuilt against the current SDK.

The own KVM4 guest verified4 configured/4 schedulable CPUs and full installed
AUDIOD16/SNES34/Desktop195 readbacks against the final artifact hashes.
Normal AUDIOD /OUT passed PCM, volume/mute, service restart/replay, four
lifecycle cycles, close, deadline and compact HDA evidence assertions. Its
endpoint ended with zero open sessions/queued requests/workers and no
BUSY/timeout/cancel errors. The unchanged continuity predicate requires no
new idle close because that case closes its stream explicitly after drain;
AudioDiagnostics.txt now describes this current requirement.

The original Spectra94 CHECK SUBSYSTEM /HOST /SNES also passes: two full60s
guest runs, each1288636320 master cycles/3605PPUframes, zero drift/pending
cycles, original PCM/input/video/SAV+RTC witnesses, independent end paths,
invalid/firmware rejection and owned Desktop exit0/reap. D2 reports2 begun
and2 completed asynchronous saves with0errors. Full original exports, four
reports and HDA records are retained unchanged under
ExFiles/Reports/Audio/0.88.42-replies/. The guest was shut down normally and
its private Source image removed. Its initial release marker was0.88.41;
the exact installed artifacts, rather than that old marker, bind this proof.
No physical hearing, input latency or isolated speed gain is claimed.

Final hashes and all qualified inputs: Temp/08842-runtime-proof.json and
Temp/08842-artifacts-final-before-image.json. The sole final STANDARD42 uses
the new0.88.42 marker and is documented separately after its original export
has been validated. Inventories remain141modules/1071test files/483documents.

Finaler STANDARD und Abschluss zu0.88.42
----------------------------------------
Einziger finaler STANDARD42: 30104894-12ac-436d-a262-ff06e9cc9546, Suite3/Metric2/KVM4,
30Samples/4Worker/6gueltigeScores, overall=164.128236.
OriginalSHA256 e71496ac0a7726193df19afc0b67bb88c60c47aed77ca445610109bd86ff59a4.
Alle Arbeitsmengen, Workerzahlen, Batch-/Bytewerte und sechs Scores wurden
verlustfrei gegen Referenz28b326e2-4323-4a4c-a0d2-4c1bab4958c0 validiert.
Das vollstaendige Original blieb unveraendert und liegt unter
ExFiles/Reports/Benchmarks/30104894-12ac-436d-a262-ff06e9cc9546/.
Status: lokal validiert; R4OS Server ausstehend (Import und Readback).
Dies ist die allgemeine Systemkontextmessung; keine Messung eines isolierten
Audio-Pruefungs-, Spiel- oder Hoergewinns.141Module/1071Testdateien/483Dokumente.

0.88.43: terminal audio wait checks real retirement before backoff
-----------------------------------------------------------------
SDK0.64.114 changes only the product Transport.drain method. After a successful
ioWait reports completed or failed, drain immediately invokes its actual
poll/status/ioClose path. Wait publication is not permission to reuse memory.
If that poll has actually submitted the next request in an existing bounded
chain, drain continues without inserting a tick. A still blocked or transient
status/close keeps its storage and uses the existing one-tick backoff.
No new worker, PCM backlog, automatic replay or completion publication exists.

All other product bytes before the private test Probe are identical to SDK113:
interactive submit/poll/open/write/volume, ordinary/progress decoding, source
time, uncertain Open/fence, closeWithTimeout and finish. The finite absolute
Close RPC budget and unlimited wait for actual storage retirement remain
separate. Public C/Rust signatures, schemas and generated projections are
unchanged. Native C/Rust consumers are rebuilt against the current SDK.

The actual native-table fixture failed three new ordering groups on the old
drain (59/62). The fixed owner passes79/79:62runtime and17platform/PCM/power.
Completed and failed waits retire before any sleep. Running/transient waits,
repeated ioClose BUSY and status BUSY still back off, retaining the same401
request and copied1920-byte PCM; another Write remains BUSY, no additional
service request appears and only one final completion is delivered. The
continuous discover/configure/tracked chain keeps its original200/180/150tick
budgets and confirmed partial prefix; expiration at201 prevents PCM submission.
Original uncertain-Open/fence, frame/prefix, shutdown-failure and pacing cases
remain. The fixture models native tables, not actual DMA/service retirement.

LanguageParity checks670files/35scopes/180exports. The SDK114 review was frozen
before technical tool export and actual Desktop receipts;547export records
cover533 unique SDK paths and all match source. Current Desktop279+3Geometry+
1SDKclock checks pass. Exact artifact comparison versions only the changed
modules: Desktop0.1.196, R4Basic1.2.46, R4GB0.10.23, R4SNES0.22.35. The other136 existing artifacts
remain byte-identical, including AUDIOD16/Synth7/Beep8; RecoveryMenu is unbuilt.
Kernel423/WINSVC27/Contract59/Library source38 remain unchanged.

An own KVM4 guest confirmed4 configured/4 schedulable CPUs and full installed
AUDIOD/SNES/Desktop readbacks. Original AUDIOD PCM/master/restart/lifecycle/
drain/close/deadline/HDA-record checks pass and leave no open audio sessions.
Original Spectra94 CHECK SUBSYSTEM /HOST /SNES passes two full60s guest runs
with the actual current SNES: each1288636320 master cycles/3605PPUframes,
zero drift/pending, original PCM/input/video/SAV+RTC witnesses, independent
end paths, invalid/firmware rejection and owned Desktop exit0/reap. Reset and
close consume actual stream acknowledgements. Normal POWEROFF and private
Source cleanup are confirmed. Full original reports/exports remain under
ExFiles/Reports/Audio/0.88.43-drain/. The native image initially carried the
old0.88.42 marker; exact installed artifact hashes bind this qualification.

This removes an imposed source tick before the first retirement check after
a terminal Wait. No isolated native teardown duration, physical hearing or
latency gain is measured. The sole final STANDARD43 and its full original
validation are documented separately below.141modules/1071test files/483docs.

Finaler STANDARD und Abschluss zu0.88.43
----------------------------------------
Einziger finaler STANDARD43: 8637ca41-d56c-4a6f-87e7-998e1fb92178, Suite3/Metric2/KVM4,
30Samples/4Worker/6gueltigeScores, overall=157.640471.
OriginalSHA256 9be9b9029467ba78cbd88739bb5afa4cf5da36106a61127adb66ecd8e9b36a22.
Alle Arbeitsmengen, Workerzahlen, Batch-/Bytewerte und sechs Scores wurden
verlustfrei gegen Referenz28b326e2-4323-4a4c-a0d2-4c1bab4958c0 validiert.
Das vollstaendige Original blieb unveraendert und liegt unter
ExFiles/Reports/Benchmarks/8637ca41-d56c-4a6f-87e7-998e1fb92178/.
Status: lokal validiert; R4OS Server ausstehend (Import und Readback).
Dies ist die allgemeine Systemkontextmessung; keine Messung eines isolierten
Audio-Drain-, Spiel- oder Hoergewinns.141Module/1071Testdateien/483Dokumente.

0.88.44: unused service writes counter and obsolete owner test cleanup
----------------------------------------------------------------------
AUDSVC0.1.18 removes the private Session.writes field and its two unused
increments. Session.bytes_written remains: replyTrackedState publishes its
sum with suppressed_bytes as accepted_source_bytes. Its increment, all public
global byte/status/latency/silence/master counters, real flow/generation and
pending-close state are unchanged. The complete main.zig delta is exactly
the one field and two increment lines; all remaining source bytes match.
The current source-consumer check therefore refines the old analysis: the
per-session byte counter is productive and is preserved by the canonical44
scope and task2, rather than removed together with the unused writes field.

The actual SDK114 rebuild of the original service17 is byte-identical to its
baseline. Its linked production ELF contains an incq at Session offset224 in
the lazy-silence path and a paired writes/bytes-written vector update in the
signal path. The optimized production IR confirms both stores. Service18
removes the unused counter work while keeping a scalar byte addition; its
private Session type shrinks272->264bytes, or128bytes across the16-slot array.
This is a struct/code result, not a measured resident-memory or time saving.

The obsolete clientIsRunning/runningRecordMatches functions, their sole
ID-only self-test and the informational AUDSVCWORK print are removed. Those
helpers and print already had no normal ELF symbols/work, so their cleanup
is not an OS polling improvement. Actual collectRunning generation/paged/
incomplete-inventory behavior, duplicate/reused IDs, new-stream generation
binding, matches/isSilence and the exact one-begin/one-read assertions remain.
Master/output and real delayed-close tests are unchanged. Before13/13 owner
cases pass; after12/12 retained cases and16/16 build steps pass without the
old misleading print-related failed-command line. No test file or gate was
added or removed; Tests.json continues to describe1071files.

Exactly one canonical artifact changes: AUDSVC0.1.18, SHA256
a3ab0c062408cdd0c0153fbc5408a81ec7174fbc803269980d8510ded450a5a0.
The other139 existing artifacts remain byte-identical; RecoveryMenu is
unbuilt. SDK114/Desktop196/SNES35/Kernel423/WINSVC27/Contract59/Library source38
remain unchanged, including their previously qualified current source inputs.

The own KVM4 guest verifies4 configured/4 schedulable CPUs and full installed
AUDSVC18/AUDIOD16/Desktop196/SNES35 readbacks. Original normal AUDIOD PCM,
master/restart/replay/lifecycle/drain/close/deadline/HDA checks pass. Original
PROGRESS confirms480accepted/consumed, stale-generation rejection and two
closes. Original GAP confirms1440accepted/backend/DMA/consumed,480silent,
zero suppression/unconfirmed, one stream/open, no silent close, actual Close
quittung and restored resources; retry count is its actual observed count.
The endpoint then has zero open audio sessions. Original Spectra94 SNES
acceptance also passes two full60s guests/each1288636320cycles/3605PPUframes,
zero drift/pending, PCM/input/video/SAV+RTC witnesses, reset, independent ends,
invalid/firmware rejection and owned Desktop exit0/reap.

Normal POWEROFF and private Source cleanup are confirmed. Unchanged original
reports, HDA data, actual installed service bytes and before/after optimized
IR/assembly remain under ExFiles/Reports/Audio/0.88.44-counter-cleanup/.
The native image initially carried the old0.88.43 marker; exact installed
service bytes bind this proof. No physical hearing/latency or isolated CPU/
time/RSS gain is claimed. The sole final STANDARD44 is documented separately
after its full original validation. Inventories remain141modules/1071test
files/483documents. Source proof: Temp/08844-source-qualification.json.

Finaler STANDARD und Abschluss zu0.88.44
----------------------------------------
Einziger finaler STANDARD44: 0abb6347-b653-4be3-acf6-08df3762eb17, Suite3/Metric2/KVM4,
30Samples/4Worker/6gueltigeScores, overall=151.334240.
OriginalSHA256 5a2054c22cdecd86c2fc21887cd0cbc6ced36cbe25248a3889709a25ab6125c7.
Alle Arbeitsmengen, Workerzahlen, Batch-/Bytewerte und sechs Scores wurden
verlustfrei gegen Referenz28b326e2-4323-4a4c-a0d2-4c1bab4958c0 validiert.
Das vollstaendige Original blieb unveraendert und liegt unter
ExFiles/Reports/Benchmarks/0abb6347-b653-4be3-acf6-08df3762eb17/.
Status: lokal validiert; R4OS Server ausstehend (Import und Readback).
Dies ist die allgemeine Systemkontextmessung; keine Messung eines isolierten
Zaehler-, CPUzeit- oder Hoergewinns.141Module/1071Testdateien/483Dokumente.

0.88.45: service owner acquisition uses the minimal lifecycle registry
----------------------------------------------------------------------
AUDSVC0.1.19 changes its actual ClientInventory reader to the existing current
R4SYS programLifecycleBegin/programLifecyclePrograms API. Its16 native rows
are ProgramLifecycleSnapshot rather than ProgramInstanceSnapshot. The reader
consumes the same handle.instance_id/generation and state0running/1closing/
2done. The unused ProgramInventorySummary local is gone. Existing cursor/
snapshot-generation, returned-count and complete/more checks remain. There
is no second owner list, cache, ID-only authority or diagnostic fallback.

The actual reader is in the existing session_ownership module and is aliased
by both unchanged main Open and shared200ms cleanup callsites. Existing
collectRunning and all three original owner groups are byte-identical. Busy,
Restart, invalid/incomplete pages or changed epochs return no absence
authority; callers retain their existing conservative behavior. A complete
empty snapshot can establish absence, while a positive shared-owner result
may still finish early on a more page. Real pending-close acknowledgement,
master/output/persistence behavior and per-session byte progress are intact.

Kernel423 source binds lifecycleBegin to the same program registry epoch with
a nonblocking lock. Lifecycle pages use scan(false)/lifecycle_info and keep
the same ID/generation/state without vm_stats or the full diagnostic begin's
task/thread/heap summary acquisition. Restart emits no rows and advances no
cursor. The existing Desktop LifecycleReader/SDK Resources::Lifecycle uses
this current contract. No Kernel, SDK or public ABI change is needed.

Three added groups in the existing owner test step execute this actual reader
through controlled native tables. The old diagnostic reader fails those
three intended call-boundary checks (12/15); the new reader passes15/15 cases
and16/16 build steps, including6ownership/4master/5pending-close cases. They
count exactly1LifecycleBegin and the expected0/1/2LifecyclePages with0full
diagnostic Begin/Programs calls. Running/closing/done, reused IDs, initial
generation binding,16duplicate owners, complete-empty vs incomplete-empty,
Begin/PageBusy, Restart, epoch mismatch, invalid status, bounds and a later
page failure retain their original generation/absence semantics. No test
file, gate or normal runtime measurement counter was added. The host callback
counts do not claim native kernel timing; the real producer is source-checked.

Actual optimized ClientInventory shrinks2776->1112bytes: the row buffer is
2304->640bytes,1664bytes smaller, and the separate old160byte begin summary
is no longer requested. This is structural/call-path evidence, not measured
native latency, RSS or isolated CPU savings. Only AUDSVC changes, version19,
SHA256 d32c7bc85ee5aa4c16169a53c638e67342f2058e3036d59807f83f6104c4fef8.
The other139existing artifacts are byte-identical, with RecoveryMenu unbuilt.
SDK114/Desktop196/SNES35/Kernel423/WINSVC27/Contract59/Library source38 remain.

An own KVM4 guest verifies4configured/4schedulable CPUs and full installed
AUDSVC19/AUDIOD16/Desktop196/SNES35 readbacks. Original AUDIOD PCM/master/
restart/replay/lifecycle/drain/close/deadline/HDA checks pass; original
PROGRESS480/stale-generation/two-close and GAP1440accepted/backend/DMA/
consumed/one-stream/restored-resources oracles pass, with actual Close retry
counts retained. The endpoint ends with0open sessions. Original Spectra94
SNES acceptance passes twofull60s guests/each1288636320cycles/3605PPUframes,
zero drift/pending, PCM/input/video/SAV+RTC, reset/independent ends, invalid/
firmware rejection and owned Desktop exit0/reap. The guest shuts down
normally and its private Source image is removed. Original reports/exports,
actual installed service and optimized IR remain under
ExFiles/Reports/Audio/0.88.45-owner-lifecycle/. Its initial image marker was
0.88.44; exact installed artifacts bind this proof. No physical hearing or
latency claim. The sole final STANDARD45 follows separately after original
validation.141modules/1071test files/483documents; source/contract proofs in
Temp/08845-source-qualification.json and Temp/08845-contract-proof.json.

Finaler STANDARD und Abschluss zu0.88.45
----------------------------------------
Einziger finaler STANDARD45: 1ba7b15d-9e05-47ba-ba3f-53d5d9ae8a79, Suite3/Metric2/KVM4,
30Samples/4Worker/6gueltigeScores, overall=154.036242.
OriginalSHA256 d21ad5960f467d4b268fdcd7749689f7593998e24dc976fb291833da1a51f07a.
Alle Arbeitsmengen, Workerzahlen, Batch-/Bytewerte und sechs Scores wurden
verlustfrei gegen Referenz28b326e2-4323-4a4c-a0d2-4c1bab4958c0 validiert.
Das vollstaendige Original blieb unveraendert und liegt unter
ExFiles/Reports/Benchmarks/1ba7b15d-9e05-47ba-ba3f-53d5d9ae8a79/.
Status: lokal validiert; R4OS Server ausstehend (Import und Readback).
Dies ist die allgemeine Systemkontextmessung; keine Messung eines isolierten
Lifecycle-, CPUzeit- oder Hoergewinns.141Module/1071Testdateien/483Dokumente.

0.88.46: remove unreachable private audio force/deferral bookkeeping
--------------------------------------------------------------------
Kernel0.1.424 removes the always-true force argument from pump_goal_locked,
pump_output_owned and pump_available_output_owned. Every current productive
caller passed true: owner-close reserved masks, individual-stream drain masks
and the audio worker. The only force consumer was the unreachable optional
open_count>1 && !force && !deferred_once branch. Its private Stream field,
initial value, resets and sole open_count/was_empty bookkeeping are removed.
No public platform API, contract type, module or SDK changes.

The actual mixing, exact reserved/target PumpGoal masks, output leases,
read reservations, partial admission and ring consumption remain unchanged.
Actual2ms BUSY, ledger, backend and flow progress schedules remain. This is
not a removed current2ms wait: the deleted branch never ran. Source cleanup
does not establish an isolated throughput or latency gain. The optimized
ELF does change before version metadata, hence the artifact version424.
Final SHA256 69d254933cec7a8162be4d84cc92257bf77ebb2eb1ce029252972c76b999a0b8.
All140existing module artifacts/manifests stay byte-identical; RecoveryMenu
remains unbuilt. SDK114/Desktop196/WINSVC27/AUDSVC19/SNES35/Contract59 and
Library source38 remain unchanged.

Pinned fmt/check/clippy and final kernel build pass. Three original current
Rust playback host cases retain mixed partial retirement/reset/reused-stream,
invalid-tail FIFO/DMA-hole and repeated-read/deadline oracles. Four exact
historical Zig mixer facade tests from1f870ac3^:audio/mixer.zig execute against
the current Rust mixer C ABI: owner generations, ringwrap, bitexact unity,
volume scaling and multi-source saturation. Only temporary no_std host
panic/personality glue is added; this is neither an old-kernel build nor a
physical audio test. No persistent test file, gate or runtime probe is added.

An own KVM4 guest verifies four configured/schedulable CPUs, actual active
and installed Kernel424, exact BOOT artifact hash and full installed
AUDSVC19/AUDIOD16/Desktop196/SNES35 readbacks. Original AUDIOD PCM/master/
restart/replay/lifecycle/drain/close/deadline/HDA checks, PROGRESS480 with
stale generation/two closes, and GAP1440 accepted/backend/DMA/consumed with
one stream/restored resources pass. Actual close retry counts remain in
the originals; the endpoint ends with zero open sessions. Original Spectra94
SNES acceptance runs two full60s guests with PCM/input/video/SAV+RTC, reset,
independent endings, invalid/firmware rejection and owned Desktop exit0/reap.
Normal POWEROFF is observed and only the private Source image is removed.
The initial image release marker was0.88.45; exact artifacts bind this proof.
Original exports/reports and host provenance are retained under
ExFiles/Reports/Audio/0.88.46-force-cleanup/. No physical hearing, isolated
CPU time or speaker latency claim. The sole final STANDARD46 follows after
original validation.141modules/1071test files/483documents. Source proof:
Temp/08846-source-qualification.json; native closure:08846-runtime-proof.json.

Finaler STANDARD und Abschluss zu0.88.46
----------------------------------------
Einziger finaler STANDARD46: 70f861f9-a4a1-4b07-bc46-51024c535900, Suite3/Metric2/KVM4,
30Samples/4Worker/6gueltigeScores, overall=152.573831.
OriginalSHA256 40dac0f7b58ad5804f06a294d6a0619de788379208f123d038ae14aa918bb30c.
Alle Arbeitsmengen, Workerzahlen, Batch-/Bytewerte und sechs Scores wurden
verlustfrei gegen Referenz28b326e2-4323-4a4c-a0d2-4c1bab4958c0 validiert.
Das vollstaendige Original blieb unveraendert und liegt unter
ExFiles/Reports/Benchmarks/70f861f9-a4a1-4b07-bc46-51024c535900/.
Status: lokal validiert; R4OS Server ausstehend (Import und Readback).
Dies ist die allgemeine Systemkontextmessung; keine Messung eines isolierten
Deferral-, CPUzeit- oder Hoergewinns.141Module/1071Testdateien/483Dokumente.
