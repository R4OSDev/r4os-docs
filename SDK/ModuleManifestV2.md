# R4MF v2 module manifest

`module.R4MF` is the single project, build and image truth for one R4OS
module. The formal grammar and validation rules are owned by
`Repositories/Contract/Module/R4MFv2.txt`.

A minimal application manifest looks like:

```text
R4OS_MODULE_MANIFEST=2
KIND=R4X
NAME=HELLO
VERSION=0.1.0
LANGUAGE=Zig
SOURCE=src/main.zig
ENTRY_MODE=app
APP_CLASS=console
TARGET=/R4OS/SOFTWARE/TERMINAL/HELLO.R4X
IMAGE_SCOPE=full
IMPORT=R4SYS:Query:1
```

The manifest defines kind, identity, version, language, sources, imports,
exports, metadata, resources, target and image scope. R4D and R4P add their
driver/protocol metadata; independent R4L projects declare their exported
library tables.

`OPTIMIZE=size|speed` is optional for R4X, R4L, R4D and R4P. Omission means
`size`/ReleaseSmall. A measured module-local hot path may select
`speed`/ReleaseFast; the choice does not alter ABI, imports or image scope.

`NATIVE_ARCHIVE=NAME` declares an ordered native archive for a Zig R4L.
Names are unique without regard to case and use the module name syntax.
The owning build maps each declaration to one tracked `LazyPath` with
`addR4MFWithOptions(..., .{ .native_archives = &.{archive} })`. Missing or
extra mappings fail. Archives must be freestanding ELF with R4OS-supported
relocations; no host library search is implied. R4NAK uses this for its
pinned C/Rust compiler. Its common PS7 builder produces the archive on
Windows or Linux; ordinary applications do not acquire these toolchains.

`IMAGE_SCOPE` is `slim`, `full`, `test` or `none`. Distribution derives the
profile plan from discovered manifests and rejects missing artifacts,
duplicate targets, unknown scopes and unresolved required providers.

`.R4CP` is only an explicit one-time import source. It is not a second normal
project format.
