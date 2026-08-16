# R4DRAW

R4DRAW ist die Zeichen- und Rastergruppe. Sie besitzt Pixel-, Linien-,
Rechteck-, Text-, Font-, Bild-, Surface- und Present-Funktionen.

Import: R4DRAW:Query:1

Zig-Context: r4os.r4draw.Context

R4DRAW beschreibt Rendering, R4DESK den Fenster-/Desktop-Lebenszyklus.
Optionale Felder werden mit hasFn geprueft.

<!-- R4OS-APIREF:BEGIN R4DRAW (generiert von ApiContractGen aus ApiContract.json - NICHT von Hand editieren) -->
## Tabellen-Referenz R4DRAW (generiert)

Kernel-Gruppentabelle `R4XStartR4Draw` v2, 272 Bytes, 32 Funktionsfelder und 32 Slots insgesamt.
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
<!-- R4OS-APIREF:END R4DRAW -->
