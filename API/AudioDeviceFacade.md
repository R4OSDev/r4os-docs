# Audio- und Gerätefassade

Normale Zig- und C-Anwendungen verwenden für PCM einen
besitzenden `AudioStream`. Der normale Pfad läuft ausschließlich über den
R4X-Dienst AUDSVC. Es gibt keinen stillen Rückfall auf direkte Kernel-
Audiooperationen. SID, MIDI und OPL3 bleiben verfügbar, sind aber sichtbar
als `AdvancedAudio` getrennt.

## PCM-Ablauf

`app.audio()` liefert die hohe `Audio`-Sicht, wenn R4AUDIO sowie die nötigen
R4SYS-Servicefunktionen vorhanden sind. `openStream` akzeptiert derzeit
48-kHz-unabhängige Raten, einen Kanalwert, das PCM-Format `s16le`, eine
16.16-Festkommalaustärke und einen `R4Timeout`.

```zig
const audio = app.audio() orelse return r4os.abi.err_no_group;
var stream = switch (audio.openStream(48_000, 2, .s16le,
    r4os.app_audio.default_volume,
    r4os.time_contract.timeoutForever())) {
    .stream => |value| value,
    .timed_out => return 1,
    .no_service, .failure => return 1,
};

const written = stream.write(pcm, r4os.time_contract.timeoutForever());
_ = stream.setVolume(0x0000_8000, r4os.time_contract.timeoutForever());
_ = stream.close(r4os.time_contract.timeoutForever());
```

Der Stream besitzt seine `ServiceConnection`. Große Schreibvorgänge werden
in AUDSVC-Payloads zerlegt; das Ergebnis nennt bestätigte Bytes. Timeout
setzt den Stream nicht automatisch auf geschlossen, weil die Gegenseite den
Auftrag bereits angenommen haben kann. Erfolgreiches Close invalidiert
Stream und Connection. Ein zweites Close meldet `err_closed`.

Ungültige Rate, Kanalzahl oder ein nicht unterstütztes Format werden vor dem
Serviceaufruf abgelehnt. AUDSVC unterstützt für den normalen Vertrag aktuell
nur S16LE. Ein fehlender Dienst ist `no_service`, ein Timeout bleibt
`timed_out`, und fachliche beziehungsweise Transportfehler tragen ihren
Rohcode.

## Advanced-Audio

`audio.advanced()` liefert `AdvancedAudio`. Diese getrennte Sicht enthält
SID-Sessions, MIDI-Synthesizer und OPL3-Register-/Renderoperationen. Sie
verwendet weiterhin die zentral beschriebene R4AUDIO-Gruppentabelle, kapselt
aber die typisierten Aufrufe. Advanced bedeutet ein sichtbar niedrigeres
Abstraktionsniveau und nicht, dass Anwendungen Tabellenfelder selbst casten.

## Geräte-, Speicher- und Performancesichten

`app.devices()` liefert `Devices` und daraus drei geliehene Sichten:

- `DeviceInventoryView`: Inventarzusammenfassung, einzelne Records und
  `HardwareSummary`.
- `MemoryView`: `ProgramMemorySummary`, Drucksnapshot und Speicherblöcke.
- `PerformanceView`: Gesamt-, Task-, Storage- und Bootphasensnapshots.

Die Sichten geben die bestehenden zentralen R4DEV-Payloadtypen zurück. Sie
führen keine neue Diagnose-ABI ein und kopieren keine Felder in parallele
SDK-Strukturen. Diagnosecode, der bewusst die ganze rohe
Gruppe benötigt, verwendet `app.devicesLowLevel()`.

## C

C bindet `<r4os/r4os.h>` ein. `R4AudioFacade`, `R4AudioStream`,
`R4AdvancedAudio`, `R4Devices`, `R4DeviceInventoryView`, `R4MemoryView` und
`R4PerformanceView` bilden denselben Vertrag ab. Normale Verbraucher rufen
zum Beispiel `r4_audio_open_stream`, `r4_audio_stream_write`,
`r4_audio_stream_set_volume`, `r4_audio_stream_close` und
`r4_performance_summary` auf. Die notwendigen Funktionszeigercasts bleiben
in den SDK-Headern.

## Maschinenlesbare Parität

`Docs/API/ZigCParity.json` wird von ApiContractGen aus
`ApiContract.json` erzeugt. `signature_parity` trennt generierte
Gruppensignaturen von SDK-Fassadenverträgen. `cross_language_fixtures` nennt
separat die tatsaechlich kompilierten und ausgefuehrten Zig-/C-Proben. Der
Bericht ist eine Generatorausgabe und keine zweite
Vertragsquelle.

## Referenzen und Prüfung

- BEEP und R4Synth verwenden den normalen `AudioStream`; R4Synth verwendet
  zusätzlich `AdvancedAudio`.
- AUDIOD verwendet `AudioStream` und `PerformanceView`.
- HWDIAG verwendet `DeviceInventoryView`.
- `Run-AudioDeviceFacadeContract05827.ps1` prüft Zig und C, negative
  Lebenszyklen, Advanced-Smokes, R4DEV-Sichten und den vollständigen
  Paritätsbericht.
