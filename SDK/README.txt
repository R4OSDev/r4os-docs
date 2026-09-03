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
