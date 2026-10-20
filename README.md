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

The thematic directories document only the current state. Historical paths,
decisions and acceptance logs remain in `Changelogs/`.

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
