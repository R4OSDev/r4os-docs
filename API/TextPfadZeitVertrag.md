# Text, path and time contract

The numeric and machine-readable truth remains in
`Repositories/Contract/API/ApiContract.json` and the R4STD library contract.
This document explains the distinctions without duplicating constants.

## Text

- Bytes make no encoding promise.
- UTF-8 text is valid UTF-8 without embedded NUL; lengths are byte lengths.
- System text accepts UTF-8 with or without BOM and common line endings, and
  is written canonically as UTF-8 with BOM and CRLF.
- Document text may preserve original bytes, encoding and line endings.
- UI rendering supports only glyphs available in the selected system or
  runtime font; valid Unicode text does not promise complete glyph coverage.

R4STD owns reusable text, settings, date, time and R4S configuration helpers.

R4STD0.2.5 adds the independent `CODEC_V1:1` without changing the five old
interfaces. Legacy bytes carry an explicit codepage/mode. CP437 text follows
Microsoft's control mapping; separate PC graphics follows Unicode IBMGRAPH
for01..1F/7F, with00 still U+0000. Windows-1252 rejects its five unassigned
bytes; CP850 is distinct and unsupported. Exact inverse conversion reports
unrepresentable scalars. There is no guessing, normalization or implicit
replacement. Bulk conversion preflights the whole span and rejects overlap.

Scalar UTF-8 permits U+0000; the existing no-NUL text/path rules still apply.
The codec accepts shortest scalar encodings only. Its caller-owned16-byte
state distinguishes complete, valid incomplete and invalid input, examines
at most four bytes and retains at most three pending bytes. Negative results
consume nothing and preserve state/output. The caller explicitly reports,
replaces or resets and may retry the offending byte; finish does not discard
unfinished input. Byte counts, scalar counts, graphemes and glyph identities
remain separate. Typed keyboard events are a separate transport contract.

Since0.85.38 R4DESK16 appends read/push event slots after the stable536-byte
prefix. A fixed16-byte record distinguishes Unicode scalars, logical keys
and single UTF-8 stream bytes; bytes80/81/82 never imply navigation. Batches
contain at most64 events, bind the exact process generation and acknowledge
only a complete-event prefix. The caller retains an unaccepted suffix.
Legacy byte reads check representability before dequeueing a larger scalar.
Terminal owns a per-instance R4STD decoder and scalar editing/history;
independent typed events retain unfinished stream state. Desktop and SSH
keep bounded producer queues and exact target bindings. Byte capacity,
scalar boundaries and glyph layout remain distinct. Core/TextInput08538
records the actual KVM4/editor/clipboard and component limits; grapheme
behavior remains a separate follow-up.

R4DESK17 appends console text metadata/encoding slots after the stable552-byte
prefix. ConsoleTextInfo is a separate fixed32-byte record; ConsoleState64 is
unchanged. Exact live process generations select UTF8, CP437 or Windows1252;
a pending prefix refuses a switch. Font charset never selects the decoder.
The R4STD resident core decodes each producer stream once, retains incomplete
prefixes and reports invalid/undefined input as U+FFFD. Closing a nonempty
prefix appends one replacement per stream and reports truncation. Snapshots
hold canonical complete UTF8 scalars, including at ring/caller boundaries.
A scalar occupies one monospaced cell; backspace removes a whole scalar and
wrap is delayed until the next printable cell. Completion reads retain raw
byte offsets/counts into that canonical transcript, including continuation
bytes; they are not a document/binary stream or a character-indexed API.
Caller output copies occur after registry/output owners and pins end, while
the exact task remains admitted. Input encoding and document/file bytes do
not change. Active-font coverage, graphemes, full-width/Bidi/shaping remain
separate. Core/TextOutput08539.txt/.json records actual software/KVM4 scope.
Source/ABI/oracle/C and real imported-provider evidence, with terminal/font/
filesystem/protocol/app/grapheme follow-up limits: Core/TextCodecs08537.txt/.json.

