# R4MF v2: eine Projekt- und Modulwahrheit

`module.R4MF` ist die fachliche Projekt-, Build- und Imagequelle fuer jedes
In-Tree-Modul. Ein Manifest beschreibt genau ein R4X-Programm, eine
R4L-Library, einen R4D-Treiber oder ein R4P-Protokollmodul: Kind, Name,
Sprache, Quellen, Ziel, Imports und eigene Metadaten. R4X ergaenzt App-Klasse,
Entry-Modus und Image-Scope; Buildprofil, Artefaktpfad, R4XStart-Export und
feste Startmetadaten werden daraus abgeleitet.

```text
R4OS_MODULE_MANIFEST=2
KIND=R4X
NAME=HELLO
VERSION=0.1.0
LANGUAGE=Zig
SOURCE=src/main.zig
ENTRY_MODE=app
APP_CLASS=console
TARGET=/R4OS/SOFTWARE/TERMINAL/HELLO.R4X
IMAGE_SCOPE=full
OPTIMIZE=size
IMPORT=R4SYS:Query:1
META=app.role=example
```

Für C wird `SOURCE=` in der gewünschten Compilerreihenfolge wiederholt. Pfade
sind relativ zum Projekt, verwenden `/` und dürfen das Projekt nicht mit `..`
verlassen. `R4SYS:Query:1` steht sichtbar in der Importliste. Desktop-Apps
deklarieren zusätzlich `R4DESK:Query:1` und `R4DRAW:Query:1`. Das Werkzeug
prüft diese Anforderungen gegen dieselbe generierte Profilmatrix, die auch
der SDK-App-Einstieg verwendet.

C-Projekte und gemischte Zig/C-R4Ls koennen ihre nativen Buildparameter
wiederholbar im Manifest deklarieren: `C_INCLUDE=<relativer Pfad>`,
`C_DEFINE=<NAME>=<WERT>` und `C_FLAG=<einzelnes Compilerflag>`. Include-Pfade
duerfen wie `ZIG_MODULE` bewusst zu einem Paketgeschwister zeigen; absolute
Pfade und Backslashes bleiben verboten. Defines werden am ersten `=`
getrennt, Flags beginnen mit `-` und kein Wert darf Whitespace enthalten.
Ohne mindestens eine C-Quelle sind alle drei Felder unzulaessig.

Weitere Runtime-R4Ls werden direkt über Modul, Export und kleinste kompatible
Revision deklariert, zum Beispiel `IMPORT=ACMECODEC:API_V1:2`. Solche
benannten Imports benötigen weder eine `R4LGroup`-Konstante noch ein
App-Profilbit. Im `R4XStartImport` werden sie mit `group_id=0`, beiden Namen,
Mindest-/aufgelöster Revision und dem direkten Tabellenpointer transportiert.
Die sechs Kernelgruppen behalten dagegen ihren festen `Query:1`-Pfad.

## Modulversion

`VERSION=` ist die Version des **Moduls** und Pflichtfeld für alle vier
Modularten. Nicht zu verwechseln mit `R4OS_MODULE_MANIFEST=2` — das ist die
Version des Manifest*formats*.

Genau drei Zahlen, `MAJOR.MINOR.PATCH`, ohne Präfix, ohne Suffix und ohne
führende Null in einem Bestandteil. Der Grund ist der spätere Abgleich mit
einem Updateserver: `0.1.0` und `0.01.0` wären sonst zwei Zeichenketten für
dieselbe Version.

Gepflegt wird der Wert ausschließlich hier im Manifest. Alles andere entsteht
daraus und wird nie von Hand geändert:

| Ziel | Form |
| --- | --- |
| R4M0-Metadatenblock jedes Containers | `module.version=0.1.0` |
| `Inventory/Modules.json` | Feld `module_version` |
| `Injection/R4OS/CONFIG/MODULES.JSON` | Feld `version` |

Die letzte Datei ist die profilgebundene schlanke Sicht, die ins Image geht
und auf `C:\R4OS\CONFIG\MODULES.JSON` landet — Schema 2, Pflichtfeld
`profile`, Name, Art, Version und Zielpfad, ohne Baupläne. Sie
ist dort der **Anfangszustand** eines veränderlichen Systeminventars: Ein
Packet Manager trägt später Anwendungen ein und aus, ein Updater zieht nach
einem Update die Versionsnummer nach. Ein Updatepaket darf sie deshalb nie
überschreiben.

