# Service- und Netzwerkfassade

Normale Zig- und C-Anwendungen greifen über besitzende
Lifecycle-Objekte auf R4X-Services und Netzwerkdienste zu. Die Fassade baut
keinen zweiten Netzwerkstack auf: `module.R4MF` importiert weiterhin R4NET,
und DNS, TCP sowie UDP laufen ausschließlich über DNSSVC, TCPSVC und UDPSVC.
Fehlt eine Gruppe oder ein Dienst, wird dies sichtbar gemeldet.

## Services

Zig erhält mit `app.services()` eine `Services`-Sicht. `open()` liefert eine
`ServiceConnection`, `register()` einen `ServiceEndpoint`. Eine Connection
besitzt den Ablauf Open, Call und Close. Ein Endpoint besitzt Register, Wait,
Recv, Reply und Unregister. Erfolgreiches Close beziehungsweise Unregister
invalidiert das Objekt; Kopien eines bereits konsumierten Raw-Handles werden
nicht still weiterverwendet.

```zig
const services = app.services() orelse return r4os.abi.err_no_group;
var connection = switch (services.open("EXSVC")) {
    .connection => |value| value,
    .failure => |raw| return raw,
};
defer _ = connection.close();

var response: [64]u8 = undefined;
const result = connection.call(1, "PING", response[0..],
    r4os.time_contract.timeoutForever());
```

`callTyped` und `recvTyped` sind für feste Request-/Response-Strukturen
gedacht. Variable Daten verwenden caller-owned Bytebuffer. Ein fachlicher
Antwortfehler ist `remote_failure`; Transport-/Handlefehler stehen in
`failure`, und ein Timeout ist ein eigener Zustand.

## DNS, TCP und UDP

`app.network()` liefert die hohe `Network`-Sicht nur, wenn R4NET und die
notwendigen Servicefunktionen vorhanden sind. Der rohe R4NET-Zugriff für
Gezielter Diagnosecode liegt getrennt unter `app.networkLowLevel()`.

- `Resolver.resolveA` liefert Adresse, Timeout, NotFound, NoService oder einen
  fachlichen Fehler.
- `Network.connectTcp` liefert einen besitzenden `TcpSocket`.
- `Network.listenTcp` liefert einen `TcpListener`; `accept` erzeugt den
  besitzenden Socket für die Verbindung.
- `Network.bindUdp` liefert einen `UdpSocket`; `sendTo` und `receiveFrom`
  verwenden `SocketAddress` und caller-owned Buffer.

Socketoperationen unterscheiden `would_block`, `timed_out`, `reset`,
`peer_closed`, lokales `closed` und sonstige Fehler. Timeout und WouldBlock
schließen das Objekt nicht. Reset, PeerClose und bestätigtes Close machen den
betroffenen Socket ungültig. `close` ist nur für den Besitzer erlaubt.

```zig
const network = app.network() orelse return r4os.abi.err_no_group;
const remote = r4os.SocketAddress{
    .address = r4os.Ipv4Address.init(10, 0, 2, 2),
    .port = 8080,
};
var socket = switch (network.connectTcp(remote,
    r4os.time_contract.timeoutForever())) {
    .socket => |value| value,
    else => return 1,
};
defer _ = socket.close(r4os.time_contract.timeoutForever());
```

## HTTP-/HTTPS-Streaming

`app.web()` ist die gemeinsame Fassade über Resolver, TCP, R4HTTP-Kern und
R4TLS. `fetch` bleibt für kleine, vollständig gepufferte Antworten bestimmt.
`download` schreibt große GET-Antworten dagegen segmentweise in einen
`DownloadSink`; Header-, I/O- und TLS-Puffer gehören dem Aufrufer und wachsen
nicht mit dem Body.

Ein Sink erhält absoluten Offset und Bytes. Er meldet Erfolg erst nach
dauerhafter Übernahme, beispielsweise über die Storage-Fassade in eine
`.PART`-Datei. `DownloadOptions` bindet Timeout, Stop-Flag, Fortschritt,
erwartete Gesamtgröße, Resumeoffset und denselben `TargetAuthorizer` wie der
normale Fetch. GET und HEAD, Content-Length, 206 Content-Range, 416 sowie
genau ein Range-Resume nach einem Lesefehler sind sichtbar typisiert.
Widersprüchliche Ranges, fremde Gesamtgrößen, Sinkfehler und
Zertifikatsfehler werden nicht wiederholt.

## Update-Dienst

`UPDSVC` ist ein normaler versionierter R4X-Service-Endpoint. Sein
anwendungsnaher Wire-Vertrag liegt in
`Code/System/SDK/r4os/update_service_contract.zig` und nutzt die bestehende
`ServiceConnection` für Status, Suche, Download, Installation, Update All,
Abbruch und Ergebnis-Seiten. Alle Clientverbindungen teilen einen einzigen
durablen Auftrag und genau einen Worker; Busy und Cancel sind daher
dienstweit und nicht nur pro Connection wirksam. Installationen rufen die
gemeinsame System-Update-Engine direkt auf.

## C

C bindet `<r4os/r4os.h>` ein. Die entsprechenden Typen heißen `R4Services`,
`R4ServiceConnection`, `R4ServiceEndpoint`, `R4Network`, `R4Resolver`,
`R4TcpSocket`, `R4TcpListener` und `R4UdpSocket`. Resultate tragen immer eine
explizite Kind-Kennung. Das Referenzprogramm `CNETD.R4X` unter
`Code/System/Diagnostics/NetworkFacadeCDiag` zeigt DNS, TCP und UDP.

## Referenzprogramme und Prüfung

- EXSVC demonstriert Service-Endpoint und Client-Lifecycle.
- DNSLOOKUP verwendet `Resolver`.
- TCPECHO verwendet TCP-Client und -Listener.
- CNETD demonstriert DNS, TCP und UDP in C.
- `Run-ServiceNetworkFacadeContract05826.ps1` prüft Zig/C-Parität sowie alle
  negativen Lifecycle-Zustände ohne Netzwerk- oder IPC-Fallback.
