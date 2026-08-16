R4OS Audio
==========

R4AUDIO is the public platform group for PCM streams, hardware status and
synthesizer access. Applications request it through `module.R4MF` and use the
SDK facade; optional functions are guarded with `hasFn`.

Hardware output is provided by loadable R4D drivers such as AC97 and HDA.
SID, MIDI and OPL3 are separate driver/protocol components. The kernel keeps
only the common timing, routing and backend mechanisms required by the
platform contract.

The normal ownership chain is:

```text
R4X application -> R4AUDIO -> audio service/core -> active R4D backend
```

Drivers advertise capabilities and own hardware-specific conversion,
DMA, interrupts, stop and recovery. Applications must use the announced
stream format and close every stream they open.

Current modules are listed in `Docs/Inventory/AllModules.json`; diagnostics
and their tests are listed in the corresponding inventories.
