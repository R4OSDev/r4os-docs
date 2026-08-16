# Fenster-, Nachrichten- und Zeichenfassade

Normale Desktop-Anwendungen in Zig und C verwenden die
SDK-Fassade `Window`/`R4Window`. Sie verbindet den fachlich gemeinsamen
Arbeitsablauf aus R4DESK und R4DRAW, ohne die beiden Gruppen im ABI
zusammenzulegen und ohne einen zusaetzlichen Kerneluebergang einzufuehren.
`r4os.gui` bleibt der vorhandene Werkzeugkasten fuer Controls, Geometrie und
Zeichnen; die neue Fassade erzeugt kein zweites GUI-Toolkit.

## Einstieg und Lebenszyklus

Eine Desktop-App fordert beim Start ein Fenster an. Die Fassade prueft die
benoetigten konkreten Tabellenfelder und liefert bei fehlender R4DESK- oder
R4DRAW-Capability kein scheinbar benutzbares Objekt. Ein PaintContext ist
genau fuer einen Frame aktiv. Nach erfolgreichem `present` oder nach
`discard` darf er nicht erneut praesentiert werden.

```zig
pub fn r4_app_main(app: *r4os.App) i32 {
    var timers: [1]r4os.Timer = .{.{}};
    var window = app.window(timers[0..]) orelse return r4os.abi.err_no_group;
    _ = window.setTitle("Meine App");

    var paint = switch (window.beginPaint()) {
        .paint => |value| value,
        .failure => |raw| return raw,
    };
    _ = paint.canvas.clear(0xC0C0C0);
    return paint.present();
}
```

In C entsprechen dem `r4_window_open`, `r4_window_begin_paint`,
`r4_paint_canvas` und `r4_paint_present`. Timer- und EventLoop-Speicher
gehoert in beiden Sprachen dem Aufrufer; die Fassade besitzt keinen globalen
Scratch- oder versteckten Allokationszustand.

## Typisierte Nachrichten

`Message` beziehungsweise `R4Message` unterscheidet Close, Resize, Key,
Mouse, Command, Clipboard und Timer. Unbekannte rohe GUI-Ereignisse bleiben
als `unknown` sichtbar. Resize liest die aktuelle Clientgroesse aus der
Fensterinformation. Command ist eine explizit durch die Anwendung gepostete
SDK-Nachricht; Clipboard entsteht aus einer Revisionsaenderung; Timer aus
caller-owned Timerzustand. Diese drei Varianten geben keine neuen
Kernel-Eventtypen vor.

Eine Key-Nachricht behaelt `key` als kompatible 8-Bit-Sicht fuer bestehende
Hotkeys und stellt den unverkuerzten Wert zusaetzlich als `codepoint` bereit.
Textcontrols verwenden `codepoint`; Befehlslogik darf weiterhin `key` nutzen.

```zig
switch (window.waitMessage(r4os.time_contract.timeoutForever())) {
    .message => |message| switch (message) {
        .close => return 0,
        .key => |key| handleKey(key.key),
        .mouse => |mouse| handleMouse(mouse.action, mouse.x, mouse.y),
        else => {},
    },
    .failure => |raw| return raw,
    .timed_out => {},
}
```

Der C-Weg verwendet `r4_window_wait_message` und prueft den Zustand
`R4_MESSAGE_NEXT_MESSAGE`, `R4_MESSAGE_NEXT_TIMED_OUT` oder
`R4_MESSAGE_NEXT_FAILED`, bevor er den getaggten Nachrichteninhalt liest.

## Warten, Timer und Threads

Wartende Desktop-Loops verwenden `desktopActivityWait`; Drei-Tick-Polling
ist kein normaler SDK-Weg mehr. Ein endlicher Timeout besitzt ein absolutes,
saturierendes Gesamtbudget und wird durch wiederholte Wakeups nicht neu
gestartet. Der EventLoop kuerzt den naechsten Wait auf den fruehesten aktiven
Timer. Timer feuern im Owner-Thread des EventLoops und koennen einmalig oder
wiederholend laufen.

Jede Aktivitaetsquelle veroeffentlicht Eingabequeue, Console- oder GUI-
Revision vollstaendig, bevor sie den Desktop signalisiert. Sequenzinkrement
und `WaitQueue`-Wake bilden im Kernel einen gemeinsamen kritischen Abschnitt;
Sequenzleser verwenden dieselbe Sperre. Damit kann ein ruhender Desktop weder
eine noch nicht sichtbare Revision konsumieren noch bis zum naechsten
Timeout auf ein bereits verlorenes Wakeup warten.

Die Fassade behauptet bewusst kein gemeinsames Waitset fuer Dateien,
Netzwerk, Services, Threads und GUI. Solche fachlichen Operationen behalten
ihre eigenen Completion-, Timeout- und Cancel-Vertraege. Fenster-, EventLoop-
und Paint-Operationen gehoeren dem GUI-Owner-Thread; Hintergrundthreads
uebergeben Ergebnisse als Anwendungszustand oder Command an diesen Thread.

## UTF-8 im Zeichenpfad

GUI-Text ist UTF-8 ohne eingebettetes NUL. Desktop und R4DRAW dekodieren
Unicode-Skalare einmal und verwenden denselben Lauf fuer Glyphabfrage,
Messung, Clipping, Ellipsen und Cursorgeometrie. Bufferlaengen sowie Cursor-
und Auswahlgrenzen bleiben Byte-Offsets; Links/Rechts und Loeschen springen
jedoch immer ueber eine vollstaendige gueltige Sequenz. Ungueltige Bytes
werden einzeln als Ersatzzeichen behandelt, damit der Lauf stets vorankommt.

Der Fontaufruf `font_glyph_row` und das Feld `GuiEvent.key` tragen bereits
einen `u32`-Codepoint. `read_key_codepoint` liest die uebersetzte physische
Tastatureingabe ohne 8-Bit-Verlust; das bisherige `read_key` bleibt als
kompatibler Bytepfad erhalten. Gehostete Anwendungen lesen fuer Texteingabe
den vollen Wert mit `eventCodepoint`. Der Vertrag verspricht noch keine IME-
oder kompositionsfaehige Eingabemethode.

## Pilotprojekte und Sichttest

`EXAMPLE.R4X`, `CALC.R4X` und das C-Desktop-Template verwenden den App-
Einstieg, typisierte Nachrichten, `desktopActivityWait` und den
PaintContext-Lebenszyklus. Fuer einen gesammelten manuellen Sichttest startet
der Nutzer Build.bat-Menueoption 6 und prueft in EXAMPLE sowie CALC:

- Fensterinhalt wird nach Start und Resize neu praesentiert.
- Tastaturfokus, Texteingabe und Mausaktionen bleiben funktionsfaehig.
- Close beendet die Anwendung ohne Pollingverzoegerung.
- Kein sichtbares Flackern oder verlorener Frame nach wiederholtem Resize.

Der Sichttest ist eine manuelle Ergaenzung; die deterministische Abnahme
erfolgt durch `Run-GuiFacadeContract05824.ps1` und den headless Smoke-Test.
