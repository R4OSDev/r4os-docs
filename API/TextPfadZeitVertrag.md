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
records the actual KVM4/editor/clipboard and component limits; output and
grapheme behavior remain separate follow-ups.
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
