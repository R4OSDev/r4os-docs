# Timeout-, Cancel- und Threading-Vertrag

Diese Regeln gelten fuer die aktuelle R4OS-Program-API. Die numerische und
maschinenlesbare Wahrheit bleibt `ApiContract.json`; dieses Dokument erklaert
den Vertrag fuer Anwendungsentwickler.

## Timeouts und Deadlines

Die normale Zig- und C-Fassade verwendet `R4Timeout`. Der Typ unterscheidet
ausdruecklich Polling, eine endliche `R4Duration` und unbegrenztes Warten.
Anwendungscode uebergibt daher nicht mehr versehentlich `0` oder `MaxInt` mit
uneinheitlicher Bedeutung. Low-Level-Gruppenslots behalten Tickwerte als ABI-
Transportform.

Ein endlicher relativer Timeout wird am Eintritt genau einmal gegen die
monotone Uhr in eine absolute Deadline umgerechnet. Jede weitere Wartephase
verwendet nur das verbleibende Budget. Rundung erfolgt nach oben, Addition
saettigt bei Ueberlauf, eine bereits abgelaufene Deadline liefert null Ticks.
UTC ist fuer Deadlines ungeeignet und wird dafuer nicht verwendet.

## Wait, Cancel und Close

Ein Wait wartet auf eine Operation; er besitzt oder beendet sie nicht
automatisch. `ioWait`, `threadJoin`, Desktop-Activity-Wait, Remote-Frame-Wait
und Endpoint-Wait veraendern bei Timeout den Grundzustand nicht. Danach darf
erneut gewartet werden. Tritt Completion am Timeout-Rand ein, gewinnt der
nachweisbare Abschluss.

`serviceCall` besitzt dagegen eine Operationsdeadline. Bei deren Ablauf wird
nur der zugehoerige Service-Request abgebrochen. Der raw Statuscode und seine
Fehlerdomaene bleiben erhalten. `would_block`, `timed_out` und `cancelled` sind
einheitliche App-Klassifikationen, keine Ersetzung des Fachfehlers.

`ioClose` gibt nur einen abgeschlossenen Request frei. Pending oder running
liefert busy; Close ist kein Cancel. Einen allgemeinen `ioCancel`-Slot und
einen oeffentlichen `ThreadKill` gibt es bewusst nicht, solange kein sicherer
Abbruchpfad fuer die eigentliche Arbeit existiert.

Die Ressourcenobjekte aus `ResourceObjects.md` setzen diese Regeln direkt um:
Process- und Thread-Waits sowie I/O-Waits bleiben bei Timeout gueltig.
Erfolgreiches Reap/Join/Release/Close invalidiert dagegen genau das besitzende
Objekt. Ein asynchroner Datenbuffer bleibt im `IoRequest` bis Completion plus
erfolgreichem `ioClose` sichtbar gebunden; vorzeitiges Loesen liefert
`err_buffer_in_use`. Nach einem erfolgreichen Close darf die physische
Request-/Taskfreigabe bereits abgeschlossen oder generationstreu dauerhaft
an den Reaper uebergeben sein; das oeffentliche Objekt ist in beiden Faellen
sofort ungueltig.

## Service- und Programmende

Ein normaler Service-Stop besteht aus `requestClose` und einer Wartefrist. Ein
Timeout laesst den Service im beobachtbaren Stopping-Zustand und fuehrt nicht
zu einem versteckten Kill. Wer bewusst eskalieren will, waehlt in der SDK-
Fassade `kill_after_grace`; die rohe Program-Kill-Operation bleibt davon
getrennt. Die Shutdown-Reihenfolge lautet: Stop anfordern, blockierte Waits
wecken, Threads beenden/joinen, Ressourcen schliessen und Instanz reap-en.

App-Threads erhalten `R4StopFlag` als atomaren kooperativen Stop-Helfer. Der
Thread prueft ihn an sicheren Punkten und verlaesst seine Funktion selbst.
Das ist eine ehrliche begrenzte Mechanik und verspricht keinen universellen
asynchronen Abbruch.

## Threading und Lebensdauer

`App` und das importierte Gruppen-Bundle werden vor dem Start weiterer Threads
initialisiert und danach unveraenderlich verwendet. TIME-, LOG- und AUDIO-
Serviceaufrufe besitzen aufruflokale Requests und Responses; parallele
Aufrufe teilen keine mutable Scratch-Antwort.

R4SYS-, R4NET-, R4AUDIO- und R4DEV-Operationen folgen ihrer erzeugten
Threading-/Reentrancy-Klassifikation. R4DESK und R4DRAW sind
`owner_thread_only`: Fenster, GUI-Ereignisse und Zeichnen bleiben auf dem
besitzenden UI-Thread. Callback-Kontext und Bufferlebensdauer stehen pro
Operation in `OperationContracts.md`. Bei asynchroner Arbeit bleiben
Caller-Buffer bis Completion und anschliessendem `ioClose` gueltig. Interne
globale Locks duerfen keinen Anwendungs-Callback umschliessen.

## Pruefung

`Run-TimeoutConcurrencyContract05821.ps1` prueft Schema-v6-Vollstaendigkeit,
Zig-/C-Paritaet, Deadline-Arithmetik, StopFlag, GUI-Threading sowie statische
Firewalls gegen globale TIME-/LOG-/AUDIO-Scratchpuffer und versteckte
ServiceStop-Eskalation. Der Test ist Bestandteil des Current-API-Gates.
