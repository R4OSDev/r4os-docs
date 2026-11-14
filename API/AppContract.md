# R4OS application contract

`r4os.App2` (also exposed through the current `r4os.App` alias) and
`R4App2` are the normal Zig and C entry surfaces. The SDK validates the
`R4XStartContext2` before calling `r4_app_main`. A C application may create
the explicit borrowed `R4App` facade with `r4_app2_facade`; it is a view over
that current context. App objects and their borrowed facades keep their
documented entry, move and callback lifetimes. The canonical layouts and
operations come from `Repositories/Contract/API/ApiContract.json` and
`API/Generation2.json`.

## Profiles and groups

A module selects its app class and imports in `module.R4MF`. R4SYS is required
for a normal R4X. Desktop, drawing, network, audio and device groups are
requested only when needed. A facade is available only if its complete
minimum function set exists. These six groups are built-in Kernel providers;
they are not Runtime-R4L files or independently installed components.

Typical Zig access:

```zig
const r4os = @import("r4os");
pub fn r4_app_main(app: *r4os.App2) i32 {
    app.system().println("Hello R4OS");
    return 0;
}
```

## Errors and optionality

Platform-resolution errors are distinct from domain errors. A missing group
is `err_no_group`; a missing table field is `err_no_fn`. Filesystem, network,
service and audio operations retain their own typed result domains.
Applications must not reinterpret an unavailable function as success.

## Handles and resources

Process identities and join handles include a generation so reuse cannot make
a stale handle valid. Owned process, thread, VM and asynchronous-I/O objects
have one consuming completion operation. Observers may read status but do not
gain ownership or reap rights.

Independent Runtime-R4Ls are initialized from `app.startContext()`. They are
not platform groups and do not appear as additional fields on `App`.

Implementations are in `Repositories/SDK/r4os/app2.zig` and `app_contract.zig` and the
matching C headers below `Repositories/SDK/Shared/C/`; generated Contract
conformance checks keep both languages aligned.
