# R4OS-API: Architektur und Einstieg

Diese Seite ist der kurze Einstieg fuer Entwickler, die R4OS noch nicht
kennen. Das wichtigste Modell lautet:

> Die Anwendung arbeitet mit einer sprachgerechten App-Fassade. Das SDK baut
> sie aus dem vom Loader geliehenen R4XStart-Kontext auf. Bei Kernelgruppen
> ruft die Fassade einen typisierten Funktionszeiger direkt auf; es gibt keine
> weitere Dispatch- oder Syscall-Schicht.

![R4OS-API-Architektur mit Laufzeitweg, Dateispur und Buildpfad](APIArchitektur.svg)

Die Grafik ist eine Erklaerung, keine zweite Vertragsquelle. Namen, Layouts,
Operationen, Statusdomaenen und Regeln stammen aus
[ApiContract.json](../../Code/System/SDK/Contract/API/ApiContract.json). Die
lesbaren, daraus erzeugten Details stehen in
[OperationContracts.md](OperationContracts.md) und
[PayloadTypes.md](PayloadTypes.md).

## Textalternative zum Schaubild

Der Laufzeitweg beginnt in einer Zig- oder C-Anwendung mit
`r4_app_main(App*)`. Der SDK-eigene Startup exportiert den binaer erwarteten
Einstieg `R4XStart:1`, validiert den geliehenen `R4XStartContext` und das
gewaehlte App-Profil und erzeugt ein App-Objekt. Dieses App-Objekt besitzt sein
Bundle und seine Fassaden selbst. Der rohe Startkontext und die darin
referenzierten Tabellen bleiben dagegen vom Kernel geliehen.

Das Manifest importiert Gruppen als `<GRUPPE>:Query:1`. Beim Laden loest der
Kernel-Loader diese R4LQuery-Imports auf und legt die Ergebnisse im
R4XStart-Kontext ab. Fuer R4SYS, R4DESK, R4DRAW, R4NET, R4AUDIO und R4DEV
ersetzt der Loader die Query-Sicht durch je eine typisierte Kernel-
Gruppentabelle. Ein normaler Laufzeitaufruf geht von der App-Fassade ueber den
SDK-Wrapper direkt durch den Funktionszeiger dieser Tabelle zum jeweiligen
Kernel-Provider. Die Query ist dabei kein zusaetzlicher Dispatcher und der
Aufruf passiert nicht durch einen zweiten Kerneluebergang.

Unabhaengige Runtime-R4Ls besitzen eine libraryeigene, versionierte
Funktionstabelle und keine zentrale Gruppen-ID. R4STD, R4IMG und R4FONT sind
nach diesem Modell aufgebaut. Ihre lokalen Bindings loesen beispielsweise
`R4STD:CONFIG_V1:1`, `R4IMG:API_V1:1` oder `R4FONT:API_V1:1` aus demselben
R4XStart-Kontext auf und rufen die geladene Library direkt. R4STD trennt Text,
Settings, Datum, Zeit und Config in eigene Tabellen; Verbraucher importieren
nur ihren Bedarf. Alle Daten- und Scratchbuffer bleiben beim aufrufenden
Prozess. R4DRAW erhaelt von Bild- und Fontlibraries nur fertige Raster fuer
den Zeichenaufruf.

Der zweite Teil der Grafik verfolgt einen konkreten Dateiaufruf. Die
`app.files().read(...)`- beziehungsweise `Files.read`-Fassade erhaelt einen
validierten Pfad und einen vom Aufrufer
bereitgestellten Buffer. Sie ruft den `file_read`-Zeiger im R4SYS-Kontext auf.
Dieser zeigt direkt auf `apiFileRead` in `Code/Kernel/program/r4x.zig`. Der
Kernel reicht den Auftrag ueber seine technische Async-I/O-Ausfuehrung an
`Code/Kernel/program/r4sys.zig` weiter. Dort koordiniert
`Code/Kernel/fs/request.zig` den Zugriff; `Code/Kernel/fs/vfs.zig` vermittelt
FS-neutral an das Dateisystem des jeweiligen Laufwerks. Dessen Backend liest
schliesslich in den Buffer des Aufrufers: `Code/Kernel/fs/ntfs/ntfs.zig` fuer
das NTFS-Systemvolume C:, `Code/Kernel/fs/fat/fat32.zig` fuer FAT32-Volumes
wie die Datenplatte D: und die Bootpartition.
Die Fassaden fuegen also keinen zweiten
Dateisystemdienst zwischen Anwendung und Kernel ein.

