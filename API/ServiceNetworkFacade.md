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
Aktuelle kanonische Releaseplanung: finales SDK0.88.99 nach allen
funktionalen Befunden94–98, danach R4OS-Slim/Full0.88.100 mit finalem
Release-Marker0.88.100. Die bisherigen Stufen92/93 wurden bei gleichen
internen API-IDs92/93 in99/100 umbenannt; ältere Planverweise sind überholt.
Qualifizierte Quellen, öffentliche Pakete und spätere Studio-Gastabnahme
bleiben getrennt. Reine Verpackung/Publikation braucht keinen neuen STANDARD.
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

## 0.88.80 TCP-Readiness und lokaler Socketbesitz

SDK0.64.123 Commit 88ce1139dbaaa4aeb1d1215d447abec212538f0e, Paketidentität
r4os_sdk-0.64.123-NnPzAum62wHsgXArzMzl9c_gb9ZvbBJ2knl2K6YcpvEa.
Contract0.64.65/TCPSVC0.1.9/Kernel0.1.446 bleiben unverändert. Erforderliche
R4OS-Basis ist der in0.88.79 qualifizierte Laufzeitsatz. Ein öffentliches
Quellarchiv ist kein neues vollständiges binäres SDK-Release; die finale
SDK-Verpackung folgt in0.88.99, R4OS-Slim/Full danach in0.88.100.

C r4_tcp_socket_readiness liefert einen neuen R4TcpPollResult44B
(result12B/bestehender R4SdkTcpReadiness28B/available4B). Rust
TcpSocket::readiness liefert TcpPoll mit Operationsausgang und Option des
bestehenden TcpReadiness-Alias. Zig benutzt die freie Funktion
app_network.tcpReadiness(&socket, timeout); keine neue reflektierte Methode.
Readability/pending_rx, Peer-Ende, Reset, terminaler Zustand, Fenster und
Status sind unabhängig. Ein Snapshot kann peer_closed UND readable sein.
available/Option bezeichnet die gültige strukturierte Antwort; bei fehlender
oder ungültiger Antwort gibt es keine erfundene Snapshotnull. Die bisherige
poll-Funktion bleibt Zustandssicht mit0 übertragenen Bytes. Nutzer, die
poll.bytes als Verfügbarkeit lasen, müssen readiness.pending_rx verwenden.
Ein Poll konsumiert keine Daten; pending_rx ist kein Transferfortschritt.

TCP Read/Write/Poll verwerfen raw weder bei PeerClosed noch Reset/Closed/
BackendBadHandle. valid() bezeichnet den lokalen Token, keine Providerprobe.
Der Kernel kann seinen Backendhandle nach dem letzten RX-Drain retiret
haben; TCPSVC hält seine Frontreferenz trotzdem bis Close. Strukturierte
Readpräfixe bleiben validiert und kopiert. Erst gültige explizite Close-/
Invaliditätsquittung im Closepfad löscht den lokalen Token. Unknown/Timeout
beim Close bleibt unbestätigt. Borrowed owned0 besitzt keine Closepflicht;
Rust-Drop versucht bei owned/raw!=0 weiter best-effort Poll-Close. Drop
allein ist kein ACK; wer ihn braucht, wertet vorher explizit close aus.

Bestehender TCP-Kernel: FIN setzt Closed mit noch drainbarem RX-Puffer.
Dies erweitert keine Halfclose-Sendefähigkeit. Nach Drain kann ein weiterer
Read/Poll Provider-Closed/BadHandle liefern; der Frontend-Close bleibt nötig.
TCP-Ende ist weder TLS-close_notify noch vollständiger HTTP-/SSE-Abschluss.
Kein Nexus-Datenverlust-/TLS-Ursachenclaim oder automatische Pinänderung.
Nexus bleibt bei SDK92/Contract45; HTTP-POST-Streaming folgt getrennt in81.

Normale aktuelle Compilerprojektion write/check und Rust-Nativziel-Typprüfung
bestanden. Alle2307 bisherigen Typ-/Layoutblöcke,14864 Funktionssignaturen
und5093 Konstanten/Aliase bleiben exakt. Neu sind nur Typ und Zugriff.
Die erzeugte Deklarationsreihenfolge verschiebt sich, weil app_network den
bestehenden net_bridge-Typ vor dessen Gebrauch einbezieht; keine Handänderung
erzeugter Dateien oder neue Plattform-/Wire-/Slot-/Contractrevision.
GUI-Header/Fingerprint bytegleich und aktueller normaler Zig-Runtime-FPguard
bestanden. C-/Zig-Runtimeobjekte frisch gebaut, sieben übrige Werkzeug-/Heap-
Komponenten unverändert normal exportiert. Erster Zig-Normalbuild meldete
nach Entfernung der raw-Mutation einen ungenutzten privaten self-Parameter;
Original erhalten, Parametername korrigiert, fehlgeschlagener Anteil gebaut.
Keine Wiederholung des bereits bestandenen unveränderten C-Hostfalls.

