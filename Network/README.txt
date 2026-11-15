R4OS Networking
===============

0.91.10: Caller-retained receive operations
------------------------------------------

Kernel0.1.482 reuses the EtherType reported by Ethernet HANDLE_RX. ARP reply
construction also reuses that accepted classification; both private callers
retain their exact input bytes. IPv4 and UDP decode into operations retained
by the receive activation, whose bounded payloads are consumed before those
operations leave scope. App/UDP queues still copy and own their messages.
Legacy private C owned-message records and TX copies, public Query2 tables,
R4P wire layouts and protocol module versions remain unchanged.

ICMP protocol gating was fixed in0.91.9; UDP already rejected non-UDP before
constructing an operation. These original subclaims are no longer pending.
Fixed-array operations remain fully initialized: uninitialized u8 tails are
not a valid substitute for the existing wire contract. A future borrowed
module-input ABI is outside this bounded optimization.

The same temporary fixed transfer drains32768 accepted UDP messages of1024
bytes each, checks exact payload/metadata, and counts reader dispatches and
explicit kernel staging/owned-message payload copies. Per packet:4->3
reader dispatches and6286->3164 counted bytes. Single instrumented A/B times:
624->514ms for32MB. One caller runs in KVM4; operation moves, zeroing,
provider-internal and asynchronous queue/caller copies are outside this
counter. This is no uninstrumented or physical-NIC throughput claim.

The normal uninstrumented ELF passes original CORPUS27 and full R4P8/8 on
KVM4/RTL8139, original NETIOD including independent typed UDP echo,
NETR4P /SELFTEST, actual DHCP binding, ICMP3/3 and an independent fixed DNS
A-answer. HTTPGET downloads an exact4096-byte binary, read back through
SFTP and checked against the independent host SHA256. Its8192-byte total
response limit is retained; the oversized64KB fixture is preserved as a
correct rejection. Two new queued UDP cases overwrite decoder inputs before
draining; the other25 corpus assertions remain byte-identical. Full apps
are explicitly uploaded temporarily to the private Test guest; its normal
profile does not install them. Ordinary external shell redirection is
intentionally rejected, so command results use normal SSH launch I/O.

All source/ELF bindings, original exports, peer bytes, host-fixture failures
(redirection, inactive Virtio, executable resolution and missing Full apps),
shutdown and immutable-source readback: ExFiles/Reports/Fable091/0.91.10/.
No physical-NIC or frozen Recovery optimization is claimed.

Finaler STANDARD a998e28d-dfb7-4dfc-bdce-df5984ae9493 / Kernel0.1.482 /
KVM4:30 Rohsamples, fuenf metric-v2-Werte und sechs Scores vollstaendig gegen
die feste Originalreferenz nachgerechnet; Gesamtindex130.155056. Status:
lokal validiert; R4OS Server ausstehend. Rest: Claim, Import, voller GET-
Readback und unabhaengige Serverauswertung. Normaler Gesamtsystemlauf;
der separate instrumentierte Empfangsvergleich ist keine STANDARD-Metrik.

0.91.9: Final STANDARD
----------------------

Finaler STANDARD e2d044cf-dff5-475b-acbd-4a1f450c1125 / Kernel0.1.481 / KVM4:30 Rohsamples, fuenf metric-v2-Werte und sechs Scores vollstaendig gegen die feste Originalreferenz nachgerechnet. Status: lokal validiert; R4OS Server ausstehend. Rest: Claim, Import, voller GET-Readback und unabhaengige Serverauswertung. Er misst das normale Gesamtsystem, keinen isolierten Netzwerkgewinn.

0.91.9: IPv4 Echo admission
--------------------------

Kernel0.1.481 and Recovery Kernel0.1.74 use the already protocol-gated ICMP
RX result for Echo replies. Only IPv4 protocol1 can request a reply. The
second payload-only classification and copy are removed from receive;
the normal kernel retains its explicit internal payload-inspection entry. NetIcmp and all public API/ABI records remain unchanged.

The existing SPECTRA CHECK NETWORK CORPUS retains its21 original cases and
adds four real receive-pipeline cases: UDP from source2048 with a valid ICMP
checksum, valid TCP with the same ambiguity, another IPv4 protocol and a true
Echo Request with exact reply bytes/checksums. ICMP RX/classify/build counters
must stay unchanged for other protocols. The original unfixed Rust fixture
fails on UDP; the corrected same fixture passes25 cases and then the original
full8/8 R4P check. The initial1/8 R4P observation is preserved: protocols load
on demand, and the failing old corpus stops before DHCP/DNS. This is no claim
that the initial full-R4P check passes. Controlled KVM4/NTFS readbacks, exact
ELFs and all results: ExFiles/Reports/Fable091/0.91.9/.

R4NET is the public application view. The kernel owns the common adapter,
packet, IPv4, UDP/TCP and timing mechanisms. Loadable R4D drivers connect
hardware, R4P modules implement protocol roles, and R4X services own
long-running DNS, DHCP, TCP, UDP, SSH, FTP, RDP and update workflows.

Applications request R4NET in `module.R4MF` and use the SDK network facade.
Missing services, protocol dependencies or optional table functions remain
visible errors; no private application stack is used as a fallback.

Current drivers, protocols, services and diagnostic tools are listed in
`Docs/Inventory/AllModules.json`. Browser capabilities are tracked in
`Docs/Inventory/Browser.json`.

Security
--------

R4OS has no hardened user or permission model. Services may use the standard
credentials `r4os` / `rosebud`. Never expose R4OS service ports to the public
Internet or an untrusted network.
