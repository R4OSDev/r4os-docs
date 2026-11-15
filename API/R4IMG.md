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

Release 0.91.15 passed all 23 owner tests in the normal provider build,
including three native PNG/JPEG/RGBA16 workers with 400 decodes each and
exact serial golden pixels.
A separate native stress probe passes 40,000 decodes; the unchanged original
crashes in the JPEG reader. These are host concurrency and correctness checks.

Release 0.91.15 also passes normal image verification and one full KVM4
STANDARD run, 659cf319-2e04-4426-93ca-00999ff13473. All 30 raw samples,
five metrics and six scores are locally recomputed against the frozen
reference (overall 128.326484). Status: "lokal validiert; R4OS Server
ausstehend"; Claim, import, full GET readback and independent server scoring
remain. This system workload does not measure decoder throughput separately.

R4IMG 0.3.9 / Release 0.91.16 uses active row edges and intersection sweeps
for SVG fills and clips. Stroke candidates are filtered by row before the
unchanged distance predicate. Glyph pixels retain their separate alpha blends
and use stack quads. Four sample positions and the blend calculation remain.
One budget covers all shapes, glyphs, clips and use expansions: 128 * 1024 *
1024 work units and 16 * 1024 render/clip node visits. Work units account for
input/geometry visits, edge preparation, ordering and sample work; they are
not elapsed time. Exceeding either limit returns the existing TooLarge status.
The public ABI remains unchanged. The SVG scratch query adds bounded row
workspace, and all temporary row arrays are rewound together after each
paint. Detailed curves at icon output size use the advertised scratch alone;
the concrete 5,706-byte regression now succeeds with 1,197,312 scratch bytes
and the original pixel. The scratch query for maximum SVG pixel/source
counts stays below 48 MiB.

A native comparison checks 73 cases and all 360,448 output pixels against
the original renderer, including fill rules, clipping, strokes, curves and
fractional-alpha text. A 512-edge fill needs 1,904 counted edge geometry
checks instead of 100,933,632. Ordering comparisons are excluded from both
counts; no elapsed-time speed factor is claimed. The original nine SVG tests
are retained and included in the normal owner test step with one use/glyph
budget regression. Detailed originals: `ExFiles/Reports/Fable091/0.91.16/`.

The corrected normal build passes 28/28 steps and 24/24 tests, including the
C consumer and the detailed icon regression. The exact 0.3.9 provider is
read back from the actual normal benchmark image; all six browser modules
are absent.

The provisional 0.3.8 build and STANDARD run
1f581fd8-6b05-4649-8858-fea921a56092 are retained under
`Provisional-0.3.8/`. The final 0.3.9 STANDARD run,
522774e1-ea7f-411d-997a-0831db234711, passes local recomputation of all 30
samples, five metrics and six scores (overall 130.035032). Status: "lokal
validiert; R4OS Server ausstehend"; Claim, import, full GET readback and
independent server scoring remain. The new run qualifies the actual scratch
correction. System STANDARD does not measure SVG time alone.

R4IMG does not draw windows or own document state. Applications such as
Klickifax decode and scale resources, then pass completed raster data to
R4DRAW. SVG parsing, paths and optional nested image resources are bounded and
fail independently where the local contract allows it.

Contract, provider, Zig/C bindings, tests and decoder provenance are owned by
`Repositories/Libraries/R4IMG/`. The central platform API contains no R4IMG
group or decoder implementation.
