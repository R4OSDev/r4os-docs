# R4DEV

R4DEV ist die Device- und Diagnosegruppe. Sie besitzt Hardware-/Device-
Inventar, Treiber- und Protokollstatus, Protokoll-Dispatch, Bootinformationen,
Performance- und Hardwarezusammenfassungen.

Import: R4DEV:Query:1

Zig-Context: r4os.r4dev.Context

R4DEV ist fuer Diagnose und device-nahe Sicht bestimmt. Hardwarebetrieb bleibt
in Kernel/R4D/R4P. Optionale Felder werden mit hasFn geprueft.

Seit 0.59.7 liefert `program_instance_storage_summary` die versionierte Sicht
auf Core-, Payload-, Klassen-, Peak-, Fehler- und Quarantaenebilanz der
Programminstanzen. `program_instance_storage_self_test` fuehrt den begrenzten,
synchronen Heap-/Ownership-Test aus und meldet Ergebnis, Fallnummern sowie die
vorherige und nachherige Speicherbilanz; es ist keine frei konfigurierbare
Fault-Injection-Schnittstelle.

Seit 0.59.8 meldet `program_registry_summary` die dynamische, stabil
adressierte Chunkregistry samt Slotzustaenden, Peaks, Admission-Fehlern und
reihenfolgeunabhaengigen Diagnosehashes des Live-ID-/Adressbestands.
`program_registry_self_test` besitzt weiterhin `arm_next_growth` und `reset`:
Growth-Arming verlangt die explizite Bootoption
`OPTION PROGRAMREGISTRY selftest=yes`, gilt fuer genau einen erforderlichen
Chunk-Growth und wird vom Growthpfad konsumiert. Reset ist bedingungslos und
idempotent; ein zweites Arm wird als busy abgelehnt. Der Aufruf ist kein
allgemeiner Heap-Fault-Schalter.

Seit 0.59.9 bleiben die v3-Slots `program_registry_summary` und
`program_registry_self_test` mit ihren v1-Payloads bei exakt 160/64 Byte
binaer eingefroren. R4DEV v4 haengt stattdessen
`program_registry_summary_v2` und `program_registry_self_test_v2` an. Deren
getrennte Version-2-Typen besitzen einen feld-, offset- und typgleichen
v1-Praefix und erweitern die Summary um Generation, Completion-, Retire- und
Historyzaehler sowie den Selftest um die Operationen
`arm_lifecycle_failure`, `signal_reaper` und `force_next_id`. Diese drei
Operationen werden nur mit `OPTION PROGRAMLIFECYCLE selftest=yes` akzeptiert.
Die Lifecycle-Fehlerinjektion ist ein synchronisiertes One-shot fuer eine der
13 dokumentierten Spawn-/Exit-/Retire-Phasen; `force_next_id` beeinflusst nur
die naechste ID-Suche und niemals die globale Generation. Die Schnittstelle
ist ausschliesslich fuer deterministische Abnahmebilder bestimmt. Das Feld
`operation` sowie die zugehoerigen INOUT-Parameter muessen vor dem
Provideraufruf erhalten bleiben. Die Legacy-Slots schreiben niemals ueber
ihre 160 beziehungsweise 64 Byte hinaus.

Die oeffentlichen SDK-Namen bleiben ebenfalls source-kompatibel: Zig
`programRegistrySummary`, `programRegistrySelfTest` und
`PerformanceView.programRegistry` sowie C `r4_program_registry_summary` und
`r4_program_registry_self_test` verwenden weiterhin die v1-Typen und die
Slots 29/30. Die Slots 31/32 sind nur ueber die expliziten Zig-Namen
`programRegistrySummaryV2`, `programRegistrySelfTestV2`,
`PerformanceView.programRegistryV2` beziehungsweise die C-Namen
`r4_program_registry_summary_v2` und `r4_program_registry_self_test_v2`
erreichbar. Namen mit dem Suffix `Legacy` sind reine Aliase der alten
v1-Fassaden.

Seit 0.59.12 liefert `execution_inventory_summary` im weiterhin 160 Byte
grossen `ProgramInventorySummary` zusaetzlich die punktuelle Kernel-Heap-
Bilanz. `heap_active_blocks` ist ein `u32` bei Offset 148;
`heap_used_bytes` ist ein `u64` bei Offset 152. Die Felder sind Messwerte des
gemeinsamen Kernel-Heaps, keine Programmkapazitaet und keine per Owner
aufgeteilte Speicherbilanz. Ein Abnahmewerkzeug darf sie zusammen mit den
Program-/Task-/Thread- und Completionzaehlern fuer einen warmen Snapshot
vergleichen. Exakte programmgebundene Ressourcen muessen ueber die
Ownerinventare gebunden werden; die globale Heapbilanz darf nur innerhalb
einer ausdruecklich dokumentierten Infrastrukturhuelle bewertet werden. Der
0.59.12-Abschlussstress begrenzt diese auf acht ownerlose Admin-Tasks und
insgesamt 512 KiB Heap-/Speicherabweichung. Wie bei der uebrigen geliehenen
R4DEV-Sicht muss der Aufrufer die optionale Funktion zuerst mit `hasFn`
pruefen.

<!-- R4OS-APIREF:BEGIN R4DEV (generiert von ApiContractGen aus ApiContract.json - NICHT von Hand editieren) -->
## Tabellen-Referenz R4DEV (generiert)

Kernel-Gruppentabelle `R4XStartR4Dev` v5, 304 Bytes, 34 Funktionsfelder und 36 Slots insgesamt.
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
<!-- R4OS-APIREF:END R4DEV -->
