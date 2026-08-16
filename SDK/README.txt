R4OS SDK - Entwicklerhandbuch
=============================

Schnellstart
------------

Wer R4OS noch nicht kennt, beginnt mit
`Docs/API/ArchitekturUndEinstieg.md`. Dort sind der normale Aufrufweg,
Runtime-R4Ls, Ownership sowie der Build-/Ladepfad mit einem Schaubild und
einer vollstaendigen Textalternative erklaert.

Der ab 0.64.1 eingefrorene Zielvertrag fuer echte benannte Runtime-R4Ls steht
in `Code/System/SDK/Contract/ABI/R4LInterface.txt`. Bestand, Eigentumsgrenzen
und Migrationsreihenfolge dokumentiert `Docs/SDK/RuntimeR4L0641.txt`; Resolver
und Lebensdauer stehen in `RuntimeR4L0642.txt`, der librarylokale Contract-,
Binding- und Buildpfad in `RuntimeR4L0643.txt`. Die ausgefuehrte
Kompatibilitaetsabnahme mit zwei Providergenerationen, append-only V1,
parallelem V2 sowie Zig-/C-Verbrauchern steht in `RuntimeR4L0644.txt`.
`RuntimeR4L0645.txt` und `RuntimeR4L0647.txt` dokumentieren die produktive
Migration von R4IMG beziehungsweise R4STD. Der unabhaengige
New-R4L-Workflow, die generierte Testreferenz und das namenfreie Dauergate
stehen in `RuntimeR4L0648.txt`.

Neue Konsolenprojekte werden mit dem Projektgenerator angelegt:

    powershell -NoProfile -ExecutionPolicy Bypass -File DevTools/Scripts/New-R4XProject.ps1 -Name MYAPP -Language zig

C-Projekt mit zusaetzlichen Gruppen:

    powershell -NoProfile -ExecutionPolicy Bypass -File DevTools/Scripts/New-R4XProject.ps1 -Name MYAPPC -Language c -Groups R4NET

Eine neue eigenstaendige Zig-Runtime-R4L entsteht mit:

    powershell -NoProfile -ExecutionPolicy Bypass -File DevTools/Scripts/New-R4LProject.ps1 -Name R4MATH

Der Name hat 2 bis 8 Grossbuchstaben/Ziffern und beginnt mit einem Buchstaben.
Der R4X-Generator erzeugt Manifest, Quelle und den duennen projektlokalen
SDK-Buildeinstieg. Der R4L-Generator erzeugt zusaetzlich lokalen Contract,
Baseline, Implementierungs-ABI, Zig-/C-Bindings, Conformance-Fixtures, Tests
und API-Referenz. Beide veraendern weder Root-Build noch Image-Tool.

Projektstruktur
---------------

    Code/System/Software/MyApp/
      module.R4MF
      build.zig
      build.zig.zon
      src/main.zig oder src/main.c
      Assets/            nur bei eingebetteten Ressourcen

Seit 0.61.8 ist jedes Modul ausserhalb des SDK eigenstaendig baubar: `zig build`
im Projektverzeichnis erzeugt dasselbe Artefakt wie der Aggregatbau,
byteidentisch. Dafuer traegt jedes Projekt eine build.zig und eine
build.zig.zon. Die build.zig besteht aus genau einem Aufruf -
`sdk.addR4MF(b.path("module.R4MF"))` - und darf keine Manifestangabe
wiederholen; genau diese Doppelung sollte R4MF v2 verhindern. Echte
projektspezifische Hosttests duerfen zusaetzliche Schritte in derselben
build.zig fuehren, aber keine zweite Moduldefinition.

Diagnoseprogramme liegen unter Code/System/Diagnostics, Treiber unter
Code/System/Driver und Protokollmodule unter Code/System/Protocols.

module.R4MF
-----------

Das Manifest ist UTF-8 ohne BOM und die einzige Projekt-/Build-/Imagewahrheit
des Moduls. Minimales R4MF-v2-Beispiel:

    R4OS_MODULE_MANIFEST=2
    KIND=R4X
    NAME=MYAPP
    VERSION=0.1.0
    LANGUAGE=Zig
    SOURCE=src/main.zig
    ENTRY_MODE=app
    APP_CLASS=console
    TARGET=/R4OS/SOFTWARE/TERMINAL/MYAPP.R4X
    IMAGE_SCOPE=full
    IMPORT=R4SYS:Query:1

