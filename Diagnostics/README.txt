R4OS Diagnostics
================

Diagnoseprogramme sind R4X-Projekte unter Code/System/Diagnostics. Sie
verwenden R4XStart und die in module.R4MF deklarierten Gruppen.

Gruppenzuordnung
----------------

R4SYS
  Console, Dateien, Programme, Services, Tasks, Threads, Zeit und VM.

R4DESK/R4DRAW
  Display-, Eingabe-, Fenster- und Rasterdiagnose.

R4NET
  Netzwerk-, Service-, Socket- und Protokolldiagnose.

R4AUDIO
  Stream-, PCM-, MIDI-, SID- und OPL3-Diagnose.

R4DEV
  Hardware, Treiber, Protokolle, Boot, Performance und Inventar.

R4STD
  Librarylokale TEXT_V1-, SETTINGS_V1-, DATE_V1-, TIME_V1- und
  CONFIG_V1-Interfaces.

Programme
---------

    BOOTDIAG   Bootkern, BootInfo und Loader
    LOADERD    R4M0, R4L und Imports
    RESDIAG    R4M0-Ressourcenbereich: liest Icons, Helpfile und benannte
               Dateien aus Modulcontainern und vergleicht sie byteweise mit
               den Bauquellen; prueft ausserdem die Fehlerfaelle (unbekannter
               Name, zu kleiner Buffer, Modul ohne Ressourcen, Nicht-Modul)
               und den eigenen Modulpfad
    R4XSTARTD  Zig-R4XStart-Smoke
    CSTARTD    C-R4XStart-Smoke
    FSDIAG     Dateisystem und Streaming
    NTFSDIAG   Read-only-NTFS-Datenvolume; prueft seit 0.60.4 das Windows-
               Fixture-Volume (Pattern-/Fragment-/Sparse-Dateien, B+Baum-
               Verzeichnis, lange Namen, sichtbare Kompressions- und
               Schreibablehnung) durch den kompletten VFS-/NTFS-Kernelpfad.
    STORDIAG   Storage und Block-I/O
    MEMSUITE   VM, Reclaim und Pressure; Cleanup-Bilanzen sind an die exakte
               MEMSUITE-Owner-ID gebunden. Pressure validiert den kombinierten
               FS-Cache-/VM-Reclaimvertrag, Pagerproben die konkrete Region.
    PERFDIAG   Performance und Latenzen
    DRVDIAG    Treiber und Workqueue
    NETDIAG    Netzwerkvertrag; seit 0.59.13 scoped Cleanup gegen die konkrete
               UDP-/TCP-Listenerbaseline statt gegen einen leeren Bestand.
    NETIOD     R4NET-/TCPSVC-I/O-Vertrag mit vollem Service-Payload.
    AUDIOD     AUDSVC-AudioStream und PerformanceView
    USBDIAG    USB; `/READSTRESS PATH [PASSES]` liest eine Datei ohne
               Schreibzugriffe 1 bis 64 Mal vollstaendig in kleinen Chunks
               (Default: 8) und meldet Bytes sowie Checksumme je Durchlauf.
    HWDIAG     Hardwarebericht ueber DeviceInventoryView
    THREADD    Threads; der kurze Pfad nutzt explizite volatile
               Worker-Uebergaben. `/DYNAMICTASKS` prueft seit 0.59.10 160
               gleichzeitig lebende ProgramThreads und 10.000
               Create/Reap-Zyklen.
    SIMDD      SIMD/FPU-State; `/DYNAMICTASKS` prueft zwei nacheinander
               vollstaendig gejointe/reapte Wellen aus je 64 AVX2-Workern
               plus Main-Task ueber 400 Isolationsrunden.
    ASYNIOD    Asynchrone I/O-Requests und Buffer-Lebensdauer; der normale
               Lauf erzeugt, wartet und schliesst seit 0.59.10 512 echte
               Worker-Tasks und meldet deren vollstaendigen Retire-Churn.
               `/RETIRERETRY` bindet 65 erzwungene Retire-BUSYs an
               `C:\TEMP\ASYNIOR.TXT` und verlangt den Reaper-Abschluss.
    APPHEAPD   VM-Regionen und SDK-Allocator
    CLEANUPD   Prozess-/Speicher-Cleanup und Ressourcen-Slot-Stress;
               `/PROGRAMSTORAGE` prueft seit 0.59.7 Console-/GUI-/Service-
               Payloads, Exit/Close/Kill, Fehlerinjektion und Churn.
               `/PROGRAMINVENTORY` haelt seit 0.59.11 80 reale Kinder,
               prueft paginierte Program-/Task-/Thread-Sichten, eine
               Mutation nach Snapshot-Beginn und die warme Baseline.
               Seit 0.59.15 bleibt diese Baseline unter produktiver SSH-/RDP-
               und Servicelast owner-exakt, ohne fluechtige running/ready/
               blocked-Schedulerverteilung als Ressourcenleck zu werten.
               `/DYNAMICSTRESS` waermt seit 0.59.12 alle dynamischen Pfade,
               haelt 128 gemischte Rootprogramme sowie 26 Kindprogramme und
               26 Zusatzthreads, injiziert Program-/Task-Admission-OOMs,
               faehrt in Quick 1.000, in Full 10.000 reale Lebenszyklen und
               verlangt exakte ownergetaggte Task-/Thread-Identitaeten sowie
               exakte Program-/Completion-/Live-Set-/Storage-/Ownerressourcen
               bei eng begrenzter globaler Adminworker-Huelle.
    CNETD      C-Referenz fuer DNS-, TCP- und UDP-Fassade
    DISPLAYD   Display