Der Buildpfad beginnt mit `module.R4MF` v2 und den Zig- oder C-Quellen. Das
Manifest bestimmt Modultyp, Sprache, App-Profil, Imports, Ziel und Einstieg.
Das SDK-Buildprofil bindet den passenden Startup und die ABI ein; Compiler und
Linker erzeugen die Modulbestandteile. R4XBuilder verpackt sie als
R4M0-Container mit der Endung `.R4X`. Beim Start validiert, laedt und reloziert
der Kernel-Loader das Modul, loest die R4L-Imports auf, baut den
R4XStart-Kontext und ruft den SDK-Startup auf. Erst dieser ruft
`r4_app_main` mit dem fertigen App-Objekt auf.

## Was ein Entwickler selbst schreibt

Ein normales Projekt braucht nur:

- ein `module.R4MF` v2 mit Sprache, App-Klasse und den wirklich benoetigten
  Imports,
- eine Zig- oder C-Quelldatei mit `r4_app_main`,
- Anwendungslogik gegen `App` beziehungsweise `R4App` und deren Fassaden.

Der Entwickler exportiert nicht selbst `R4XStart`, baut keinen rohen
Startkontext und traegt keine ABI-Tabellen von Hand zusammen. Das erledigt das
SDK. Die App-Profile legen Mindestgruppen fest: `console` und `service`
benoetigen R4SYS; `desktop` benoetigt R4SYS, R4DESK und R4DRAW. Weitere Gruppen
werden nur durch ausdrueckliche `IMPORT`-Zeilen verfuegbar.

Die normale Reihenfolge ist:

1. Projekt mit `New-R4XProject.ps1` fuer Zig oder C erzeugen.
2. Imports und App-Klasse in `module.R4MF` festlegen.
3. Nur `r4_app_main` und die Anwendungslogik schreiben.
4. Mit `DevTools\Scripts\Build.bat -app NAME` bauen.
5. Das erzeugte `.R4X` wird beim Imagebau an das im Manifest genannte Ziel
   aufgenommen und spaeter vom Loader gestartet.

Die genauen Manifestfelder beschreibt
[ModuleManifestV2.md](../SDK/ModuleManifestV2.md); der komplette SDK-
Schnellstart steht in [README.txt](../SDK/README.txt).

## Kleine Zig- und C-Beispiele

Zig nutzt die normale Console-Fassade:

```zig
const r4os = @import("r4os");

pub fn r4_app_main(app: *r4os.App) i32 {
    const console = app.console() orelse return r4os.abi.err_no_fn;
    console.line("Hallo aus einer R4OS-App");
    return 0;
}
```

C verwendet dieselbe Fassade mit C-Namen:

```c
#include <r4os/r4os.h>

int32_t r4_app_main(R4App *app)
{
    R4Console console = r4_app_console(app);
    return r4_console_line(&console, "Hallo aus einer R4OS-App");
}
```

Beide Formen werden von den aktuellen Console-Profilen gebaut. Fuer eine
Desktop-App bleibt der Einstieg gleich; nur `APP_CLASS=desktop`, die
Pflichtimports und die verwendete Window-Fassade kommen hinzu.

## Die Regeln, die man frueh kennen sollte

### Handles und Close

Typsichere Handles tragen Ressourcentyp und Ownership. Ein besitzendes Handle
muss ueber seine passende `close`-/`release`-Operation geschlossen werden.
Nach erfolgreichem Close ist es konsumiert. Geliehene Sichten werden nicht vom
Aufrufer geschlossen. Die Einzelheiten und Negativfaelle stehen in
[ResourceObjects.md](ResourceObjects.md).