VERSION ist Pflichtfeld und wird bei jeder Aenderung des Moduls erhoeht - von
dem, der die Aenderung macht, im selben Schritt. Optional bettet das Manifest
Ressourcen in den Container ein: ICON= fuer Programmicons, HELP= fuer das
Helpfile von NAME /? und RESOURCE=NAME:pfad fuer weitere Dateien; die
Bauquellen liegen unter Assets/. Details dazu und woertliches Boilerplate:
Agents/R4M0-Container.txt.

R4SYS ist explizite Basis. Zusaetzliche zentrale IMPORT-Zeilen nennen
R4DESK, R4DRAW, R4NET, R4AUDIO oder R4DEV. Eine unabhaengige Runtime-R4L
nennt ihr exportiertes Interface, beispielsweise `R4STD:CONFIG_V1:1`,
`R4IMG:API_V1:1` oder `R4FONT:API_V1:1`, und liefert ihr Zig-/C-Binding im
eigenen Projekt. C darf
SOURCE in der gewuenschten Reihenfolge wiederholen. ENTRY_MODE=app ist der normale r4_app_main-Weg;
lowlevel markiert einen aktuellen direkten R4XStart-Einstieg. ZIG_MODULE
bindet bei Zig einen expliziten gemeinsamen Quellmodulalias. PACKAGE gruppiert
Module nur fuer Installation/Doku und beeinflusst den Build nicht.
SOURCE_PROJECT, ARTIFACT, BUILD_PROFILE, EXPORT,
CONTRACT und feste Startmetadaten werden abgeleitet. Details:
Docs/SDK/ModuleManifestV2.md und Contract/Module/R4MFv2.txt.

ModuleCatalog ist der gemeinsame Parser, Validator, Resolver und Planer:

    Code/BuildTools/ModuleCatalog/zig-out/bin/module-catalog.exe validate --manifest <Pfad>
    Code/BuildTools/ModuleCatalog/zig-out/bin/module-catalog.exe catalog --root Code --output <Datei>
    Code/BuildTools/ModuleCatalog/zig-out/bin/module-catalog.exe contract-plan --manifest <Pfad> --output <Datei>
    Code/BuildTools/ModuleCatalog/zig-out/bin/module-catalog.exe image-plan --root Code --image-mode full --output <Datei>
    Code/BuildTools/ModuleCatalog/zig-out/bin/module-catalog.exe convert-r4cp --manifest <alt.R4CP> --output <module.R4MF>

Der Root-Build entdeckt alle In-Tree-R4X unter Software, Services und
Diagnostics aus dem Katalog. Fuer ein portables Out-of-Tree-
Projekt kann weiterhin ein faktenfreier generischer build.zig-Einstieg
mitgeliefert werden:

    const std = @import("std");
    pub fn build(b: *std.Build) void {
        const sdk_build = b.lazyImport(@This(), "r4os_sdk") orelse return;
        const sdk_dep = b.dependencyFromBuildZig(sdk_build, .{});
        const sdk = sdk_build.sdk(b, sdk_dep, .{});
        _ = sdk.addR4MF(b.path("module.R4MF"));
    }

Repository-Build und zentrale Ausgabe:

    DevTools\Scripts\Build.bat -app MYAPP
    Code\zig-out\MYAPP.R4X

In-Tree baut `-app` den exakt aufgeloesten Katalogeintrag ueber den gefilterten
Root- beziehungsweise SDK-Smoke-Aggregatbuild; ein gueltiges neues Manifest
braucht keine Root-Aenderung.
Der Builder uebernimmt die IMPORT-Zeilen exakt in Manifestreihenfolge. Er
fuegt auch R4SYS nicht hinzu und entfernt keinen deklarierten Import. BEEP,
CALC, CNETD und APPCDESK sind die ersten Zig-/C-Console-/Desktop-Referenzen.
R4CODE, R4BUILD, R4PACK und R4CC sind vier getrennte
Manifestmodule; gemeinsame Cores liegen einmal im R4Code-Shared-Bereich.
Alle In-Tree-Manifeste verwenden R4MF v2. Der gemeinsame Katalog umfasst die
R4X-Module des Root- und SDK-Smoke-Aggregats sowie alle R4D-, R4P- und R4L-
Module; jedes andere Manifestformat wird abgelehnt.

