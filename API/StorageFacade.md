# Console-, Datei-, Verzeichnis- und Registry-Fassade

## Zweck

Normale Zig- und C-Anwendungen greifen ueber kleine, typisierte
SDK-Fassaden auf Console, Dateien, Verzeichnisse, Streams und Registry zu.
Die Fassaden liegen ueber den vorhandenen R4SYS-Feldern. Sie fuehren weder
eine zweite Implementierung noch neue Kernelaufrufe oder erfundene
Dateihandles ein.

Zig erhaelt die Fassaden ueber `r4os.App`:

```zig
const console = app.console() orelse return r4os.abi.err_no_fn;
var files = app.files() orelse return r4os.abi.err_no_fn;
var registry = app.registry() orelse return r4os.abi.err_no_fn;
```

C verwendet dieselben Sichten aus `<r4os/r4os.h>`:

```c
R4Console console = r4_app_console(app);
R4Files files = r4_app_files(app);
R4Registry registry = r4_app_registry(app);
```

Eine Fassade ist nur verfuegbar, wenn ihre benoetigten Tabellenfelder
vorhanden sind. Fehlende Voraussetzungen bleiben ein sichtbares Ergebnis.

## Pfade und Buffer

`FilePath`, `AbsoluteFilePath`, `RelativeFilePath` und `RegistryPath` stammen
aus dem gemeinsamen Text-/Pfadvertrag. Eingaben werden normalisiert, aber nie
still gekuerzt. Registry-Pfade bleiben ein eigener Namensraum.

Alle Daten-, Verzeichnis- und Konfigurationsbuffer gehoeren dem Aufrufer.
Iteratoren, `StreamReader` und der gewoehnliche `StreamWriter` speichern nur
die uebergebene Pfadsicht und ihren kleinen lokalen Zustand. Der Pfad muss
deshalb mindestens so lange leben wie dieser Iterator oder Stream. Der
create-only `OwnedStageWriter` ist die bewusste Ausnahme: Er besitzt eine
typisierte Kopie seines absoluten Stage-Pfads und bindet den internen
R4SYS-Zeiger nach Struct-Moves neu. Die Fassade besitzt keinen globalen
Scratch-Buffer und allokiert nicht implizit.

## Dateien

`Files` bietet pfadbasierte Operationen:

- `read` und `readAt`;
- `write` und `append`;
- `info`, `delete`, `rename`, `createDirectory` und `deleteDirectory`;
- `iterate`, `streamReader`, `streamWriter` und `copy`.

Lesen und Schreiben liefern `Transfer`: `bytes`, `end` oder `failure`.
Operationen ohne Daten liefern `Operation`: `ok`, `missing` oder `failure`.
`DirectoryIterator` adressiert den jeweils N-ten lebenden Eintrag. Loescht
ein Verbraucher den gerade gelieferten Eintrag waehrend der Iteration, ruft
er `revisitAfterRemoval` auf; dadurch wird der an denselben logischen Index
nachgerueckte Nachbar nicht uebersprungen.
Der fachliche Rohcode bleibt im Fehlerfall erhalten. Ein Leseergebnis mit
null Bytes ist ein explizites Dateiende. Ein Schreibresultat mit null Bytes
bleibt dagegen ein bestaetigter Transfer und wird nicht zu Dateiende
umgedeutet.

```zig
var path = r4os.FilePath.parse("C:/TEMP/HELLO.TXT") catch return 1;
var buffer: [512]u8 = undefined;
switch (files.read(path.asZ(), buffer[0..])) {
    .bytes => |count| console.write(buffer[0..count]),
    .end => {},
    .failure => |raw| return raw,
}
```

```c
R4FilePath path = {0};
uint8_t buffer[512];
if (r4_file_path((const uint8_t *)"C:/TEMP/HELLO.TXT", 17u, &path) != R4_PATH_OK)
    return 1;
R4Transfer result = r4_files_read(&files, &path, buffer, sizeof(buffer));
if (result.state == R4_TRANSFER_FAILED) return result.raw_code;
```

## Verzeichnisse

