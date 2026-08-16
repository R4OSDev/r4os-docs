R4OS Audio
==========

Architektur
-----------

R4AUDIO
  Oeffentliche Programmsicht fuer PCM, Streams, MIDI, SID, OPL3 und Status.

AudioService
  R4X-Service fuer Stream-Lifecycle, Pufferung und dauerhafte Audioarbeit.

R4D
  HDA, AC97, SID, MIDI und OPL3 Hardware-/Engine-Treiber.

R4P
  MIDI-, SID- und OPL3-Protokollmodule.

Kernel
  Audio-Core und technisch notwendige Transport-/Bootgrundlage.

Programme
---------

BEEP und R4Synth sind Anwendungen. AUDIOD und SYNTHD pruefen den Vertrag.
Programme deklarieren R4AUDIO in module.R4MF und verwenden fuer PCM
`app.audio()` sowie den besitzenden `AudioStream`. Open, Write, Volume und
Close laufen ausschliesslich ueber AUDSVC; ein stiller direkter Kernel-
Fallback existiert nicht. SID, MIDI und OPL3 liegen sichtbar getrennt unter
`audio.advanced()`. Der rohe R4AUDIO-Kontext ist nur Low-Level-Zugriff.

Capability-Regel
----------------

Optionale R4AUDIO- und R4DEV-Felder werden mit hasFn geprueft. Fachliche
Service- und Streamfehler bleiben von fehlender Gruppe/Funktion getrennt.
Timeout invalidiert einen Stream nicht; erfolgreiches Close tut es. Der
vollstaendige Entwicklervertrag steht in Docs/API/AudioDeviceFacade.md.

Build und Test
--------------

    DevTools/Scripts/Build.bat -app AudioService
    DevTools/Scripts/Build.bat -app AudioDiag
    DevTools/Scripts/Build.bat -norun
    DevTools/Scripts/Build.bat -test
    powershell -NoProfile -ExecutionPolicy Bypass -File Tests/Gate/Run-AudioDeviceFacadeContract05827.ps1

Hardware-Sichttests verwenden die dafuer vorgesehenen Audio-TestRunner unter
Tests/Gate.