Die R4X-Imageplaene stammen ebenfalls aus diesen Manifesten.
`normal` und `test` gelten nur fuer das jeweilige Image, `both` fuer beide und
`none` fuer keines. SDK-Smokes und bewusst nur extern gebaute Module verwenden
`none`. Raw erzeugte Fixtures besitzen getrennte, validierte Image-Manifeste
mit ihrem jeweils ausdruecklichen Scope.

R4CODE erzeugt neue Projekte direkt als `module.R4MF`. R4BUILD
verwendet fuer `VALIDATE`, `PLAN` und `BUILD` denselben Runtime-Parser und
denselben umgebungsneutralen `R4MF_PLAN=1`-Vertrag wie ModuleCatalogs
`contract-plan`. Der Inside-R4OS-Build unterstuetzt bewusst nur die vorhandenen
C-Console- und C-Desktop-Profile und meldet andere Sprachen oder Profile als
Capabilityfehler. R4CC akzeptiert dabei in beiden Profilen nur den aktuellen
`r4_app_main(R4App*)`-Einstieg. Historische `.R4CP`-Dateien werden nur ueber den expliziten
Einmalbefehl `R4BUILD CONVERT <alt.R4CP> <module.R4MF>` gelesen; sie sind kein
paralleler Projekt- oder Buildvertrag.

R4CodePad verwendet im Partnerrepository nur noch
`module.R4MF` v2 und die aktuelle App-Fassade. Der C#-Projektparser ist ein
Adapter auf ModuleCatalogs `contract-plan`; BuildExecutionService erzeugt nur
einen festen `sdk.addR4MF`-Treiber. R4CP bleibt ausschliesslich ein explizites
Importformat ueber `module-catalog convert-r4cp`, dessen Bytes aus demselben
SDK-Konverter wie bei R4BUILD stammen. Das permanente R4OS-Gate prueft die
gemeinsame Grenze leichtgewichtig; `-Acceptance` fuehrt zusaetzlich den
Partner-Closure-Test mit exportiertem SDK und Toolchain in einem externen Pfad
mit Leerzeichen aus.

Zig-App-Einstieg
----------------

    const r4os = @import("r4os");

    pub fn r4_app_main(app: *r4os.App) i32 {
        app.system().println("Hallo R4OS");
        return 0;
    }

Das SDK besitzt den binaeren R4XStart-Einstieg, validiert den Startkontext
und uebergibt ein aufruflokales App-Objekt. Anwendungsquellen exportieren
weder R4XStart selbst noch Entry-Assembler oder einen rohen Startkontext.

App-Profile und Gruppen
-----------------------

Der Build waehlt genau ein Profil. console und service verlangen R4SYS,
desktop verlangt R4SYS, R4DESK und R4DRAW. Alle weiteren Gruppen sind
optional und nur verfuegbar, wenn module.R4MF sie importiert:

    const net = app.network() orelse return r4os.abi.err_no_group;
    const desk = app.desktop(); // ?r4desk.Context

Ein Kernel-Feld wird vor optionaler Nutzung konkret geprueft:

    if (dev.hasFn("hardware_summary")) {
        // Feld ist in der gelieferten Tabelle vorhanden und ungleich 0.
    }

SDK-Wrapper liefern bei fehlender Gruppe `err_no_group` und bei fehlendem Feld
`err_no_fn`. Die Rohwerte stammen aus ApiContract.json und werden nicht hier
dupliziert. Fachliche Fehlercodes bleiben unveraendert.
R4STD, R4IMG und R4FONT sind unabhaengige Runtime-R4Ls mit lokalem Vertrag
und lokalen API-Tabellen; ihre Bindings werden aus `app.startContext()`
aufgebaut. R4STD trennt Text, Settings, Datum, Zeit und Config in einzeln
importierbare Tabellen. Alle Buffer und Zustaende bleiben im aufrufenden
Prozess.

