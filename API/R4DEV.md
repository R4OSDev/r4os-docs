# R4DEV

R4DEV ist die Device- und Diagnosegruppe. Sie besitzt Hardware-/Device-
Inventar, Treiber- und Protokollstatus, Protokoll-Dispatch, Bootinformationen,
Performance- und Hardwarezusammenfassungen.

Import: R4DEV:Query:1

Bereitstellung: eingebauter Kernel-Provider bereits vor dem R4D-/R4P-
Preload; keine R4L-Datei und kein eigenstaendiger Installations- oder
Updatepfad.

Zig-Context: r4os.r4dev.Context

Ab 0.84.36 vermittelt die optionale COM-Erweiterung den dynamischen seriellen
Portkatalog und exklusive Prozesshandles. Der typisierte Anwendungskontext
ist `app.serial()` (SDK 0.64.35); die zehn Felder brauchen Tabellenrevision21.
Unveraenderte Nutzbytes, endliche Tickbudgets, Teilresultate und gesondertes
physisches Drain/Close sind in `Core/SeriellePorts.txt` beschrieben. Normale
UART-Register, Ringpuffer und IRQ-Bedienung gehoeren `SERIAL.R4D`.

R4DEV ist fuer Diagnose und device-nahe Sicht bestimmt. Hardwarebetrieb bleibt
in Kernel/R4D/R4P. Optionale Felder werden mit hasFn geprueft.

Program-, Task- und Threadinventare sind geliehene, versionierte Snapshots.
Eine unvollstaendige oder veraltete Sicht wird nicht als leerer Erfolg
gemeldet. Diagnosewerte wie Heap-, Storage- oder Performancezaehler sind
Messwerte und keine fest eingebauten Kapazitaeten.

Registry- und Lifecycle-Selftests sind begrenzte Abnahmefunktionen. Sie werden
nur mit den zugehoerigen Testoptionen freigegeben und sind keine allgemeine
Fault-Injection-Schnittstelle. Fixed-layout-Kompatibilitaetstypen bleiben
binaer eingefroren; neue Telemetrie verwendet append-only Nachfolgetypen und
neue Slots.

`ProgramPerformanceSummary` ist append-only. Version 2 haengt Clock-, Boot-
und Loaderfelder an den Version-1-Prefix an, Version 3 request-spezifische
Completion- und Admission-Zaehler und Version 4 Service-Payloadkopien sowie
Metadatenresets. Version 5 ergaenzt Queue-Scanarbeit, Endpoint-Revalidierungen
und Registry-/Endpoint-Lockzeiten fuer sieben feste Operationsfamilien.
Version 6 ergaenzt den deterministischen Timing-Abstand und die echte Anzahl
gemessener Lockhaltezeiten. Version 7 fuegt die lineare Service-
Registryenumeration hinzu: externe Indexabfragen, angeforderte Refreshes,
tatsaechlich besuchte Eintraege, Programminstanzlookups und Endemarkierungen.
Version 8 ergaenzt indizierte physische und virtuelle Memory-Hotpaths,
Version 9 laufwerks- und controllerlokale Storage-Dispatchwerte, Version 10
Mehrsektorwrite und selektive Pagecache-Durability, Version 11 die begrenzte
Hintergrund-/Read-ahead-Policy und Version 12 den generationsgebundenen
NTFS-Metadatencache. Version 13 fuegt RAM-/Druckkapazitaet,
zusammenhaengende Mehrseiten-Fills sowie rohe Backend-/Seiten-/Sektor-/Byte-/
Fehler-/Retry-/Kopier-/Lockzaehler an. Die ebenfalls angehaengten Read-ahead-
Felder weisen in 0.75.6 Fenster und Aktivitaet mit null aus: Spekulative I/O
wurde nach reproduzierbaren Subsystemhaengern verworfen, waehrend die durch
FSDIAG abgedeckten Zwei-Seiten-Demand-Fills aktiv bleiben. Groessere Runs sind
bis zur geklaerten Ursache ebenfalls gesperrt.
Version 14 ergaenzt die gezielte NTFS-Metadatencache-Invalidierung: getrennte
Zaehler fuer behaltene Payload- und cache-unabhaengige Systemwrites, Record-,
Attribut- und Verzeichnisidentitaeten, globale beziehungsweise Recovery-
Invalidierungen sowie die tatsaechlich entfernten Record-, Attribut-, INDX-
und Pfadeintraege. Nur unbekannte und Recovery-Mutationen bleiben global.
Version 15 ergaenzt den gebufferten R4M0-Metadatenpfad: physisch gelesene
Range-Bytes, Readerinstanzen, logische Zugriffe und Bytes, Fenstertreffer,
Fensterfuellungen und deren Bytes sowie bewusst direkte Grosszugriffe. Die feste
Kapazitaet von zwei 4-KiB-Fenstern wird explizit gemeldet; Section-Nutzdaten
bleiben direkte Zielreads und werden nicht in diesem Cache gehalten.
Der Aufrufer setzt Version und Puffergroesse; der Provider schreibt nur den
ausgehandelten Prefix. Zeitfelder liefern aufgeloeste Nanosekunden,
Quellenmetadaten und explizite Nichtverfuegbarkeit statt stiller Scheinwerte.

