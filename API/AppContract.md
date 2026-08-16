# R4OS-App-, Fehler-, Handle- und Lifecycle-Vertrag

## Zweck

`r4os.App` in Zig und `R4App` in C sind der normale fachliche Einstieg.
Das SDK besitzt den binaeren R4XStart-Startup, validiert den
Startkontext und uebergibt ein aufruflokales App-Objekt. `program.Bundle`
bleibt als expliziter Low-Level-Zugriff unter `r4os.lowlevel` verfuegbar.

Die einzige maschinenlesbare Wahrheit ist
`Code/System/SDK/Contract/API/ApiContract.json`. Die vollstaendige
`OperationContracts.md` wird daraus erzeugt und darf nicht von Hand geaendert
werden.

## App-Profile

Beim Einstieg wird genau eines der Profile `console`, `desktop` oder
`service` gewaehlt. Das Profil beschreibt die Art der Anwendung, erzeugt aber
keine zweite ABI und keinen weiteren Kerneluebergang. `App.init` bzw.
`r4_app_init` validieren den aktuellen R4XStart-/R4SYS-Vertrag. Eine fehlende
Basisgruppe wird als Contract-Fehler mit unveraendertem Rohcode gemeldet.
Console und Service verlangen R4SYS. Desktop verlangt R4SYS, R4DESK und
R4DRAW. Weitere Gruppen sind optional und nur vorhanden, wenn das Manifest
sie importiert. Die Profilwerte und Gruppenmasken stammen aus
`ApiContract.json`, nicht aus einer zweiten handgeschriebenen Tabelle.

Jedes App-Objekt besitzt sein aufgeloestes Bundle selbst. Argumente,
App-Klasse, Close-Anforderung, Yield, monotone Ticks und der optionale
Allocator werden ueber das Objekt angeboten. Zwei App-Objekte teilen weder
veraenderlichen Bundle-Zustand noch SDK-Scratchdaten.

## Outcome, Failure und R4Status

Zig verwendet `Outcome(T)` mit entweder `value: T` oder `failure: Failure`.
C verwendet `R4Status`; Rueckgabewerte stehen in einem passenden
`R4Outcome...`-Typ. Ein Fehler besitzt immer:

- eine von `ApiContract.json` nummerierte Domaene;
- den unveraenderten fachlichen `raw_code`;
- optional bestaetigten Fortschritt;
- optional die fuer einen zu kleinen Buffer benoetigte Groesse;
- eine Aussage, ob Seiteneffekte ausgeschlossen, bestaetigt oder unbekannt
  sind.

Es gibt keinen globalen Last-Error-Zustand. Contractfehler wie
`err_no_group` und `err_no_fn` sowie Fehler aus Dateisystem, Threads,
Services, Netzwerk und Audio behalten ihren urspruenglichen Zahlenwert.

## Handles und Besitz

Numerische IDs werden in Zig und C durch verschiedene Handletypen getrennt.
Ein `ThreadHandle` kann dadurch nicht versehentlich als `ServiceHandle`
uebergeben werden. Der Vertrag unterscheidet:

- besitzende Handles, die explizit geschlossen, gejoint, freigegeben oder
  gereapt werden muessen;
- geliehene Views, die keine Ressource freigeben;
- konsumierende Abschlussoperationen, die den besitzenden Wrapper nur bei
  Erfolg invalidieren.

Aktuell sind Programm-, Thread-, I/O-Request-, Service-, Endpoint-, VM-,
Fenster-, TCP-, IPC-, Audio-, SID- und MIDI-Handles modelliert. Datei- und
Verzeichnisoperationen bleiben pfadbasiert; R4OS erfindet dafuer keinen
Dateihandle, den das Backend nicht besitzt.