App-, Fehler- und Handlevertrag
------------------------------

`r4os.App`/`R4App`, Outcome/Failure beziehungsweise R4Status und
typsichere Handleprototypen fuer Console-, Desktop- und Service-Anwendungen
fest. Der Rohcode und seine Domaene bleiben erhalten; es gibt keinen globalen
Last-Error. Besitzende Handles werden nach erfolgreichem Close/Join/Release/
Reap invalidiert. Pfadbasierte Dateioperationen erhalten keinen erfundenen
Dateihandle. Details stehen in Docs/API/AppContract.md, die vollstaendig
generierte Operationsmatrix in Docs/API/OperationContracts.md.

App/R4App ist der normale Einstieg fuer Zig und C. Jedes
App-Objekt besitzt sein Tabellen-Bundle selbst; mehrere App-Objekte teilen
keinen veraenderlichen SDK-Start- oder Scratchzustand. Der rohe ABI-Zugriff
bleibt fuer Loader-, Startup- und gezielten Diagnosecode explizit unter
r4os.lowlevel erreichbar.

Program-, Task- und Threadinventar
----------------------------------

Seit 0.59.11 stellt R4SYS v7 append-only die Operationen
`programInventoryBegin`, `programInventoryPrograms`,
`programInventoryTasks` und `programInventoryThreads` bereit. Zig-SDK,
R4XStart und C-Fassade verwenden dieselben versionierten Payloadtypen
`ProgramInventoryCursor`, `ProgramInventorySummary`,
`ProgramInventoryPageInfo` sowie die drei Snapshottypen. Der Aufrufer stellt
den Seitenbuffer; eine Seite enthaelt hoechstens 64 Eintraege und loest keine
verdeckte SDK-Allokation aus.

Ein stabiler Durchlauf beginnt immer mit `programInventoryBegin`. Bei
`program_inventory_status_more` wird mit demselben Cursor weitergelesen, bei
`complete` ist die Objektart abgeschlossen. `restart` bedeutet, dass sich die
gebundene Registrygeneration geaendert hat: Alle bisher gelesenen Seiten
werden verworfen und der komplette Durchlauf beginnt neu. OOM oder ein
fachlicher Fehler duerfen weder als leere Abschlussseite noch als
abgeschnittener Erfolg behandelt werden.

`ProgramInstanceSnapshot.handle` bleibt zusammen mit den sichtbaren Daten
gebunden. Der Desktop verwirft diese Generation deshalb nicht beim Staging:
Fensterzuordnung, Close, Kill und Reap verwenden den exakten
`ProgramProcessHandle`. `programSetWindowHandle` ist dafuer append-only in
R4DESK v7 vorhanden. Ein transientes `WOULD_BLOCK` behaelt Fenster und Handle
fuer den naechsten Versuch; nur `STALE` oder `NOT_FOUND` erlauben den sicheren
lokalen Abbau einer bereits verschwundenen Generation.

Neue Threads werden ueber `threadCreateHandle` als vollstaendiger
`ProgramJoinHandle` erzeugt. `threadHandleStatus` und `threadHandleJoin`
pruefen Thread- und Besitzer-ID jeweils zusammen mit ihrer Generation. Der
besitzende Zig-`JoinHandle` beziehungsweise C-`R4JoinHandle` speichert diese
volle Identitaet einschliesslich eines auf null festgelegten Reserved-Felds
und wird nach erfolgreichem Join invalidiert; der reine `u32`-Threadwert ist
nur noch die Legacy-Fassade.

`app.devices().performance().executionInventory()` liefert ueber R4DEV eine
geliehene Zusammenfassung derselben Program-/Task-/Threadzaehler, Peaks und
Admission-/Rollbackursachen. Sie ersetzt kein paginiertes Einzelinventar und
setzt wie jede optionale Gruppe einen erfolgreichen R4DEV-Import voraus.

