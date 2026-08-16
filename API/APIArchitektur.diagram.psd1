@{
    Title = 'R4OS API-Architektur'
    Description = 'Aktueller Aufruf-, Lade- und Buildpfad fuer normale Zig- und C-Anwendungen.'
    Height = 2770
    Boundaries = @(
        @{ Id = 'lowlevel_boundary'; X = 4; Y = 420; Width = 92; Height = 740; Label = 'Low-Level-/ABI-Grenze' }
        @{ Id = 'kernel_boundary'; X = 4; Y = 900; Width = 92; Height = 260; Label = 'Kernel' }
    )
    Nodes = @(
        @{ Id = 'app_source'; X = 8; Y = 90; Width = 84; Height = 72; Kind = 'app'; Lines = @('Zig- oder C-Anwendung', 'schreibt r4_app_main(App*)') }
        @{ Id = 'sdk_startup'; X = 8; Y = 200; Width = 84; Height = 72; Kind = 'sdk'; Lines = @('SDK-eigener R4XStart:1-Startup', 'validiert Kontext und App-Profil') }
        @{ Id = 'app_facade'; X = 8; Y = 310; Width = 84; Height = 82; Kind = 'facade'; Lines = @('App-/R4App-Fassade und SDK-Wrapper', 'besitzen das Bundle', 'pruefen Gruppe, Feld und Vertrag') }
        @{ Id = 'r4x_context'; X = 8; Y = 465; Width = 84; Height = 90; Kind = 'abi'; Lines = @('R4XStartContext mit Import-Bundle', 'Kontext ist fuer den Startaufruf borrowed', 'Tabellenzeiger bleiben Kernel-owned') }
        @{ Id = 'r4l_query'; X = 8; Y = 610; Width = 40; Height = 120; Kind = 'loader'; Lines = @('R4LQuery', 'beim Laden', 'loest Gruppen-', 'importe auf', 'kein Laufzeit-', 'Dispatcher') }
        @{ Id = 'runtime_libraries'; X = 8; Y = 770; Width = 40; Height = 120; Kind = 'library'; Lines = @('Runtime-R4Ls', 'R4STD, R4IMG, R4FONT', 'lokaler Contract', 'eigene API-Tabellen', 'keine Kernel-Gruppe') }
        @{ Id = 'kernel_tables'; X = 52; Y = 610; Width = 40; Height = 280; Kind = 'table'; Lines = @('6 Kernel-Tabellen', 'R4SYS', 'R4DESK', 'R4DRAW', 'R4NET', 'R4AUDIO', 'R4DEV') }
        @{ Id = 'kernel_providers'; X = 8; Y = 950; Width = 84; Height = 82; Kind = 'kernel'; Lines = @('Sechs typisierte Kernel-Provider', 'direkte Funktionszeiger', 'kein Syscall- oder Dispatch-Zwischenweg') }
        @{ Id = 'kernel_subsystems'; X = 8; Y = 1060; Width = 84; Height = 72; Kind = 'kernel'; Lines = @('Kernel-Subsysteme', 'FS, Desktop, Draw, Network', 'Audio und Device') }
        @{ Id = 'trace_facade'; X = 8; Y = 1290; Width = 84; Height = 82; Kind = 'trace'; Lines = @('1  App-Fassade', 'app.files().read', 'Pfad plus caller-owned Buffer') }
        @{ Id = 'trace_sdk'; X = 8; Y = 1400; Width = 84; Height = 82; Kind = 'trace'; Lines = @('2  R4SYS-SDK-Wrapper', 'ruft file_read-Zeiger', 'aus der Gruppentabelle direkt auf') }
        @{ Id = 'trace_provider'; X = 8; Y = 1510; Width = 84; Height = 82; Kind = 'trace'; Lines = @('3  Kernel-Provider in program/r4x.zig', 'apiFileRead -> Async-I/O', 'weiter zu program/r4sys.zig') }
        @{ Id = 'trace_fs_request'; X = 8; Y = 1620; Width = 84; Height = 82; Kind = 'trace'; Lines = @('4  Technische FS-Request-Schicht', 'fs/request.zig', 'koordiniert den Zugriff') }
        @{ Id = 'trace_vfs'; X = 8; Y = 1730; Width = 84; Height = 82; Kind = 'trace'; Lines = @('5  FS-neutrale VFS-Schicht', 'fs/vfs.zig dispatcht', 'an das Dateisystem des Laufwerks') }
        @{ Id = 'trace_fat32'; X = 8; Y = 1840; Width = 84; Height = 82; Kind = 'trace'; Lines = @('6  FS-Backend des Laufwerks', 'ntfs.zig fuer C:, fat32.zig fuer D:', 'liest in den Buffer des Aufrufers') }
        @{ Id = 'manifest_source'; X = 8; Y = 2070; Width = 84; Height = 72; Kind = 'build'; Lines = @('module.R4MF v2 plus Zig-/C-Quellen', 'Profil, Imports, Ziel und Einstieg') }
        @{ Id = 'compiler_linker'; X = 8; Y = 2180; Width = 84; Height = 82; Kind = 'build'; Lines = @('SDK-Buildprofil, Compiler und Linker', 'binden Startup und ABI', 'sowie deklarierte R4L-Imports') }
        @{ Id = 'r4x_builder'; X = 8; Y = 2290; Width = 84; Height = 72; Kind = 'build'; Lines = @('R4XBuilder', 'verpackt Code, Daten, Imports und Metadaten') }
        @{ Id = 'r4m0_artifact'; X = 8; Y = 2400; Width = 84; Height = 72; Kind = 'artifact'; Lines = @('R4M0-Container als .R4X', 'current-only Modul- und Startvertrag') }
        @{ Id = 'kernel_loader'; X = 8; Y = 2510; Width = 84; Height = 82; Kind = 'loader'; Lines = @('Kernel-Loader', 'validiert, laedt und reloziert', 'baut den R4XStartContext') }
        @{ Id = 'app_entry'; X = 8; Y = 2620; Width = 84; Height = 72; Kind = 'app'; Lines = @('SDK R4XStart -> r4_app_main', 'Anwendung laeuft mit ihrem App-Objekt') }
    )
    Edges = @(
        @{ Id = 'runtime_1'; X1 = 50; Y1 = 162; X2 = 50; Y2 = 200; Kind = 'runtime'; Label = 'Start' }
        @{ Id = 'runtime_2'; X1 = 50; Y1 = 272; X2 = 50; Y2 = 310; Kind = 'runtime'; Label = 'App erzeugen' }
        @{ Id = 'runtime_3'; X1 = 50; Y1 = 392; X2 = 50; Y2 = 465; Kind = 'runtime'; Label = 'Bundle nutzen' }
        @{ Id = 'provision_1'; X1 = 28; Y1 = 610; X2 = 28; Y2 = 555; Kind = 'provision'; Label = 'Loader provisioniert' }
        @{ Id = 'runtime_tables'; X1 = 72; Y1 = 555; X2 = 72; Y2 = 610; Kind = 'runtime'; Label = 'direkter Aufruf' }
        @{ Id = 'library_1'; X1 = 28; Y1 = 730; X2 = 28; Y2 = 770; Kind = 'library'; Label = 'Librarycode' }
        @{ Id = 'provider_tables'; X1 = 72; Y1 = 890; X2 = 50; Y2 = 950; Kind = 'runtime'; Label = '' }
        @{ Id = 'provider_subsystem'; X1 = 50; Y1 = 1032; X2 = 50; Y2 = 1060; Kind = 'runtime'; Label = '' }
        @{ Id = 'trace_1'; X1 = 50; Y1 = 1372; X2 = 50; Y2 = 1400; Kind = 'trace'; Label = '' }
        @{ Id = 'trace_2'; X1 = 50; Y1 = 1482; X2 = 50; Y2 = 1510; Kind = 'trace'; Label = '' }
        @{ Id = 'trace_3'; X1 = 50; Y1 = 1592; X2 = 50; Y2 = 1620; Kind = 'trace'; Label = '' }
        @{ Id = 'trace_4'; X1 = 50; Y1 = 1702; X2 = 50; Y2 = 1730; Kind = 'trace'; Label = '' }
        @{ Id = 'trace_5'; X1 = 50; Y1 = 1812; X2 = 50; Y2 = 1840; Kind = 'trace'; Label = '' }
        @{ Id = 'build_1'; X1 = 50; Y1 = 2142; X2 = 50; Y2 = 2180; Kind = 'build'; Label = '' }
        @{ Id = 'build_2'; X1 = 50; Y1 = 2262; X2 = 50; Y2 = 2290; Kind = 'build'; Label = '' }
        @{ Id = 'build_3'; X1 = 50; Y1 = 2362; X2 = 50; Y2 = 2400; Kind = 'build'; Label = '' }
        @{ Id = 'build_4'; X1 = 50; Y1 = 2472; X2 = 50; Y2 = 2510; Kind = 'build'; Label = '' }
        @{ Id = 'build_5'; X1 = 50; Y1 = 2592; X2 = 50; Y2 = 2620; Kind = 'build'; Label = '' }
    )
    Annotations = @(
        @{ Id = 'runtime_title'; X = 4; Y = 46; Class = 'section-title'; Text = '1. Laufzeit: App bis Kernel' }
        @{ Id = 'ownership_note'; X = 6; Y = 410; Class = 'note'; Text = 'App owns; Kontext und Tabellen borrowed.' }
        @{ Id = 'trace_title'; X = 4; Y = 1235; Class = 'section-title'; Text = '2. Dateispur: Datei lesen' }
        @{ Id = 'build_title'; X = 4; Y = 2015; Class = 'section-title'; Text = '3. Bauen und Laden' }
        @{ Id = 'legend_title'; X = 4; Y = 2720; Class = 'legend'; Text = 'Legende: durchgezogen = Laufzeit | gestrichelt = Laden' }
        @{ Id = 'legend_more'; X = 4; Y = 2742; Class = 'legend'; Text = 'gepunktet = Build | nummeriert = Dateispur' }
    )
}
