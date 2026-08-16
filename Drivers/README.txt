R4OS Treiber
=============

Rolle
-----

Ladbare Treiber sind R4D-Projekte unter Code/System/Driver. Sie sind R4M0-
Module, exportieren DriverInit/DriverShutdown und importieren R4DEV.

Aktuelle Projekte
-----------------

Storage:
  NVME, AHCI, ATAPIO, USBMSC

USB:
  XHCI

Netzwerk:
  RTL8139, RTL8168, VirtioNet

Audio/Synth:
  HDA, AC97, SID, MIDI, OPL3

Weitere:
  Example und gezielte Negativfixtures

Bootgrenze
----------

Was fuer Boot, C:, fruehe Ausgabe, Speicher, Interrupts oder Timer technisch
zwingend ist, bleibt built-in, bis ein sicherer Preload-/Fruehladepfad
existiert. Nicht bootkritische Built-ins werden nach echter R4D-Abnahme
entfernt.

Registry und Inventar
---------------------

Die Driver Registry fuehrt Name, Typ, Version, Quelle, Status und Owner.
R4DEV stellt Status/Details und Hardwareinventar fuer Programme bereit.
Optionale Felder werden mit hasFn geprueft.

Regeln
------

- Ein aktives R4D besitzt den produktiven Hardwarepfad.
- Keine stille parallele Built-in-Datenroute.
- Ressourcen, IRQs, DMA/MMIO und Completions werden technisch validiert.
- R4D enthaelt keine Benutzer-Sicherheitschecks.
- Treiberspezifische Policy bleibt im Treiber/Subsystem.

xHCI-Recovery
-------------

Seit 0.60.20 quiesziert die USBMSC-Recovery beide Bulk-Endpoints, bevor sie
den BOT-Class-Reset sendet. Ein Transfer-Timeout stoppt dazu einen noch
laufenden Endpoint mit STOP_ENDPOINT; ein durch Protokollfehler gehaltener
Endpoint wird mit RESET_ENDPOINT in Stopped ueberfuehrt. Erst danach darf
der BOT-Reset beziehungsweise ClearFeature(ENDPOINT_HALT) eine neue
Transportphase beginnen. So kann ein spaet abgeschlossenes WRITE-TD nicht
in die neue BOT-Sitzung hineinragen.

Stopped und Error duerfen gemaess xHCI direkt SET_TR_DEQUEUE_POINTER
ausfuehren; nur Disabled verlangt eine Endpoint-Neukonfiguration. Da der
Endpoint waehrend STOP/RESET asynchron seinen Zustand wechseln kann, liest
die Recovery bei Context State Error den DMA-eigenen Output-Kontext volatile
neu und wiederholt die Zustandsmaschine begrenzt.

SET_TR_DEQUEUE_POINTER setzt den Controller auf den aktuellen
Software-Producer samt DCS. Auch eine Neukonfiguration beginnt an diesem
Producer statt an Ringanfang/Cycle 1. Der Transfer-Ring wird nie auf TRB 0
zurueckgespult, weil alte Cycle-Bits sonst bereits konsumierte TDs erneut
publizieren koennten.

Dieselbe Endpoint-Zustandsmaschine gilt fuer EP0. Ein verlorenes oder
fehlgeschlagenes Control-TD wird vor dem naechsten Class-Request mit
STOP/RESET/SET_TR_DEQUEUE_POINTER quiesziert. Configure Endpoint darf einen
Bulk-, Interrupt- oder Control-Kontext erst wieder verwenden, wenn dessen
letzte Recovery eindeutig erfolgreich war. `configured` beschreibt deshalb
nur den xHC-Kontext, `faulted` separat einen nicht aufgeloesten
Recoveryzustand. Ein Fehler setzt nicht blind `configured=false`: Ein
ungeprueftes Add-Configure gegen einen moeglicherweise noch vorhandenen
Kontext waere selbst wieder undefiniert.

