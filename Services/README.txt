R4OS Services
=============

Services are long-running R4X modules under `Repositories/Services/`. They
use the same R4XStart and SDK contracts as applications, but their manifest
class and service configuration define lifecycle and autostart behavior.

The kernel service core owns endpoint registration, queues and generic
lifecycle mechanisms. `SERVMAN.R4X` owns visible policy, configuration and
operator commands. Individual services own their protocol, session and
recovery logic.

The registry lock protects service definitions, lifecycle state and the short
lookup that maps a handle to a stable endpoint address and generation. Queue
state, waiter objects, counters and payload copies are protected by the
persistent lock of that endpoint. A data operation releases the registry
before acquiring the endpoint lock and revalidates handle, generation and
service slot before touching endpoint state. Lifecycle paths use registry
before endpoint; if the endpoint is already busy, they release the registry,
wait for the endpoint alone and retry the complete mapping. Neither lock is
held while a task sleeps.

Each endpoint has eight request slots. A synchronous call uses one absolute
deadline across slot admission and response completion. If all slots are
occupied, the central service core admits blocking callers in FIFO order;
explicitly nonblocking submission continues to return `busy` immediately.

Response completion is request-specific. A reply publishes the response and
wakes only the waiter for that request. Timeout, cancellation, endpoint
unregister and service stop close the affected request completion, and handle
plus request-ID validation prevents a reused slot from satisfying an older
caller. Services must use this central contract instead of implementing their
own polling, retry or admission loops.

Request and response payload storage is reused without clearing the complete
4-KB arrays. `request_len` and `response_len` are the sole publication
boundaries: submit, receive, reply and take copy only that many bytes. Slot
reclamation resets IDs, lengths, status and request-specific synchronization;
endpoint retirement first wakes all waiters and then resets only endpoint,
queue and semaphore metadata. Bytes beyond a published length are never
returned, including after a shorter request reuses a formerly full slot.

The append-only performance snapshot reports lifetime service payload copy
bytes, payload clear bytes, slot metadata resets, endpoint metadata resets and
endpoint payload-reset bytes. Normal operation keeps both payload-clear
counters at zero while the metadata-reset counters prove that slot and
endpoint reuse actually occurred.

The same snapshot reports queue-scan passes and visited slots plus acquisition,
contention, wait and hold nanoseconds for registry-control, registry-lookup,
registry-snapshot, endpoint-lifecycle, endpoint-data, endpoint-wait and
endpoint-snapshot locks. Status and performance snapshots classify every
queue slot in one endpoint pass instead of scanning once per state.
Acquisition and contention counts are exhaustive. Every contended acquisition
is timed; otherwise hold timing uses the published deterministic stride and
reports the exact number of samples. This avoids placing multiple HPET MMIO
reads on every uncontended service hot-path acquisition.

The public ServiceInfo and ServiceDetail enumerators share one dense internal
index map in physical registry order. Register and unregister rebuild that map;
ordinary status changes do not. An index query refreshes only its selected
service, revalidates registry generation, slot, name and instance identity,
then returns the existing API payload. The end marker performs no refresh.
Consequently one complete N-service enumeration performs N refresh visits
instead of the former `(N + 1) * N` visits. The performance snapshot reports
index queries, requested refreshes, actual visits, program-instance lookups and
end markers separately.

A service communicates through R4SYS service endpoints and uses R4NET,
R4AUDIO, R4DESK or other public groups as required. It must not add a private
kernel path or a second filesystem/network implementation.

A service cannot stop, restart or disable itself, directly or through one of
its console descendants. Each operation uses the same ancestry check and
returns -19 before changing the mode or stopping the service.

A start reserves one registry slot and a unique generation under the service
owner, including the matching path and argument snapshot. Loader I/O runs
without that owner lock. Publication binds the program only if the same
reservation is still starting and enabled. Disable, cancellation and removal
invalidate the reservation; a replacement registration cannot reuse it. A
rejected publication terminates the exact spawned program handle through the
existing lifecycle path and abandons its owned completion for reaping. A late
load error only changes its own reservation. A mode change must not detach a
program that has started between STOP and DISABLE.

Since 0.89.20-0.89.23 the native registry and endpoints grow through stable
individual resident allocations and intrusive indexes. There is no fixed
service-count limit. Registration IDs and endpoint handles are not reused
within a boot; real allocation and representation exhaustion remain errors.
Closed endpoint storage is retained until short leases and actual native
wait queues are quiescent, then freed outside registry/runtime ownership.

SERVMAN and Services use the revision-bound dynamic SDK inventory. END proves
completion; pages bound only one transfer. Membership/configuration changes
invalidate the cursor with RESTART. Up to three complete attempts discard
partial data. Runtime counters remain separate per-owner observations.
Actions bind registration ID, start generation and exact process identity;
a same-name reinstall or restarted process is never adopted implicitly.