## Paths

System paths use a drive plus normalized components. Resolution is
case-insensitive. Mixed case is preserved below `C:\R4OS\Media\`; the rest
of the system tree normally uses uppercase names. Normalization rejects NUL,
invalid components, root escape and length overflow rather than truncating.
Registry paths use a distinct typed path and are not filesystem paths.

## Time

Monotonic time drives waits and deadlines. UTC/calendar values are for civil
time and must not drive a timeout. A relative timeout is converted once to an
absolute deadline; later phases consume the remaining budget. Conversion
rounds upward and saturates safely.

High-resolution APIs use the continuous monotonic nanosecond epoch. Kernel
sleeps, waits, service timeouts, watchdogs and scheduler accounting use the
logical event-clock tick and its published frequency; a caller samples `now`
once before adding a duration. `u64` maximum is reserved for `no deadline`.
The largest finite deadline is one less, and additions saturate there instead
of wrapping into the sentinel. A zero-duration finite wait is immediately due.

Finite scheduler waits form one stable ordered queue. Earlier deadlines sort
first and equal deadlines retain enrollment order. Cancellation removes the
exact waiter and causes the next idle transition to cancel or reprogram the
hardware event. A completion that is provably present at the boundary retains
the completion-wins rule from the cancellation contract.

On supported HPET or calibrated-LAPIC paths, active execution remains
periodically preemptible while true idle arms only the queue head as a
one-shot. With no finite deadline the idle timer is disarmed. Hardware counter
horizons are implementation limits, not API limits: a long finite deadline is
split into bounded checkpoints and compared against the same absolute value
again. One timer IRQ publishes at most 64 due waits; a larger simultaneous
storm remains ordered and is continued by a later delivery. Programming is
rounded so that a finite timeout never fires early, and late delivery remains
measurable. Missing or failed one-shot support falls back explicitly to the
periodic PIT granularity without changing the deadline epoch.

Zig implementations are under `Repositories/SDK/r4os/`; C layouts are under
`Repositories/SDK/Shared/C/`; R4STD bindings are under
`Repositories/Libraries/R4STD/Bindings/`.

0.88.82 – U+2013: unveränderte Textbytes und begrenzte Fontabdeckung
-----------------------------------------------------------------
Im aktuellen öffentlichen SDK124-Pfad ist kein Datenverlust reproduziert:
U+2013 bleibt E2 80 93 vom eigenen GUI-U32-Ereignis über TextArea-Eingabe,
Editieren, Kopieren/Einfügen, separate Verlaufs-TextArea, JSON-Nutzdaten und
Drawcommand. Der alte Key-Bytewert ist kein Ersatz für codepoint:u32.
handleCodepointEx unterstützt den Scalar bereits im historischen SDK92
(51ed03d813d9baeab630746f1d1bbc46c2d2a1e6). Die aktuellen C-/Rust-Fassaden
übertragen ebenfalls den vollständigen U32-Scalar; vorhandene gemeinsame
C-/Rust-Orakel für volle Scalars/UTF8 bleiben erhalten. Kein behaupteter
neuer separater C-/Rust-Nativlauf und keine neue Fassade oder ABI nötig.

Der erste aktuelle Fragezeichenersatz ist eine Darstellungsentscheidung:
Alle14 normalen R4F-Systemschriften enthalten257 Glyphmaps, jedoch kein
U+2013. DESKTOP.R4S wählt TERMINAL8.R4F. Kernel font/state sucht den Scalar
im tatsächlichen GMAP; beim Fehlen liefert builtin::glyph/row_mask das
Fragezeichenbitmap. Weder TextArea noch JSON werden dabei umgeschrieben.
Eine Anwendung muss gespeicherten UTF8-Text behalten und einen Font mit
passender Abdeckung auswählen, wenn sie den Gedankenstrich anzeigen will.
Keine stille Transliteration, Codepageumdeutung oder Voll-Unicodezusage.
Der öffentliche GlyphBitmap-Record besitzt kein fallback-Bool: Abdeckung
hier aus den exakten Fontbytes und Bitmaps ermittelt, kein erfundenes Feld.

Genau ein KVM4-Softwaregast1180244 mit unverändertem Kernel446 und dem
öffentlichen SDK124-GUIverbraucher G82 qualifiziert den aktuellen Pfad.
Die echte GUI-Instanz empfängt '-', U+2013 und U+00E4 als U32; resultierende
Textbytes sind 2D E2 80 93 C3 A4. Auswahl/Clipboard einschließlich Restore,
Editieren, Verlauf und JSON sowie beide Frame-Textpayloads bleiben exakt.
Stockfont-ID14 und eigene Testfont-ID15, Katalogrevision2, wurden erfasst.
Die ausdrücklich private 6588B-Schrift R4OS82Fixture/EnDash82 ergänzt nur
für die Diagnose einen eigenen U+2013-Glyphen. SHA256:
087daa88c7929d3c50dff9ae9cd188355264f5758061ec3cb706508cce49d839.
Stock-U+2013 entspricht '?'; U+10FFFD ist absichtlich nicht vorhanden.
Die fähige Schrift zeigt den definierten achtzeiligen Glyphen, zusätzlich
64 exakte Pixel im originalen QMP-Softwareframe geprüft. Kein physischer
Sichttest. Echter Exit0,175B vollständige Ausgabe, Generationsticket und
Release0; regulärer Desktopclose, POWEROFF/terminal und Source-Retention.

Nur ein gezielter neuer Fall im vorhandenen tatsächlichen Font-Owner-Test:
Stock-/Testfont, exakte Glyphzuordnung, '?' bei fehlendem Scalar und
Bitmap-/Pixel-Sampler. Vier ältere Fälle wurden gefiltert, keine breite
Font-/GUI-/PROGRAMLIFECYCLE-Wiederholung. Kleine Testfixture liegt unter
Kernel/Tests/Fixture/Unicode82 und wird nicht ins normale Image installiert.
Ein anfänglicher privater G82-NUL-Sentinel-Compilefehler und ein korrigierter
Test-Modulimport bleiben mit Quellen/Originaldiagnosen erhalten. Keine
Abschwächung des Produktverhaltens und keine neue Laufzeitmessstelle.

Der ursprüngliche Nexus-Composer-/Verlaufsfall unter0.87.14 ist damit nicht
als reproduziert oder behoben behauptet: dessen Originalquellen/-binary,
Fontbytes und aktive Font-ID/Revision/Renderpins liegen nicht vor. Die
separate Test-Verlaufsarea ist keine Nexus-Abnahme. Nexus-Pins92/45 bleiben
unverändert. Grapheme, Shaping/Bidi, Hardware und Windows sind nicht geprüft.

Keine neue SDK-/Contract-/Kernel-/Desktop-/Font-Lieferrevision: Produktion
und normale Artefakte sind unverändert; nur Kernel-Testquelle/-fixture,
dieser Vertrag und Inventar werden ergänzt. Release0.88.82 einmal gesetzt.
Alle140 normalen OS-Artefakte,141 Modulmanifeste und Kernel446 sind exakt
bytegleich79..81. Deshalb kein identischer STANDARD82; voller Original79
(e0631a6b-31fd-445e-8815-69dbf79d4db7, overall129.931272, SHA256
143a50b7a71fe643584e66d308bb4b5c5698f97d9286633c9cd182ef17beec8a)
bleibt diesem Binärsatz zugeordnet. Kein neues82Etikett/SDK-Leistungsclaim;
Serverimport/-readback weiter offen. Quellen, Fontbytes, alle Originale,
Readbacks und Softwareframe: ExFiles/Reports/Core/0.88.82-unicode-font/.
