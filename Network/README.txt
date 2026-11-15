R4OS Networking
===============

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