SERVMAN reads and renders SERVICES.R4S dynamically in bounded I/O blocks;
4096 bytes is no longer a file limit. SAVE stages the complete BOM/UTF-8 file,
verifies bytes and revision, and uses the native checked atomic exchange.
An uncertain exchange preserves stage/backup evidence. Runtime changes and
persistence results are reported separately. Services delegates persistence
to SERVMAN and retains/reaps its exact child. Its dynamic list preserves
selection by registration ID, renders visible rows and supports wheel,
scrollbar, Home/End, arrow and page keys. Failed refresh retains stale data
and disables mutations until a successful complete refresh.

Legacy fixed-layout detail/index and named control APIs remain available.
Their old 128-byte detail path cannot carry a longer valid path: BUFFER_TOO_SMALL
is explicit. New rows carry the full 1024-byte native path field. Telemetry
service_max_count=0 denotes dynamic capacity, not a capacity of zero.

SERVICES keeps START, STOP, mode and installation results after refreshing the
list. Refresh failure adds its own error without replacing the action result;
only an explicit refresh or initial successful load sets Ready.
In a Terminal session without a desktop, use the existing console launch
switch: C:\R4OS\SOFTWARE\DESKTOP\SERVICES.R4X /LIST /CONSOLE.
The SELFTEST switch already selects the Terminal's console launch policy.

Current services and image scopes are listed in
`Docs/Inventory/AllModules.json`.

Fortschreibung 0.90.64 - Normal Start2 administration
---------------------------------------------------
SERVMAN0.1.7 and SERVICES0.1.11 use App2 and Query2 on SDK200.
Service actions bind the full registration and process identities.
Status uses a bound endpoint channel and one five-second budget.
Configuration readers check the exact metadata identity, content
revision and length around a complete bounded stream read.

SAVE compares the whole existing file when size and checksum match
the desired configuration. A stable complete read and the current
inventory revision confirm an already saved state. Changed data uses
the existing checked atomic transaction. Services retains its exact
SERVMAN child, waits for process completion or GUI activity, and
reports success after reaping the child. CLI mutations wait for SAVE.

The private KVM4 software Desktop exercised End selection and an
actual Auto click, whole saved bytes, a successful window close and
the configured auto start. Original command tests, retained old
service completion, stale restart rejection, SSH ancestry refusal,
malformed configuration and normal shutdown have separate records
under Research/API-ABI/Migration/0.90.64.


Window-service timing and current Fable scope (0.91.26)
-----------------------------------------------------
WINSVC 0.1.39 defines its owner-liveness interval as 500 ms and converts it
through the current logical clock when arming a new deadline. Ordinary
requests preserve that deadline. Its registration budget is 1000 ms and
diagnostic service calls use 1200 ms. Owner interest arms/disarms the sweep;
the next pending tray, graphics, launch, evidence, action or diagnostic
deadline still wins independently. An unavailable clock retains owners
without inventing a frequency or entering an immediate deadline loop.
The two bounded one-tick registration/open retries remain scheduler
cooperation, rather than periodic idle work.

Fable 0026 is partially stale after the API migration: RegEdit already uses
EventLoop with Forever; UpdateCenter was retired and SysUpdate now enters
the terminal update engine. R4STD already exposes WritebackPolicy.forHz
with millisecond defaults (lazy 150/1000 ms, soon 50/500 ms, sync 0/250 ms).
An actual-source host witness checks these at 100/1000 Hz. Its explicit tick
fields/defaults remain a compatibility surface; no current audited app uses
the old implicit policy. The SDK, Contract, Kernel and Library artifacts
remain unchanged.

The existing WINSVC tests retain original owner/generation/error/independent
deadline assertions, including the original 100 Hz case, and add 1000 Hz and
unknown-frequency retention to that same case. Full owner target 10/10 and
existing repository target 51/51 pass. Native evidence uses the original 38
and corrected 39 source bodies with identical passive counters, an actual
minimal GUI process declaring the existing Desktop-host role, real tray
sync/upsert/remove, cooperative close and exact terminal reaping. It does
not claim product Desktop presentation, physical graphics or Windows tests.
Over the paired three-second KVM4 samples, live-owner sweeps and process
checks fall from 19.99/s to 2.00/s; timer wakes fall from 19.99/s to 6.00/s.
The empty service performs zero owner work on both versions; its separate
200 ms central stop check remains. Both original runtime selftests, tray
operations, exact child reaping, owner retirement and normal shutdown pass.
Sources, raw setup failures, exact installed bytes and results:
ExFiles/Reports/Fable091/0.91.26/.

Final STANDARD b4d8f63f-c42d-469e-92ee-619db775d99b (Suite 3, KVM4) completed with
overall 133.764579. All 30 raw samples, five metrics and six scores
were independently recomputed against the frozen reference. The normal
WINSVC 39 payload and Kernel 486 were read back from the actual source image;
private actors and the unchanged browser were absent. Full original records:
ExFiles/Reports/Benchmarks/b4d8f63f-c42d-469e-92ee-619db775d99b/
Status: lokal validiert; R4OS Server ausstehend (Claim, import, full GET
readback and independent server scoring).

0.94.9 - Idle service endpoints
TIMESVC and other services using ServiceLoop wait for a request, cooperative
process close or their own deadline when R4XStart advertises endpoint_stop_wake.
Older providers keep the configured finite stop interval (default 200 ms).
