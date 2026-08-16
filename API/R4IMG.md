# R4IMG.R4L

R4IMG ist eine unabhaengige Runtime-R4L fuer begrenzte Raster- und
Vektorbilddekodierung. Sie besitzt keine zentrale Gruppen-ID und keine
Kernel-Gruppentabelle. Verbraucher importieren ihre versionierte
Funktionstabelle direkt:

    R4IMG:API_V1:1
    C:\R4OS\LIBS\R4IMG.R4L

Implementierung, lokaler Vertrag, Baseline und Zig-/C-Bindings liegen
vollstaendig in `Code/System/Libraries/R4IMG/`. Das Binding validiert den
gemeinsamen R4L-Interface-Header, API-Major, Mindestrevision, Tabellenlaenge
und Pflichtslots. Zig-Anwendungen bauen `r4img.Context` aus
`app.startContext()` auf; C-Anwendungen initialisieren `R4ImgApiV1Client` mit
`r4img_api_v1_init(app->context, ...)`.

Der aktuelle Zielstand dekodiert PNG einschliesslich Alphakanal, Baseline-
und Progressive-JPEG, 24-/32-Bit-BMP sowie einen statischen SVG-2-Teilbestand.
Format und Abmessungen werden vor der Dekodierung geprueft. Bilder sind auf
4096 Pixel je Achse, vier Millionen dekodierte Pixel und 72 MB
Scratchspeicher begrenzt. Rasterformate verwenden einen mit Pixel- und
Encodedatenmenge wachsenden Arena-Puffer. SVG verwendet eine eigene
quell-, knoten-, attribut-, pfad- und tiefenbegrenzte Userland-Arena.

## Besitz und Systemgrenze

Encodedaten, Scratchspeicher, ARGB-Pixel und skalierte XRGB-Pixel gehoeren
vollstaendig dem aufrufenden Prozess. R4IMG allokiert nicht im Kernel und
legt keine Bilder in R4DRAW ab. R4DRAW erhaelt nur die fertige Rasteransicht
fuer den jeweiligen Zeichenaufruf.

Projektartefakt:

- Source: `Code/System/Libraries/R4IMG/`
- Import: `R4IMG:API_V1:1`
- Image-Ziel: `C:\R4OS\LIBS\R4IMG.R4L`
- Vertrag: `Code/System/Libraries/R4IMG/Contract/LibraryContract.json`
- Zig-Binding: `Code/System/Libraries/R4IMG/Bindings/Zig/r4img.zig`
- C-Binding: `Code/System/Libraries/R4IMG/Bindings/C/r4img.h`
- Generierte API-Referenz: `Code/System/Libraries/R4IMG/Docs/API.md`

## Ablauf

1. `probe` prueft Signatur, MIME-Vertrag, intrinsische Abmessungen und Limits.
2. Der Aufrufer reserviert Pixel- und Scratchpuffer in der berechneten Groesse.
3. `decode` schreibt ARGB32-Pixel ausschliesslich in diese Puffer.
   `decodeSvg` nimmt zusaetzlich optionale Glyphen- und Linktreffer-Callbacks.
4. `scaleComposite` skaliert bilinear und komponiert Alpha auf den gewaehlten
   Hintergrund.
5. Der Aufrufer zeichnet das Ergebnis und gibt alle Puffer bei Navigation,
   Abbruch oder Programmende frei.

Klickifax bindet diesen Ablauf an seinen vorhandenen Ressourcenlebenszyklus.
Relative und absolute URLs, Redirects sowie Abbruch bleiben Aufgaben der
Webtransport- und Ressourcenfassaden; R4IMG verarbeitet nur den gelieferten,
vollstaendigen Antwortkoerper.

## SVG-Zielstand

Der gemeinsame Parser verarbeitet `svg`, `g`, `defs`, `a`, `use`,
`clipPath`, `path`, `rect`, `circle`, `ellipse`, `line`, `polyline`,
`polygon` und einfachen horizontalen `text`. Enthalten sind ViewBox und
PreserveAspectRatio, affine Transformationen, Vollfarben, Fill/Stroke,
Opazitaet, Nonzero/Evenodd, einfache User-Space-Clip-Pfade und
`currentColor`. Text wird ueber einen Glyphenprovider des Verbrauchers
gerastert; Klickifax reicht dafuer den laufenden R4OS-Fontkatalog durch.