DHCP-Linkdiagnose 0.59.13
------------------------

`DHCP05913` enthaelt Zustand, Link-/Operationsgeneration, Retryrunde,
Leasequelle, IP, Maske, Gateway, DNS und Fehler. DHCPSVC transportiert
`runtime_state` sowie desired/task/link/retry im bestehenden Payloadlayout.
Der Quick-Runner verlangt zwei Bound-Generationen, `dhcp/running/up`, Ping,
`NETIOD result: OK`, `NETDIAG selftest: ok` und `System poweroff.`.
Seit der 0.59.15-Hardwarehaertung nimmt der Client Antworten nur in einem
aktiven, serialisierten Antwortfenster an. BOOTREPLY-Typ, XID, Client-MAC und
erwartete Offer- beziehungsweise Ack/Nak-Phase muessen uebereinstimmen;
Broadcasts fremder DHCP-Clients koennen Lease und Netzkonfiguration nicht
mehr veraendern. Inaktive, fremde und phasenfalsche Antworten werden getrennt
gezaehlt. Schlaegt das einmalige Erzeugen des DHCP-Koordinatortasks beim Boot
fehl, wiederholt der bereits laufende NET-RX-Task den Start gedeckelt.

Regeln
------

- Der LOGCENTER-Selftest schreibt seit 0.59.15 unmittelbar vor seiner
  Mehrquellenabfrage je einen frischen Record pro Quelle. Damit bleibt die
  Abnahme auch nach produktivem Ring-Wrap aussagekraeftig; alte Boot-, Treiber-
  oder Dateirecords muessen nicht zufaellig noch unter den letzten 512 liegen.

- Optionale Felder werden mit hasFn geprueft.
- Diagnostics setzen keine produktive Policy.
- Ein Resultat besitzt eindeutige OK/FAILED-Marker.
- C- und Zig-Smokes pruefen denselben R4XStart-Vertrag.
- Fachliche Fehler werden nicht mit fehlender Gruppe/Funktion vermischt.
- AUDIOD und HWDIAG verwenden die normalen Audio-/R4DEV-Sichten; neue
  Diagnosepayload-Kopien sind kein Ersatz fuer die zentrale ABI.
- R4DEV v2 (248-Byte-Gruppentabelle) stellte fuer den 0.59.7-Instanzspeicher
  die optionalen Funktionen
  `program_instance_storage_summary` und
  `program_instance_storage_self_test` bereit. Aufrufer pruefen `hasFn`;
  `ProgramStatus` und `ProgramInstanceInfo` bleiben unveraenderte
  fixed-layout Inventartypen.
- R4DEV v3 brachte fuer 0.59.8 append-only die Registry-Slots 29/30.
  `program_registry_summary` und der explizit bootoption-gebundene
  `program_registry_self_test` melden Chunk-/Slotzustand, stabile Live-Set-
  Hashes und genau einen ruecksetzbaren Growth-OOM.
- Seit 0.59.9 liefert R4DEV v4 die volle Lifecycle-Sicht append-only ueber
  `program_registry_summary_v2` und `program_registry_self_test_v2`. Die
  alten v3-Slots 29/30 und ihre v1-Payloads bleiben bei exakt 160/64 Byte;
  `CLEANUPD /PROGRAMLIFECYCLE` prueft beide mit nachgestellten Canaries. Die
  V2-Sicht ergaenzt generationensichere Handle-/Completion-, Retire- und
  Historyzaehler. Die
  zusaetzlichen R4DEV-Operationen fuer phasenweise One-shot-Fehler, Reaper-
  Signal und deterministische naechste ID verlangen getrennt
  `OPTION PROGRAMLIFECYCLE selftest=yes`; sie sind keine Produktionspolicy.
