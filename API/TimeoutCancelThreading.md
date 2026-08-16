# Timeout, cancellation and threading contract

## Timeouts

The SDK distinguishes polling, a finite duration and unlimited waiting. A
finite timeout becomes one monotonic absolute deadline on entry. Repeated
phases use only the remaining budget; they do not restart it.

A wait observes an operation and does not consume it on timeout. When
completion is already observable at the boundary, completion wins.

## Cancellation and close

Cancellation is capability-specific. Some operations support cooperative
cancel, some can only close future admission and some cannot be cancelled
after dispatch. The generated operation contract states which class applies.
A cancel result never pretends that an already completed operation did not
complete.

Service stop and program close are lifecycle requests, not arbitrary thread
termination. A service cannot stop or restart itself through its own caller
tree.

## Threading

The initialized application/group bundle is immutable and may be shared where
the operation classification allows it. R4DESK and R4DRAW are
owner-thread-only. Asynchronous caller buffers remain valid until completion
and close. Internal locks never surround an application callback.

Threading and reentrancy classifications for individual operations are in
`OperationContracts.md` and are validated by Contract/SDK tests.
