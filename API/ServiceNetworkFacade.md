# Service and network facade

The SDK exposes owning lifecycle objects over R4SYS service endpoints and
R4NET network operations. It does not contain a second IPC or network stack.

## Services

A service connection owns open, call and close. A service endpoint owns
register, wait, receive, reply and unregister. Successful close/unregister
invalidates the wrapper. Payload and response buffers remain caller-owned for
the documented call duration.

Endpoint requests are delivered in admission order, independently of reused
payload slots and request-ID wrap. Cancellation removes only that request
from the order; a receive buffer that is too small leaves the head pending.

A caller can cancel after its request was delivered. The raw reply API then
returns `service_api_result_not_found`, while an invalid endpoint remains a
separate error. Service handlers can use `app_services.replyIfPending` or the
owning `ServiceEndpoint.replyIfPending` / `replyTypedIfPending` methods to
finish this expected late reply without terminating their loop. Their zero
result means processing may continue; it does not claim delivery to the
cancelled caller. Other reply errors still propagate, and `ServiceLoop.drain`
continues to propagate arbitrary handler/provider failures unchanged.

### Desktop notification area

`app.tray()` in Zig and `r4_app_tray()` in C bind a client to its exact
program generation and expose status, upsert, remove and finite event-wait
operations as a logical tray contract multiplexed on the existing `WINSVC`
endpoint. WINSVC brokers copied state and events while the exact R4DESK
generation remains the sole owner of layout, rendering and input. Upsert
copies a bounded tooltip and an exact 16x16 straight-alpha ARGB32 icon into
one atomic request; the provider keeps no buffer ownership after the call.

Item IDs are stable only inside one owner generation and revisions must
increase when state changes. Responses expose the Desktop epoch, registry
revision, capacity and whether an item currently exists and is layout-visible.
An epoch change means that the provider must publish its current state again.
Primary, double, context and wheel events carry a per-owner monotonic sequence;
only one finite wait may be outstanding per owner. Providers must tolerate a
missing service, timeouts, bounded queue overflow and Desktop restart without
polling continuously. The facade uses the normal Userland service IPC and does
not add a platform-table function or a separate service process.

## DNS, TCP and UDP

Resolver, TCP socket/listener and UDP socket wrappers use DNSSVC, TCPSVC and
UDPSVC through R4NET. Connect, accept, read, write, close, timeout,
would-block and stale-handle states remain distinct. One absolute deadline is
shared across all phases of a bounded operation.

The paced TCP writer first submits the largest service-safe chunk (up to
4,068 bytes). Kernel TCP performs MSS segmentation and reports exact partial
progress. A service poll is requested only after a write returns no progress;
the SDK does not pre-poll every chunk. The optional R4NET
`tcp_performance` snapshot provides diagnostic counters without changing the
service message size or queue depth.

## Web and update services

The web facade composes the existing DNS/TCP, HTTP and TLS owners. The update
client uses UPDSVC and the shared update-service contract in
`Repositories/SDK/r4os/update_service_contract.zig`; all clients observe the
same durable job rather than starting private installers.

Zig and C wrappers share generated layouts and are validated by the SDK and
Contract conformance tests.

## 0.88.79 TCP-Deadlines und bestätigter Fortschritt

Lieferpaar: SDK0.64.122 Commit a1274c7d1fa370a6818204ade41aca0b3378de21,
Contract0.64.65 Commit dded1377ee6c603c3a47903bc4086432eaf72584,
TCPSVC0.1.9 SHA256 b8b4e0660e890c6bf589135325e36464b466430fb6f6b27ef2b6c3ffc25fc472.
Kernel0.1.446 SHA256 dd9913991fdf3066e85edc5cafb8313f5b5a710c12b0c0b7b756b4d922b01224 bleibt unverändert.
Kein neuer Kernelbuild oder Kernel-/Modul-ABI-Versionssprung.

C/Rust/Zig tragen für Connect/Listen/Accept/Read/Write/Poll/Close denselben
24-Byte-ServiceDeadlineFooter. Ein endliches Budget beginnt vor Discovery;
nach Discovery verbleiben nur die übrigen nativen Ticks. Queuezeit wird
durch die absolute Serverfrist erfasst. TCPSVC prüft endliche Fristen vor
jeder Backendzulassung und vor dem nächsten deferred Read/Write/Accept.
Bereits zugelassene Wirkung wird durch späteren Fristablauf nicht rückgängig.
Poll benutzt den ergänzten TCPSVC-Sentinel0: höchstens ein unmittelbarer
Versuch, kein Deferred-/blockierender Connectpfad. Forever bleibt MAX.
Finite Overflow darf nicht zu Forever werden. Fehlender Footer bleibt
Legacy: Read/Write50ms, Accept unmittelbar, Connect bestehende RTO/Retry-Policy.
Die technischen APIs behalten ausdrücklich getrennte Operations-, Completion-
und Drainbudgets; ihre bewusste Low-Level-Steuerung wird nicht überschrieben.

