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

Zig implementations are under `Repositories/SDK/r4os/`; C layouts are under
`Repositories/SDK/Shared/C/`; R4STD bindings are under
`Repositories/Libraries/R4STD/Bindings/`.