Externe SVG-Dateien aus IMG-Ressourcen und eingebettete SVG-DOM-Teilbaeume
laufen durch denselben Parser und Rasterizer. Die HTML-Bruecke serialisiert
den aktuellen DOM-Stand begrenzt, damit JavaScript-Aenderungen beim
naechsten Dokument-Reflow sichtbar werden. Linkbereiche eingebetteter
`a`-Elemente werden in Rasterkoordinaten gemeldet und von Klickifax wieder
auf den urspruenglichen HTML-DOM-Knoten abgebildet.

Der Decoder kann SVG entweder in seiner intrinsischen Groesse oder direkt
in eine vom Verbraucher vorgegebene Zielgroesse rasterisieren. Klickifax
behaelt deshalb die begrenzte SVG-Quelle dokumentgebunden und rastert sie
bei einer geaenderten CSS-Anzeigegroesse neu. Vektorgrafiken werden dadurch
nicht aus einem kleinen Zwischenbitmap vergroessert.

Die erreichbare Darstellungsschaerfe ist davon getrennt. Ein einzelnes
R4DRAW-XRGB-Rasterkommando nimmt hoechstens 128 x 128 Pixel an. Seit 0.62.42
koennen mehrere solcher Auftraege jedoch in dynamisch besessenen Rasterknoten
denselben Frame bilden; eine feste Gesamtgrenze von 16384 Rasterpixeln besteht
nicht mehr. Verbraucher koennen groessere Zielraster deshalb kacheln. Bereits
bestehende Bildpfade duerfen aus eigenem Speicher- oder Qualitaetsbudget noch
eine kleinere Rastergroesse mit ganzzahligem Faktor waehlen. R4IMG selbst kann
innerhalb seiner dokumentierten Grenzen in die volle Zielgroesse
rasterisieren.

Nicht zum Vertrag gehoeren Animation, Filter, Masken, Pattern,
Fremdobjekte, Textpfade, TSPAN, komplexe Textformung, eingebettete
Stylesheets und externe Folgeressourcen innerhalb einer SVG-Datei.
Externe USE-Ressourcen sowie erkannte Filter-, Masken- und Patternknoten
schlagen als nicht unterstuetzte Funktion fehl, statt Netzwerkzugriffe am
Dokument-Ressourcenvertrag vorbei auszufuehren. Ein IMAGE-Knoten wird als
derzeit nicht gezeichnete optionale Teilressource isoliert uebersprungen;
andere gueltige Vektorgeometrie derselben SVG-Datei bleibt sichtbar.

## Decoderbasis

Die freestanding Rasterdecoderbasis ist `stb_image` 2.30. Der Wrapper
aktiviert nur PNG, JPEG und BMP, deaktiviert Datei-I/O, HDR, SIMD und nicht
benoetigte Formate und ersetzt die C-Allokation durch einen vom Aufrufer
gelieferten Arena-Puffer. SVG ist eine eigenstaendige Zig-Implementierung
innerhalb von R4IMG und verwendet keinen stb-Code. Quelle und Lizenz der
Rasterbasis sind unter
`Code/System/Libraries/R4IMG/ThirdParty/stb/README.txt` dokumentiert.

`decoderDiagnostic` meldet fuer Diagnoseprogramme den maximal belegten
Arena-Anteil und einen technischen Allokationsfehler des letzten Decode-
Aufrufs. KFXLIVE `/IMAGE` fuehrt denselben produktiven Kontext headless im
Gast aus und kann Encodedaten- und Pixelhash gegen stabile Referenzen
pruefen. Die Abnahme umfasst PNG, Baseline-/Progressive-JPEG und SVG; sie
endet vor R4DRAW und trennt damit Decoderfehler von Skalierungs- oder
Zeichenfehlern. Klickifax besitzt zusaetzlich einen Pflichtmarker, der im
Gast ein SVG mit gueltigem Vektorpfad und nicht verfuegbarem optionalem
IMAGE-Teilbild ueber den ausgelieferten R4IMG-Kontext dekodiert.