Seit 0.59.12 enthaelt der 160-Byte-`ProgramInventorySummary` ausserdem
`heap_active_blocks: u32` bei Offset 148 und `heap_used_bytes: u64` bei Offset
152. Die Zig- und C-Fassaden geben diese punktuelle globale Kernel-Heap-Sicht
unveraendert weiter. Sie dient zum Begrenzen globaler Abweichungen, nicht als
versteckte Slotgrenze oder per-Owner-Speicherwert. Exakte programmgebundene
Ressourcen kommen aus den Ownerinventaren; der 0.59.12-Abschlussstress erlaubt
daneben hoechstens acht ownerlose Admin-Tasks und insgesamt 512 KiB globale
Heap-/Speicherabweichung. Fuer Einzelobjekte bleibt das paginierte R4SYS-
Inventar die verbindliche Sicht.

Console-, Datei-, Verzeichnis- und Registry-Fassade
---------------------------------------------------

`app.console()`, `app.files()` und `app.registry()` sind der normale zentrale
Zugriff. Dateien bleiben pfadbasiert. Iteratoren und Streams haben explizite
End-/Fehler- und Finish-/Abort-Zustaende. R4STD wird als lokales Binding mit
den benoetigten Runtime-Tabellen eingebunden. Alle Daten- und Scratchbuffer
gehoeren dem Aufrufer; es gibt keine implizite Allokation oder globalen
SDK-Scratch. Die C-Sichten folgen demselben Vertrag. Beispiele stehen in
`Docs/API/StorageFacade.md`.

Fenster-, Nachrichten- und Zeichenfassade
-----------------------------------------

`app.window(timers)` liefert fuer Desktop-Apps den normalen
R4DESK-/R4DRAW-Ablauf. `Window` besitzt einen typisierten EventLoop fuer
Close, Resize, Key, Mouse, Command, Clipboard und Timer. `waitMessage`
verwendet `desktopActivityWait` statt periodischem Sleep-Polling.
`beginPaint` liefert einen PaintContext, der genau einmal praesentiert oder
verworfen wird; sein Canvas ist weiterhin der bestehende `r4os.gui`-
Werkzeugkasten. C bietet denselben Ablauf mit `R4Window`, `R4MessageNext` und
`R4PaintContext`. Details und Beispiele stehen in `Docs/API/GuiFacade.md`.

Service- und Netzwerkfassade
----------------------------

`app.services()` liefert besitzende `ServiceConnection`- und
`ServiceEndpoint`-Objekte. `app.network()` stellt `Resolver`, `TcpSocket`,
`TcpListener` und `UdpSocket` bereit. DNS, TCP und UDP laufen weiterhin ueber
die in `module.R4MF` importierte R4NET-Gruppe und die R4X-Dienste DNSSVC,
TCPSVC und UDPSVC; es gibt keinen direkten Kernel-Netzwerkfallback. WouldBlock,
Timeout, Reset, PeerClose und lokales Close bleiben unterscheidbar. Die C-
Fassade bietet denselben Lifecycle. Details und Beispiele stehen in
`Docs/API/ServiceNetworkFacade.md`.

Audio- und Geraetefassade
-------------------------

`app.audio()` liefert den besitzenden AUDSVC-basierten
`AudioStream` fuer Open, Write, Volume und Close. Es gibt keinen stillen
Direkt-Kernel-Fallback. SID, MIDI und OPL3 sind getrennt unter
`audio.advanced()` erreichbar. `app.devices()` liefert geliehene Inventar-,
Speicher- und Performance-Sichten auf die bestehenden R4DEV-Payloadtypen.
Zig und C verwenden denselben Lifecycle; Details stehen in
`Docs/API/AudioDeviceFacade.md`.

Text-, Pfad- und Zeitvertrag
----------------------------

R4STD Date, Time, Settings und Config verwenden dieselben librarylokalen
fixed-layout-Typen in Zig und C. Bytes, UTF-8-, System-, Dokument- und UI-Text
sind getrennt. Dateipfade werden kanonisiert und niemals still gekuerzt;
Registry-Pfade bleiben ein eigener Namensraum. Dauer, monotone Zeit, Deadline
und UTC sind unterscheidbare Typen. Der vollstaendige Nutzungsvertrag steht
in Docs/API/TextPfadZeitVertrag.md.

