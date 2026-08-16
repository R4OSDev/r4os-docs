# R4FONT Runtime-R4L

R4FONT is an independent library for bounded font-container parsing and
glyph rasterization. Consumers import:

```text
R4FONT:API_V1:1
```

The library supports the TrueType/OpenType, WOFF/WOFF2 and collection paths
implemented by its current local contract. It exposes face metadata,
character mapping, metrics, kerning and deterministic Alpha8 glyph rasters.
Encoded data, decoder scratch and result buffers are owned by the caller or
the explicit library context.

Font parsing remains outside the kernel and R4DRAW. R4DRAW receives completed
metrics and Alpha8 coverage for drawing; persistent system-font catalog policy
remains separate from browser webfonts.

Contract, baseline, provider, Zig/C bindings, third-party provenance and tests
are all owned by `Repositories/Libraries/R4FONT/`. Compatible implementation
changes or append-only revisions do not require a platform Contract, Kernel
or core SDK change.
