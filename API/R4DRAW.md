# R4DRAW

R4DRAW ist die Zeichen- und Rastergruppe. Sie besitzt Pixel-, Linien-,
Rechteck-, Text-, Font-, Bild-, Surface- und Present-Funktionen.

Import: R4DRAW:Query:1

Bereitstellung: eingebauter Kernel-Provider; keine R4L-Datei und kein
eigenstaendiger Installations- oder Updatepfad.

Zig-Context: r4os.r4draw.Context

R4DRAW beschreibt Rendering, R4DESK den Fenster-/Desktop-Lebenszyklus.
Optionale Felder werden mit hasFn geprueft.

`display_blit_xrgb32_stride` transportiert ein Rechteck mit explizitem
Source-Stride in einem Aufruf. Der alte dicht gepackte Slot 9 bleibt
unveraendert; Aufrufer pruefen den neuen Slot und verwenden nur gegen aeltere
Tabellen den zeilenweisen Kompatibilitaetspfad.

R4DRAW v6 haengt `font_glyph_bitmap` an. Der Slot liefert mit
`GuiGlyphBitmap` alle maximal 40 monochromen Zeilen und die Glyphmetriken nach
genau einer Indexauflösung. `font_glyph_row` bleibt unveraendert. Das SDK
erkennt den neuen Slot mit `hasFn`; bei einer aelteren Tabelle setzt es den
Snapshot aus der Zeilen-API zusammen. Dessen Pixel bleiben identisch, nur
proportionale Einzelglyphbreite und -advance koennen dabei nicht rekonstruiert
werden und fallen auf die Face-Breite beziehungsweise den maximalen Advance
zurueck.

R4DRAW v7 haengt `font_revision` an. Die stets von null verschiedene
Fontkataloggeneration wird nach jedem erfolgreich abgeschlossenen Reload
weitergeschaltet. Glyph- und Layoutcaches koennen dadurch Font-ID, Revision
und Codepoint als Schluessel verwenden, ohne bei wiederverwendeten IDs
veraltete Daten auszuliefern. Die SDK-Fassade liefert fuer aeltere Tabellen
die stabile Kompatibilitaetsrevision 1.

R4DRAW v8 haengt `gui_frame_begin_replace` und `gui_frame_stream_info` an.
Eine Ersatzgeneration beschreibt einen vollstaendigen, eigenstaendig
lesbaren GUI-Zustand und verdraengt nach atomarem Commit die bisherige Kette;
ihre Regionen bleiben die exakte Damage-Angabe fuer Komposition und Present.
Der native `GuiXrgb32Resource` transportiert Quellkachel, Stride, Gast- und
Viewportgeometrie ohne Farblaufzerlegung. Die Telemetrie weist Freigabe,
Koaleszenz, Leser-Retirement, XRGB32-Arbeit und Framebytes ownergebunden aus.

R4DRAW v9 haengt einen optionalen generationengebundenen Shared-Raster-Pfad
an. Produzenten erzeugen eine begrenzte XRGB32-, Indexed8- oder
Alpha8-Ressource, schreiben in genau einen freien Puffer und veroeffentlichen
ihn unveraenderlich. Der Desktop erwirbt die im konkreten Frame referenzierte
Generation und gibt seine Lease nach dem Snapshottausch frei. Drei Puffer
begrenzen den Bestand; bei Rueckstau bleibt der bestehende kopierende
Framepfad der korrekte Fallback. `GuiFrameStreamInfo` v2 ergaenzt Publish-,
Acquire-, Release-, Backpressure-, Copy-Vermeidungs- und Livebytezaehler; der
v1/112-Prefix bleibt lesbar.

<!-- R4OS-APIREF:BEGIN R4DRAW (generiert von ApiContractGen aus ApiContract.json - NICHT von Hand editieren) -->
## Tabellen-Referenz R4DRAW (generiert)

Kernel-Gruppentabelle `R4XStartR4Draw` v10, 472 Bytes, 57 Funktionsfelder und 57 Slots insgesamt.
Signatur-Wahrheit: `abi.R4DrawFns` (Feldname == Tabellenfeld).
Ein Feld ist nutzbar, wenn `hasFn("feld")` es als vorhanden meldet.

