# R4FONT.R4L

R4FONT ist eine unabhaengige Runtime-R4L fuer begrenzte Schriftquellen. Sie
besitzt keine zentrale Gruppen-ID und keine Kernel-Gruppentabelle. Der
versionierte Import lautet:

    R4FONT:API_V1:1
    C:\R4OS\LIBS\R4FONT.R4L

Der gemeinsame 32-Byte-Interface-Header bindet API-Major 1, Revision 1,
Tabellengroesse und R4FONT-Interface-ID. Zig-Anwendungen bauen den
Librarykontext mit `Bindings/Zig/r4font.zig` aus `app.startContext()` auf und
erzeugen daraus einen Decoder mit ihrem eigenen Allocator. Der generierte
C-Vertrag steht in `Code/System/Libraries/R4FONT/Bindings/C/r4font.h`.

Unterstuetzt werden TrueType-SFNT, OpenType mit CFF-Konturen, WOFF, WOFF2 und
SFNT-Collections. R4FONT liest Familien- und Stilnamen, CMAP,
horizontale und vertikale Metriken sowie einfaches Pair-Kerning aus `kern`
und GPOS. TrueType- und CFF-Konturen werden fuer eine angeforderte
Pixelhoehe als deterministische Alpha8-Glyphen rasterisiert.

## Systemgrenze und Besitz

FreeType, der WOFF-zlib-Teilbestand, Brotli und die R4FONT-Bruecke sind
Userland-Code. Weder Kernel noch R4DRAW enthalten Fontcontainerparser,
Brotli-Code oder persistente Webfontdaten. R4DRAW erhaelt spaeter nur die
fertigen Glyphmetriken und Alpha8-Raster eines Zeichenauftrags.

Der Aufrufer besitzt:

- die vollstaendige Quellbytefolge;
- den Decoderallocator und dessen Speicherlimit;
- den temporaeren Face-Handle;
- den Ausgabepuffer eines Glyphrasters.

Die Quellbytes und der Decoder muessen bis zum Schliessen aller daraus
geoeffneten Faces gueltig bleiben. Ein Face darf nicht parallel aus mehreren
Tasks mutiert werden, weil Pixelgroesse und aktueller Glyphslot zum
FreeType-Face gehoeren. Faces werden vor dem Decoder und der Decoder vor dem
Programmallocator freigegeben.

Die von `info` gelieferten Familien- und Stiltexte sind geliehene Sichten des
Faces und werden mit `closeFace` ungueltig. Der C-Allocator muss jede
angeforderte, von Null verschiedene Zweierpotenz-Ausrichtung einhalten.
`realloc` darf bei einem Fehler Null liefern, muss den alten Block dann aber
unveraendert gueltig lassen; `free` erhaelt wieder die zugehoerige Groesse und
Ausrichtung. Allocatorfunktionen und Benutzerkontext bleiben bis zum
Decoderabbau gueltig.

Ein R4FONT-Face ist ein temporaeres Laufzeitobjekt mit R4F-kompatiblen
Glyphmetriken, Unicode-Abdeckung und Rasterdaten. Es ist keine installierte
`.R4F`-Datei. R4FONT schreibt nichts nach `C:\R4OS\FONTS\`, aktualisiert
keinen Systemfontkatalog und startet den Font Installer nicht.

## Ablauf

1. Das lokale Binding validiert Modulname, Symbol, Interface-ID, API-Major,
   Mindestrevision, Tabellengroesse und alle Pflichtslots.
2. Der Verbraucher erzeugt einen begrenzten Decoder mit seinem Allocator.
3. `sniff` erkennt nur die dokumentierten Containersignaturen.
4. `openFace` prueft Container, Laengen, Tabellenbereiche, Faceindex und
   Decodergrenzen, bevor ein Face sichtbar wird.
5. `glyphIndex` bildet einen Unicode-Codepoint ueber CMAP auf einen
   Glyphindex ab. Null bedeutet fehlende Glyphabdeckung.
6. `info`, `glyphMetrics` und `kerning` liefern Designmetriken und
   Pair-Positionierung.
7. `rasterize` schreibt genau ein begrenztes Alpha8-Raster in den
   aufrufereigenen Puffer.
8. Der Aufrufer schliesst Face und Decoder auch auf jedem Fehlerpfad.

Ein fehlgeschlagener Open-, Metrik- oder Rasteraufruf hinterlaesst kein
teilweise aktivierbares Face. `diagnostics` meldet aktuelle und maximale
Decoderallokation, Allokations- und Reallokationszaehler sowie einen
technischen Speicherfehler.

## Grenzen

| Bereich | Grenze |
| --- | ---: |
| Quelldatei | 8 MB |
| Rekonstruiertes SFNT | 32 MB |
| Standard-Decoderbudget | 64 MB |
| Tabellen pro Container | 128 |
| Faces pro Collection | 32 |
| Pixelhoehe pro Rasterauftrag | 4 bis 256 |
| Rasterbreite oder -hoehe | 512 Pixel |

Groessen werden vor Addition und Multiplikation geprueft. WOFF2 muss seinen
Brotli-Eingang und die exakt deklarierte Ausgabe vollstaendig verbrauchen.
FreeType und Brotli allokieren ausschliesslich ueber dasselbe begrenzte
`FT_Memory`; ein Host-Allocator, Datei-I/O oder stiller Fallback existiert
nicht.

## Bewusste Grenze

R4FONT ist kein Textlayout- oder Shaping-System. Es implementiert keine
Bidirektionalitaet, Script-Shaping, Ligaturauswahl, Variation-Achsen,
Farbglyphen, Font-Synthese oder CSS-Fontmatching. Komplexes GPOS/GSUB und
sprachabhaengige Formung benoetigen spaeter einen eigenen Userland-Vertrag.
Klickifax bleibt fuer CSS-Auswahl, Unicode-Fallbacklaeufe, Umbruch,
Lebensdauer und Reflow verantwortlich.

## Decoderbasis und Abnahme

Die gepinnten Quellen, Lizenzen, R4OS-Anpassungen und die geschlossene
Modulliste sind unter
`Code/System/Libraries/R4FONT/ThirdParty/r4font/README.txt` dokumentiert. Die
Decoderbasis ist FreeType 2.14.3 mit Brotli 1.2.0.

Die Komponentenabnahme oeffnet TrueType-, OpenType/CFF-, WOFF-, WOFF2- und
Collection-Fixtures, prueft Unicode-CMAP, beide Kerningpfade, exakte
Metriken und Alpha8-Hashes. Ein Negativcorpus deckt gekuerzte und
widerspruechliche Container, uebergrosse Bereiche sowie Allokations- und
Reallokationsfehler ab. Der eigenstaendige Produktbuild linkt den gesamten
Decoder freestanding in `R4FONT.R4L`; generierte Zig-/C-Conformance-Fixtures
und ein echter C-R4X-Verbraucher pruefen dieselbe lokale Funktionstabelle.

## Aenderungsgrenze

Contract, Baseline, Provider, Fremdcode und Bindings liegen gemeinsam unter
`Code/System/Libraries/R4FONT/`. Eine kompatible Implementierungsaenderung
oder append-only Revision benoetigt keine fachliche Aenderung an Kernel,
zentralem Contract oder Kern-SDK. Nur Verbraucher, die neue Slots verlangen
oder einen neuen ABI-Major nutzen, muessen angepasst werden.