`performance_boot_summary` liefert den kleinen passiven
`ProgramBootPerformanceInfo`-Datensatz. Solange der Boot laeuft, sind
Endpunkt und Dauer live; Readiness, Fallback oder Fehler frieren dieselben
Felder und alle Phasenspannen gemeinsam ein. Die Abfrage sammelt keine breite
Subsystemtelemetrie und veraendert den Messzustand nicht.

`performance_driver_work` stellt die besitzerbezogene Workqueue- und Cleanup-
Telemetrie bereit. Version 2 ergaenzt die getrennte Audio-Deadline-Lane mit
Kapazitaet, reservierter Aufnahme, laufendem Besitzer sowie Submitted-,
Started-, Completed-, Miss-, Budget- und Reject-Zaehlern. Die allgemeinen
Task-/IRQ-Zaehler bleiben davon getrennt; ein Snapshot weist dadurch sowohl
Fairness des normalen Pfads als auch die begrenzte Deadline-Isolation aus.
`performance_pci_inventory` beschreibt die kanonische
ECAM-/Legacy-Inventur, Found/Stored/Dropped/Truncated, Config- und Mappingarbeit
sowie Such-, Detail- und Zeitzaehler. Beide Slots sind append-only und fuer
aeltere Kernel optional.

`display_state` liefert seit 0.79.4 einen koharenten DisplayStateInfo-Snapshot:
aktiver und vorbereiteter Besitzer, bestehende PCI-Identitaet, Generation,
Softwarepolicy, Fallbackgrund und bestaetigte Capabilities. Keine GPU-Probe,
kein neuer Inventarkatalog. Details: `Docs/Drivers/GrafikFallback07904.txt`.
Der Slot ist optional; die Mindestprefix-Konstanten ersetzen keine hasFn-
Pruefung der tatsaechlich gelieferten Tabelle.

Externe Firmwareeingabe verwendet seit0.80.35 den optionalen56-Byte-Tail
DriverResourceApi.platform_query. DriverPlatformApi leiht bereits permanente
Firmware-/UC-Seiten und veroeffentlicht authentifizierte Eingabefakten;
AML, EC, Notify und Benutzerpolicy bleiben ausserhalb des Kernels. Es entsteht
kein neuer Appzugriff auf Hardware. Der aeussere DriverApi-Vertrag bleibt35.
Details: [AMD-Laptopbedienung](../Drivers/AMDLaptop08035.txt).

<!-- R4OS-APIREF:BEGIN R4DEV (generiert von ApiContractGen aus ApiContract.json - NICHT von Hand editieren) -->
## Tabellen-Referenz R4DEV (generiert)

Kernel-Gruppentabelle `R4XStartR4Dev` v35, 728 Bytes, 84 Funktionsfelder und 89 Slots insgesamt.
Signatur-Wahrheit: `abi.R4DevFns` (Feldname == Tabellenfeld).
Ein Feld ist nutzbar, wenn `hasFn("feld")` es als vorhanden meldet.