Wann eine Modulversion steigt, entscheidet der Mensch. Kein Gate erzwingt es;
geprüft wird nur, dass das Feld vorhanden und wohlgeformt ist.

`ENTRY_MODE=app` ist der normale Weg mit SDK-Startup und `r4_app_main`.
`ENTRY_MODE=lowlevel` kennzeichnet dagegen sichtbar einen direkten
R4XStart-Einstieg fuer die wenigen begruendeten Startup-, Loader- und
SIMD-Fixtures. Normale Anwendungslogik verwendet immer `app`.

Zig-Projekte koennen gemeinsam genutzten Quellcode explizit binden, zum
Beispiel `ZIG_MODULE=r4code_cc_core:../../Shared/r4cc_core.zig`. Alias und
Pfad sind damit Teil des Plans; C lehnt `ZIG_MODULE` ab. `PACKAGE=R4CODE`
gruppiert mehrere eigenstaendige Module nur fuer Installation und Doku. Der
Builder liest `PACKAGE` bewusst nicht als Buildentscheidung.

`IMAGE_SCOPE` hat vier current-only Werte:

- `slim`: zwingender Grundbestand
- `full`: zusätzliches Modul des Full-Images
- `test`: reines Testmodul
- `none`: kein Image

Die Mengen sind exakt: Slim enthält `slim`, Full enthält `slim + full`, Test
enthält `slim + test`. Full-Module gelangen nicht automatisch in Testimages.
`normal` und `both` werden abgewiesen. Der Scope beschreibt weder
Laufzeitabhängigkeit noch spätere Installierbarkeit. Kennt der Katalog für
eine importierte Gruppe eine R4L, muss sie im gewählten Profil ebenfalls
enthalten sein.

## Codeoptimierung

`OPTIMIZE=` ist fuer R4X optional und hat die Werte `size` oder `speed`.
Ohne Zeile gilt weiterhin `size` (`ReleaseSmall`). `speed` waehlt
`ReleaseFast` fuer nachweislich rechenintensive Anwendungen und darf ein
groesseres R4M0-Artefakt erzeugen. Die Wahl bleibt damit Bestandteil derselben
Manifestwahrheit und wird nicht in einer projektspezifischen `build.zig`
wiederholt. Sie veraendert weder Speicherprofil noch ABI, Imports oder
Imageplatzierung. Andere Modularten lehnen das Feld derzeit ab.

## Eingebettete Ressourcen (seit 0.61.12)

Ein Modul kann Icons, ein Helpfile und weitere Dateien direkt im
R4M0-Container tragen (Ressourcenbereich, Vertrag in
`Code/System/SDK/Contract/ABI/R4M0.txt`):

```text
ICON=Assets/Desktop.ico
HELP=Assets/Help.txt
RESOURCE=TOOLBAR.BMP:Assets/Toolbar.bmp
```

- `ICON=` ist wiederholbar; die Reihenfolge ist der Icon-Index, der erste
  Eintrag (Index 0) ist das Desktopicon. Icons muessen den SDK-ICO-Parser
  bestehen (klassisches ICO, kein PNG-Eintrag, 32x32 in 32 bpp BGRA oder
  8 bpp Palette) - ein unpassendes Icon ist ein Baufehler.
- `HELP=` hoechstens einmal; UTF-8, ein fuehrendes BOM der Bauquelle
  entfernt der Builder. Inhaltssprache ist Englisch wie alle sichtbaren
  R4OS-Ausgaben.
- `RESOURCE=NAME:pfad` wird am ERSTEN Doppelpunkt getrennt; Namen sind
  1 bis 63 Bytes druckbares ASCII ohne Pfadtrenner und Doppelpunkt,
  case-insensitive eindeutig. Hoechstens 64 Eintraege je Modul.

