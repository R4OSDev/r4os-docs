# Service and network facade

The SDK exposes owning lifecycle objects over R4SYS service endpoints and
R4NET network operations. It does not contain a second IPC or network stack.

## Services

A service connection owns open, call and close. A service endpoint owns
register, wait, receive, reply and unregister. Successful close/unregister
invalidates the wrapper. Payload and response buffers remain caller-owned for
the documented call duration.

### Desktop notification area

`app.tray()` in Zig and `r4_app_tray()` in C bind a client to its exact
program generation and expose status, upsert, remove and finite event-wait
operations as a logical tray contract multiplexed on the existing `WINSVC`
endpoint. WINSVC brokers copied state and events while the exact R4DESK
generation remains the sole owner of layout, rendering and input. Upsert
copies a bounded tooltip and an exact 16x16 straight-alpha ARGB32 icon into
one atomic request; the provider keeps no buffer ownership after the call.

Item IDs are stable only inside one owner generation and revisions must
increase when state changes. Responses expose the Desktop epoch, registry
revision, capacity and whether an item currently exists and is layout-visible.
An epoch change means that the provider must publish its current state again.
Primary, double, context and wheel events carry a per-owner monotonic sequence;
only one finite wait may be outstanding per owner. Providers must tolerate a
missing service, timeouts, bounded queue overflow and Desktop restart without
polling continuously. The facade uses the normal Userland service IPC and does
not add a platform-table function or a separate service process.

## DNS, TCP and UDP

Resolver, TCP socket/listener and UDP socket wrappers use DNSSVC, TCPSVC and
UDPSVC through R4NET. Connect, accept, read, write, close, timeout,
would-block and stale-handle states remain distinct. One absolute deadline is
shared across all phases of a bounded operation.

The paced TCP writer first submits the largest service-safe chunk (up to
4,068 bytes). Kernel TCP performs MSS segmentation and reports exact partial
progress. A service poll is requested only after a write returns no progress;
the SDK does not pre-poll every chunk. The optional R4NET
`tcp_performance` snapshot provides diagnostic counters without changing the
service message size or queue depth.

## Web and update services

The web facade composes the existing DNS/TCP, HTTP and TLS owners. The update
client uses UPDSVC and the shared update-service contract in
`Repositories/SDK/r4os/update_service_contract.zig`; all clients observe the
same durable job rather than starting private installers.

Zig and C wrappers share generated layouts and are validated by the SDK and
Contract conformance tests.
