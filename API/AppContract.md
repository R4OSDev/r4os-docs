# R4OS application contract

`r4os.App` is the normal Zig entry surface; `R4App` is the matching C
surface. Both are immutable views over the same validated R4XStart context.
The canonical layouts and operations come from
`Repositories/Contract/API/ApiContract.json`.

## Profiles and groups

A module selects its app class and imports in `module.R4MF`. R4SYS is required
for a normal R4X. Desktop, drawing, network, audio and device groups are
requested only when needed. A facade is available only if its complete
minimum function set exists.

Typical Zig access:

```zig
var app = try r4os.App.init(start_context);
const console = app.console() orelse return r4os.abi.err_no_fn;
var files = app.files() orelse return r4os.abi.err_no_fn;
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

Implementations are in `Repositories/SDK/r4os/app_contract.zig` and the
matching C headers below `Repositories/SDK/Shared/C/`; generated Contract
conformance checks keep both languages aligned.
