# R4IMG Runtime-R4L

R4IMG is an independent library for bounded raster and vector image decoding.
Consumers import:

```text
R4IMG:API_V1:1
```

The current library contract covers PNG, baseline/progressive JPEG, selected
BMP variants and the documented static SVG subset. Probe validates format and
dimensions before decode. Encoded bytes, decoder arena and ARGB/XRGB output
remain caller-owned through explicit buffers and contexts.

R4IMG does not draw windows or own document state. Applications such as
Klickifax decode and scale resources, then pass completed raster data to
R4DRAW. SVG parsing, paths and optional nested image resources are bounded and
fail independently where the local contract allows it.

Contract, provider, Zig/C bindings, tests and decoder provenance are owned by
`Repositories/Libraries/R4IMG/`. The central platform API contains no R4IMG
group or decoder implementation.