`DirectoryIterator` startet hinter den FAT-Sondereintraegen und unterscheidet
`entry`, `end` und `failure`. Nur der aktuelle Backend-Endmarker `-5` wird zu
`end`; andere negative Codes bleiben Fehler. Nach `end` bleiben weitere
Aufrufe deterministisch am Ende. In Zig zeigt der Eintragspfad in den vom
Aufrufer uebergebenen Ausgabebuffer und ist bis zu dessen naechster Verwendung
gueltig. C liefert den normalisierten Pfad als festen Inline-Buffer im vom
Aufrufer gehaltenen `R4DirectoryNext`-Wert zurueck.

```zig
var root = r4os.FilePath.parse("C:\\") catch return 1;
var iterator = files.iterate(root.asZ());
var name: [256]u8 = undefined;
while (true) switch (iterator.next(name[0..])) {
    .entry => |entry| console.line(entry.path),
    .end => break,
    .failure => |raw| return raw,
};
```

## Streams

`StreamReader` behaelt den Offset und meldet Dateiende explizit.
`StreamWriter` verwendet die bestehende `file_stream`-Implementierung und
besitzt den vollstaendigen `begin`/`write`/`finish`- beziehungsweise
`abort`-Lifecycle. Nach einem Fehler, Finish oder Abort darf der Writer nicht
als aktiver Stream weiterverwendet werden. Teilerfolg wird nicht automatisch
wiederholt oder verschwiegen.

`ownedCreateWriter` oeffnet einen privaten create-only Stage mit R4SYS-Lease.
Sein `OwnedStageWriter` behaelt nach `finishKeepOwnership` den exakten
Ownership-Claim fuer `replaceAtomic`; `abort` gibt den Slot und den noch
nicht veroeffentlichten Stage frei. Der Writer bleibt auch nach Rueckgabe oder
einem normalen Struct-Move pfadsicher, weil er die normalisierte absolute
Pfadkopie selbst traegt. Vor dem ersten Sichtbarkeitspunkt materialisiert
R4SYS einen durablen, als allgemeines Storage attribuierten Publish-Claim;
ein frisches Image benoetigt dafuer keinen vorher angelegten UPDATE-Baum.

## Registry

`Registry` verwendet `RegistryPath` und liefert eine `RegistryValue`-Sicht in
den Aufruferbuffer. Der Typ steht in `RegistryValueInfo`; Zig bietet
`asString`, `asU32`, `asU64` und `asBool`, C die entsprechenden typisierten
View-Helfer. Setzer fuer String, U32, U64, Bool und Binaerdaten kodieren den
vorhandenen R4SYS-Vertrag. Fehlender Key oder Wert ist `missing`, nicht ein
allgemeiner Fehler.

## R4STD Date, Time, Settings und Config

R4STD ist eine unabhaengige Runtime-R4L mit getrennten TEXT_V1-, SETTINGS_V1-,
DATE_V1-, TIME_V1- und CONFIG_V1-Tabellen. Ein Modul importiert nur seinen
Bedarf und bindet die lokalen R4STD-Zig-/C-Bindings ein. Zig initialisiert sie
mit `r4std.init(app.startContext())`; C initialisiert die jeweilige
Clientstruktur aus `app->context`. Es gibt weder `app.standard()` noch eine
`R4XStartR4Std`-Kerneltabelle.

Date-/Time-Helfer verwenden librarylokale fixed-layout-Typen. Settings liest
eine geliehene Dokumentsicht und laesst bei doppelten Keys den letzten Eintrag
gewinnen. Config erhaelt die opake Adresse des caller-eigenen Startkontexts pro
Aufruf und nutzt daraus R4SYS fuer den atomaren Dateipfad. Pointer, Daten- und
Scratchbuffer werden nicht behalten.

## Quellen und Abnahme

- zentrale Storage-Fassade: `Code/System/SDK/r4os/app_storage.zig`
- R4STD-Bindings: `Code/System/Libraries/R4STD/Bindings/`
- R4STD-Implementierung: `Code/System/Libraries/R4STD/Source/`
- zentrale C-Fassade: `Code/System/SDK/Shared/C/include/r4os/app_storage.h`
- Sprachproben: `StorageFacadePrototype05823.zig` und `.c`
- permanentes Gate: `Run-StorageFacadeContract05823.ps1`

HELP, FSDIAG und REG sind die ersten migrierten In-Tree-Verbraucher. Ihre
Low-Level-Diagnoseanteile bleiben dort sichtbar, wo sie absichtlich rohe
Subsystemdaten pruefen.
