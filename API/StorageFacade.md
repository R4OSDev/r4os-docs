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

## Physical devices and exclusive maintenance

`r4os.storage.Context` and the C `r4os/storage.h` facade expose the additive
R4SYS storage contract. Inventory returns a generation and bounded slot counts;
consume every slot, including unmounted/unknown/failed partitions, and restart
on STALE. Device references bind a registration generation; targets also bind
the table generation, complete region and partition GUID. Volume references
bind an exact mount incarnation. Never retain only a drive letter as a raw
maintenance target. Partial tables, unsupported geometry and exhausted
capacity reject destructive admission.

`claimBegin` accepts a whole device or one complete partition. It rejects
open uses before changes, closes affected admission, flushes and invalidates
cached sectors, drains and detaches affected mounts. Read/write/flush using
the returned claim are bound to the exact logical program thread. Raw buffers
are caller-owned and limited to 256 sectors of 512 bytes per call. A failed
write can have changed a prefix; the caller must treat the target as uncertain.

`claimEnd` closes raw admission, flushes, rescans and remounts matching prior
identities unless KEEP_UNMOUNTED is requested. BUSY retains the claim for
retry. Successful close and terminal I/O/remount failures consume it; both
facades clear the caller's token in those cases. A failed target stays in the
inventory with its error. Program/thread retirement drains outstanding I/O
and releases abandoned claims through the cleanup worker. Runtime-required
volumes remain protected.

File operations stay path-based. Each kernel call pins the actual backing
mount before entering the filesystem queue, including the internal BOOT
alias. Existing write-stream handles retain their mount across calls.
`useBegin(path)`/`useEnd` retain a real volume use for multi-call activities,
without inventing file handles. SSH/SFTP/SCP and FTP hold these uses for their
actual file/directory/transfer lifetime. New services use their older behavior
only if the provider has neither volume uses nor exclusive storage claims;
a partially available new contract fails closed.

Explicit mount/unmount, rescan and letter assignment use the same admission
mechanism. Unrelated volumes and Recovery's RAM runtime remain usable during
a partition claim. Re-enumerate after completion: old mount and table
references must not become valid again.
