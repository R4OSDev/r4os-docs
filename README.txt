R4OS Dokumentation
===================

Einstieg
--------

    Leitbild.txt
    Core/Architektur.txt
    Agents/R4M0-Container.txt
    Core/ProgramInstanceStorage.txt
    Core/DynamicProgramRegistry.txt
    Core/ProgramLifecycle.txt
    Core/DynamicTaskRegistry.txt
    Deployment/BuildUndTest.txt
    SupportedHardware.txt

Softwareentwicklung
-------------------

    SDK/README.txt
    SDK/CABI.txt
    SDK/ModuleManifestV2.md
    Agents/R4M0-Container.txt
    Applications/R4X.txt
    Applications/Anwendungsstruktur.md
    API/ArchitekturUndEinstieg.md
    API/APIArchitektur.svg
    API/Readme.txt
    API/AppEntry.md
    API/AppContract.md
    API/StorageFacade.md
    API/GuiFacade.md
    API/GuiShapeContract.txt
    API/ResourceObjects.md
    API/ServiceNetworkFacade.md
    API/AudioDeviceFacade.md
    API/OperationContracts.md
    API/PayloadTypes.md
    API/TextPfadZeitVertrag.md
    API/TimeoutCancelThreading.md
    API/R4SYS.md
    API/R4DESK.md
    API/R4DRAW.md
    API/R4NET.md
    API/R4AUDIO.md
    API/R4DEV.md
    API/R4STD.md
    API/R4IMG.md
    API/R4FONT.md

Zentrale Vertragsquelle
-----------------------

    ../Code/System/SDK/Contract/README.txt
    ../Code/System/SDK/Contract/ABI/R4M0.txt
    ../Code/System/SDK/Contract/ABI/R4XStart.txt
    ../Code/System/SDK/Contract/ABI/R4LQuery.txt
    ../Code/System/SDK/Contract/API/ApiContract.json
    ../Code/System/SDK/Contract/API/ApiContract.baseline.json
    ../Code/System/SDK/Contract/API/Groups.txt
    API/PayloadTypes.md
    API/OperationContracts.md
    API/AppEntry.md
    API/AppContract.md
    API/StorageFacade.md
    API/GuiFacade.md
    API/GuiShapeContract.txt
    API/ResourceObjects.md
    API/ServiceNetworkFacade.md
    API/AudioDeviceFacade.md
    API/TextPfadZeitVertrag.md
    API/TimeoutCancelThreading.md

Subsysteme
----------

    Applications/
    Audio/
    Desktop/
    Diagnostics/
    Drivers/
    FileSystem/
    Fonts/
    Network/
    Protocols/
    Services/
    Terminal/
    Tests/

Build und Test
--------------

Der normale lokale Abnahmelauf ist:

    DevTools/Scripts/Build.bat -norun

Der headless Smoke-Test ist:

    DevTools/Scripts/Build.bat -test

Details, Modi und Logs stehen in Deployment/BuildUndTest.txt.

Bestand
-------

Inventory/Docs.json fuehrt jede Datei unter Docs/ ausser den Changelogs mit
Beschreibung und Status. Wer ein Dokument anlegt, verschiebt oder entfernt,
pflegt den Eintrag mit.

Archive
-------

Versionierte Abschlussberichte und Changelogs/ dokumentieren historische
Staende. Sie sind keine aktuelle API- oder Build-Vertragsquelle. Aus den
Changelogs koennen Verweise auf inzwischen geloeschte Dokumente zeigen; sie
beschreiben den Stand ihrer Version und werden nicht nachgezogen.
