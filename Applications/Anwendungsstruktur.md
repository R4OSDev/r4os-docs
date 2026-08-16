# Anwendungsstruktur

Jede R4OS-Anwendung ist ein eigenstaendiges Repository unter
`Repositories/Apps/<Projekt>/`. Das Projekt enthaelt mindestens:

```text
Build.bat
Settings.R4S
build.zig
build.zig.zon
module.R4MF
src/
```

`module.R4MF` ist die einzige Projekt-, Build- und Imagewahrheit. Es legt
Name, Version, Sprache, Einstieg, Imports, Zielpfad und `IMAGE_SCOPE` fest.
Die lokale `build.zig` delegiert den Modulbau an das SDK und wiederholt den
Manifestvertrag nicht.

Bauen
------

```text
Repositories\Apps\<Projekt>\Build.bat
Tools\Build.bat -module Apps\<Projekt>
```

Der Starter verwendet die in `Settings.R4S` gemappten lokalen Checkouts von
SDK, Contract, Libraries und DevKit. Er schreibt das Artefakt standardmaessig
nach `Artifacts/Modules/<Projekt>/`.

Neue Anwendungen erhalten ein eigenes oeffentliches Repository und einen
Eintrag in `Docs/Inventory/AllModules.json`.