USBMSC uebernimmt Fehler aus jedem Recovery-Schritt und startet nach einem
Transportfehler keinen zweiten REQUEST-SENSE-Timeoutzug. Ein
idempotenter READ10, ein sektor- und bytegleicher WRITE10 sowie
SYNCHRONIZE CACHE werden nach vollstaendig erfolgreicher BOT-/Endpoint-
Recovery exakt einmal wiederholt. Die gesamte Folge aus Endpoint-Recovery,
BOT-Reset und beiden ClearFeature-Aufrufen teilt eine feste
Acht-Sekunden-Frist und bricht nach dem ersten fehlgeschlagenen Pflichtschritt
ab. Ein Commandfehler oder eine fehlgeschlagene Recovery erlaubt keinen
solchen Retry.

Bei Data-IN wird die tatsaechliche xHCI-Transferlaenge vor dem nachfolgenden
CSW-Wait gesichert und gegen die CSW-Residue geprueft. READ10 und WRITE10
gelten nur bei exakter Nutzdatenlaenge und Residue null als erfolgreich.
Ein Short Transfer darf damit keinen alten, nicht ueberschriebenen
Pufferrest als Sektordaten veroeffentlichen.

USBMSC kennzeichnet am Blockdevice, dass es diesen Transport-Retry selbst
besitzt. Der PageCache fuehrt fuer ein so gekennzeichnetes Backend weder
einen zusaetzlichen Writeback-Retry noch nach einem fehlgeschlagenen
Page-Fill einen zweiten direkten Read aus. Damit bleibt der Drahtvertrag bei
hoechstens dem Erstversuch plus genau einem USBMSC-Recovery-Versuch. Nur wenn
vor dem ersten Backend-I/O gar kein Cache-Frame bereitsteht, darf der
urspruengliche Read ungecached laufen. Die letzte teilweise Device-Seite
fordert ausserdem nur die physisch noch vorhandenen Sektoren an.

Runtime-Waits erhalten ueber scheduler.parkBlocked den exakten
Interruptzustand ihres Callers. Insbesondere darf Event.waitResult den
Storage-Worker nicht unbeabsichtigt mit IF=0 fortsetzen.

Synchrone xHCI-Waits verwenden vier getrennte Fristen: Die normale
Zwei-Sekunden-Tickdeadline bleibt der primaere Takt. Eine nach Moeglichkeit
aus CPUID kalibrierte TSC-Deadline mit konservativem Fallback beendet den Wait
auch bei ausbleibenden Timer-IRQs; ein grosszuegiger CPU-Iterationsguard
bleibt als unabhaengiger letzter Notausgang. Recovery-Kommandos beachten
zusaetzlich die gemeinsame Gesamtfrist. Die Timeoutdiagnose nennt den
ausloesenden Takt (`ticks`, `tsc`, `cpu-guard` oder `recovery-budget`) und
nimmt die verstrichenen Werte sowie xHC-Register vor der sichtbaren
Framebufferdiagnose auf.

Der erste Vorfall bleibt in einem festen RAM-Protokoll erhalten und wird
sofort auf COM1 und in den Bootlog gespiegelt. Die begrenzte
Framebuffer-Diagnose darf die Ursache nicht durch Folgefehler ueberschreiben;
ein spaeterer Crash rendert den gespeicherten Erstvorfall erneut. Der
allgemeine Deadman bleibt bewusst kooperativ und kann einen harten Spin mit
gesperrten Interrupts nicht praemptieren. Diese Fehlerklasse muss deshalb
durch die lokalen xHCI-Fristen beendet werden.

Dieser Abschnitt beschreibt den implementierten 0.60.20-Vertrag. Eine neue
Lenovo-Kalt-/Warmstart- und Grossschreibabnahme ist damit nicht vorweggenommen.

Abnahme
-------

    DevTools/Scripts/Build.bat -app NAME
    DevTools/Scripts/Build.bat -norun
    DevTools/Scripts/Build.bat -test
