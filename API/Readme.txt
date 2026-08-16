R4OS API-Referenz
====================

Uebersicht
----------

Der bebilderte Einstieg fuer neue Entwickler steht in
ArchitekturUndEinstieg.md. Das responsive Schaubild kann auch direkt als
APIArchitektur.svg geoeffnet werden.

Die oeffentliche R4X-Schnittstelle besteht aus sechs Kernel-Gruppentabellen
sowie unabhaengigen Runtime-R4Ls mit jeweils eigener Funktionstabelle. R4STD,
R4IMG und R4FONT verwenden dieses Modell:

- R4SYS.md
- R4DESK.md
- R4DRAW.md
- R4NET.md
- R4AUDIO.md
- R4DEV.md
- R4STD.md
- R4IMG.md
- R4FONT.md
- AppContract.md
- AppEntry.md
- StorageFacade.md
- GuiFacade.md
- GuiShapeContract.txt
- ResourceObjects.md
- ServiceNetworkFacade.md
- AudioDeviceFacade.md
- TextPfadZeitVertrag.md
- TimeoutCancelThreading.md
- OperationContracts.md (generiert)
- PayloadTypes.md (generiert)
- ZigCParity.json (generiert)
- ArchitekturUndEinstieg.md (Einsteigertext und vollstaendige Textalternative)
- APIArchitektur.svg (deterministisch aus APIArchitektur.diagram.psd1)

R4STD.md, R4IMG.md und R4FONT.md beschreiben ihre lokalen Runtime-Vertraege
und verweisen auf die jeweils generierte API-Referenz. Die zentral generierten
Referenzen enthalten ausschliesslich die sechs Plattformgruppen.

Nutzung
-------

Ein normales Zig- oder C-Programm deklariert Gruppen in module.R4MF und
implementiert r4_app_main. Der SDK-eigene R4XStart-Startup validiert den
Kontext und uebergibt ein aufruflokales App-Objekt. Optionale Gruppen sind
sichtbar abwesend; optionale Funktionen werden konkret geprueft:

    if (ctx.hasFn("feld")) {
        // Feld ist vorhanden und Zeiger ungleich 0.
    }

Es gibt keine pauschale Freigabe einer Gruppe nur anhand ihrer Version.
Die Tabellen sind append-only; reservierte Slots bleiben physisch erhalten.
Eine kuerzere Tabelle kann ihre vorhandenen fruehen Felder weiter anbieten.
r4xstart.Context und program.Bundle sind Low-Level-ABI-Werkzeuge und kein
zweites Backend fuer normale Anwendungen. Sie sind bewusst unter
r4os.lowlevel gebuendelt.

Der App-, Fehler-, Handle- und Lifecycle-Vertrag steht in AppContract.md.
AppEntry.md beschreibt den produktiven Zig-/C-Einstieg und die
Profile console, desktop und service.
StorageFacade.md beschreibt die produktiven Console-, Datei-,
Verzeichnis-, Stream- und Registry-Sichten sowie die getrennte Einbindung von
R4STD fuer Zig und C.
GuiFacade.md beschreibt die produktiven Fenster-, Nachrichten-,
EventLoop-, Timer- und Zeichenablaeufe fuer Zig und C.
GuiShapeContract.txt beschreibt die nativen versionierten R4DRAW-Formdaten
und ihre Wiedergabe im gemeinsamen Frame-Ressourcenblob.
ResourceObjects.md beschreibt die produktiven ProcessHandle-,
JoinHandle-, VmRegion- und IoRequest-Lebenszyklen fuer Zig und C.
ServiceNetworkFacade.md beschreibt die produktiven Service-
Connection-/Endpoint- sowie DNS-, TCP- und UDP-Lebenszyklen fuer Zig und C.
AudioDeviceFacade.md beschreibt den AUDSVC-basierten PCM-
AudioStream, die getrennte SID-/MIDI-/OPL3-Advanced-Sicht und lesbare
R4DEV-Inventar-, Speicher- und Performance-Views.

