# Service and network facade

The SDK exposes owning lifecycle objects over R4SYS service endpoints and
R4NET network operations. It does not contain a second IPC or network stack.

## Services

A service connection owns open, call and close. A service endpoint owns
register, wait, receive, reply and unregister. Successful close/unregister
invalidates the wrapper. Payload and response buffers remain caller-owned for
the documented call duration.

## DNS, TCP and UDP

Resolver, TCP socket/listener and UDP socket wrappers use DNSSVC, TCPSVC and
UDPSVC through R4NET. Connect, accept, read, write, close, timeout,
would-block and stale-handle states remain distinct. One absolute deadline is
shared across all phases of a bounded operation.

## Web and update services

The web facade composes the existing DNS/TCP, HTTP and TLS owners. The update
client uses UPDSVC and the shared update-service contract in
`Repositories/SDK/r4os/update_service_contract.zig`; all clients observe the
same durable job rather than starting private installers.

Zig and C wrappers share generated layouts and are validated by the SDK and
Contract conformance tests.
