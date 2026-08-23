R4OS Services
=============

Services are long-running R4X modules under `Repositories/Services/`. They
use the same R4XStart and SDK contracts as applications, but their manifest
class and service configuration define lifecycle and autostart behavior.

The kernel service core owns endpoint registration, queues and generic
lifecycle mechanisms. `SERVMAN.R4X` owns visible policy, configuration and
operator commands. Individual services own their protocol, session and
recovery logic.

Each endpoint has eight request slots. A synchronous call uses one absolute
deadline across slot admission and response completion. If all slots are
occupied, the central service core admits blocking callers in FIFO order;
explicitly nonblocking submission continues to return `busy` immediately.

Response completion is request-specific. A reply publishes the response and
wakes only the waiter for that request. Timeout, cancellation, endpoint
unregister and service stop close the affected request completion, and handle
plus request-ID validation prevents a reused slot from satisfying an older
caller. Services must use this central contract instead of implementing their
own polling, retry or admission loops.

A service communicates through R4SYS service endpoints and uses R4NET,
R4AUDIO, R4DESK or other public groups as required. It must not add a private
kernel path or a second filesystem/network implementation.

A service cannot stop or restart itself, directly or through one of its
console descendants. The kernel rejects that request to avoid destroying the
active caller tree.

Current services and image scopes are listed in
`Docs/Inventory/AllModules.json`.
