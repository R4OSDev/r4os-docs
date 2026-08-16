# Prozess-, Thread-, VM- und Async-I/O-Ressourcenobjekte

## Zweck

Die normale App-Fassade bietet besitzende Ressourcenobjekte fuer
Programme, joinbare Threads, virtuelle Speicherbereiche und asynchrone
I/O-Requests. Sie liegen in Zig unter `r4os.app_resources` und in C in
`r4os/app_resources.h`. Seit 0.59.9 verwendet `ProcessHandle` die append-only,
generationensicheren R4SYS-v7-Slots. Die alten ID-basierten Slots bleiben fuer
binaere Kompatibilitaet unveraendert; Thread-, VM- und I/O-Objekte behalten
ihre bisherigen Punktvertraege.

`app.resources()` liefert in Zig eine `Resources`-Sicht. In C erzeugt
`r4_app_resources(app)` die gleichwertige `R4Resources`-Sicht.

## Gemeinsamer Lebenszyklus

Ein erfolgreicher Create- oder Spawn-Aufruf liefert ein besitzendes Objekt.
Der Aufrufer muss genau eine konsumierende Abschlussoperation ausfuehren:

- `ProcessHandle`: `wait`/`reap` nach optionalem `requestClose` oder `kill`;
- `JoinHandle`: `join`;
- `VmRegion`: `release`;
- `IoRequest`: nach Completion `close`.

Konsumierende Methoden erhalten in Zig einen Pointer auf das Objekt und in C
einen Struct-Pointer. Nach erfolgreichem Abschluss wird die rohe ID auf null
gesetzt; Generation und beide neuen Reserved-Felder werden ebenfalls
invalidiert. Ein erneuter Abschluss liefert deterministisch `err_closed`. Eine
geliehene Prozesssicht darf Status lesen, Close/Kill anfordern, per
`waitReady` eine fertige Completion beobachten und vor deren Verbrauch per
`completionRead` Ausgabe lesen. Nur `reap` und der konsumierende High-Level-
`wait` verlangen Besitz; ein geliehener Aufruf liefert dort `err_not_owned`,
bevor gewartet oder konsumiert wird.

Zig kann Kopien eines Structs nicht als move-only verbieten. Ein ProcessHandle
enthaelt deshalb neben der ID eine vom Kernel global monoton vergebene
Generation. Eine stale Kopie wird auch dann atomar abgelehnt, wenn dieselbe ID
oder Slotadresse inzwischen einer neuen Instanz gehoert. `err_closed` gilt fuer
das lokal invalidierte Objekt, `program_handle_error_stale` fuer eine alte
Identitaet und `err_not_owned` fuer einen geliehenen Reap. Anwendungen sollen
besitzende Objekte trotzdem nicht kopieren, sondern per Pointer weiterreichen.

Die Quelloberflaeche bleibt dabei kompatibel: `ProcessHandle.raw` ist in Zig
weiterhin ein `u32`, und C behaelt den bisherigen Tag `struct R4Process` samt
Prefix `app`, `uint32_t raw`, `owned`, `reserved[3]`. Append-only folgen
`generation`, `handle_reserved` und `extension_reserved`; der C-Typ
`R4OS_ProcessHandle` ist ein Alias desselben Structs. Die Inlinefassaden bauen
aus diesen Feldern fuer jeden R4SYS-v7-Aufruf einen lokalen
`ProgramProcessHandle` und schreiben Spawn-/Open-Ergebnisse feldweise zurueck.
Direktes Lesen, Vergleichen und Nullsetzen von `raw` kompiliert dadurch wie
bisher, erzeugt allein aber keine neue gueltige generationensichere Identitaet.

## Prozesse

`Resources.spawn` beziehungsweise `r4_resources_spawn` startet ein Programm
und gibt sofort ein besitzendes Prozessobjekt aus ID plus Generation zurueck.
`status` fuehrt einen direkten generationengeprueften Punktlookup aus.
`requestClose` fordert kooperatives Beenden an; `kill` ist die explizite harte
Alternative.

Der Kernel legt den kleinen Completion-Knoten bereits in der Spawntransaktion
an. Nach dem Exit werden Image, Stack, VM und Laufzeit-Payloads abgebaut; nur
Exitmetadaten und gegebenenfalls die begrenzte Konsolenausgabe bleiben bis zum
Reap. Der nicht konsumierende Low-Level-Wait liefert eine
`ProgramProcessCompletion`. Der High-Level-Aufruf `wait(R4Timeout)` wartet mit
einem einmalig berechneten Budget und konsumiert danach per Reap. Ein Timeout
konsumiert weder Handle noch Completion. `waitReady` und `completionRead`
sind auch fuer geliehene Handles nicht konsumierend; der kompakte High-Level-
`wait` bleibt owner-only, weil er nach erfolgreichem Warten unmittelbar
`reap` ausfuehrt.

