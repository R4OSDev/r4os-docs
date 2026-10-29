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
