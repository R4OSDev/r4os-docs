R4OS Text-, Pfad- und Zeitvertrag
=================================

Zweck
-----

Dieser Vertrag trennt Begriffe, die an der Programmschnittstelle nicht
gegeneinander austauschbar sind. Die zentralen maschinenlesbaren Typen,
Konstanten und Limits stehen in
`Code/System/SDK/Contract/API/ApiContract.json`; R4STD-Typen und -Operationen
stehen in `Code/System/Libraries/R4STD/Contract/LibraryContract.json`. Dieses
Dokument erklaert ihre Verwendung und ist keine zweite numerische
Vertragsquelle.

Text und Bytes
--------------

- `Bytes` sind beliebige Bytes. Sie versprechen weder UTF-8 noch Text.
- `Utf8Text` ist gueltiges UTF-8 ohne eingebettetes NUL. `len` ist immer die
  Byte-Laenge; die Anzahl der Unicode-Skalare muss bei Bedarf getrennt
  ermittelt werden.
- `SystemText` ist das Format fuer R4OS-Systemtextdateien. Gelesen werden
  UTF-8 mit oder ohne BOM sowie LF oder CRLF. Geschrieben wird kanonisch als
  UTF-8 mit BOM und CRLF. Ein einzelnes CR ist ungueltig.
- `DocumentText` bewahrt die exakten Eingangsbytes, das erkannte Encoding und
  die erkannten Zeilenenden. Speichern mit `writeExact` normalisiert nichts.
- `UiText8` bildet den derzeit real vorhandenen UI-Pfad ab: druckbares
  7-Bit-ASCII sowie Tab, CR und LF. Nicht-ASCII wird sichtbar abgelehnt.

`R4TextView` ist eine nicht besitzende ABI-Sicht aus Pointer und Byte-Laenge.
Der Pointer darf nur waehrend der vom aufgerufenen Wrapper dokumentierten
Lebensdauer verwendet werden. Die Sicht ist kein C-String und garantiert
keinen abschliessenden NUL. C-Strings bleiben an den vorhandenen `*Z`-
Grenzen NUL-terminiert; eingebettetes NUL ist in Text immer ein Fehler.

Die kanonische SystemText-Ausgabe berechnet zuerst die erforderliche Groesse.
Bei einem zu kleinen Zielbuffer wird die erforderliche Groesse gemeldet und
kein Teil des Buffers veraendert.

Dateipfade
----------

Die SDK-Typen machen die erlaubte Pfadart sichtbar:

- `FilePath` akzeptiert absolute oder relative Dateipfade.
- `AbsoluteFilePath` verlangt einen Laufwerksroot.
- `RelativeFilePath` lehnt einen Laufwerksroot ab.
- `PathZ` ist eine explizite NUL-terminierte Sicht auf einen bereits
  validierten Pfad.
- `RegistryPath` ist ein eigener Namensraum und keine Dateipfadvariante.

Ein kanonischer absoluter Dateipfad hat die Form `X:\...`, verwendet einen
grossen Laufwerksbuchstaben und Backslashes. Am Eingangsrand werden Slash und
Backslash akzeptiert. Doppelte Separatoren und `.` werden entfernt; `..`
wird aufgeloest und darf niemals oberhalb des Roots fuehren.

Pfadkomponenten sind seit 0.60.18 UTF-8, beschraenkt auf die Basic
Multilingual Plane: erlaubt sind ASCII (ohne die reservierten Zeichen
`< > " | ? * :` und Steuerzeichen) sowie wohlgeformte 2- und
3-Byte-UTF-8-Sequenzen. Overlong-Formen, Surrogate, einzelne
Fortsetzungsbytes und 4-Byte-Sequenzen (ausserhalb der BMP) werden sichtbar
abgelehnt; es gibt keine stille Ersetzung. Der Pfadvergleich bleibt
ASCII-case-insensitiv; Nicht-ASCII vergleicht exakt. Auf NTFS laeuft der
Namensvergleich zusaetzlich ueber die $UpCase-Tabelle des Volumes
(Windows-Verhalten), auf FAT32 werden lange Namen als UTF-16-Units in
LFN-Eintraegen gespeichert.