C R4_NET_RESULT_OUTCOME_UNKNOWN=9 und r4_net_progress_known sowie Rust
SocketState::OutcomeUnknown und confirmed_bytes()->Option unterscheiden
fehlende gültige Serverantwort nach Einreichung von bestätigtem Nullfortschritt.
bytes0 in diesem Fall ist kein bestätigter Zähler. Ein vor Einreichung
abgewiesener Aufruf bleibt bekannter Nullfortschritt. Gültige Serverantworten
bewahren einen Teilpräfix auch neben Timeout/Terminalstatus. Zig bewahrt die
bestehende Ergebnisunion: native Servicefehler sind failure ohne Bytezähler,
serverseitig bestätigter Null-Timeout ist timed_out, positiver bestätigter
Präfix ist bytes(n). Wer gleichzeitig Terminalstatus und Zähler benötigt,
nutzt den technischen strukturierten Reply. Keine automatische Wiederholung
nichtidempotenter Reads/Writes/POSTs. Ein Servicezähler quittiert die
Backendannahme/akzeptierte Sendesegmente, keinen TCP-Peer-ACK; TLS-Recordbytes
und HTTP-Nutzbytes bleiben getrennt. Die Ursache des externen Nexus-TLS-Fehlers
ist weiterhin unbewiesen. Nexus bleibt auf SDK92/Contract45; Migration separat.

Wirelayout, Footergröße/Offsets, R4NetResult12B, Slots und Signaturen bleiben
unverändert. Contract ergänzt drei Konstanten und präzisiert genau eine
Deadlinebeschreibung; normale Generierung/Baselineprüfung bestanden.
Normale C-/Rust-Projektion und unveränderte GUI-Grenze compilergeprüft.
Ein zunächst reflektierter öffentlicher Zig-Methodenhelfer wurde vor der
Veröffentlichung als Top-Level-Funktion angeordnet: keine GUI-ID-/Fingerprint-
Änderung. Erste Guard-/Adapter-/Compilefehler und Originale bleiben erhalten.
Frische normale C-/Zig-Runtimes, Rust-Nativziel-Typprüfung, TCPSVC9-Normalbuild
und alle drei öffentlichen Gastverbraucher bestanden. Sieben unveränderte
SDK-Werkzeugkomponenten mit zwei frischen Laufzeitobjekten normal exportiert.

Nur drei gezielte Hostfälle: tatsächliche C-Fassade (alte Quelle FAIL101,
neue PASS) sowie zwei exakte Providerquellfälle (vorher2FAIL/nachher2PASS).
Kontrollierte Uhr/Backend/Replyblätter sind kein physischer Nativebeweis.
Keine breite RustServices-/Transportmatrix und kein PROGRAMLIFECYCLE-Replay.
Ein KVM4-Softwaregast1154438 (installierter Marker noch0.88.78 vor der
abschließenden Dokumentation/Marker79) prüft C/Rust/Zig am selben Peer:
je4B-Tag, erster Read20ms endet ohne bestätigte Wirkung (C9/known0,
Rust OutcomeUnknown/None, Zig failure); Peer sendet erst nach800ms16B.
Ein ausdrücklich frischer kontrollierter Forever-Read erhält alle16B.
Dies ist kein automatisches Retry einer unbekannten Wirkung.
Alle drei echten Prozessabschlüsse Exit0, voller Text, Closequittung;
Peer beobachtet je EOF und keine doppelten Anwendungswrites.
Nach einmal3.5s bestehender TCP-Nachlaufzeit zeigt das vollständige
NETWORK-Inventar keine der eigenen Zielport43221-Verbindungen mehr; eine
fremde SSH-Verbindung bleibt. Geschlossener Frontref und tatsächlicher
TCP-Registryslot-Abbau getrennt belegt, kein globaler Null-/NIC-DMA-/Heap-
Freigabeclaim. Alle installierten Binärdateien vollständig rückgelesen.
Einmal normales POWEROFF/terminal, eigene Imagequelle per Retention entfernt.

Release0.88.79. Bestand141Module/1089Tests/483Docs, bestehende Notizen ergänzt,
keine neue Messstelle, Queue, Ownerverwaltung oder gelockerte Oracle.
140 normale Module: nur TCPSVC geändert,139 bytegleich. Kernel446 bleibt.
Finale SDK-Binärpakete92 und Slim/Full93 erst nach allen funktionalen
Befunden94–98; tatsächlicher finaler Marker mindestens0.88.98.
Originale: ExFiles/Reports/Core/0.88.79-tcp-deadlines/;
Temp/08879-native-proof.json, SDK-/Contract-Publikationsbelege.

STANDARD79 abgeschlossen: e0631a6b-31fd-445e-8815-69dbf79d4db7; Suite3/Metric2/KVM4, overall 129.931272.
Alle30 Samples mit je4 abgeschlossenen Workern und alle6 Scores verlustfrei
ueber uint64/Decimal gegen Referenz28b326e2-4323-4a4c-a0d2-4c1bab4958c0
validiert. Optionaler observer_overhead_ns bleibt null/unavailable; keine
gemessene0 daraus. Vollstaendiges unveraendertes Original SHA256:
143a50b7a71fe643584e66d308bb4b5c5698f97d9286633c9cd182ef17beec8a
Archiv: ExFiles/Reports/Benchmarks/e0631a6b-31fd-445e-8815-69dbf79d4db7/.
Serverimport/-readback ausstehend; kein isolierter Geschwindigkeitsnachweis.
