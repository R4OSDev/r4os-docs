# R4DEV

R4DEV ist die Device- und Diagnosegruppe. Sie besitzt Hardware-/Device-
Inventar, Treiber- und Protokollstatus, Protokoll-Dispatch, Bootinformationen,
Performance- und Hardwarezusammenfassungen.

Import: R4DEV:Query:1

Bereitstellung: eingebauter Kernel-Provider bereits vor dem R4D-/R4P-
Preload; keine R4L-Datei und kein eigenstaendiger Installations- oder
Updatepfad.

Zig-Context: r4os.r4dev.Context

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

<!-- R4OS-APIREF:BEGIN R4DEV (generiert von ApiContractGen aus ApiContract.json - NICHT von Hand editieren) -->
## Tabellen-Referenz R4DEV (generiert)

Kernel-Gruppentabelle `R4XStartR4Dev` v10, 352 Bytes, 40 Funktionsfelder und 42 Slots insgesamt.
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
| 27 | 232 | function | `program_instance_storage_summary` | `*const fn (*ProgramInstanceStorageSummary) callconv(.c) i32` |
| 28 | 240 | function | `program_instance_storage_self_test` | `*const fn (*ProgramInstanceStorageSelfTestResult) callconv(.c) i32` |
| 29 | 248 | function | `program_registry_summary` | `*const fn (*ProgramRegistrySummary) callconv(.c) i32` |
| 30 | 256 | function | `program_registry_self_test` | `*const fn (*ProgramRegistrySelfTestResult) callconv(.c) i32` |
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
<!-- R4OS-APIREF:END R4DEV -->