Generierte Referenz
-------------------

ApiContract.json ist die einzige maschinenlesbare API-/ABI-Quelle.
ApiContractGen erzeugt daraus die Feldbereiche der sechs Gruppendokumente,
PayloadTypes.md, OperationContracts.md und ZigCParity.json sowie die
sprachspezifischen ABI- und Conformance-Dateien. Das kompakte
`Inventory/API.json` wird ebenfalls daraus erzeugt. Es fuehrt alle
aufrufbaren Public- und Advanced-Funktionen mit Gruppe, Slot beziehungsweise
SDK-only-Kennzeichnung, Beschreibung und stabilen Quellorten. Reservierte,
entfernte und interne Eintraege erscheinen dort nicht.

    Code/BuildTools/ApiContractGen/zig-out/bin/api-contract-gen.exe --write
    Code/BuildTools/ApiContractGen/zig-out/bin/api-contract-gen.exe --check

Die generierten Dateien und markierten Bereiche duerfen nicht von Hand
editiert werden. Handgeschriebene Texte erklaeren Konzepte und Arbeitsablaeufe;
Zahlen, Layouts und Operationslisten werden nicht als zweite Wahrheit
dupliziert. Auch die Funktionsbeschreibungen werden ausschliesslich in
ApiContract.json gepflegt. Der Generator weist generische Platzhaltertexte
zurueck, damit das Inventar eine brauchbare Kurzreferenz bleibt.

Fehler
------

SDK-Wrapper unterscheiden fehlende Gruppen oder Funktionen, konsumierte oder
fremde Ressourcen und noch gebundene I/O-Buffer. Die stabilen Namen, Rohcodes
und Statusdomaenen stehen ausschliesslich im maschinenlesbaren Contract und
in OperationContracts.md. Fachliche Fehler bleiben ihrer Gruppe zugeordnet.

Vertrag
-------

    Code/System/SDK/Contract/API/ApiContract.json
    Code/System/SDK/Contract/ABI/R4XStart.txt
    Code/System/SDK/Contract/API/Groups.txt
    Docs/API/PayloadTypes.md
    Docs/API/OperationContracts.md
    Docs/API/AppContract.md
    Docs/API/TextPfadZeitVertrag.md
    Docs/API/TimeoutCancelThreading.md
    Docs/API/ResourceObjects.md
    Docs/API/ServiceNetworkFacade.md
    Docs/API/AudioDeviceFacade.md
    Docs/API/ZigCParity.json
    Docs/SDK/README.txt

ApiContract.json ist die maschinenlesbare Quelle. Die Markdown-Dateien sind
lesbare Referenzen. ApiContract.baseline.json dient ausschliesslich der
internen append-only-Driftpruefung und bedeutet keinen API-Freeze.
PayloadTypes.md dokumentiert generiert Reachability, Layouts,
Pointer-/Buffervertraege, Fehler, Konstanten, Limits und die App-Profile der
zentralen Plattform. OperationContracts.md bildet alle Operationssemantiken und stabilen
Statusdomaenen ab. Zig-, Kernel- und C-Program-ABI, R4L-Identitaeten,
Contractlayouts, Referenztabellen und Conformance-Fixtures werden aus
demselben Schema erzeugt.
ZigCParity.json trennt Generator-/Fassadenvertrag von den wirklich
ausgefuehrten Cross-Language-Fixturefamilien.
Der handgeschriebene TextPfadZeitVertrag.md erklaert die zentralisierten
Text-, Pfad- und Zeittypen, ohne ihre numerischen Werte zu duplizieren.
TimeoutCancelThreading.md beschreibt Tagged Timeouts, absolute Deadlines,
ehrliche Cancel-Klassen, Completion-wins, StopFlag und Thread-/GUI-Regeln.
abi.zig, r4x_api.zig und die C-Header bleiben stabile Fassaden.
