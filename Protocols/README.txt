R4OS Protocol Modules
=====================

Loadable protocol modules are independent R4P repositories below
`Repositories/Protocols/`. They provide reusable roles for networking, USB,
audio, data formats and web/security protocols.

Each module owns a `module.R4MF`, exports its protocol entry point and
declares role and dependencies in the manifest. The protocol registry
resolves required roles deterministically; an unavailable mandatory
dependency is a visible load or plan error.

R4P code is fully trusted userland module code. It may parse or transform
data but must not become a private hardware driver, service lifecycle or
application-specific fallback. Current modules are listed in
`Docs/Inventory/AllModules.json`.
