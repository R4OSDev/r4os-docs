R4OS Diagnostics
================

Diagnostics are independent R4X modules under `Repositories/Diagnostics/`.
They exercise public contracts, report subsystem state and provide guest-side
markers for integration tests. They are not hidden kernel commands and must
not become alternative production implementations.

Most diagnostics use `IMAGE_SCOPE=test`; a few build-only conformance
programs use `none`. The authoritative module list is
`Docs/Inventory/AllModules.json`. Individual automated checks are recorded in
`Docs/Inventory/Tests.json`.

Build one diagnostic with its repository `Build.bat` (Windows) or `Build.sh`
(Linux), or through the workspace starter:

```text
Tools\Build.bat -module Diagnostics\<Project>
./Tools/Build.sh -module Diagnostics/<Project>
```

A diagnostic may inspect low-level state when that is its explicit purpose,
but normal applications continue to use the SDK facades.


Spectra: central kernel tool (0.83.2)
--------------------------------------

Owner: Repositories/Diagnostics/Spectra; public repository
https://github.com/R4OSDev/r4os-diagnostic-spectra.
SPECTRA.R4X is included from the Slim profile upward. Terminal and SSH use
METRICS for passive counters, LOGS for bounded kernel sources, CHECK for
explicit functional probes, and BENCH for selected bounded workloads.
No desktop is required. The later hybrid GUI can reuse these collectors
and output models; no GUI or permanent collector is included in this step.

Usage, exact groups, JSON/explicit export, clock/sampling quality, unavailable
values, cancellation and observer costs: Spectra.txt. The function-by-function
owner mapping and retained specialist purposes are in SpectraMigration.json.
Existing loader fixtures and measurement assertions move with their owner;
original licenses, provenance and source commits remain in the Spectra repo.
The old whole-kernel diagnostic modules and BootInfo/MemView are retired after
migration verification. Mixed apps keep their independent tasks: SDK allocator,
storage hardware, TCP/UDP services, non-kernel logs and system identity.

Kernel boot/loader, scheduler/waits/locks, clocks/IRQs, memory, lifecycle, IPC,
work and filesystem/I/O probes belong here. The provider API alone does not
change a driver/service diagnostic into a kernel diagnostic. All queries
respect the normal/detail build mode; they do not enable traces or benchmarks.
Complete standard benchmark runs are retained as unchanged local exports.

Spectra standard benchmark and result data (0.84.47, Suite 3)
-----------------------------------------------------------

SPECTRA BENCH STANDARD runs scheduler_sync, memory, ipc, lifecycle and
filesystem_io separately or together. Each area assigns equal fixed work
to every available schedulable CPU behind a common preparation/start gate.
Active warmup performs at least one second and three complete batches;
five measurement batches follow. The full suite retains 30 raw samples
with exact worker/completion counts, median/range/MAD and six scores.
The fixed reference defines 100; the five areas have equal geometric weights.
Incomplete or incompatible data cannot produce a valid overall score.

The regular SMP4 runner has one bounded Terminal boot phase before its existing
acceptance. Quick probes and pure builds retain their scope. The central Spectra
owner also supplies the offline Schema-1 exporter and strict reference scorer;
no database service is required. Exact workloads, CLI/host calls, frozen reference,
comparison limits, lossless raw fields and the complete export contract are documented
in SpectraStandardBenchmark.txt. Current qualification and run identities are in
SpectraAllCpu08447.json. Spectra0833.json retains the original Suite-1
qualification; historical suites are never rescored as Suite 3. QEMU here
remains SMP4; native hardware uses its full available CPU capacity.
Performance benchmark history uses this standard suite and complete local
exports. Keep the original run.json with its UUID, host, context and SHA-256;
check all five metrics, 30 raw samples and six scores against the frozen
reference and comparison contract. The short workflow is in Agents/Benchmark.txt.
