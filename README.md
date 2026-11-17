# R4OS Documentation

This repository contains cross-project R4OS documentation and inventories
that do not belong to one component repository.

Component-specific API, build, test, and implementation documentation remains
with the component that owns the corresponding contract or source code.

## Structure

    API/          Platform and Runtime-R4L API reference
    Core/         Kernel-facing architecture and lifecycle contracts
    Deployment/   Build, image and update workflows
    Inventory/    Module, test, browser and documentation inventories
    Changelogs/   Historical release roadmaps

The thematic directories describe current contracts and identify the scope
of older evidence. Complete release roadmaps remain in `Changelogs/`.

## Current release and archived roadmap

[R4OS 0.92.12](Deployment/Release09212.txt) is published as Slim and Full,
with Kernel 0.1.493, SDK 0.64.230 / Contract 0.64.99 / Libraries 0.64.69 and the
unchanged independent Recovery 0.1.78 package. The source/tool/package checks,
complete anonymous download verification and exact-image KVM4 boots retain
the scope recorded in that report.

Release family 0.92.X is complete: eleven subversions completed, 0.92.2
intentionally discarded. The full roadmap is archived in
[V0.92.X.txt](Changelogs/V0.92.X.txt). Active planning remains in the roadmap
API. [ExplorerStart0921.txt](Desktop/ExplorerStart0921.txt) and
[Performance092.txt](Desktop/Performance092.txt) describe implementation,
measurements and limits. Hardware acceptance was discarded; the original
STANDARD records are locally validated with R4OS Server processing pending.

## Completed graphics and responsiveness work

Release family 0.87.X is complete through 0.87.66: 66 subversions,
280 tasks (279 completed, one intentionally discarded) and 212 acceptances. Its full roadmap is archived in
[V0.87.X.txt](Changelogs/V0.87.X.txt). At that checkpoint, planning moved to the separate,
initially empty 0.88.X roadmap and the installed release remained 0.87.66.

The final implementation and acceptance limits are documented in
[Parallelitaet.txt](Core/Parallelitaet.txt),
[SNESArchitecture.txt](Subsystems/SNESArchitecture.txt),
[SnesBenchmark.txt](Diagnostics/SnesBenchmark.txt) and
[AudioDiagnostics.txt](Audio/AudioDiagnostics.txt).
SNES virtual debt is bounded; real-time deficits and audio starvation remain.
Later passing checks do not explain earlier failures, and automated native
receipts do not substitute for the explicitly skipped physical checks.

[DeskRun.txt](Desktop/DeskRun.txt) describes visible application launches from
SSH. The separately published Full/Slim 0.87.51 packages and their exact
qualification are recorded in [Release08751.txt](Deployment/Release08751.txt);
roadmap completion does not create a new Full/Slim package.

## Completed CPU and text work

Release family 0.85.X is complete through 0.85.48. Its full roadmap, all 48
subversions, 195 tasks and 48 acceptances are archived in
[V0.85.X.txt](Changelogs/V0.85.X.txt).

The current implementation and its limits are indexed in
[Parallelitaet.txt](Core/Parallelitaet.txt),
[CpuHardware085.txt](Core/CpuHardware085.txt),
[Codepages085.txt](Core/Codepages085.txt) and
[FpuSimd085.txt](Core/FpuSimd085.txt). Their dated analyses remain historical;
the completion notes point to the implementation evidence. Local KVM4 results
do not qualify native hardware or Windows execution.

## License

Original R4OS documentation in this repository is licensed under the Apache
License 2.0. See `LICENSE`, `NOTICE`, and `THIRD_PARTY_NOTICES.md`.