Usersteuerung SPARSAM: ein gebündelter C-Hostprotokollfall. Alter SDK122-
Stand scheitert181, neue Quelle besteht FIN/24Restbytes/5B-Drain/EOF/
Reset/IOBadHandle/UnknownClose/Borrow/KnownClose/malformedNoCopy.
Kontrollierte Clock/Serviceblätter sind kein physischer Nativebeweis.
Vorhandene C-/Zig-/Rust-Fixtureerwartungen gezielt angepasst; keine breite
RustServices-/Transport-/PROGRAMLIFECYCLE-Suite ausgeführt.

Ein KVM4-Softwaregast1166822 (installierter Marker noch0.88.79) qualifiziert
im ersten Versuch die drei tatsächlichen öffentlichen SDK123-Verbraucher
C80/R80/Z80 am identischen Peer43280. Volle installierte Rücklesungen aller
drei und des unveränderten TCPSVC9. Peer sendet je48B und echtes SHUT_WR-FIN.
Alle3 sehen FIN mit pending48/readable gleichzeitig, Polltransfer0,
drainen alle48B genau einmal in7 Reads bis EOF und behalten raw bis zum
Close-ACK. Borrowed Close verweigert; Rust-Borrow-Drop lässt den Owner
nutzbar. Alle3 echten Exit0 samt vollständigen PASS-Ausgaben.
Frontend-Handles1→1 und nach einmal3.5s Nachlauf keine eigenen Zielport-
TCPslots; eine fremde SSH-Verbindung bleibt. Einmal normales POWEROFF/
terminal, eigene Imagequelle kanonisch entfernt. Keine neue Messstelle.
Kein nativer Reset-/Windows-/Hardware-/SDK-Speedclaim.

Der schon Closed gewordene Kernel sendet beim lokalen Close nur ACK.
Daher keinen Client-FIN/Host-EOF-Beweis erfinden: alle drei Host-Wire-
EOF-/Reset-Beobachtungen waren false. Der Peer räumt seinen eigenen Socket
erst nach dem gespeicherten originalen Gast-Exit0 auf. Gastseitige Close-
Quittung/Frontendbaseline und TCPslots werden unabhängig belegt.
Kein allgemeiner NIC-/DMA-/Heap-Freigabeclaim. Globaler TCPSVC-bad_op-Zähler
0→1 bleibt unzugeordnet in vollständigen Status-/Serialoriginalen erhalten;
keine pauschale unveränderte Fehlerzähler- oder Ursachenzusage daraus.

Release0.88.80 nach dieser Qualifikation einmal gesetzt. Alle140 normalen
R4OS-Module,141 Manifeste und Kernel446 sind vor/nach Imageplan bytegleich79.
Nur SDK-Quellen und zwei externe SDK-Bare-Runtimes/Verbraucher ändern sich.
Deshalb kein identischer OS-Benchmark erneut: gültiger voller STANDARD79
e0631a6b-31fd-445e-8815-69dbf79d4db7, overall129.931272,30Samples/4Worker/
6Scores, Original SHA256
143a50b7a71fe643584e66d308bb4b5c5698f97d9286633c9cd182ef17beec8a.
Sein gemessener Release79 bleibt erhalten; kein neues als80 etikettiertes
Ergebnis und kein SDK-Leistungsclaim daraus. SDK123-Verhalten ist durch
die obigen neuen gezielten Fälle qualifiziert. Optionale Observerwerte
bleiben null/unavailable, Serverimport/-readback des Originals ausstehend.

Bestand141Module/1089Tests/483Docs; drei bestehende Testnotizen ergänzt,
kein neuer Gate und keine Produktmesslogik. Originale und qualifizierte
Quellen: ExFiles/Reports/Core/0.88.80-tcp-peer-end/ sowie Temp/08880-*.json.

0.88.81 – Begrenztes inkrementelles HTTP-POST-Streaming
-----------------------------------------------------
Der öffentliche SDK-Library-Owner app_web.PostStream sendet Header und
Requestbody getrennt und liefert Nutzdaten vor dem Ende der Gesamtantwort.
Das 12KB-Headerbudget beschränkt keinen vollständigen POSTbody mehr.
Bekannte Slice-/Readerlänge benutzt Content-Length, unbekannte Readerlänge
chunked. Ein Reader produziert maximal8KB in den Aufruferpuffer, mit
0=EOF/-1=Pause/-2=Cancel/-3=Fehler. Fester Body und Reader sind exklusiv;
Framing-/Expect-/Connection-Header bleiben Transportbesitz, kein Requesttrailer.