- Seit 0.59.10 aktiviert `OPTION TASKREGISTRY selftest=yes` den gebundenen
  Kernel-Selftest der dynamischen Taskgrundlage. Er prueft mindestens 128
  gemischte Tasks, drei Prioritaeten, Wait/Timeout/Cancel/Kill, 10.000 Churns
  bis zur Task-/Heap-/PMM-/VM-/FPU-Baseline sowie einen gezielt injizierten
  `task_metadata`-Admissionfehler mit Fortschritt ueber die technische
  Viererreserve. Der Netzwerk-Canary wartet hoechstens 64 echte Ein-Tick-
  Intervalle. Die Option ist ausschliesslich eine explizite Testpolicy. Der
  normale Boot fuehrt diese Last nicht aus.
- Seit 0.59.11 ergaenzt R4DEV v4 append-only Slot 33
  `execution_inventory_summary`. `ProgramInventorySummary` meldet die
  Registryepochen, Program-/Completion-/Task-/Threadzaehler, laufende
  Zustaende, Spitzenwerte sowie getrennte Program-/Task-/Thread-Admission-
  und Rollbackfehler. CLEANUPD vergleicht alle gemeinsamen Epochen-, Zaehler-,
  Peak- und Fehlerfelder mit der beim R4SYS-Inventarbeginn gelieferten
  Zusammenfassung. Die `snapshot_generation` bleibt bewusst an die jeweilige
  R4SYS- beziehungsweise R4DEV-Anfrage gebunden und wird nicht gleichgesetzt.
- `CLEANUPD /PROGRAMINVENTORY` verwendet absichtlich Siebenerseiten und
  verlangt alle Kinder an den Grenzen 15/16/17, 31/32/33 und 63/64/65. Nach
  einem zusaetzlichen 81. Kind muss der vor dessen Start erzeugte Cursor
  `RESTART`, null Eintraege und eine unveraenderte Position liefern. Erst ein
  neuer Cursor darf anschliessend alle drei Objektarten vollstaendig lesen;
  weitere legitime Epochenwechsel verwerfen erneut den gesamten Teilstand.
  Nach Close/Wait/Reap muessen Programme, Tasks, Threads und Completions zur
  warmen Baseline zurueckkehren.
- `CLEANUPD /DYNAMICSTRESS` ist an `OPTION EXECUTIONSTRESS selftest=yes`
  gebunden. Seine 128 Rootprogramme verteilen sich auf Console-, GUI- und
  Serviceklassen; 26 davon starten ein Kindprogramm, weitere 26 halten einen
  Zusatzthread. Der Gleichzeitigkeitsmarker muss deshalb exakt 154 Programme
  sowie 180 programmgebundene Tasks und Threads melden. 128 ist eine
  Abnahmeuntergrenze und keine Produktkapazitaet. Nach der gleichzeitigen Welle
  muessen Close/Kill, Wait und Reap abgeschlossen sein. Ein kontrollierter
  Program-Growth-OOM und ein Task-Admission-OOM duerfen keinen halben Start
  publizieren oder das Live-Set veraendern; ein normaler Folgestart muss jeweils
  wieder gelingen. Danach pruefen Quick mit 1.000 beziehungsweise Full mit
  10.000 echten gemischten Thread- und Programzyklen Spawn, Exit, Kill, Wait
  und Reap; die stummen Churn-Kinder erzeugen dabei keine kuenstliche
  SSH-Ausgabelast.

      CLEANUPD dynamicstress concurrency programs=154 ownedTasks=180 threads=180 roots=128 inventory=complete

- Fuer die 0.59.12-Baseline enthaelt `ProgramInventorySummary` die globalen
  Messfelder `heap_active_blocks` und `heap_used_bytes`. CLEANUPD vergleicht
  Programme, Completions, Live-Set, Storage und die Ressourcen des
  Stressowners exakt. Anzahl und generationstreue Identitaet der
  ownergetaggten Tasks und Threads werden getrennt gehasht und muessen exakt
  zur warmen Ausgangslage passen. Die Registry muss bis
  `chunk_count == warm_chunks` schrumpfen. Nur hoechstens acht ownerlose
  Admin-Tasks, 512 KiB globale Heapabweichung, 640 KiB globale
  Speicherabweichung und hoechstens zwei produktive Service-VM-Ranges mit
  zusammen 128 KiB sind zulaessig. Programmbilder und App-Stacks bleiben auch
  in dieser Huelle exakt. Die Grenzen gelten nur fuer Mehrverbrauch;
  Registry-Shrink und Stackcache-Retirement duerfen Speicher freigeben. Die
  Felder sind keine Slotgrenze und keine per-Owner-Speicherabrechnung.

      CLEANUPD dynamicstress baseline program=exact task=owner-tagged-exact thread=owner-tagged-exact completion=exact ownerResources=exact storage=exact registry=warm heap=bounded512K memory=bounded640K serviceVm=bounded128K adminTasks=bounded8 waiter=covered
