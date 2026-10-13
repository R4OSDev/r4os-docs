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
The migration does not use or replace Benchmarks.jsonl. The separate private
database/WebAPI tool remains outside the R4OS build and inventories.

Spectra standard benchmark and result data (planned 0.83.3)
----------------------------------------------------------

The user explicitly requested this benchmark as a standard test. Introduce
one bounded benchmark phase in the regular SMP4 guest acceptance. Existing
quick probes keep their documented narrow scope unless deliberately invoked
with the benchmark. Run the five areas separately and report six scores:

    scheduler_sync   Scheduler and synchronization
    memory           Memory management
    ipc              Kernel communication
    lifecycle        Program startup and complete retirement
    filesystem_io    Filesystem and I/O core
    overall          Composite of the five areas

Each area uses fixed, versioned work, correctness checks, declared cache and
warmup policy, and repeated timing samples. Prefer elapsed nanoseconds per
completed operation for the primary metric. Multiple primary metrics within
an area require fixed weights in the scoring definition. Diagnostic counters
and correctness checks are supporting data, not additional score inputs.

A validated reference run defines 100 points for each area. For a lower-is-
better time metric, normalized performance is reference/current. For a
higher-is-better throughput metric it is current/reference. Area scores are
100 times the weighted geometric mean of their normalized primary metrics.
All five areas have equal weight: overall = 100 * product(area_score/100)^0.2.
Higher is better. No score is an absolute claim about every R4OS application.

Reference and candidate need matching environment, suite/workload version,
scoring version, measurement configuration and instrumentation mode. Release,
kernel and Spectra revisions identify the measured artifact set; those are
allowed to change and are not themselves the comparison key. The first
validated reference is frozen. A new baseline gets a new identity; importing
a new run never silently replaces the reference. Persist which reference
was used, even if the database later displays another comparison.

Missing, failed, cancelled, zero-time or incompatible primary measurements
produce null scores with an explicit reason. An incomplete five-area run has
no valid overall score; weights are never redistributed over surviving areas.
Keep successful partial measurements and failure details for diagnosis.
Small sample sets report raw samples, median, minimum, maximum and MAD; do
not invent precise tail percentiles from a handful of repetitions.

The following database-neutral field design is the handoff for the separate
database application. The application and private repository are outside this
roadmap. Spectra and the host runner export a versioned result without needing
that application's service, database or network access. No use or replacement
of Benchmarks.jsonl is part of this work.

benchmark_runs (one row per invocation)

    run_id                  UUID, assigned by the invoking host/orchestrator
    schema_version          Result schema revision
    started_at_utc          UTC timestamp supplied by the host
    finished_at_utc         UTC timestamp supplied by the host
    status                  ok / partial / failed / cancelled
    failure_reason          Nullable error code/details
    suite_version           Versioned five-area workload definition
    scoring_version         Metric membership, direction and fixed weights
    baseline_run_id         Nullable reference to the frozen reference run
    environment_id          Stable identifier for the declared test environment
    comparison_key          Hash of canonical comparison-relevant configuration
    environment             Structured host/guest CPU, RAM, QEMU version/backend,
                            vCPU count, disk/backend/image settings and clock data
    workload_config         Work sizes, cache policy, warmups and repetitions
    instrumentation_mode    Normal/detail capture and sampling configuration
    release_version         R4OS release version
    kernel_version          Kernel artifact version
    spectra_version         Spectra artifact version
    artifacts               Relevant component names, versions, commit IDs,
                            dirty state, build options and artifact SHA-256
    notes                   Optional contextual note

benchmark_measurements (one row per metric per run)

    run_id, area_id, metric_id    Stable identity; unique together
    metric_version               Metric/workload semantics revision
    unit                         For example ns/op or bytes/s
    direction                    lower / higher
    primary                      Whether this metric contributes to the score
    weight                       Fixed weight within its area
    status, failure_reason       Explicit availability/correctness outcome
    sample_count                 Number of accepted measured samples
    median_value                 Nullable raw metric median
    min_value, max_value         Nullable observed range
    mad_value                    Nullable median absolute deviation
    checks                       Structured correctness/accounting results

benchmark_samples (raw evidence, one row per attempt)

    run_id, area_id, metric_id, sample_index    Unique sample identity
    phase                        warmup / measured
    status, failure_reason       Preserve rejected/failed attempts as well
    elapsed_ns                   Monotonic measured interval
    operation_count              Completed work units
    bytes_processed              Optional amount of data processed
    value                        Derived metric in the measurement's unit
    clock_source                 Source used for this interval
    clock_generation             Source generation/epoch
    clock_resolution_ns          Reported clock resolution
    observer_overhead_ns          Optional separately measured observer cost

benchmark_scores (six rows per full invocation)

    run_id, area_id               Unique together; includes area_id=overall
    baseline_run_id               Exact reference used
    scoring_version              Calculation definition
    score                        Nullable decimal; reference=100
    status                       valid / incomplete / no_baseline /
                                 incompatible / invalid
    reason                       Nullable explanation

Store nanosecond intervals, counts and bytes as exact integers, derived values
and scores as numeric values. Preserve 64-bit integers losslessly in the export
and importer (decimal strings are suitable for JSON clients with limited integer
precision). Null denotes unavailable; zero must never substitute for failure.
Import run_id idempotently and detect conflicting payloads instead of silently
overwriting old results. The database can add its own import timestamp and
report/log artifact references without changing the measured result.

Kernelinstrumentierung 0.83.1: siehe KernelInstrumentation.txt fuer Messmodi,
Besitzer, Ausgabegrenzen und den kontrollierten A/B-Nachweis.