Defaultgrenzen: Request-/Responsebody je64MB, URL1024B, Requestheader12KB,
Responseheader16KB/64Felder, Chunk-/Trailerzeile1024B, Trailer16KB/64Felder,
maximal8Zwischenantworten. 1MB=1024KB. Kontext und vier getrennte stabile
Puffer bleiben beim Aufrufer: Header16KB, TLSscratch54KB und kleine nichtleere
IO-/Uploadpuffer. Keine vollständig gepufferte Antwort, keine neue Messstelle,
kein Hintergrundpoller oder neuer Netzwerk-/TLSstack. Die bisherigen Fetch-/
Download-Typen und der CL-only StreamDecoder bleiben unverändert; deren
HTTP-Quellpräfix bis vor den neuen Funktionen ist exakt bytegleich.

PayloadStreamDecoder verwendet den bestehenden parseHead. CL/chunked und
ausdrücklich erlaubtes Close-Delimited-EOF werden inkrementell verarbeitet;
Nutzdaten bleiben geliehene Ausschnitte des aktuellen Empfangspuffers.
Chunkgrößen/Extensions/Nullchunk/Trailer dürfen über Eingaben verteilt sein.
Extensions berücksichtigen BWS/Token/quoted-string nach
[RFC9112Abs7.1.1](https://www.rfc-editor.org/rfc/rfc9112.html#section-7.1.1).
TE/CL-Konflikt, Zusatzbytes im bereits empfangenen Input, zu frühes EOF,
unzulässiges1xx-/204-Framing, fehlerhafte Zeilen und Limits bleiben Fehler.
Ein unbekanntes Antworttotal ist null, nicht0. TCP-EOF, TLS-close_notify,
HTTPvollständigkeit und ein LLM-/SSE-Endmarker sind unabhängige Befunde.
Insbesondere vervollständigt nacktes TCP-EOF keinen TLS-EOF-Body.

Sink accept übernimmt den ganzen Chunk vor Rückkehr; pause übernimmt0Bytes
und behält denselben Chunk bis run nach tatsächlicher Verbraucherbereitschaft.
Die gemeinsame absolute Frist läuft während Anwendungspausen weiter.
Callbacks müssen begrenzt zurückkehren; die bestehenden StopFlags bleiben
atomar. Accepted-then-Stop behält bereits übernommene Bytes im Ergebnis.
Bestätigter Requestbodypräfix, Applikationswirebytes, decodierte Antwortbytes
und vom Sink übernommene Bytes werden getrennt gezählt. TLS-Wirebytes
enthalten Recordoverhead, keinen Handshake; nur vollständig bestätigt
gesendete Records erhöhen den bestätigten Plaintextpräfix. Ungewisse Writes
bleiben markiert; weder POST noch angefangene TLSrecords werden automatisch
wiederholt. TCP-Annahme ist kein Nachweis der Ausführung beim Server.

Der echte Socket verbleibt bei unbekanntem Close im ortsfesten Kontext.
Explizites Close mit eigenem begrenztem Cleanupbudget und canRelease/
close_ack auswerten; Rust-Drop versucht nur best-effort Poll-Close.
Bestehende Zertifikats-/Hostname-/Trustprüfung, Target-/Cookie-/CORSregeln
werden verwendet. CORS-Preflight hat einen eigenen bestätigten Close vor dem
POST; keine implizite Sessionwiederverwendung. Redirect ist manuell oder ein
Fehler, kein automatisches Replay/Credentialweiterreichen.

C benutzt transport_helpers.h mit postStreamInit/Run/Report/Response/Cancel/
Close/CanRelease und bestehender Callbacktabelle (neue Kinds38/39; alte Werte
unverändert). Zig benutzt app_web.PostStream; Rust web::transport ergänzt
PostRequest/PostBuffers/PostStream/StreamReport. Normale Compilerprojektion
der lokalen web-/transport-Bridge und CFacadeGen write/check bestanden.
Die SDK-lokalen Fingerprints werden gemeinsam geliefert; kein Mischbetrieb
alter Header und neuer Runtime. GUI-Header/Fingerprint bleiben bytegleich.
SDK- und tatsächlicher Clientcode für x86_64-unknown-none typgeprüft.
Examples/README.md dokumentiert den Nexus-tauglichen POST-/Callbackpfad und
SSE-Zeilen, UTF8-Zustand, id/mehrzeilige data sowie LLM-Endmarker als
Anwendungsschicht. Nexus-Pins SDK92/Contract45 wurden nicht verändert.

Usersteuerung SPARSAM: vier direkt betroffene reale HTTP-/PostStream-
Hostfälle; darunter byteweise UTF8/Chunkheader/Trailer, alle3Framings,
Fehler-/Grenzfälle, Pause/Fortsetzen, Sinkfehler, Cancel und Accepted-then-Stop.
Ein vorheriger Grenzenfall bestätigte die alten12KB-/CL-only-Limits.
Ein privater neuer UTF8-Fixture hatte zunächst23/0x17 statt22/0x16Bytes;
2PASS/1FAIL samt Originalquelle bleiben erhalten. Keine Produktabschwächung.
Ein direkter privater Cargoaufruf ohne normalen Startup-Generator meldete
fehlende Entry-Umgebung; Bodytypcheck und regulärer Build-Project bestanden.
Erster normaler Runtimebuild erfolgreich; eine Zwischenkompilierung wurde
bei der Frist-/Stopquellenprüfung gezielt130 beendet; endgültiger Build und
alle nötigen Projektionen erfolgreich. Keine breite RustWeb-/Transport-/
PROGRAMLIFECYCLE-Matrix, kein neuer Gate; HTTP81 im vorhandenen Filter.

Genau ein KVM4-Softwaregast1174728 mit installiertem Release0.88.80,
Kernel446/TCPSVC9 qualifizierte den tatsächlichen öffentlichen SDK124-
Rust→C→Zig-Ownerpfad im ersten Lauf. R81 und TCPSVC vollständig zurückgelesen.
Vier Fälle, echter Exit0 und vollständige Ausgabe:
* CL-Request20480B; erster Sinkchunk9B pausiert mit0übernommenen Bytes.
  Nach Resume derselbe Pointer/Chunk, Signal über eine zweite Verbindung
  vor dem vom Peer gesperrten letzten Daten-/Nullchunk. Danach35B exakt.
* Reader-Request20480B chunked; CL-Antwort35B exakt, bekanntes Total35.
* Absolutes Timeout mit bestätigt gesendetem Body20480B und erhaltenem
  Antwortpräfix15B; kein vorgetäuschter HTTPabschluss und kein POST-Replay.
* Readercancel nach bestätigt8192B; Peer hält genau diesen Requestpräfix,
  Antwort0B/kein HTTPabschluss. Vier eindeutige Requeststarts, kein Duplikat.
Alle vier besitzen echte Close-ACKs. Frontendhandles1→1; nach einmal3.5s
keine eigenen Zielport-TCPslots, fremde SSH-Verbindung bleibt. Globale volle
Status-/Serialoriginale enthalten den gezielten Timeout-/Spätantwortpfad;
keine pauschale Nullfehlerzählerbehauptung oder Einzelattribution daraus.
Normales POWEROFF/terminal, lokaler Peer regulär beendet, eigene Imagequelle
kanonisch entfernt. HTTP-EOF-Framing ist Host-decoderqualifiziert; keine
zusätzliche native EOF-/TLS-Erfolgs-/Zertifikats-/Windows-/Hardware-/NIC-/
Heapfreigabeabnahme oder SDK-Geschwindigkeitsbehauptung.

SDK0.64.124 öffentlich: c5e6a366d707667a98a39c47ae230c9c14494ea6
r4os_sdk-0.64.124-NnPzAheB3gGtLZYVaC3r2eOU9CtRNFNyInZYHFK96Zjw
Contract65 unverändert; aktuelle normale C-/Zig-Bareobjekte und sieben
unveränderte Tool-/Heapkomponenten mit passendem technischem Profil exportiert.
Die finale öffentliche SDK-Archivabnahme bleibt Stufe99, R4OSfinal Stufe100.

Release0.88.81 wird nach dieser Qualifikation einmal gesetzt. Alle140 normalen
R4OS-Modulartefakte,141 Manifeste und Kernel446 sind exakt bytegleich79/80.
Deshalb kein identischer OS-Standard erneut: Original79 e0631a6b-31fd-445e-8815-69dbf79d4db7,
overall 129.931272, SHA256 143a50b7a71fe643584e66d308bb4b5c5698f97d9286633c9cd182ef17beec8a.
Alle30Samples/4Worker/6Scores waren verlustfrei validiert; Observernulls bleiben
unavailable, Serverimport/-readback ausstehend. Kein neues81etikett und kein
SDK-Leistungsclaim. Originale/Beforearchive/Objekte/Readbacks und qualifizierte
Quellen: ExFiles/Reports/Core/0.88.81-post-stream/ und Temp/08881-*.json.