- Verbindliche 0.59.10-Erfolgsmarker sind:

      TASKREG05910 concurrency live=(12[8-9]|1[3-9][0-9]|[2-9][0-9]{2,}) runnable=[1-9][0-9]* blocked=[1-9][0-9]* priorities=3 wait=OK stable=OK
      TASKREG05910 churn=10000 task=baseline heap=baseline pmm=baseline vm=baseline fpu=baseline
      TASKREG05910 admission fault=task_metadata normal=REJECTED critical=OK reserve=returned netrx=progress caller=alive recovery=OK
      TASKREG05910 result: OK
      ASYNCIO05910 retire retry: injected request=[1-9][0-9]* attempts=65
      ASYNCIO05910 sync close: deferred request=[1-9][0-9]* retries=64
      ASYNCIO05910 retire retry: recovered request=[1-9][0-9]*
      ASYNIOD retire retry: OK
      THREADD dynamic concurrency live=160 runnable=[1-9][0-9]* blocked=[0-9]+ stable=OK
      THREADD dynamic warm joined=160 postJoinGone=160 baseline=captured
      THREADD dynamic baseline task=([0-9]+)/\1 fpu=([0-9]+)/\2 fpuInitDelta=[1-9][0-9]* fpuBytesDelta=[1-9][0-9]*
      THREADD dynamic memory instanceReserved=([0-9]+)/\1 instanceCommitted=([0-9]+)/\2 instanceResident=([0-9]+)/\3 stackReserved=([0-9]+)/\4 stackCommitted=([0-9]+)/\5 exact=OK
      THREADD dynamic memory global appStack=[0-9]+/[0-9]+ r4xOwner=[0-9]+/[0-9]+ blocks=[0-9]+/[0-9]+ physical=[0-9]+/[0-9]+ reserved=[0-9]+/[0-9]+ committed=[0-9]+/[0-9]+ drift=bounded
      THREADD dynamic churn=10000 createReap=OK postJoinGone=10000 baseline=OK
      THREADD dynamic result: OK
      SIMDD dynamic wave=0 joined=64 reaped=64 freshInit=OK isolation=OK
      SIMDD dynamic wave=1 joined=64 reaped=64 freshInit=OK isolation=OK
      SIMDD dynamic result: OK waves=2 workers=64 active=65 rounds=400 avx2Isolation=OK freshInit=OK reuse=OK
      ASYNIOD task churn: OK requests=512
      ASYNIOD result: OK

  Jeder entsprechende `FAILED`-Marker macht die Abnahme ungueltig. Details
  stehen in `../Core/DynamicTaskRegistry.txt`.

Abnahme
-------

    DevTools/Scripts/Build.bat -apps
    DevTools/Scripts/Build.bat -test
    Tests/Runtime/Run-ProgramInstanceStorageRuntime0597.ps1
    Tests/Runtime/Run-DynamicProgramRegistryRuntime0598.ps1
    Tests/Runtime/Run-ProgramLifecycleRuntime0599.ps1
    Tests/Gate/Run-DynamicTaskRegistryContract05910.ps1
    Tests/Runtime/Run-DynamicTaskRegistryRuntime05910.ps1
    Tests/Runtime/Run-AsyncIoNetworkChurnRuntime05910.ps1
    Tests/Gate/Run-ProgramTaskInventoryContract05911.ps1
    Tests/Runtime/Run-ProgramTaskInventoryRuntime05911.ps1
    Tests/Gate/Run-DynamicExecutionStressContract05912.ps1
    Tests/Runtime/Run-DynamicExecutionStress05912.ps1

Der letzte Runner faehrt ohne Tierparameter als Quick-Standard genau eine
QEMU-Bootrunde mit 1.000 Zyklen und 2.000 Tick finaler Settle-Frist. Er nutzt
den kurzen RDP-Drain von 1.000 ms plus 250 ms und wartet vor Poweroff 1.000
Gast-Ticks. Der optionale Diagnosemodus `-Full` verlangt bei explizitem Aufruf
mindestens drei frische Bootrunden mit je 10.000 Zyklen und 10.000 Tick Settle-
Frist; dort gelten 8.000 ms plus 2.000 ms fuer den RDP-Drain und 5.000 Gast-
Ticks vor Poweroff. Das Hostmodell bleibt immer bei 10.000 Zyklen. `-SkipImage`
ist nur fuer einen Harness-Retry ohne zwischenzeitliche Quellen-, Artefakt-
oder `TestInjection/`-Aenderung erlaubt. Wiederholte Boots und Full-Laeufe sind
optionale Tiefendiagnosen, keine Abschlussblocker. Am Ende von 0.59.14 werden
ausschliesslich genau ein aggregiertes `Build.bat -test` und ein
`Build.bat -norun` gebuendelt.