Die Bauquellen liegen nach Konvention unter `Assets/` im Projektordner
(bevorzugter Standardname des Desktopicons: `Assets/Desktop.ico`) und
duerfen das Projekt NICHT verlassen - Standalone-Baubarkeit. Projekte mit
Assets nehmen `"Assets"` in die `.paths` ihrer `build.zig.zon` auf.
R4L-Manifeste lehnen Ressourcenzeilen ab, weil ihr comptime-Baupfad nie
einbettet.

Das Hostwerkzeug liegt unter `Code/BuildTools/ModuleCatalog/`:

```text
module-catalog validate --manifest <Pfad>
module-catalog catalog --root Code --output <Katalog.json>
module-catalog resolve --root Code --name HELLO --path-only
module-catalog plan --manifest <Pfad> --output <Plan.json>
module-catalog contract-plan --manifest <Pfad> --output <Plan.txt>
module-catalog image-plan --root Code --image-mode full --output <Plan.txt>
module-catalog image-inventory --root Code --image-mode full --output <MODULES.JSON>
module-catalog convert-r4cp --manifest <alt.R4CP> --output <module.R4MF>
```

## Bauen

`Code/build.zig` entdeckt alle Standard-R4X unter Software,
Services und Diagnostics direkt aus dem Katalog. Ein normales In-Tree-Projekt
besitzt zusaetzlich `build.zig` und `build.zig.zon`, damit es eigenstaendig
baubar bleibt. Diese Dateien enthalten keine Modulwahrheit: `build.zig`
delegiert nur mit `sdk.addR4MF` an `module.R4MF`, `build.zig.zon` bindet das
SDK. Ein neues gueltiges Manifest wird ohne Aenderung am Root-Build gebaut.
Projektspezifische Hosttests bleiben getrennt moeglich.

`New-R4XProject.ps1` erzeugt fuer Zig und C das V2-Manifest, die Quelle und
den duennen eigenstaendigen SDK-Buildeinstieg. Der Standard-Scope ist `full`;
`-ImageScope` und `-Target` koennen ihn beziehungsweise das Installationsziel
bewusst setzen. Weder Root-Build noch Image-Tool oder Ankerdateien werden
bearbeitet.

`New-R4LProject.ps1` erzeugt fuer eine neue Zig-Runtime-R4L zusaetzlich den
librarylokalen Contract samt Baseline, Implementierungs-ABI, Zig-/C-Bindings,
Conformance-Fixtures, Runtime-Test und API-Referenz. Sein Standard-Scope ist
`none`; eine Aufnahme in `slim`, `full` oder `test` bleibt eine bewusste
Manifestentscheidung. Alle fachlichen Pfade bleiben innerhalb der
Librarywurzel, und der Root-Build entdeckt die Einheit ohne Namenseintrag.

