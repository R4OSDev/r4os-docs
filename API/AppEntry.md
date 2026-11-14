# SDK-eigener App-Einstieg

## Normaler Einstieg

R4X-Programme exportieren binaer `R4XStart2:2`. Diesen technischen
Einstieg erzeugt das SDK. Anwendungsquellen implementieren in beiden
Sprachen nur den fachlichen Einstieg `r4_app_main`:

```zig
const r4os = @import("r4os");

pub fn r4_app_main(app: *r4os.App2) i32 {
    app.system().println("Hallo R4OS");
    return 0;
}
```

```c
#include <r4os/app2.h>
#include <r4os/r4os.h>

int32_t r4_app_main(R4App2 *app2) {
    R4App app;
    int32_t rc = r4_app2_facade(app2, &app);
    if (rc < 0) return rc;
    return r4sys_write_line(&app.system, "Hallo R4OS");
}
```

Der Entwickler schreibt keinen Entry-Assembler, verarbeitet keinen rohen
`R4XStartContext2` und initialisiert kein globales Tabellen-Bundle.

## Profile

Die Build-/SDK-Auswahl gehoert den drei SDK-Profildateien unter
`Repositories/SDK/Profiles/`. `ApiContract.json` beschreibt die gemeinsamen
App-Klassen- und Gruppenanforderungen:

| Profil | App-Klasse | Pflichtgruppen | Optionale Gruppen |
| --- | --- | --- | --- |
| `console` | `console` | R4SYS | R4DESK, R4DRAW, R4NET, R4AUDIO, R4DEV |
| `desktop` | `gui` | R4SYS, R4DESK, R4DRAW | R4NET, R4AUDIO, R4DEV |
| `service` | `service` | R4SYS | R4DESK, R4DRAW, R4NET, R4AUDIO, R4DEV |

Eine fehlende Pflichtgruppe beendet die Initialisierung sichtbar mit
`err_no_group`. Eine nicht importierte optionale Gruppe ist in Zig `null` und
in C ueber `r4_app_has_group` als abwesend erkennbar.

Unabhaengige Runtime-R4Ls gehoeren nicht zu den App-Profilen. Ihr lokales
Binding loest nur die im Manifest genannten benannten Interfaces aus dem
Startkontext auf.

## App-Objekt

Jeder Start erzeugt ein eigenes App-Objekt mit eigenem Gruppen-Bundle.
Darueber sind Argumente, App-Klasse, Close-Anforderung, Yield, monotone Ticks
und ein optionaler Allocator erreichbar. Gruppen werden feld- und
groessengeprueft aufgeloest. Optionale Operationen bleiben weiterhin ueber
`hasFn` beziehungsweise die entsprechenden C-Helfer zu pruefen.

App liefert ausserdem die normalen zentralen Fassaden `console`, `files` und
`registry`. Unabhaengige Runtime-R4Ls sind bewusst keine App-Fassade: Ihr
eigenes Binding baut den Library-Kontext aus `app.startContext()` auf. R4STD,
R4IMG und R4FONT verwenden dieses Modell.
Details stehen in `StorageFacade.md`.

Das Desktop-Profil liefert mit `app.window(timers)` die
Window-/Message-/EventLoop-/PaintContext-Fassade ueber R4DESK und R4DRAW.
Details stehen in `GuiFacade.md`.

## Build

`module.R4MF` setzt fuer normale Apps `ENTRY_MODE=app` und waehlt Sprache und
App-Klasse. Der zentrale SDK-Manifesttreiber bindet daraus den passenden
Zig-/C-Startup ein. Projektquellen rufen die internen Buildhelfer nicht selbst
auf; `module.R4MF` bleibt die einzige Import- und Modulwahrheit.

Der rohe ABI-Zugriff fuer Loader-, Startup- und gezielten Diagnosecode ist bewusst
als `r4os.lowlevel` benannt. Er ist kein alternativer normaler App-Einstieg.
