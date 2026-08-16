R4OS Netzwerk
==============

Architektur
-----------

R4NET ist die oeffentliche Programmsicht. Der Kernel enthaelt Adapter-,
ARP-, IPv4-, UDP-/TCP-Grundlage und notwendige Timing-/Transportbausteine.
R4P-Module besitzen Protokollrollen. R4X-Services besitzen dauerhafte
DHCP-, DNS-, TCP-, UDP-, SSH-, FTP-, RDP- und Serial-Link-Funktionen.
Seit 0.55.35 ist diese offene Abnahme als Gate-Audit festgehalten: Interne
RDPSVC-Harness-Erfolge ersetzen keine echte manuelle Windows-mstsc-Sichtprobe.

Gruppenfelder
-------------

R4NET besitzt Adapter-/Konfigurationsstatus, Socket-/UDP-/TCP-Operationen,
DNS, DHCP, ICMP, Netz-Service-Status, Serial Link und Diagnose. Programme
deklarieren R4NET in module.R4MF und pruefen optionale Felder mit hasFn.

Treiber und Protokolle
----------------------

Netzwerkhardware wird ueber R4D wie RTL8139, RTL8168 oder VirtioNet betrieben.
RTL8168.R4D bindet seit 0.59.5 Realtek 10EC:8168 per MMIO und Descriptor-DMA
an den gemeinsamen Adapter-/Net-Core an. Erstes reales Ziel ist
17AA:38C7/Revision 10. Der Lenovo-Laptop hat mit 0.59.5 Link und DHCP erreicht;
Ping und SSH ueber 192.168.178.213 bestaetigen realen ICMP-/TCP-Traffic.
RTL8139 bleibt fuer QEMU und aeltere Hardware im
Produktionsimage und in der unveraenderten Testkonfiguration erhalten.
Ethernet, ARP, IPv4, ICMP, UDP, TCP, DHCP, DNS und Serial-Link-Rollen werden
ueber R4P registriert. Dependencies muessen sichtbar erfuellt sein; ein
fehlendes Pflichtmodul wird nicht still ersetzt.

RDPSVC kuendigt seit 0.59.6 die tatsaechliche R4DESK-Remote-Frame-Geometrie
als Sitzungsdesktop an. Der Bitmappfad ist nicht mehr auf 1280 Pixel begrenzt,
liest auch im Kompatibilitaetspfad nur 256-Pixel-Kacheln und behaelt fuer
krumme Breiten durch RLE16 plus gepaddeten RGB565-Rest eine einheitliche
16-bpp-Sitzung. Geometrie und `nonblack`-Inhaltsmetrik werden sofort nach
LOGSVC geschrieben und sind per LOGCENTER `/RDPTRACE` abrufbar.
Die reale Lenovo-Abnahme ist abgeschlossen: Ein minimales R4U-Update hob den
laufenden Laptop von 0.59.5 auf 0.59.6, der anschliessende Kaltstart hielt
Ping/SSH und Port 3389 bereit, und Windows mstsc zeigte den 1920x1080-Desktop
korrekt statt des vorherigen Schwarzbilds.

Seit 0.59.13 besitzt DHCP einen dauerhaften `dhcp-link`-Task statt eines
einmaligen synchronen Bootversuchs. Wunschmodus und aktive Lease sind getrennt;
vor einem echten ACK bleiben Adresse, Gateway und DNS im DHCP-Modus Null. Der
Koordinator wartet auf Adapter und Carrier, serialisiert genau eine Operation,
retryt mit gedeckeltem Backoff und behandelt Linkverlust, Renew, Rebind und
Leaseablauf generationstreu. VIRTNET handelt `VIRTIO_NET_F_STATUS` aus, sodass
QMP-`set_link` und reale Carrierwechsel den gemeinsamen Adapterstatus erreichen.

Die reale 0.59.15-LAN-Abnahme schloss zwei von QEMU-Usernet verdeckte
Hardwarepfade. Unbekannte EtherTypes wie IPv6 oder LLDP werden nach der
Ethernet-Klassifikation nicht mehr in einem Rohpaketpool ohne Verbraucher
festgehalten; normale LAN-Broadcasts koennen den 16er-Diagnosepool daher nicht
mehr dauerhaft fuellen. Vor einem Soft-Reboot wird ausserdem der aktive
Netzwerk-R4D geordnet stillgelegt, damit ein ACPI-Warmreset keinen laufenden
RTL8168-DMA-Ring an den naechsten Kernel vererbt.

R4DEV/LOGSVC, DHCP, DeviceManager und DHCPSVC zeigen Zustand, Linkgeneration,
Retryrunde, Wunschmodus, Task/Link, Leasequelle und Adressen. Der QMP-Quick-
Lauf prueft down/up/down/up, zwei Bindgenerationen, Ping, NETIOD und NETDIAG;
OfferDrop, AckDrop und Full bleiben optional. Die reale FritzBox-Nachprobe
erfolgt weiterhin erst in 0.59.15.

Services
--------

Dauerhafte Server-/Clientablaeufe laufen ueber die jeweiligen R4X-Services
und R4SYS-Service-Endpunkte. Fachliche Timeouts und Resultcodes bleiben beim
Netzwerk-/Servicevertrag.

Diagnose
--------

NETDIAG, NETR4P, NETIOD, IPCONFIG, PING, DNSLOOKUP, DHCP, NETCAT, SEND und
RECV nutzen aktuelle R4NET-/R4DEV-Felder.

Build und Test
--------------

    DevTools/Scripts/Build.bat -app NetDiag
    Tests/Gate/Run-DhcpLinkRetryContract05913.ps1
    Tests/Runtime/Run-DhcpLinkRetry05913.ps1 -Tier Quick -ImageOnly
    DevTools/Scripts/Build.bat -norun
    DevTools/Scripts/Build.bat -test

Erweiterte Connectivity-Tests stehen unter
Tests/Runtime/Run-ConnectivitySuite05515.ps1.
Seit 0.55.46 umfasst die Suite ausserdem den statischen und optionalen
Live-Stresstest fuer parallele SSH-, FTP- und RDP-Verbindungen. Der Runner
liegt unter Tests/Runtime/Run-ConnectivityStress05546.ps1.
