R4OS Networking
===============

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
