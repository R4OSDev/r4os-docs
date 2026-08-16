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

`IMAGE_SCOPE` is `slim`, `full`, `test` or `none`. Distribution derives the
profile plan from discovered manifests and rejects missing artifacts,
duplicate targets, unknown scopes and unresolved required providers.

`.R4CP` is only an explicit one-time import source. It is not a second normal
project format.
