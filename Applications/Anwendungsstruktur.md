# R4OS-Anwendungsstruktur

R4OS-Anwendungen sind eigenstaendige R4X-Projekte unter
Code/System/Software/. Diagnoseprogramme liegen unter
Code/System/Diagnostics/, Services unter Code/System/Services/.

## Neues Projekt

    DevTools/Scripts/New-R4XProject.ps1 -Name MYAPP -Language zig
    DevTools/Scripts/New-R4XProject.ps1 -Name MYAPPC -Language c -Groups R4NET

Der Generator erzeugt das aktuelle Manifest, die Quelle und die duennen
Standalone-Builddateien. Root-Build, Modulkatalog und Imageplan entdecken das
Projekt aus dem Manifest; feste Aggregat- oder Imageeintraege werden nicht
angelegt.

## Verzeichnis

    Code/System/Software/MyApp/
      module.R4MF
      build.zig          duenn, nur sdk.addR4MF(b.path("module.R4MF"))
      build.zig.zon      bindet r4os_sdk ueber .path; .paths inkl. Assets
      src/main.zig
      Assets/            Bauquellen des R4M0-Ressourcenbereichs
        Desktop.ico      bevorzugter Standardname des Desktopicons
        Help.txt         Helpfile fuer NAME /?
        ...              weitere Mediendateien (RESOURCE=)

C-Projekte verwenden src/main.c. Assets/ existiert nur, wenn das Modul
Ressourcen einbettet; die Boilerplate-Formen stehen woertlich in
`Agents/R4M0-Container.txt`.

## Manifest

module.R4MF ist UTF-8 ohne BOM und definiert fuer ein R4X:

- KIND=R4X
- Name, Sprache, Quelle, App-Klasse, Einstieg, Imageziel und Image-Scope
- Imports wie R4SYS:Query:1 und weitere Gruppen
- optionale Metadaten und gemeinsame Zig-Quellmodule
- optionale eingebettete Ressourcen: ICON=, HELP= und RESOURCE=NAME:pfad
  (seit 0.61.12; landen als .rsrc-Bereich im R4M0-Container)

Buildprofil, Artefaktpfad, R4XStart-Export, R4M0-/R4XStart-Contracts und feste
Startmetadaten werden abgeleitet. Die projektlokale build.zig existiert seit
0.61.8 fuer den eigenstaendigen Bau, bleibt aber duenn: Sie zeigt nur auf das
Manifest und wiederholt keine Modulangabe - es gibt keine zweite Modulwahrheit.
Der vollstaendige aktuelle Vertrag steht in `Docs/SDK/ModuleManifestV2.md`.

## Einstieg und App-Objekt

Der SDK-eigene Startup exportiert den binaeren R4XStart-Einstieg. Zig- und
C-Anwendungsquellen implementieren nur denselben fachlichen App-Einstieg:

    pub fn r4_app_main(app: *r4os.App) i32 {
        app.system().println("Hallo R4OS");
        return 0;
    }

    int32_t r4_app_main(R4App *app) {
        r4sys_write_cstr(&app->system, "Hallo R4OS\r\n");
        return 0;
    }

Das Profil console oder service verlangt R4SYS. desktop verlangt R4SYS,
R4DESK und R4DRAW. Fehlende Pflichtgruppen machen den Einstieg sichtbar
ungueltig; optionale Gruppen werden in Zig als null und in C ueber
r4_app_has_group sichtbar. Jedes App-Objekt besitzt sein Bundle selbst.

Normale Console-, Datei-, Verzeichnis-, Stream- und Registry-Zugriffe laufen
ueber `app.console()`, `app.files()` und `app.registry()` beziehungsweise die
gleichwertigen C-Sichten. R4STD ist eine unabhaengige Runtime-R4L: Das Projekt
importiert die benoetigten TEXT_V1-, SETTINGS_V1-, DATE_V1-, TIME_V1- oder
CONFIG_V1-Tabellen, bindet das lokale Zig-/C-Binding ein und initialisiert es
aus `app.startContext()` beziehungsweise `app->context`. Alle Daten- und
Scratchbuffer bleiben beim Aufrufer. Siehe `Docs/API/StorageFacade.md`.

R4IMG ist eine unabhaengige Runtime-R4L. Das Projekt importiert
`R4IMG:API_V1:1`, bindet das lokale Zig- oder C-Binding ein und erzeugt den
Librarykontext aus `app.startContext()` beziehungsweise `app->context`.
Der Aufrufer besitzt Encodedaten, Decoder-Scratch und Pixelpuffer; die
Formatgrenzen stehen in `Docs/API/R4IMG.md`.

R4FONT ist ebenfalls eine unabhaengige Runtime-R4L. Das Projekt importiert
`R4FONT:API_V1:1`, bindet das lokale Zig- oder C-Binding ein und erzeugt den
Librarykontext aus `app.startContext()` beziehungsweise `app->context`.
Quellbytes, Decoder, Faces und Glyphraster gehoeren dem Aufrufer; Formate und
Grenzen stehen in `Docs/API/R4FONT.md`.

Prozesse, joinbare Threads, virtuelle Speicherbereiche und Async-I/O-Requests
werden ueber `app.resources()` beziehungsweise `r4_app_resources` erzeugt.
Die besitzenden Objekte werden per Wait/Join/Reap/Release/Close abgeschlossen
und danach invalidiert; Async-I/O haelt den caller-owned Buffer sichtbar bis
Completion plus Close. Siehe `Docs/API/ResourceObjects.md`.

Optionale Kernel-Felder werden mit hasFn("feld") geprueft. Unabhaengige
Runtime-R4Ls wie R4STD, R4IMG und R4FONT validieren ihre eigenen Tabellen beim
Aufbau ihres Kontexts.

Roher R4XStart-/Tabellenzugriff ist kein normaler Anwendungseinstieg und
liegt fuer Loader-, Startup- und gezielte Diagnosefixtures unter
`r4os.lowlevel`. Neue Anwendungslogik verwendet die typisierten Fassaden.

## Schichten

Anwendungslogik bleibt im Projekt. Wiederverwendbare sprachneutrale
Systemfunktionen gehoeren in R4L-Libraries. Hardwarezugriff gehoert in R4D,
Protokollcode in R4P. Nur technisch zwingende Grundlage liegt im Kernel.

## Build und Abnahme

    DevTools/Scripts/Build.bat -app MYAPP
    DevTools/Scripts/Build.bat -norun
    DevTools/Scripts/Build.bat -test

Die Vertragspruefung laeuft permanent vor Kernel-/App-Builds. Feldreferenzen
stehen unter Docs/API/, der binaere Vertrag unter
Code/System/SDK/Contract/.
