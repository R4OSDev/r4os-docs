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

Independent Runtime-R4Ls keep contract, baseline, implementation, bindings
and tests in their own library unit. The core SDK provides only the generic
named-table resolver and module-build mechanism.

Build the SDK with `Repositories\SDK\Build.bat test` or as part of
`Tools\Build.bat -central`.