C-App-Einstieg
--------------

C bindet <r4os/r4os.h> ein. Der SDK-Startup exportiert R4XStart und ruft:

    int32_t r4_app_main(R4App *app) {
        r4sys_write_cstr(&app->system, "Hallo R4OS\r\n");
        return 0;
    }

Optionale Gruppen werden mit r4_app_has_group geprueft. Die fachliche
Einstiegsform und die Profilregeln sind damit in Zig und C gleich.
Oeffentliche Typen stehen in Code/System/SDK/Shared/C/include/r4os/.

Build
-----

Ein Projekt:

    DevTools/Scripts/Build.bat -app MYAPP

Alle Apps/Module:

    DevTools/Scripts/Build.bat -apps

Voller Build ohne QEMU:

    DevTools/Scripts/Build.bat -norun

Explizites Slim-Image:

    DevTools/Scripts/Build.bat -slim

Der Projektbuild erzeugt R4M0. ModuleCatalog validiert vor jedem Imagepfad den
vollstaendigen Katalog, waehlt alle R4X/R4L/R4D/R4P deterministisch nach
IMAGE_SCOPE und Profil und lehnt doppelte Ziele, scopebedingt fehlende bekannte
R4L-Provider oder fehlende Artefakte ab. Slim enthaelt `slim`, Full
`slim + full`, Test `slim + test`. Danach prueft das Current-R4X-Gate jedes
einzupackende R4X, bevor ImageCreator `disk.img` schreibt.

Tests
-----

    DevTools/Scripts/Build.bat -test
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-SDKExternalBuild05116.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-R4XProjectGenerator0584.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Invoke-CurrentApiContractGate.ps1 -SelfTest
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-ApiContractConformance05818.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-AppContractSemantics05819.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-TimeoutConcurrencyContract05821.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-AppEntryContract05822.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-StorageFacadeContract05823.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-GuiFacadeContract05824.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-ResourceFacadeContract05825.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-ServiceNetworkFacadeContract05826.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-AudioDeviceFacadeContract05827.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-ModuleCatalogContract05828.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-ManifestBuildContract05829.ps1 -Acceptance
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-R4CodeModuleContract05830.ps1 -Acceptance
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-CatalogAggregateContract05831.ps1 -Acceptance
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-ManifestImageContract05832.ps1 -Acceptance
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-R4CodeR4MFContract05833.ps1 -Acceptance
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-R4CodePadR4MFContract05834.ps1 -Acceptance
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-InTreeApiClosure05835.ps1 -Acceptance
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-DisposableAppMatrix05835.ps1 -Acceptance
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-RuntimeR4LCompatibility0644.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-NewR4LWorkflow0648.ps1

Maschinenlesbarer Vertrag:

    Code/BuildTools/ApiContractGen/zig-out/bin/api-contract-gen.exe --validate
    Code/BuildTools/ApiContractGen/zig-out/bin/api-contract-gen.exe --check
    Code/BuildTools/ApiContractGen/zig-out/bin/api-contract-gen.exe --selftest
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Invoke-PayloadLayoutPreviewGate.ps1

ApiContract.json ist UTF-8 ohne BOM und kanonisch. Die Baseline wird nicht
von normalen Builds geschrieben. Ein bewusstes Update verlangt die getrennte
Aktion --write --baseline. Das Schema erfasst zentrale Public-Payloadtypen
einschliesslich ihrer Zig-Defaultwerte, Gruppenslots,
Status-/Fehlerdomaenen und deren Operationssemantiken, App-Profile sowie
Konstanten und Limits. Die erzeugten Referenzen
unter Docs/API, die generierten Zig-/Kernel-/C-ABI-Dateien, R4L-
Identitaeten, Contractlayoutbloecke und Conformance-Fixtures gehoeren zum
bytegenauen --check. Normale Builds generieren diese Dateien nicht still neu.
Die Kernel-Gruppentabellen werden aus sechs exakt typisierten Providern gebaut;
falsche Signaturen oder fehlende Felder sind Compilerfehler.
`Docs/API/ZigCParity.json` wird ebenfalls daraus erzeugt und trennt
Signatur-/Fassadenvertraege von ausgefuehrten Zig-/C-Fixturefamilien.

