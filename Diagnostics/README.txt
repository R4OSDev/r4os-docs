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

Build one diagnostic with its repository `Build.bat` or through:

```text
Tools\Build.bat -module Diagnostics\<Project>
```

A diagnostic may inspect low-level state when that is its explicit purpose,
but normal applications continue to use the SDK facades.
