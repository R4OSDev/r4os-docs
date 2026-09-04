R4OS SDK
========

The SDK in `Repositories/SDK/` is the normal development surface for Zig and
C modules. It provides startup code, typed platform facades, module build
support, templates, C headers and generic Runtime-R4L helpers. The separate
Contract repository remains the canonical API and ABI source.

A module project contains `module.R4MF`, `build.zig`, `build.zig.zon`,
`Settings.R4S`, `Build.bat` and its own sources. The repository starter maps
the current local SDK, Contract, Libraries and DevKit checkouts before Zig
resolves packages. Relative or absolute mappings are supported.

Zig applications initialize `r4os.App`; C applications include
`<r4os/r4os.h>`. Both consume the same R4XStart context and group tables.
Optional groups and fields remain explicit; facades do not invent fallback
handles or second subsystem implementations. The six Platform APIs are
implemented by the Kernel; the SDK neither builds provider R4Ls nor owns an
independent copy of their implementation.

R4DRAW v6 exposes a fixed-capacity whole-glyph snapshot. Current kernels
resolve the bounded font index once and return metrics plus all row masks in a
single call. The SDK keeps older tables compatible through `font_glyph_row`;
that fallback preserves pixels but can only report face-wide width and maximum
advance for proportional fonts.

R4DRAW v7 appends `font_revision`. The nonzero catalog generation advances
after every completed font reload, allowing layout and monochrome-coverage
caches to key font id, revision and codepoint without retaining reused stale
ids. The SDK returns the stable compatibility generation 1 when an older
table has no revision slot.

R4DRAW v8 adds standalone replacement frames, native XRGB32 nearest-neighbor
tiles and per-owner stream telemetry. `r4os.subsystem_host` uses the path for
current XRGB32 producers: every changed frame is a complete independently
readable state with exact damage, while the Desktop no longer replays
superseded frame history or decomposes pixels into color-run rectangles.
Older tables retain the bounded raster and damage-chain fallback.

`ctx.allocator()` is the normal Zig `std.mem.Allocator` backed by the R4SYS VM
calls. Small blocks use twenty bounded geometric free-size classes inside a
64-MiB reserved region, checked header/footer boundary tags and constant-time
neighbor coalescing. Allocations of at least 1 MiB, or alignments above 4 KiB,
use a direct VM region. Zero-size behavior, alignment and caller ownership stay
unchanged. Metadata damage fails closed and is counted; failed VM mutations
leave the prior index state retryable. An allocator-local atomic lock protects
metadata and VM mutations across R4X threads, yielding through R4SYS only when
contended. `ctx.allocatorStats()` includes the existing allocation/byte totals
plus free-candidate and class searches, boundary probes, splits, coalesces,
corruptions and reserve/commit/decommit/release call counts.

Small-region commit starts at 64 KiB and grows geometrically to at most 1 MiB
per normal step. A 256-KiB floor plus a 512-KiB decommit hysteresis prevents a
short-lived block from repeatedly committing and decommitting the same tail;
explicit pressure trimming can still reduce each free tail to one page.
Large allocations may reuse one exact-sized mapping in each of the bounded
2-/4-/8-MiB buckets, with a 14-MiB aggregate ceiling. Alignment-only direct
regions and mappings above 8 MiB are not cached. `ctx.allocatorTrim()` drops
all reclaimable cache state, and allocation failures do so before a single
retry. Stats report cache use, current/peak commit and reclaimed bytes so the
space/time tradeoff stays measurable.

Independent Runtime-R4Ls keep contract, baseline, implementation, bindings
and tests in their own library unit. The core SDK provides only the generic
named-table resolver and module-build mechanism.

Subsystem hosts remain ordinary GUI R4X processes. `r4os.subsystem_host`
provides caller-owned virtual video surfaces, bounded raster presentation and
guest-neutral input translation. `r4os.subsystem_runtime` composes that host
with one bounded guest slice per cycle, monotonic pause-aware guest time,
frame or cycle pacing, explicit lifecycle commands and caller-owned buffered
S16LE audio through the normal app audio facade. Audio degradation never
turns into unpaced guest execution; completion, close and failure share an
idempotent cleanup path.

Subsystem input policies preserve stable raw sequences and ticks while
choosing key-plus-text or single-text delivery and mapped or prefiltered
pointers. Passive filter/drop counters remain available without hot logs;
ignored deliveries never wake an event-only guest.

Build the SDK with `Repositories\SDK\Build.bat test` or
`Repositories/SDK/Build.sh test`, or as part of the matching central build.