| Slot | Offset | Zustand | Tabellenfeld | Signatur |
| ---: | ---: | --- | --- | --- |
| 0 | 16 | function | `screen_width` | `*const fn () callconv(.c) u32` |
| 1 | 24 | function | `screen_height` | `*const fn () callconv(.c) u32` |
| 2 | 32 | function | `clear` | `*const fn (u32) callconv(.c) void` |
| 3 | 40 | function | `rect` | `*const fn (i32, i32, u32, u32, u32) callconv(.c) void` |
| 4 | 48 | function | `text` | `*const fn (i32, i32, [*:0]const u8, u32, u32) callconv(.c) void` |
| 5 | 56 | function | `display_revision` | `*const fn () callconv(.c) u32` |
| 6 | 64 | function | `display_begin_frame` | `*const fn () callconv(.c) i32` |
| 7 | 72 | function | `display_begin_frame_rect` | `*const fn (i32, i32, u32, u32) callconv(.c) i32` |
| 8 | 80 | function | `display_present` | `*const fn () callconv(.c) i32` |
| 9 | 88 | function | `display_blit_xrgb32` | `*const fn (i32, i32, u32, u32, [*]const u32, u32) callconv(.c) i32` |
| 10 | 96 | function | `gui_clear` | `*const fn (u32) callconv(.c) i32` |
| 11 | 104 | function | `gui_rect` | `*const fn (i32, i32, u32, u32, u32) callconv(.c) i32` |
| 12 | 112 | function | `gui_draw_text` | `*const fn (i32, i32, [*:0]const u8, u32, u32) callconv(.c) i32` |
| 13 | 120 | function | `gui_draw_text_ex` | `*const fn (i32, i32, [*:0]const u8, u32, u32, u32, u32) callconv(.c) i32` |
| 14 | 128 | function | `gui_blit` | `*const fn (i32, i32, u32, u32, u32, [*]const u32, u32) callconv(.c) i32` |
| 15 | 136 | function | `gui_raster_read` | `*const fn (u32, u32, [*]u32, u32) callconv(.c) i32` |
| 16 | 144 | function | `gui_present` | `*const fn () callconv(.c) i32` |
| 17 | 152 | function | `font_count` | `*const fn () callconv(.c) u32` |
| 18 | 160 | function | `font_info` | `*const fn (u32, *GuiFontInfo) callconv(.c) i32` |
| 19 | 168 | function | `font_measure` | `*const fn (u32, [*:0]const u8, *GuiTextMetrics) callconv(.c) i32` |
| 20 | 176 | function | `gui_set_font` | `*const fn (u32) callconv(.c) i32` |
| 21 | 184 | function | `gui_font` | `*const fn (u32, *GuiFontInfo) callconv(.c) i32` |
| 22 | 192 | function | `text_font` | `*const fn (u32, i32, i32, [*:0]const u8, u32, u32) callconv(.c) void` |
| 23 | 200 | function | `font_reload` | `*const fn () callconv(.c) i32` |
| 24 | 208 | function | `font_glyph_row` | `*const fn (u32, u32, u32) callconv(.c) u64` |
| 25 | 216 | function | `gui_blend_alpha8` | `*const fn (i32, i32, u32, u32, u32, u32, [*]const u8, u32) callconv(.c) i32` |
| 26 | 224 | function | `gui_frame_begin` | `*const fn () callconv(.c) i32` |
| 27 | 232 | function | `gui_frame_append` | `*const fn (?[*]const GuiFrameCommand, u64, ?[*]const u8, u64) callconv(.c) i32` |
| 28 | 240 | function | `gui_frame_commit` | `*const fn () callconv(.c) i32` |
| 29 | 248 | function | `gui_frame_cancel` | `*const fn () callconv(.c) i32` |
| 30 | 256 | function | `gui_frame_info` | `*const fn (?*const ProgramProcessHandle, *GuiFrameInfo) callconv(.c) i32` |
| 31 | 264 | function | `gui_frame_read` | `*const fn (*const ProgramProcessHandle, u64, ?[*]GuiFrameCommand, u64, ?[*]u8, u64, *GuiFrameInfo) callconv(.c) i32` |
| 32 | 272 | function | `display_blit_xrgb32_stride` | `*const fn (i32, i32, u32, u32, [*]const u32, u32, u32) callconv(.c) i32` |
| 33 | 280 | function | `display_present_regions` | `*const fn (*const DisplayPresentRequest, [*]const u32, u32, [*]const DisplayDamageRect, u32, *DisplayPresentResult) callconv(.c) i32` |
| 34 | 288 | function | `display_present_capabilities` | `*const fn (*DisplayPresentCapabilities) callconv(.c) i32` |
| 35 | 296 | function | `display_present_completion` | `*const fn (u64, *DisplayPresentCompletion) callconv(.c) i32` |
| 36 | 304 | function | `gui_frame_begin_damage` | `*const fn ([*]const DisplayDamageRect, u32) callconv(.c) i32` |
| 37 | 312 | function | `gui_frame_generation_info` | `*const fn (*const ProgramProcessHandle, u64, *GuiFrameGenerationInfo) callconv(.c) i32` |
| 38 | 320 | function | `gui_frame_generation_read` | `*const fn (*const ProgramProcessHandle, u64, ?[*]GuiFrameCommand, u64, ?[*]u8, u64, ?[*]DisplayDamageRect, u32, *GuiFrameGenerationInfo) callconv(.c) i32` |
| 39 | 328 | function | `font_glyph_bitmap` | `*const fn (u32, u32, *GuiGlyphBitmap) callconv(.c) i32` |
| 40 | 336 | function | `font_revision` | `*const fn () callconv(.c) u32` |
| 41 | 344 | function | `gui_frame_begin_replace` | `*const fn ([*]const DisplayDamageRect, u32) callconv(.c) i32` |
| 42 | 352 | function | `gui_frame_stream_info` | `*const fn (*const ProgramProcessHandle, *GuiFrameStreamInfo) callconv(.c) i32` |
| 43 | 360 | function | `gui_shared_raster_create` | `*const fn (*const GuiSharedRasterCreateInfo, *GuiSharedRasterHandle) callconv(.c) i32` |
| 44 | 368 | function | `gui_shared_raster_destroy` | `*const fn (*const GuiSharedRasterHandle) callconv(.c) i32` |
| 45 | 376 | function | `gui_shared_raster_map_write` | `*const fn (*const GuiSharedRasterHandle, *GuiSharedRasterWriteMap) callconv(.c) i32` |
| 46 | 384 | function | `gui_shared_raster_publish` | `*const fn (*const GuiSharedRasterWriteMap, *u64) callconv(.c) i32` |
| 47 | 392 | function | `gui_shared_raster_acquire` | `*const fn (*const ProgramProcessHandle, u64, *const GuiSharedRasterHandle, u64, *GuiSharedRasterMap) callconv(.c) i32` |
| 48 | 400 | function | `gui_shared_raster_release` | `*const fn (*const GuiSharedRasterLease) callconv(.c) i32` |
| 49 | 408 | function | `gfx_buffer_create` | `*const fn (*const GfxBufferDescriptor, *GfxBufferReference) callconv(.c) i32` |
| 50 | 416 | function | `gfx_buffer_describe` | `*const fn (*const GfxBufferHandle, *GfxBufferDescriptor) callconv(.c) i32` |
| 51 | 424 | function | `gfx_buffer_import` | `*const fn (*const GfxBufferHandle, *GfxBufferReference) callconv(.c) i32` |
| 52 | 432 | function | `gfx_buffer_release` | `*const fn (*const GfxBufferHandle) callconv(.c) i32` |
| 53 | 440 | function | `gfx_buffer_map` | `*const fn (*const GfxBufferHandle, u32, u64, u64, *GfxBufferMap) callconv(.c) i32` |
| 54 | 448 | function | `gfx_buffer_unmap` | `*const fn (*const GfxBufferHandle) callconv(.c) i32` |
| 55 | 456 | function | `gfx_buffer_export_raster` | `*const fn (*const GuiSharedRasterLease, *GfxBufferReference) callconv(.c) i32` |
| 56 | 464 | function | `gfx_buffer_stats` | `*const fn (*GfxBufferStats) callconv(.c) i32` |
<!-- R4OS-APIREF:END R4DRAW -->


