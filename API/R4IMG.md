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

Since R4IMG 0.3.7 / Release 0.91.15, each raster decode owns its allocator
context on its stack. PNG, JPEG, BMP and full-precision PNG calls can execute
concurrently with separate writable caller buffers. The original image and
allocator algorithms are retained with explicit context arguments. Decoder
diagnostics expose one coherent atomic snapshot of the last completed raster
call across callers. Public interface IDs, revisions, slots, layouts and error
statuses remain compatible; the local contract records the stronger threading
guarantee. Source comparison and parallel originals:
`ExFiles/Reports/Fable091/0.91.15/`.

All 23 owner tests pass in the normal provider build, including three native
PNG/JPEG/RGBA16 workers with 400 decodes each and exact serial golden pixels.
A separate native stress probe passes 40,000 decodes; the unchanged original
crashes in the JPEG reader. These are host concurrency and correctness checks.

Release 0.91.15 also passes normal image verification and one full KVM4
STANDARD run, 659cf319-2e04-4426-93ca-00999ff13473. All 30 raw samples,
five metrics and six scores are locally recomputed against the frozen
reference (overall 128.326484). Status: "lokal validiert; R4OS Server
ausstehend"; Claim, import, full GET readback and independent server scoring
remain. This system workload does not measure decoder throughput separately.

R4IMG does not draw windows or own document state. Applications such as
Klickifax decode and scale resources, then pass completed raster data to
R4DRAW. SVG parsing, paths and optional nested image resources are bounded and
fail independently where the local contract allows it.

Contract, provider, Zig/C bindings, tests and decoder provenance are owned by
`Repositories/Libraries/R4IMG/`. The central platform API contains no R4IMG
group or decoder implementation.