Kompilierte Runtime-R4Ls verwenden stattdessen einen librarylokalen Contract
und eine librarylokale Baseline. Ihr module.R4MF nennt alle Eingaben und
materialisierten Ausgaben; R4LContractGen besitzt keine Standardpfade. Der
normale `zig build` fuehrt ausschliesslich den schreibfreien bytegenauen
`--check` aus und baut danach den Zig- oder C-Provider als freestanding ELF und
R4M0. Das Muster unter `Code/System/Libraries/ACMECALC` ist absichtlich nicht
auszuliefern. Seine zwei eingefrorenen Providergenerationen, ein alter
V1-Verbraucher sowie aktuelle Zig-/C-Verbraucher belegen append-only V1,
paralleles V2, Buffer- und Handle-Ownership und die Aktivierung erst nach dem
Neustart. Kein konkreter Libraryname ist dafuer im zentralen Contract, Kernel
oder Kern-SDK erforderlich. `New-R4LProject.ps1` legt dieses vollstaendige
Muster fuer eine neue Zig-Library an. R4ECHO belegt als Testprofil-Referenz,
dass Einzelbuild, Hosttests, Root-Discovery und Imageauswahl ohne zentrale
Namensregistrierung funktionieren.

Wichtige Pfade
--------------

    Code/System/SDK/r4os/                         Zig-SDK
    Code/System/SDK/r4os/abi_generated.zig        generierte Program-ABI
    Code/System/SDK/r4os/abi.zig                  stabile Zig-Fassade/Reexports
    Code/System/SDK/r4os/app_contract.zig         App-Fassade und Profile
    Code/System/SDK/r4os/app_storage.zig          Datei-/Registry-Fassade
    Code/System/SDK/r4os/app_gui.zig              Fenster-/Nachrichten-/Zeichenfassade
    Code/System/SDK/r4os/app_resources.zig        Prozess-/Thread-/VM-/Async-I/O-Ressourcen
    Code/System/SDK/r4os/app_services.zig         Service-Connection-/Endpoint-Lebenszyklen
    Code/System/SDK/r4os/app_network.zig          DNS-/TCP-/UDP-Fassade ueber R4X-Services
    Code/System/SDK/r4os/app_audio.zig            AUDSVC-PCM und getrennte Advanced-Synth-Sicht
    Code/System/SDK/r4os/app_devices.zig          Inventar-/Speicher-/Performance-Sichten
    Code/System/SDK/r4os/lowlevel.zig             expliziter roher ABI-Zugriff
    Code/System/SDK/r4os/runtime_r4l.zig          generische Header-/Slotpruefung
    Code/Kernel/program/r4x_api_generated.zig      generierte Kernel-Program-ABI
    Code/Kernel/program/r4x_api.zig                zyklusfreie Kernel-Fassade
    Code/System/SDK/Shared/C/include/r4os/        C-Fassade und generierte ABI
    Code/System/Libraries/*/src/api_contract_generated.zig generierte R4L-Basis
    Code/System/SDK/Templates/                    Projektvorlagen
    Code/System/SDK/Templates/R4L/Zig/             New-R4L-Vorlagen
    Code/System/SDK/BuildProfiles/                Buildprofile
    Code/System/SDK/Contract/                     API-/ABI-Vertrag
    Code/System/SDK/Contract/API/ApiContract.json maschinenlesbare Quelle
    Code/System/SDK/Tools/R4LContractGen/          lokaler R4L-Generator
    Code/System/Libraries/ACMECALC/                Zig-/C-Referenzeinheit
    Code/System/Libraries/R4ECHO/                   generierte Testprofil-Referenz
    Code/BuildTools/ApiContractGen/                Schema- und Driftpruefung
    Docs/API/                                     generierte Feld-/Payloadreferenz
    Docs/SDK/RuntimeR4L0644.txt                    Kompatibilitaetsabnahme
    Docs/SDK/RuntimeR4L0648.txt                    New-R4L und zentrale Bereinigung
    Docs/Applications/R4X.txt                     R4X-Laufzeitmodell
