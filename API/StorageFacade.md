# Console, file, directory and registry facade

The SDK wraps R4SYS with typed Zig and C views. These views validate paths,
buffers and lifecycle but do not add new kernel operations or invented file
handles.

## Console

Console output, input and STDIO use the program's console host. Kernel logging
and COM1 are not application stdout fallbacks.

## Files and directories

File operations are path-based where the R4SYS contract is path-based.
Directory enumeration uses bounded caller buffers and explicit end/error
states. Atomic replace/update helpers bind staging, target, backup and
identity checks so applications do not reimplement system-file transactions.

## Streams

A stream has begin, ordered writes, finish and abort. Offsets and final size
are checked; a failed abort or finish remains visible. Caller buffers are not
retained after a synchronous write.

## Registry and R4STD config

The registry facade reads and writes typed R4R1 values through R4SYS. R4STD
provides separate library-local settings, date/time and R4S configuration
tables. There is no R4STD platform group or second registry implementation.

`Registry.beginSnapshot` returns a caller-owned cursor for child-key or value
pages. `RegistrySnapshot.page` writes only to caller-provided entry and data
buffers and exposes complete, more and restart explicitly; consumers discard
an attempt after restart. The facade checks the optional slots before use, so
applications can retain legacy per-entry enumeration as a compatibility
fallback.

`RegistryBatchBuilder` writes fixed-layout operations and every referenced
path, name and payload into caller-provided storage. `Registry.applyBatch`
returns both the raw Registry result and `RegistryBatchResult`, including the
before/after generation, failed index and atomic commit status. The Zig and C
facades neither allocate nor retain those buffers. Old typed Set/Delete
methods remain available for kernels without the optional batch slot.

Implementations are in `Repositories/SDK/r4os/app_storage.zig`, the matching
C headers under `Repositories/SDK/Shared/C/` and the independent R4STD unit
under `Repositories/Libraries/R4STD/`.
