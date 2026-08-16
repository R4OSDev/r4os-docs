# R4STD.R4L

R4STD ist eine unabhaengige Runtime-R4L. Ihre fachliche ABI ist keine zentrale
Plattformgruppe: Sie besitzt keine Gruppen-ID, keine R4XStart-Kerneltabelle,
kein Feld in `r4os.App` und keine R4STD-Operation im zentralen
`ApiContract.json`.

Die gesamte Library-Einheit liegt unter `Code/System/Libraries/R4STD/`:

- `Contract/LibraryContract.json` ist die API-/ABI-Wahrheit.
- `Contract/LibraryContract.baseline.json` prueft append-only-Kompatibilitaet.
- `Source/` besitzt die produktive Implementierung.
- `Bindings/Zig/r4std.zig` und `Bindings/C/r4std.h` sind die lokalen
  Sprachbindungen.
- `Docs/API.md` ist die aus dem lokalen Contract erzeugte Slotreferenz.

Das Artefakt liegt als `C:\R4OS\LIBS\R4STD.R4L` im Image. Sein technischer
`Query:1`-Export dient nur der Modulidentitaet; Anwendungen importieren direkt
die benoetigten Funktionstabellen.

## Interfaces

R4STD 0.2.1 exportiert fuenf unabhaengig pruefbare V1-Interfaces:

| Import | Aufgabe |
| --- | --- |
| `R4STD:TEXT_V1:1` | Textinspektion und kanonisches Schreiben |
| `R4STD:SETTINGS_V1:1` | R4S-Parser, Writer und Writeback-Zustand |
| `R4STD:DATE_V1:1` | Kalender, Formatierung, Parsing und FAT-Zeit |
| `R4STD:TIME_V1:1` | Zeitzonen, Sommerzeit und Zeitkonfiguration |
| `R4STD:CONFIG_V1:1` | typisierte und atomare R4S-Dateioperationen |

Jede Tabelle besitzt eigene Identitaet, ABI-Major-Version, Revision,
Mindestgroesse und Pflichtslots. Eine kompatible Erweiterung waechst nur am
Ende ihrer Tabelle. Ein Verbraucher importiert nur die Interfaces, die er
wirklich nutzt.

## Date

Das lokale Zig-Binding `r4std.date` kapselt Datumsberechnung,
Plausibilitaetspruefung, Parsing und Formatierung. Die ABI verwendet
librarylokale fixed-layout-Typen und kopiert keine Plattformstruktur.

## Time

`r4std.time` kapselt Zeitdarstellung sowie Zeitzonen-/DST-Berechnung. Dauer,
monotone Zeit, Deadline und UTC bleiben dabei verschiedene Begriffe; der
Nutzungsvertrag steht in `TextPfadZeitVertrag.md`.

## Settings

Settings ist die Parser-/Writer-Grundlage fuer R4S-Dokumente:

- tolerant lesen
- kanonisch UTF-8 mit BOM und CRLF schreiben
- `R4S_FORMAT=1` und `SCHEMA=...` erzeugen
- Bool-, Integer- und RGB24-Werte lesen und schreiben

Settings besitzt keinen weiteren R4L-Import. Eine Dokumentansicht leiht sich
die Eingabebytes; der Aufrufer haelt sie waehrend der Auswertung gueltig.

## Config

Config ist der Komfortpfad fuer R4S-Konfigurationsdateien. Die Registry bleibt
ein eigener Namensraum; app-eigene Dokumente bleiben Dateien. Jede Operation
erhaelt deshalb einen expliziten, validierten Dateipfad, zum Beispiel:

    C:\R4OS\CONFIG\APPS\NOTEPAD.R4S
    C:\R4OS\CONFIG\APPS\PAINT.R4S
    D:\TOOLS\MYAPP\MYAPP.R4S

Lesen unterscheidet vorhandene Werte, verwendete Vorgaben und Fehler.
Schreiben unterscheidet Aktualisierung, Neuanlage und Wiederherstellung.
Rohcodes werden nicht umgedeutet; ihre aktuelle Zuordnung steht generiert in
der Operationsmatrix.

Config liest tolerant:

- fehlende Dateien liefern Defaultwerte.
- leere Dateien liefern Defaultwerte.
- kaputte Zeilen werden ignoriert.
- doppelte Keys werden wie bei R4S behandelt: der letzte gueltige Wert gewinnt.
- ein vorhandenes `R4S_FORMAT` wird nur akzeptiert, wenn es `1` ist.

Config schreibt kanonisch:

- UTF-8 mit BOM.
- `R4S_FORMAT=1`.
- `SCHEMA=<Dateiname>` oder vorhandenes gueltiges Schema.
- CRLF-Zeilenenden.
- Bool-Werte als `ON` oder `OFF`.
- RGB24 als sechs Hex-Ziffern ohne `#`.
- atomischer Schreibpfad ueber `.TMP`, Readback-Check, `.BAK` und Replace.

## Einbindung

Ein Zig-Modul bindet die lokale Fassade mit `ZIG_MODULE` ein, deklariert die
benoetigten R4STD-Imports und initialisiert sie einmal aus seinem Startkontext:

```zig
const r4os = @import("r4os");
const r4std = @import("r4std");

pub fn r4_app_main(app: *r4os.App) i32 {
    if (!r4std.init(app.startContext())) return r4os.abi.err_no_group;
    const path = "C:\\R4OS\\CONFIG\\APPS\\NOTEPAD.R4S";

    var system = app.system();
    var enabled = false;
    const result = r4std.config.readBool(
        &system,
        path,
        "ENABLED",
        true,
        &enabled,
    );
    if (result < 0) return result;
    return 0;
}
```

Dieses Beispiel braucht `IMPORT=R4STD:CONFIG_V1:1`. C bindet den lokalen
Header ein und initialisiert je nach Bedarf etwa `R4StdConfigV1Client` mit
`r4std_config_v1_init(app->context, ...)`.

## Besitz und Plattformzugriff

Alle Eingabe- und Ausgabebuffer sowie R4S-/Writeback-Zustaende bleiben beim
Aufrufer. R4STD behaelt keine uebergebene Adresse ueber einen Funktionsaufruf
hinaus. CONFIG_V1 erhaelt den R4XStart-Kontext als opake caller-eigene Adresse
pro Aufruf und loest daraus R4SYS; die Library definiert weder eine Kopie der
Plattform-ABI noch einen eigenen Dateisystempfad.

Konfigurationswrites verwenden weiterhin TMP, Readback, BAK und Replace.
Positive Ergebnisse unterscheiden vorhandenen Wert, Vorgabe, Neuanlage und
Recovery; negative Werte bleiben der lokalen R4STD-Fehlerdomaene zugeordnet.

## Unabhaengigkeit

Eine append-only-kompatible R4STD-Aenderung betrifft nur Contract,
Implementierung, Bindings, Tests und Versionsstand dieser Library-Einheit.
Kernel, zentraler Contract und Kern-SDK muessen dafuer nicht geaendert werden.
Nur Verbraucher, die neue oder inkompatible Funktionen verwenden wollen,
passen ihren Import und ihre Nutzung an.

## Abnahme

Der eigenstaendige R4STD-Build prueft lokalen Contract, Zig-/C-Conformance,
Provider und Runtime-Verhalten. Consumer-Hosttests verwenden einen echten
In-Process-R4STD-Provider. R4CFGD prueft im Gast fehlende Dateien, ungueltige
Zeilen, Vorgabewerte, zentrale und app-lokale Pfade sowie den atomaren
TMP/BAK-Schreibpfad.