Der SDK-Buildtreiber konsumiert dasselbe Manifest direkt. Fuer ein portables
Out-of-Tree-Projekt kann ein faktenfreier generischer Einstieg mitgeliefert
werden:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const sdk_build = b.lazyImport(@This(), "r4os_sdk") orelse return;
    const sdk_dep = b.dependencyFromBuildZig(sdk_build, .{});
    const sdk = sdk_build.sdk(b, sdk_dep, .{});
    _ = sdk.addR4MF(b.path("module.R4MF"));
}
```

Der Repository-Build erfolgt ueber `Build.bat -app NAME` oder einen
Projektpfad. In-Tree-Namen werden exakt im Katalog aufgeloest und ueber den
gefilterten Root- beziehungsweise SDK-Smoke-Aggregatbuild gebaut; portable
Out-of-Tree-Projekte verwenden den obigen generischen Einstieg. Das Ergebnis landet immer unter
`Code/zig-out/<NAME>.R4X`. Zig-/C-Quelle, Profil, App-Klasse,
Entry-Modus, Imports, Zig-Module und Metadaten werden ausschliesslich aus
R4MF v2 gelesen. Insbesondere
wird `R4SYS` nicht mehr still vorangestellt: Die Reihenfolge im binaeren R4M0
entspricht bytegenau der Reihenfolge der `IMPORT`-Zeilen.

Die vier ersten App-Referenzen sind BEEP (Zig/Console), CALC (Zig/Desktop), CNETD
(C/Console) und APPCDESK (C/Desktop). Nicht unterstuetzte Manifest- oder
Hostfaehigkeiten brechen mit einem ausdruecklichen Contract- beziehungsweise
Capabilityfehler ab; es gibt keinen Ersatzbuild. R4CODE,
R4BUILD, R4PACK und R4CC vier weitere eigenstaendige V2-Module. Die gemeinsam
verwendeten Compiler-/Packer-Cores liegen einmal unter
`Code/System/Software/R4Code/Shared/`.

Alle In-Tree-Manifeste verwenden denselben aktuellen V2-Parser. Der Katalog
enthaelt R4X, R4D, R4P und R4L und lehnt jede andere Manifestversion ab.
Normale R4X werden aus dem Root- beziehungsweise SDK-Smoke-Aggregat gebaut;
die anderen Modulkinds behalten ihre fachlichen Einzelprojekte, verwenden
aber dieselbe Katalog- und Imagewahrheit.

`image-plan` erzeugt die Installationsliste aller vier Modularten
deterministisch aus TARGET, IMAGE_SCOPE und dem gewaehlten Profil. Produktive
Apps verwenden `slim` oder `full`; SDK-Smokes und bewusst nur extern gebaute
Module verwenden `test` oder `none`. Auch synthetisch erzeugte Fixtures halten
ihre Policy in getrennten, vom gemeinsamen Parser validierten Manifesten.
CreateImageAddList liest keine Manifeste parallel. Fehlende Artefakte,
scopebedingt fehlende bekannte R4L-Provider und case-insensitive
Zielkollisionen sind harte Fehler vor dem ersten Imagewrite.

## R4CODE und R4BUILD

R4CODE legt neue C-Projekte direkt mit `module.R4MF` an und liest
beim Oeffnen keine zweite Projektsemantik. R4BUILD besitzt die drei aktuellen
Befehle `VALIDATE`, `PLAN` und `BUILD`. Alle drei verwenden den gemeinsamen
Runtime-Parser `r4os.r4mf`; `PLAN` schreibt denselben umgebungsneutralen
`R4MF_PLAN=1`-Vertrag wie ModuleCatalogs `contract-plan`. Dadurch lassen sich
Host- und Inside-R4OS-Plan fuer dasselbe Manifest bytegenau vergleichen.

Der interne Compilerpfad unterstuetzt aktuell genau die vorhandenen C-Console-
und C-Desktop-Profile mit einer C-Quelle und den profilgenauen Imports. Zig,
Service-Apps, zusaetzliche C-Quellen oder andere Importsaetze brechen sichtbar
mit einem Capabilityfehler ab; R4BUILD wechselt nicht auf einen Ersatzpfad.
R4CC erwartet in beiden Profilen den aktuellen C-App-Einstieg
`r4_app_main(R4App*)`; der rohe Console-Einstieg wird nicht mehr akzeptiert.

Eine historische `.R4CP`-Datei wird nur noch durch den ausdruecklichen
Einmalbefehl `R4BUILD CONVERT <alt.R4CP> <module.R4MF>` gelesen. Der Konverter
bewahrt Modulname, Quellenreihenfolge, Imports und Ziel, schreibt atomar und
ist bei identischem Ziel byteerhaltend. Ein vorhandenes abweichendes Ziel oder
ein Fehler laesst Quelle und Ziel unveraendert. R4CODE und normale R4BUILD-
Befehle behandeln R4CP nicht als Projekt- oder Buildvertrag.

Auch die externe Host-IDE R4CodePad nutzt ausschliesslich
`module.R4MF` v2. Projektansicht, Validierung und Buildplan stammen aus
ModuleCatalogs `contract-plan`; die IDE besitzt keinen C#-Manifestparser mehr.
Der portable Build verwendet einen faktenfreien `sdk.addR4MF`-Treiber. Der
explizite R4CP-Import ruft `module-catalog convert-r4cp` auf und verwendet
damit denselben `r4cp_convert`-Renderer wie R4BUILD. R4CodePad 0.1.18 wurde im
Partnerrepository mit Commit `ec469dd` abgeschlossen.

Der vollständige formale Vertrag steht in
`Code/System/SDK/Contract/Module/R4MFv2.txt`. Die maschinenlesbare Inventur
des aktuellen Übergangsbestands ist `Inventory/Modules.json`.
