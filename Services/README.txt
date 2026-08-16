R4OS Services
=============

Rolle
-----

Services sind externe R4X-Programme unter Code/System/Services. Sie laufen
mit app.class=service und werden ueber C:/R4OS/CONFIG/SERVICES.R4S durch
SERVMAN verwaltet.

Kernelgrundlage
---------------

Der Kernel besitzt Service Registry, Endpunkte, Queues und R4SYS-
Servicefelder. Produktive Autostart-/Installationspolicy bleibt in SERVMAN
und der Konfiguration.

Aktuelle Services
-----------------

    AUDSVC    Audio-Streams
    CLIPSVC   Clipboard
    DHCPSVC   DHCP
    DNSSVC    DNS
    FTPSVC    FTP
    LOGSVC    strukturierte Logs
    RDPSVC    Remote Desktop
    R4SLSVC   Serial Link
    SSHD      SSH
    TCPSVC    TCP
    TIMESVC   Zeit
    UDPSVC    UDP
    WINSVC    Fensterdienst

DHCPSVC-Laufzeitstatus 0.59.13
-----------------------------

DHCPSVC dupliziert keine DHCP-Policy. Der Kernelkoordinator liefert den
Low-Level-Status; DHCPSVC reicht seit 0.59.13 `runtime_state` und die Flags
desired, task_started, link_up und retry_wait durch. Das alte Reservefeld wird
ohne Payloadgroessenbruch als Zustand verwendet. SDK-Clients sehen damit im
Service- und direkten R4NET-Pfad denselben Runtimezustand.
    EXSVC     Referenzservice

API-Vertrag
-----------

Services starten ueber den SDK-eigenen R4XStart-Einstieg, importieren Gruppen
aus module.R4MF und verwenden fuer normale Anwendungen `app.services()` mit
ServiceConnection beziehungsweise ServiceEndpoint. EXSVC ist die Referenz
fuer Register/Wait/Recv/Reply/Unregister und Open/Call/Close. Fachliche Daten
liegen in R4NET, R4AUDIO, R4DESK oder R4DEV. Rohe Gruppenfelder bleiben auf
Diagnose-, Loader- und Migrationscode begrenzt.

LOGSVC-Inventartelemetrie
-------------------------

Seit 0.59.11 importiert LOGSVC die optionale R4DEV-Sicht und erzeugt bei der
Adapteraktualisierung einen `StatusSnapshot` mit Origin `R4DEV`. Er enthaelt
aktive, reservierte, fertige und retirende Programme, Completions, aktuelle
Task-/Threadzahlen, die drei Spitzenwerte, getrennte Admissionfehler,
Rollbackfehler und den letzten klassifizierten Fehler. Die Werte stammen aus
`execution_inventory_summary`; LOGSVC erfindet bei fehlender Gruppe oder
Funktion keine Nulltelemetrie.

Auch die Console-Statusquellen werden nicht mehr ueber einen festen
Ordinalscan gelesen. LOGSVC sammelt die paginierten Programmseiten zuerst in
einem caller-owned dynamischen Buffer und schreibt Records erst nach einer
vollstaendigen stabilen Generation. Meldet der Kernel `restart`, wird der
begonnene Durchlauf verworfen. Dadurch entstehen aus einem abgebrochenen
Snapshot weder doppelte Console-Records noch eine still auf 16 oder 64
Instanzen begrenzte Sicht.

Produktionsnaher Lastvertrag 0.59.12
-----------------------------------

`Run-DynamicExecutionStress05912.ps1` erzeugt sein QEMU-Profil aus der
Produktionskonfiguration und verlangt alle 13 Auto-Services gleichzeitig im
Zustand Running/Starting bei null fehlgeschlagenen Diensten. FTPSVC bleibt
dabei aktiv. Der SSHD-Produktionsdefault `MaxSessions=8` und die acht
Workerplaetze werden mit genau acht gleichzeitig offenen SSH-Sitzungen
ausgelastet; parallel muss RDPSVC einen aktiven Worker halten.

Ueber die offenen Sitzungen werden SERVMAN-Diagnose und wiederholte
SSHD-/RDPSVC-Statusabfragen, ein LOGCENTER-RDPTRACE-Export sowie `SYSUPD STATUS`
und die erfolgreiche Verifikation eines Testpakets ausgefuehrt. Erst nachdem
diese Adminaktivitaet vollstaendig belegt und zur Ruhe gekommen ist, beginnt
der eigentliche CLEANUPD-Stress. Quick prueft eine QEMU-Bootrunde mit 1.000
Zyklen und 2.000 Tick finaler Settle-Frist. Dabei gelten der kurze RDP-Drain
von 1.000 ms plus 250 ms und 1.000 Gast-Ticks vor Poweroff. Der optionale
Diagnosemodus `-Full` verlangt bei explizitem Aufruf mindestens drei Runden mit
je 10.000 Zyklen und 10.000 Tick Settle-Frist; er nutzt 8.000 ms plus 2.000 ms
RDP-Drain und 5.000 Gast-Ticks vor Poweroff. Das Hostmodell bleibt unabhaengig
davon bei 10.000 Zyklen. Beide Tiers verwenden keine reale Hardware.

Wiederholte Boots und Full-Laeufe bleiben optionale Tiefendiagnosen und sind
kein Abschlussblocker. Am Ende von 0.59.14 werden ausschliesslich genau ein
aggregiertes `Build.bat -test` und ein `Build.bat -norun` gebuendelt. Dieser
Text beschreibt das Testverfahren und nimmt kein Full-Laufresultat vorweg.

Regeln
------

- Kein stiller direkter Parallelpfad fuer normale Clients.
- Timeouts, Queuegrenzen und Resultcodes sind Teil des jeweiligen
  Servicevertrags.
- Ein Dienst darf keine Kernelpolicy duplizieren.
- Diagnoseprogramme pruefen Service- und Gruppenvertrag getrennt.
- Kein Selbst-Stop und kein Selbst-Restart (seit 0.60.29). Laeuft der
  Aufrufer als Programm des Dienstes oder als dessen Console-Nachfahre,
  liefern service_stop und service_restart sichtbar
  service_api_result_self_restart (-19), statt den eigenen Aufruferbaum
  mitten im Syscall abzuraeumen und einen Erfolg zu melden, den niemand
  mehr beobachten kann. Der reale Fall ist SERVMAN RESTART SSHD in einer
  SSH-Sitzung: SERVMAN ist dort ein Console-Kind von SSHD. Die Erkennung
  sitzt im Kernel (Console-Ownership-Kette gegen die instance_id des
  Dienstes), damit jeder Aufrufer sie erbt, und gilt fuer STOP UND
  RESTART - sonst waere sie mit STOP plus START umgehbar. SERVMAN meldet
  self-restart-refused und nennt die Alternative: lokale Konsole oder
  eine andere Sitzung.

Build und Test
--------------

    DevTools/Scripts/Build.bat -app NAME
    DevTools/Scripts/Build.bat -norun
    DevTools/Scripts/Build.bat -test