| Slot | Offset | Zustand | Tabellenfeld | Signatur |
| ---: | ---: | --- | --- | --- |
| 0 | 16 | function | `device_inventory_summary` | `*const fn (*DeviceInventorySummary) callconv(.c) i32` |
| 1 | 24 | function | `device_inventory_record` | `*const fn (u32, *DeviceInventoryRecord) callconv(.c) i32` |
| 2 | 32 | function | `memory_summary` | `*const fn (*ProgramMemorySummary) callconv(.c) i32` |
| 3 | 40 | function | `memory_block_count` | `*const fn () callconv(.c) u32` |
| 4 | 48 | function | `memory_block` | `*const fn (u32, *ProgramMemoryBlockInfo) callconv(.c) i32` |
| 5 | 56 | function | `memory_pressure_snapshot` | `*const fn (*ProgramMemoryPressureSnapshot) callconv(.c) i32` |
| 6 | 64 | function | `memory_reclaim_probe` | `*const fn (u32, *ProgramMemoryReclaimProbe) callconv(.c) i32` |
| 7 | 72 | function | `memory_backing_store_probe` | `*const fn ([*:0]const u8, u64, u32, *ProgramMemoryBackingStoreProbe) callconv(.c) i32` |
| 8 | 80 | function | `memory_backing_store_slot_probe` | `*const fn ([*:0]const u8, u64, u32, u64, u32, u32, u32, u32, u32, *ProgramMemoryBackingStoreSlotProbe) callconv(.c) i32` |
| 9 | 88 | function | `memory_pager_gate_probe` | `*const fn ([*:0]const u8, u64, u32, u64, u32, *ProgramMemoryPagerGateProbe) callconv(.c) i32` |
| 10 | 96 | function | `memory_page_io_probe` | `*const fn ([*:0]const u8, u64, u32, u32, u64, u32, u64, u64, u32, u32, u64, [*]u8, u32, *ProgramMemoryPageIoProbe) callconv(.c) i32` |
| 11 | 104 | function | `memory_vm_page_state_probe` | `*const fn (u32, u64, u64, u32, u32, u64, u64, u32, *ProgramMemoryVmPageStateProbe) callconv(.c) i32` |
| 12 | 112 | function | `memory_vm_reserve_probe` | `*const fn (u64, *ProgramVmReserveProbe) callconv(.c) i32` |
| 13 | 120 | function | `paging_summary` | `*const fn (*PagingSummary) callconv(.c) i32` |
| 14 | 128 | function | `performance_summary` | `*const fn (*ProgramPerformanceSummary) callconv(.c) i32` |
| 15 | 136 | function | `performance_task` | `*const fn (u32, *ProgramTaskPerformanceInfo) callconv(.c) i32` |
| 16 | 144 | function | `performance_storage` | `*const fn (u32, *ProgramStoragePerformanceInfo) callconv(.c) i32` |
| 17 | 152 | function | `performance_boot_phase` | `*const fn (u32, *ProgramBootPhasePerformanceInfo) callconv(.c) i32` |
| 18 | 160 | function | `protocol_status` | `*const fn ([*]const u8, u32, *ProtocolStatus) callconv(.c) i32` |
| 19 | 168 | function | `protocol_dispatch` | `*const fn ([*]const u8, u32, u32, *const ProtocolBuffer, *ProtocolBuffer) callconv(.c) i32` |
| 20 | 176 | function | `display_summary` | `*const fn (*DisplaySummary) callconv(.c) i32` |
| 21 | 184 | function | `hardware_summary` | `*const fn (*HardwareSummary) callconv(.c) i32` |
| 22 | 192 | function | `boot_info_summary` | `*const fn (*BootInfoSummary) callconv(.c) i32` |
| 23 | 200 | function | `boot_info_memory_count` | `*const fn () callconv(.c) u32` |
| 24 | 208 | function | `boot_info_memory_entry` | `*const fn (u32, *BootInfoMemoryEntry) callconv(.c) i32` |
| 25 | 216 | reserved | `reserved0` | - |
| 26 | 224 | reserved | `reserved1` | - |
| 27 | 232 | tombstone | `reserved_program_instance_storage_summary_v1` | - |
| 28 | 240 | function | `program_instance_storage_self_test` | `*const fn (*ProgramInstanceStorageSelfTestResult) callconv(.c) i32` |
| 29 | 248 | tombstone | `reserved_program_registry_summary_v1` | - |
| 30 | 256 | tombstone | `reserved_program_registry_self_test_v1` | - |
| 31 | 264 | function | `program_registry_summary_v2` | `*const fn (*ProgramRegistrySummaryV2) callconv(.c) i32` |
| 32 | 272 | function | `program_registry_self_test_v2` | `*const fn (*ProgramRegistrySelfTestResultV2) callconv(.c) i32` |
| 33 | 280 | function | `execution_inventory_summary` | `*const fn (*ProgramInventorySummary) callconv(.c) i32` |
| 34 | 288 | function | `program_instance_storage_summary_v2` | `*const fn (*ProgramInstanceStorageSummary) callconv(.c) i32` |
| 35 | 296 | function | `kernel_version` | `*const fn (*KernelVersion) callconv(.c) i32` |
| 36 | 304 | function | `performance_boot_phase_clock` | `*const fn (u32, *ProgramBootPhaseClockInfo) callconv(.c) i32` |
| 37 | 312 | function | `performance_irq_timing` | `*const fn (u32, *ProgramIrqTimingInfo) callconv(.c) i32` |
| 38 | 320 | function | `performance_boot_summary` | `*const fn (*ProgramBootPerformanceInfo) callconv(.c) i32` |
| 39 | 328 | function | `performance_driver_work` | `*const fn (u32, *ProgramDriverWorkPerformanceInfo) callconv(.c) i32` |
| 40 | 336 | function | `performance_pci_inventory` | `*const fn (*ProgramPciInventoryPerformanceInfo) callconv(.c) i32` |
| 41 | 344 | function | `performance_input` | `*const fn (*ProgramInputPerformanceInfo) callconv(.c) i32` |
| 42 | 352 | function | `display_state` | `*const fn (*DisplayStateInfo) callconv(.c) i32` |
| 43 | 360 | function | `driver_module_info` | `*const fn (u32, *DriverModuleInfo) callconv(.c) i32` |
| 44 | 368 | function | `performance_instrumentation` | `*const fn (*ProgramInstrumentationInfo) callconv(.c) i32` |
| 45 | 376 | function | `performance_lock` | `*const fn (u32, *ProgramLockPerformanceInfo) callconv(.c) i32` |
| 46 | 384 | function | `performance_stack` | `*const fn (u32, *ProgramStackPerformanceInfo) callconv(.c) i32` |
| 47 | 392 | function | `stack_fault` | `*const fn (u32, *ProgramStackFaultInfo) callconv(.c) i32` |
| 48 | 400 | function | `memory_kernel_heap_check` | `*const fn (*ProgramKernelHeapCheck) callconv(.c) i32` |
| 49 | 408 | function | `scheduler_kernel_check` | `*const fn (u32, *ProgramKernelSchedulerCheck) callconv(.c) i32` |
| 50 | 416 | function | `smp_kernel_check` | `*const fn (*ProgramKernelSmpCheck) callconv(.c) i32` |
| 51 | 424 | function | `performance_smp_tlb` | `*const fn (*ProgramSmpTlbSnapshot) callconv(.c) i32` |
| 52 | 432 | function | `storage_block_queue_check` | `*const fn (*ProgramKernelBlockQueueCheck) callconv(.c) i32` |
| 53 | 440 | function | `storage_nvme_check` | `*const fn (*ProgramKernelNvmeCheck) callconv(.c) i32` |
| 54 | 448 | function | `usb_contract_check` | `*const fn (*ProgramKernelUsbCheck) callconv(.c) i32` |
| 55 | 456 | function | `serial_count` | `*const fn () callconv(.c) u32` |
| 56 | 464 | function | `serial_port_at` | `*const fn (u32, *SerialPortInfo) callconv(.c) i32` |
| 57 | 472 | function | `serial_open` | `*const fn (u64, u64, *const SerialConfig, *u64) callconv(.c) i32` |
| 58 | 480 | function | `serial_configure` | `*const fn (u64, *const SerialConfig) callconv(.c) i32` |
| 59 | 488 | function | `serial_read` | `*const fn (u64, [*]u8, u32, u64, *SerialTransfer) callconv(.c) i32` |
| 60 | 496 | function | `serial_write` | `*const fn (u64, [*]const u8, u32, u64, *SerialTransfer) callconv(.c) i32` |
| 61 | 504 | function | `serial_drain` | `*const fn (u64, u64) callconv(.c) i32` |
| 62 | 512 | function | `serial_status` | `*const fn (u64, *SerialStatus) callconv(.c) i32` |
| 63 | 520 | function | `serial_cancel` | `*const fn (u64) callconv(.c) i32` |
| 64 | 528 | function | `serial_close` | `*const fn (u64, u32, u64) callconv(.c) i32` |
| 65 | 536 | function | `cpu_topology` | `*const fn (u32, *CpuTopologyInfo) callconv(.c) i32` |
| 66 | 544 | function | `cpu_cache_topology` | `*const fn (u32, u32, *CpuCacheTopologyInfo) callconv(.c) i32` |
| 67 | 552 | function | `cpu_lifecycle` | `*const fn (u32, u32, u64, *CpuLifecycleInfo) callconv(.c) i32` |
| 68 | 560 | function | `kernel_cpu_lifecycle_check` | `*const fn (*ProgramKernelCpuLifecycleCheck) callconv(.c) i32` |
| 69 | 568 | function | `cpu_capabilities` | `*const fn (u32, *CpuCapabilitiesInfo) callconv(.c) i32` |
| 70 | 576 | function | `cpu_feature` | `*const fn (u32, u64, u32, *CpuFeatureInfo) callconv(.c) i32` |
| 71 | 584 | function | `cpu_register_read` | `*const fn (u32, u64, u32, *CpuRegisterInfo) callconv(.c) i32` |
| 72 | 592 | function | `kernel_cpu_register_check` | `*const fn (u32, u64, *ProgramKernelCpuRegisterCheck) callconv(.c) i32` |
| 73 | 600 | function | `cpu_power_info` | `*const fn (u32, u64, *CpuPowerInfo) callconv(.c) i32` |
| 74 | 608 | function | `cpu_power_capture` | `*const fn (u32, u64, *CpuPowerInfo) callconv(.c) i32` |
| 75 | 616 | function | `cpu_performance` | `*const fn (*const CpuPerformanceRequest, *CpuPerformanceInfo) callconv(.c) i32` |
| 76 | 624 | function | `cpu_cppc` | `*const fn (*const CpuPerformanceRequest, *CpuCppcInfo) callconv(.c) i32` |
| 77 | 632 | function | `cpu_performance_hint` | `*const fn (u32, u64, *CpuPerformanceHintInfo) callconv(.c) i32` |
| 78 | 640 | function | `cpu_firmware_performance` | `*const fn (*const CpuPerformanceRequest, *CpuFirmwareInfo) callconv(.c) i32` |
| 79 | 648 | function | `cpu_idle_info` | `*const fn (u32, *CpuIdleInfo) callconv(.c) i32` |
| 80 | 656 | function | `cpu_machine_info` | `*const fn (u32, *CpuMachineInfo) callconv(.c) i32` |
| 81 | 664 | function | `cpu_machine_bank` | `*const fn (u32, u64, u64, u32, *CpuMachineBank) callconv(.c) i32` |
| 82 | 672 | function | `cpu_microcode_info` | `*const fn (u32, *CpuMicrocodeInfo) callconv(.c) i32` |
| 83 | 680 | function | `cpu_pmu_info` | `*const fn (u32, *CpuPmuInfo) callconv(.c) i32` |
| 84 | 688 | function | `cpu_pmu_measure` | `*const fn (u32, u64, u32, u32, ?*const PmuWorkFn, u64, *CpuPmuResult) callconv(.c) i32` |
| 85 | 696 | function | `cpu_pmu_result` | `*const fn (u32, u64, u64, *CpuPmuResult) callconv(.c) i32` |
| 86 | 704 | function | `cpu_acceleration_info` | `*const fn (*CpuAccelerationInfo) callconv(.c) i32` |
| 87 | 712 | function | `cpu_acceleration_work` | `*const fn (u32, u32, ?*const CpuPureWorkFn, u64, *CpuAccelerationWork) callconv(.c) i32` |
| 88 | 720 | function | `fpu_observation` | `*const fn (*const FpuObservationRequest, *FpuObservationInfo) callconv(.c) i32` |
<!-- R4OS-APIREF:END R4DEV -->