### Fehler und Ergebnisse

Die App-Fassaden unterscheiden erfolgreiche Werte, Ende beziehungsweise
Abwesenheit und Fehler. `Outcome`, `Failure` und `R4Status` bewahren die
Statusdomaene und den Rohcode; Fehler verschiedener Gruppen werden nicht zu
einer erfundenen globalen Fehlerliste vermischt. C bietet dazu entsprechende
Status- und Ergebnisstrukturen. Die vollstaendige Operationstabelle steht in
[OperationContracts.md](OperationContracts.md).

### Buffer und Ownership

Ein- und Ausgabebuffer bleiben grundsaetzlich beim Aufrufer. Der Vertrag sagt,
ob ein Buffer nur fuer den Aufruf geliehen oder bis zum Abschluss einer
asynchronen Operation gebunden ist. Gebundene Buffer duerfen nicht zu frueh
freigegeben oder erneut verwendet werden. Zu kleine Buffer werden sichtbar
gemeldet; stille Truncation ist kein normaler Erfolgsfall.

### Text, Pfade und Zeit

Bytes, UTF-8-, System-, Dokument- und UI-Text sind getrennte Begriffe. Pfade
werden durch die SDK-Pfadtypen validiert und normalisiert; Grenzwerte werden
nicht still abgeschnitten. Dauer, monotone Zeit, Deadline und UTC sind
verschiedene Typen und duerfen nicht ausgetauscht werden. Details stehen in
[TextPfadZeitVertrag.md](TextPfadZeitVertrag.md).

### Blocking, Timeout, Cancel und Threads

`R4Timeout` unterscheidet Poll, endliche Dauer und Forever. Ein relatives
Budget wird einmal in eine monotone Deadline umgerechnet. Timeout ist nicht
automatisch Cancel, und Cancel ist nicht automatisch Kill. GUI-Gruppen sind
owner-thread-only; App-Threads beenden sich kooperativ ueber `R4StopFlag`.
Welche Operation blockiert, abbrechbar oder reentrant ist, steht in
[TimeoutCancelThreading.md](TimeoutCancelThreading.md).

## Wann Low-Level gerechtfertigt ist

`r4os.lowlevel`, ein roher `R4XStartContext` und direkte Gruppen-Contexts sind
fuer SDK-Infrastruktur, Contracttests, Diagnosewerkzeuge oder Funktionen
gedacht, fuer die noch keine passende Fassade existiert. Normale Anwendungen
bleiben bei `App`/`R4App`. Low-Level gibt keine zusaetzlichen Rechte; es legt
nur ABI-Details und deren Lifecyclepflichten offen.

Wenn fuer normale Anwendungslogik wiederholt Low-Level-Zugriff noetig wird,
ist das ein Hinweis auf eine fehlende SDK-Fassade. Dann sollte die Fassade
zentral erweitert werden, statt denselben rohen Aufruf in vielen Programmen
zu duplizieren.

## Diagramm pflegen und pruefen

Die wartbare Quelle ist
`Docs/API/APIArchitektur.diagram.psd1`. Die SVG wird ohne externe
Diagrammabhaengigkeit deterministisch erzeugt:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File DevTools/Scripts/Generator/Generate-ApiArchitectureDiagram05837.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File DevTools/Scripts/Generator/Generate-ApiArchitectureDiagram05837.ps1 -Check
```

Die Quelle enthaelt Knoten, Grenzen, Richtungen und Legendentexte; die SVG
verwendet Prozentbreiten und feste, lesbare Schriftgroessen. Farbe wird immer
durch Beschriftung, Rahmen- oder Linienstil ergaenzt. `title`, `desc` und diese
vollstaendige Textalternative machen den Inhalt auch ohne visuelle Darstellung
zugaenglich.

ApiContract.json bleibt trotzdem die einzige maschinenlesbare API-/ABI-Quelle.
Bei einer Vertragsaenderung wird zuerst der Contract aktualisiert und danach
die Erklaerung. Diese Seite verspricht weder einen API-Freeze noch eine
Langzeitgarantie fuer den aktuellen Entwicklungsstand.
