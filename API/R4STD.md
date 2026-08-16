# R4STD Runtime-R4L

R4STD is an independent standard-library provider. It exports separate
versioned tables for text, settings, date, time and configuration. Consumers
import only the table they need, for example:

```text
R4STD:TEXT_V1:1
R4STD:CONFIG_V1:1
```

The library owns UTF-8/system-text handling, R4S parsing, date/time helpers,
settings views and atomic configuration-file updates. Operations that need
filesystem access receive the caller's start context and use R4SYS; they do
not create a second file implementation.

There is no R4STD platform group and no `app.standard()` facade. Zig and C
consumers initialize the library-local binding from the R4XStart context.

Contract, compatibility baseline, implementation, bindings and tests are
owned by `Repositories/Libraries/R4STD/`. Compatible library work remains
independent of Kernel, central Contract and core SDK changes.
