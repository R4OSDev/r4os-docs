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

## Shared partition and formatting tools

`r4os.storage_tools` owns userland/host GPT/MBR editing and FAT32/NTFS
formatting. `storage_tools_guest.Target` adapts a complete physical target
and its live claim; `storage_tools.host_file.File` uses a locked positional
host file. They share sector-relative I/O and a 128-KB transfer limit.

Prepare every layout, metadata buffer and source before starting execution.
The partition plan captures the actual parsed table bytes and rechecks their
SHA-256 after exclusive admission. Unknown, hybrid, extended or inconsistent
tables reject ordinary editing; explicit CLEAN and subsequent creation are
separate destructive operations. New partition starts align to 1 MB.

A formatter receives a complete target region and bounded caller-owned work
buffer. Quick writes filesystem administration, Full also zeros free space.
NTFS streams the cluster bitmap instead of allocating a volume-sized image;
its metadata source and byte receipts are SDK-owned. Existing whole-image
fixture builders retain an explicit RAM compatibility call.

Progress distinguishes the first failure and LBA, attempted writes, fully
acknowledged sectors, flush and verification. A failed backend call may have
changed an unknown prefix; no automatic write retry or power-fail atomicity
is implied. Backup/main ordering and metadata readback are followed by the
normal checked claim close, rescan and fresh mount identities. See the SDK
owner documentation for limits and the grouped component fixture.

Partition identity changes (0.76.10)
------------------------------------
Claim completion restores only surviving disk GUID/MBR ID, partition number,
bounds, unique GUID and type. Deleted or reidentified partitions do not inherit
old letters or installation roles and are not remount failures. A matching
identity with a damaged filesystem still reports a real remount failure.
R4PART OFFLINE flushes/detaches affected mounts with KEEP_UNMOUNTED; this
survives application EXIT. ONLINE explicitly mounts them again and does not
change device power or prevent another explicit mount.

Offline NTFS growth (0.76.11)
---------------------------
R4PART EXTEND uses SDK storage_tools.ntfs_extend with an exclusive whole-disk
claim for the table change. The partition starts and IDs stay fixed. The
prepared metadata plan relocates the cluster bitmap into adjacent new space,
updates MFT/root duplicated sizes and $Bad, then publishes both boot sectors.
Dirty marking, table/bitmap/metadata/boot publication and final clean marking
have explicit flush/readback barriers. The plan and working buffer are bounded;
bitmap size does not become a volume-sized RAM allocation. Fingerprints are
rechecked after unmount and before writes. No automatic power-fail rollback.
Unsupported/dirty layouts and busy volumes reject before mutation; interruption
can require external NTFS/table repair. SDK/DOCUMENTATION.de.txt specifies the
accepted geometry and actual persistence windows. On success R4PART restores
only the resized target at its former letter after a fresh identity check.
The kernel's generic identity/size restoration rule remains unchanged.

Offline NTFS shrink (0.76.12)
---------------------------
SDK storage_tools.ntfs_resize owns both directions (ntfs_extend is a compatible
alias). SHRINK QUERYMAX scans the actual bitmap and active MFT attribute runs;
fixed file/metadata clusters, real replacement-bitmap space and a 16-MB floor
set the executable maximum. The bitmap may move; file data and other metadata
stay at their LCNs. A bounded bitmap cache validates run allocation and rejects
references shared with the retired bitmap. The MFT and the bitmap used for the
query are fingerprinted and rechecked before writes, for either resize direction.
The accepted profile has no attribute-list/extension records and at most one
million MFT records; metadata runs retain their tighter bound. This is not a
complete filesystem repair or defragmenter. The SDK owner contract lists limits.
SHRINK DESIRED=MB removes exactly the requested amount, or without DESIRED the
current maximum. The smaller filesystem and both boot copies become durable
before the smaller GPT/MBR boundary; clean marking and remount require both to
succeed. Failure leaves the affected target unmounted with its actual progress.
