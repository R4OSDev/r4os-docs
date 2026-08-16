# R4OS Softwareinventar

Die kanonische Maschinenwahrheit jedes Moduls ist sein module.R4MF. Dieses
Dokument beschreibt die aktuellen fachlichen Bereiche, nicht historische
Migrationsstaende.

## Systemsoftware

Unter Code/System/Software liegen unter anderem:

- Desktop und AppDefaults
- Terminal, Help und ServiceManager
- Explorer, Notepad, Paint, Calculator, Clock und Fonts (Windows-FON-Import
  in den R4F-Systemfontordner)
- Klickifax als eigenstaendiger Browser unter
  `Start -> Programs -> Internet -> Klickifax`; die App besitzt klassische
  Browserleiste, interne Seiten sowie URL-, Navigations- und Verlaufsmodell.
  HTTP/HTTPS laeuft ueber die gemeinsame SDK-Webtransport-Fassade aus R4NET,
  R4HTTP und R4TLS. R4HTML baut daraus einen dokumenteigenen DOM-Baum;
  R4CSS berechnet Kaskade und responsive strukturelle Renderliste. Klickifax
  zeichnet den geclippten Ausschnitt per R4DRAW und bedient ihn per Scrollbar.
  Der gemeinsame Webinteraktionskern verbindet Links, Fokus, DOM-Ereignisse
  und UTF-8-kodierte GET-Formulare mit dem URL-/Verlaufsmodell. Die lokale
  Suchfixture fuehrt bis zu einer navigierbaren Ergebnisliste; Stop erhaelt
  bei einem abgebrochenen Abruf das bisherige Dokument.
  R4JS stellt ausserhalb der App die begrenzte JavaScript-Laufzeit mit
  Bytecodecompiler, validierter Stack-VM, Closures, Modulen, VM-verwurzeltem
  GC, Event Loop und Promises bereit. Die
  SDK-Webruntime bindet Window, DOM, Ereignisse, Timer, Fetch/XHR sowie
  Readable-, Writable-, Transform- und BYOB-Streams mit Rueckdruck,
  URL/History und Timing an Dokumente. SOP, CORS, CSP, Mixed-Content-Schutz,
  Cookies sowie origin-getrenntes Local/Session Storage bleiben ausserhalb
  von Kernel und R4DRAW. Einstellungen liegen unter
  `C:\R4OS\CONFIG\APPS\KLICKIFAX.R4S`, Profildaten unter
  `C:\R4OS\APPDATA\KLICKIFAX\PROFILE\` und loeschbare Cache-/Tempdaten unter
  `C:\R4OS\Temp\Klickifax\`.
- DeviceManager, Services, LogCenter und RegEdit
- RegistryTool, SysInfo, SysUpdate und BootInfo
- Netzwerktools: IpConfig, NetConfig, Dhcp, DnsLookup, Ping, NetCat, Send,
  Recv, HttpGet und TcpEcho
- Audio: Beep und R4Synth
- R4Code mit R4CODE, R4BUILD, R4PACK und R4CC

## Services

Code/System/Services enthaelt Audio-, Clipboard-, DHCP-, DNS-, FTP-, Log-,
RDP-, Serial-Link-, SSH-, TCP-, Time-, UDP-, Window- und Example-Service.

## Diagnostics

Code/System/Diagnostics enthaelt die aktuellen Boot-, Loader-, R4XStart-,
CStart-, Datei-, Storage-, Memory-, Performance-, Driver-, Network-, Audio-,
USB-, Hardware-, Thread-, Display- und weiteren Smokes.

## Libraries

Code/System/Libraries enthaelt R4SYS, R4DESK, R4DRAW, R4NET, R4AUDIO,
R4DEV, R4STD, R4IMG und R4FONT als R4L-Systemlibraries. R4STD, R4IMG und
R4FONT sind unabhaengige Runtime-R4Ls mit eigener Implementierung,
Vertragsbaseline, API-Tabellen und eigenen Zig-/C-Bindings. Die sechs
Plattformgruppen bleiben im zentralen Contract.

## Treiber und Protokolle

R4D-Projekte liegen unter Code/System/Driver, R4P-Projekte unter
Code/System/Protocols. Details stehen in Docs/Drivers/README.txt,
Docs/Protocols/README.txt und fuer den Browsertransport in
Docs/Network/WebTransport06214.txt. Der HTML-Dokumentkern ist in
Docs/Network/HtmlDocumentCore06215.txt beschrieben, CSS und Layout in
Docs/Network/CssLayoutCore06216.txt.

## Projektvertrag

Jedes produktive Modul besitzt:

- module.R4MF als Projekt-, Build- und Imagewahrheit, mit VERSION= als
  Pflichtfeld
- build.zig und build.zig.zon, damit das Projekt allein aus seinem
  Verzeichnis heraus baut; die build.zig besteht aus einem Aufruf
  `sdk.addR4MF(b.path("module.R4MF"))` und wiederholt keine Manifestangabe
- Quellcode unter src/, optionale eingebettete Ressourcen unter Assets/
- R4M0 als Artefaktformat

Alle In-Tree-Module verwenden den gemeinsamen aktuellen R4MF-v2-Vertrag.
Normale R4X-Quellen implementieren `r4_app_main`; SDK und Buildtreiber leiten
den binaeren R4XStart-Vertrag ab. Gruppen werden als NAME:Query:1 importiert.
Optionale Kernel-Felder werden mit hasFn geprueft. R4D, R4P und R4L verwenden
denselben Manifestparser mit ihren kind-spezifischen Zielen und Metadaten.

## Image und Build

ModuleCatalog erzeugt den gemeinsamen Katalog. Root-Build und
CreateImageAddList konsumieren daraus Build- beziehungsweise Imageplan. Der
normale Audit ist:

    DevTools/Scripts/Build.bat -apps
    DevTools/Scripts/Build.bat -norun
    DevTools/Scripts/Build.bat -test
