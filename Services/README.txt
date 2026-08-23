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

Request and response payload storage is reused without clearing the complete
4-KB arrays. `request_len` and `response_len` are the sole publication
boundaries: submit, receive, reply and take copy only that many bytes. Slot
reclamation resets IDs, lengths, status and request-specific synchronization;
endpoint retirement first wakes all waiters and then resets only endpoint,
queue and semaphore metadata. Bytes beyond a published length are never
returned, including after a shorter request reuses a formerly full slot.

The append-only performance snapshot reports lifetime service payload copy
bytes, payload clear bytes, slot metadata resets, endpoint metadata resets and
endpoint payload-reset bytes. Normal operation keeps both payload-clear
counters at zero while the metadata-reset counters prove that slot and
endpoint reuse actually occurred.

A service communicates through R4SYS service endpoints and uses R4NET,
R4AUDIO, R4DESK or other public groups as required. It must not add a private
kernel path or a second filesystem/network implementation.

A service cannot stop or restart itself, directly or through one of its
console descendants. The kernel rejects that request to avoid destroying the
active caller tree.

Current services and image scopes are listed in
`Docs/Inventory/AllModules.json`.