Die Limits sind seit 0.60.19 Windows-Paritaet in ZEICHEN: eine Komponente
traegt hoechstens 255 Zeichen (`path_component_max_chars`), ein Pfad
hoechstens 260 Zeichen inklusive `X:\` (`file_path_max_chars`, klassisches
MAX_PATH). Die Byte-Konstanten (`fat_path_component_max_bytes` = 767,
`file_path_max_bytes` = 1023) sind der UTF-8-BMP-Worst-Case dieser
Zeichenlimits und dimensionieren die Puffer (768 bzw. 1024 inkl. NUL);
beide Grenzen werden geprueft, keine schneidet still ab. Ein Zeichen ist
ein Unicode-Skalar der BMP (entspricht einer UTF-16-Unit, wie Windows
zaehlt). Der NT-Long-Path-Namensraum (`\\?\`, ~32k Zeichen) ist bewusst
ausserhalb des Vertrags. Die On-Disk-Namensgrenzen folgen Windows: NTFS
und FAT32-LFN tragen je hoechstens 255 UTF-16-Units pro Namen.

Die konkreten Limits stammen ausschliesslich aus den Contract-Konstanten und
der generierten Payloadreferenz. Datei-, Komponenten- und Registry-Pfade
besitzen getrennte Grenzen.

Kein Parser oder Persistenzhelfer schneidet einen Pfad still ab. Config,
Associations, Shortcuts, Recent Documents, Kernel-CWD und SYSUPD verwenden
denselben Dateipfadvertrag. Das alte Recent-Documents-Format kann weiterhin
gelesen werden; ein darin gespeicherter Pfad oberhalb des aktuellen Limits
wird verworfen und nicht gekuerzt.

Persistente Systemtexte
-----------------------

R4S-Schreibpfade validieren Text und Pfad vor der ersten persistenten
Aenderung. Unbekannte Eintraege in den migrierten generischen Config-,
Shortcut- und Association-Dokumenten bleiben beim gezielten Aendern erhalten. Ein
ungueltiger neuer Wert laesst die bestehende Quelle bytegleich.

Atomare Config-Saves schreiben zuerst eine temporaere Datei, ersetzen das
Ziel und halten bei Fehlern das vorherige Ziel oder die dokumentierte
Backup-Recovery wieder bereit. Temporaer- und Backup-Pfade unterliegen
ebenfalls dem Dateipfadlimit.

Zeit
----

- `R4Duration` ist eine vorzeichenlose Dauer in Nanosekunden.
- `R4MonotonicInstant` ist ein vorzeichenloser Zeitpunkt der monotonen Uhr in
  Nanosekunden.
- `R4Deadline` ist ein absoluter monotoner Ablaufzeitpunkt in Nanosekunden.
- `R4UtcTime` besteht aus vorzeichenbehafteten Sekunden seit der Unix-Epoch
  und einem Nanosekundenanteil von 0 bis 999999999.

Die Nanosekundenrepraesentation ist keine Zusage ueber die Aufloesung der
Hardware. `resolutionNanoseconds(monotonic_hz)` meldet die tatsaechliche
Rasterung. Ticks sind Low-Level-Werte. Umrechnungen verwenden immer die
gemeldete Frequenz, runden positive Dauern nach oben auf mindestens einen
Tick und saettigen bei Ueberlauf. Eine Frequenz von 0 ist ein sichtbarer
Fehler.

Monotonic-Zeit ist unabhaengig von UTC, lokaler Kalenderzeit und Zeitzone.
Kalenderkonvertierungen laufen ueber `R4STD.Date`; unbekannte Zeitzonen werden
nicht in `R4UtcTime` eingebaut.

Zig und C
---------

Zig verwendet fuer die zentrale Plattform die Helfer unter `r4os.path` und
`r4os.time_contract`. Die unabhaengige Runtime-R4L bindet
`Code/System/Libraries/R4STD/Bindings/Zig/r4std.zig` lokal als `r4std` ein;
Settings, Config, Date und Time arbeiten ueber deren getrennte Tabellen.

C bindet fuer die Plattform `<r4os/r4os.h>` ein. Die validierenden zentralen
Pfad- und Timeout-Helfer stehen in `path_timeout.h`. Fuer
R4STD bindet ein Projekt zusaetzlich den lokalen Header
`Code/System/Libraries/R4STD/Bindings/C/r4std.h` ein; dessen Layouttypen und
Clients stammen ausschliesslich aus dem librarylokalen Contract.

Implementierung und Pruefung
----------------------------

Wichtige Implementierungsdateien:

- `Code/System/SDK/r4os/path.zig`
- `Code/System/SDK/r4os/time_contract.zig`
- `Code/System/Libraries/R4STD/Source/`
- `Code/System/Libraries/R4STD/Bindings/Zig/`
- `Code/System/Libraries/R4STD/Bindings/C/`
- `Code/System/SDK/Shared/C/include/r4os/path_timeout.h`

Die zentralen Pfad- und Timeoutlayouts werden vom Current-API- und
Timeout-/Concurrency-Vertrag geprueft. Text- und Kalenderfunktionen besitzt
ausschliesslich R4STD. Der eigenstaendige R4STD-Build prueft
den lokalen Contract bytegenau, kompiliert die Zig-/C-Conformancefixtures und
deckt Text, R4S, Datum, Zeitzonen, Config sowie echte Consumerbindungen ab.

Bewusste Grenzen
----------------

Der GUI-Zeichenpfad misst und zeichnet UTF-8 nach Unicode-Skalaren. Das ist
keine Zusage fuer vollstaendige Unicode-Schriftabdeckung: dargestellt werden
nur Glyphen der ausgewaehlten R4F-Schrift beziehungsweise des begrenzten
Systemfallbacks. Physische Key-Ereignisse koennen einen Unicode-Codepoint im
vorhandenen `u32`-Feld tragen; Textcontrols kodieren ihn beim Einfuegen als
UTF-8. IME, Komposition und Unicode-FAT-LFN-Unterstuetzung sind weiterhin
nicht Teil dieses Vertrags.
Timeout-Sonderwerte, Cancel-Verhalten und Threadingregeln werden getrennt
festgelegt; sie sind keine Sonderwerte von `R4Duration`.
