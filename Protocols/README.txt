R4OS Protokollmodule
=====================

Rolle
-----

R4P-Projekte liegen unter Code/System/Protocols. Sie sind R4M0-Module,
exportieren den R4P-Vertrag und importieren R4DEV. Die Protocol Registry
fuehrt Rollen, Dependencies, Quelle, Status und Owner.

Aktuelle Rollen
---------------

Netzwerk:
  Ethernet, ARP, IPv4, ICMP, UDP, TCP, DHCP, DNS und Serial Link

USB:
  HID Boot, HID Report, Mass-Storage BOT und SCSI Block

Audio:
  MIDI, SID und OPL3

Sicherheit/Transport:
  R4AUTH und R4TLS

Formate:
  JSON (Rolle format.json) - liest und aendert JSON ohne Heap und ohne Baum.
  Damit verarbeitet ein Programm JSON, ohne selbst JSON zu koennen; der
  Parser liegt einmal im System statt als Kopie in jedem Binary. Fassade:
  Code/System/SDK/r4os/json.zig.
  R4HTML (Rolle application.html) - dekodiert HTML, ordnet den MIME-Typ zu,
  bestimmt den DOCTYPE-Dokumentmodus und baut einen begrenzten,
  dokumenteigenen DOM-Baum.
  R4CSS (Rolle text.css) - verarbeitet die benoetigte CSS-Kaskade und
  erzeugt responsive strukturelle Renderlisten.
  R4JS (Rolle application.javascript) - stellt den begrenzten
  ECMAScript-Parser, den kompakten Bytecodecompiler und die validierte
  Stack-VM samt Modulen, VM-verwurzeltem Mark-and-Sweep-GC, Event Loop und
  Promises bereit. Die getrennte SDK-Webruntime bindet DOM, Ereignisse,
  Timer, Fetch/XHR und Origin-Sicherheit an den Sprachkern; ihr Gastvertrag
  wird ueber R4JS-Operation 5 geprueft.

Weitere:
  Conformance, Smoke, Example und Negativfixtures

Programmsicht
-------------

R4DEV besitzt Protokollstatus und Dispatch. R4NET/R4AUDIO besitzen die
fachlichen Nutzfunktionen; fuer Netz und Audio ist das der normale Weg.

Ein Programm darf ein Protokollmodul auch direkt aufrufen. Dafuer gibt es
R4DEV-Slot 19:

    protocolDispatch(role_ptr, role_len, op, in_buffer, out_buffer) -> i32

Adressiert wird ueber die ROLLE aus r4p.role, nicht ueber den Modulnamen -
also net.ipv4, nicht NETIPV4. op waehlt die Operation des jeweiligen
Protokolls. ProtocolBuffer ist ein geliehener Zeiger plus Laenge; in_buffer
ist const, out_buffer wird beschrieben, und das Protokoll besitzt die Daten
nicht. Der Slot ist optional, Praesenz also mit hasFn pruefen; Status
liefert Slot 18 protocolStatus.

Der Satz "normale Programme laden keine zweite Protokollimplementierung"
betrifft die Implementierung, nicht den Aufruf: Ein Programm soll fuer eine
bereits vorhandene Rolle keine eigene Zweitimplementierung mitbringen, also
kein eigenes TCP neben NETTCP. Dispatchen darf es sehr wohl.

Dependencies
------------

Pflichtrollen muessen sichtbar aktiv sein. Fehlende, blockierte oder
inkompatible Dependencies werden als Status/Fehler gemeldet und nicht still
durch eine andere Implementierung ersetzt.

Abnahme
-------

    DevTools/Scripts/Build.bat -app NAME
    DevTools/Scripts/Build.bat -apps
    DevTools/Scripts/Build.bat -test