API-Status und Exitcode sind getrennte Felder. Auch `-1`, `-2` und der
Kill-Exitcode `-9` sind deshalb uneingeschraenkt als Programmrueckgabe moeglich
und werden nicht mehr als `not found` oder `would block` fehlgedeutet. Wer vor
dem Reap die eingefrorene Ausgabe benoetigt, verwendet `waitReady`,
`completionRead` und anschliessend `reap`; der normale `wait` bleibt die
kompakte Wait-und-Reap-Fassade.

Der normale Terminalstart verwendet diesen Weg. Konsolenprogramme erben beim
asynchronen Spawn die ID und Generation ihres aufrufenden Console-Hosts, so
dass Ein-/Ausgabe waehrend des Waits weiterhin im Terminal landet, ohne dass
eine spaeter wiederverwendete Host-ID getroffen werden kann.

## Threads

`Resources.createThread` liefert einen `JoinHandle`. `status` liest
`ProgramThreadInfo`. `join(R4Timeout)` konsumiert den Handle nur bei
erfolgreichem Join. Poll- oder endliche Timeouts lassen ihn gueltig und
erneutes Warten ist erlaubt. Ein allgemeiner Thread-Kill wird nicht
vorgetaeuscht; kooperatives Stoppen erfolgt mit `R4StopFlag`.

## Virtuelle Speicherbereiche

`Resources.reserveVm` liefert eine `VmRegion` samt initialer
`ProgramVmRegionInfo`. `commit`, `info` und `decommit` arbeiten nur auf einer
gueltigen Region. `release` verlangt Besitz und invalidiert bei Erfolg. Ein
Owner-Mismatch bleibt der unveraenderte VM-Fachfehler und wird nicht als
scheinbarer Close-Erfolg umgedeutet.

## Asynchrones I/O und Buffer

Read-Requests speichern den gebundenen schreibbaren Slice beziehungsweise
Pointer und seine Laenge im `IoRequest`. Write-Requests speichern den
gebundenen read-only Buffer. Die Bindung bleibt sichtbar, bis der Request
completed ist und `io_close` erfolgreich war. `buffersHeld` beziehungsweise
`r4_io_request_buffers_held` zeigt diesen Zustand. Ein ausdruecklicher Versuch,
den Buffer vorher aus dem Objekt zu loesen, liefert `err_buffer_in_use`.

`wait(R4Timeout)` ist bei Timeout nicht destruktiv. `close` auf pending oder
running liefert den R4SYS-Fehler `io_error_busy`; Close cancelt nicht. Erst
nach Completion loest erfolgreiches `close` die oeffentliche Bufferbindung
und invalidiert das Objekt. Die physische Slot-/Taskfreigabe ist dann entweder
bereits abgeschlossen oder generationstreu dauerhaft an den Reaper
uebergeben; fuer den Aufrufer bleibt der Request in beiden Faellen geschlossen.

## Kurzes Zig-Beispiel

    var resources = app.resources();
    var path = try r4os.FilePath.parse("C:\\TEMP\\DATA.TXT");
    var buffer: [256]u8 = undefined;
    var request = switch (resources.asyncRead(path.asZ(), buffer[0..], 0)) {
        .request => |value| value,
        .failure => |raw| return raw,
    };
    switch (request.wait(r4os.time_contract.timeoutForever())) {
        .completed => {},
        .timed_out => return 1,
        .failure => |raw| return raw,
    }
    if (request.close() != r4os.abi.io_ok) return 1;

## Pruefung

`Run-ResourceFacadeContract05825.ps1` kompiliert und startet Zig- und
C-Prototypen fuer Spawn/Status/Close/Kill/WaitReady/CompletionRead/Reap,
Thread-Join, VM-Lifecycle und Async-I/O. Die Proben enthalten geliehene
Beobachter, owner-only Reap/High-Level-Wait, getrennte Invalid-/No-Fn-Fehler,
Timeout, falschen Besitzer, vorzeitiges Bufferende, doppelte Abschluesse und
80 sequenzielle Durchlaeufe je Ressourcenart ohne verbleibenden Mock-Slot. Im
Gast pruefen THREADD, ASYNIOD, APPHEAPD und CLEANUPD dieselben realen
Kernelpfade.