`ProcessHandle`, `JoinHandle`, `VmRegion` und `IoRequest` bilden
diese Regeln als vollstaendige Zig-/C-Lebenszyklen ab. Erfolgreiches
Wait/Join/Reap/Release/Close invalidiert das besitzende Objekt. Timeout ist
nicht konsumierend, geliehene Views duerfen nicht freigeben und ein zweiter
Abschluss liefert `err_closed`. Details und Beispiele stehen in
`ResourceObjects.md`.

Seit 0.59.9 besteht eine Prozessidentitaet aus ID plus globaler Generation.
Status, Close, Kill, Wait und Reap pruefen diese Kombination atomar; ein stale
Handle darf nach ID-/Slotwiederverwendung keine neue Instanz treffen. API-
Status und der signierte Exitcode liegen getrennt in der
`ProgramProcessCompletion`, sodass jeder `i32`-Exitcode Nutzdatum bleiben
kann. Der Diagnosering ist kein besitzender Completion-Speicher.

## Semantik jeder Operation

Jeder physische zentrale Gruppenslot traegt direkt im Schema folgende
Angaben:

- Sichtbarkeit: `public`, `advanced` oder `internal`;
- benoetigte Gruppe und optionale Capability;
- Fehlerdomaene;
- Ownership, Bufferlebensdauer und Close-Regel;
- Blocking- und Threading-Regel;
- gueltige Outputs und Seiteneffektgrenze;
- Retry-Regel;
- Verhalten bei zu kleinem Buffer;
- erforderliche Zig-/C-Paritaet.

Funktionsslots sind als public oder advanced klassifiziert. Reservierte
beziehungsweise Tombstone-Slots bleiben internal. Runtime-R4Ls wie R4STD
beschreiben dieselben Semantikaspekte in ihrem librarylokalen Contract; ihre
Typen und Operationen gehoeren nicht zum zentralen App-Vertrag. Die exakten
zentralen Mengen stehen nur in der generierten Matrix.

## Teilerfolg und Wiederholung

Datei-, Stream- und TCP-Operationen mit bestaetigtem Fortschritt werden nur
ab dem gemeldeten Offset wiederholt. Serviceaufrufe koennen bereits einen
Seiteneffekt gehabt haben und werden daher niemals automatisch wiederholt.
Ein negativer Status ohne bestaetigten Fortschritt darf nicht in einen
scheinbar vollstaendigen Erfolg umgedeutet werden.

## Quellen und Pruefungen

- `Code/System/SDK/Contract/API/ApiContract.json`: zentrale Quelle
- `Docs/API/OperationContracts.md`: vollstaendig generierte Matrix
- `Code/System/SDK/r4os/app_contract.zig`: Zig-Prototyp
- `Code/System/SDK/Shared/C/include/r4os/app_contract.h`: C-Prototyp
- `Run-AppContractSemantics05819.ps1`: Vollstaendigkeits-, Verhaltens- und
  Sprachprobe
- `Run-AppEntryContract05822.ps1`: Profil-, Einstieg-, Optionalitaets- und
  Instanzisolationsprobe fuer Zig und C
- `Run-StorageFacadeContract05823.ps1`: zentrale Datei-, Verzeichnis-,
  Stream- und Registry-Fassade mit caller-owned Speicher in Zig und C
- `Code/System/Libraries/R4STD/Contract/LibraryContract.json`: lokaler
  R4STD-Operations-, Ownership- und Kompatibilitaetsvertrag
- `Run-ResourceFacadeContract05825.ps1`: Prozess-, Thread-, VM- und
  Async-I/O-Lebenszyklen, Negativfaelle und Slot-Stress in Zig und C

Der App-Einstiegsvertrag aendert weder Loader noch den binaeren Export
`R4XStart:1`. Die seit 0.59.9 von der Ressourcenfassade verwendeten
generationensicheren Prozessoperationen wurden append-only an R4SYS v7 und
R4DESK v7 angehaengt; die erweiterte Diagnose liegt getrennt in R4DEV v4.
Fruehere Tabellenpraefixe und ID-basierte Slots bleiben binaer unveraendert.