Direkte Anzeige und geordnete Praesentation ab 0.78.76
---------------------------------------------------
clear, rect, text und text_font zeichnen ueber den DisplayManager auf die
sichtbare Anzeige. Rechtecke und Glyphen werden einschliesslich negativer
Startkoordinaten an deren Grenzen beschnitten. Text haelt einen Fontkatalog-
Snapshot fuer den gesamten Aufruf; text verwendet den ausgewaehlten Font,
text_font die angegebene ID mit vorhandener Normalisierung. UTF-8, Glyph-
Advance, Zeilenumbruch und Vorder-/Hintergrundfarbe folgen dem Fontbesitzer.
Erst eine ausgefuehrte Zeichnung schaltet die atomare display_revision weiter
und meldet die Anzeige als benutzt. Gehostete GUI-Frames und die separate
Boot-/Fatal-Konsole behalten ihre bisherigen Ziel- und Besitzgrenzen.

Alle produktiven DisplayManager-Schreibpfade versuchen denselben
praeemptiblen UnwindGuard einmal. Bei Kollision wartet ein Present-Aufruf
nicht, schreibt keine Pixel und liefert keinen Erfolgs-Fence; der Aufrufer
kann erneut praesentieren. Die direkten void-Basisoperationen setzen den
bestehenden exklusiven Vollbildbesitz voraus und melden bei einer Kollision
keine erfolgreiche Nutzung. Sie erhalten keinen neuen ABI-Rueckgabewert.
WC-Pixelstores werden vor abgeschlossener Statistik/Fence-Veroeffentlichung
und vor Besitzerfreigabe geordnet. Status liest einen kurzen SMP-geschuetzten
Snapshot der letzten abgeschlossenen Operation; aktive Kopien laufen ohne
No-Sleep-Owner. Eine erfolgreich abgeschlossene Regionspraesentation erhaelt
genau die naechste von null verschiedene Generation und denselben Fence.
Dies ist ein synchroner Kopierabschluss, keine Zusage ueber VBlank/Pageflip.

DisplayBlit-Admission erhoeht den laufenden Besitzerbezug atomar mit der
Pruefung der Registrierung. Der Descriptor wird kopiert; Name, Besitzer und
Registrierungsgeneration bleiben dem konkreten Aufruf zugeordnet. Shutdown
kann einen laufenden Callback nicht ueberholen. Der Callback selbst laeuft
ausserhalb des kurzen SMP-Owners; sein Abschluss kann keinen busy-Zaehler
einer spaeteren Registrierung veraendern. Die vorhandene R4D-Abbaufolge und
der synchrone DISPBLIT-Treibervertrag werden damit wirksam abgesichert.
