# Process, thread, VM and asynchronous-I/O resources

The SDK exposes owning wrappers over R4SYS resources. A successful create or
spawn transfers exactly one responsibility to the caller:

- a process handle is completed by wait/reap after optional close or kill;
- a join handle is consumed by join;
- a VM region is consumed by release;
- an asynchronous I/O request is closed after completion.

## Identity

Process and join identities include a generation. Copies may observe status,
but only the owner may perform the consuming operation. Reused registry slots
therefore do not make stale handles valid.

## Timeouts and buffers

A timed-out wait does not consume the resource. The caller may wait again or
cancel when the operation's contract supports it. Completion wins at the
timeout boundary when it is already observable.

Buffers supplied to asynchronous I/O remain valid until completion and
subsequent close. A request does not silently copy or detach a caller buffer
unless the generated operation contract explicitly says so.

## Failure

Invalid, stale, wrong-owner, already-consumed and unavailable-function states
are distinct. Cleanup is idempotent only where the public operation explicitly
defines it; callers must not rely on double-close as normal control flow.
