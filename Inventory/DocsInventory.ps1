param(
    [switch]$Initial,
    [switch]$Update,
    [switch]$Check
)

$ErrorActionPreference = 'Stop'

$modeCount = 0
if ($Initial.IsPresent) { $modeCount++ }
if ($Update.IsPresent) { $modeCount++ }
if ($Check.IsPresent) { $modeCount++ }
if ($modeCount -gt 1) {
    throw 'Nur einer der Schalter -Initial, -Update oder -Check ist erlaubt.'
}
if ($modeCount -eq 0) {
    $Update = $true
}

$docsRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$inventoryPath = Join-Path $PSScriptRoot 'Docs.json'
$utf8NoBom = New-Object Text.UTF8Encoding($false)
$keyComparer = [StringComparer]::OrdinalIgnoreCase
$excludedRootFiles = [Collections.Generic.HashSet[string]]::new($keyComparer)
foreach ($name in @(
    '.gitattributes',
    '.gitignore',
    'LICENSE',
    'NOTICE',
    'README.md',
    'THIRD_PARTY_NOTICES.md'
)) {
    [void]$excludedRootFiles.Add($name)
}

function Test-ExcludedPath([string]$RelativePath) {
    if ($excludedRootFiles.Contains($RelativePath)) { return $true }
    if ($RelativePath.StartsWith('Changelogs/', [StringComparison]::OrdinalIgnoreCase)) { return $true }
    if ($RelativePath.StartsWith('Inventory/', [StringComparison]::OrdinalIgnoreCase)) { return $true }
    return $false
}

function Get-DocumentFiles {
    if (-not (Test-Path -LiteralPath (Join-Path $docsRoot '.git'))) {
        throw ('Docs ist kein Git-Checkout: ' + $docsRoot)
    }

    $gitPaths = @(& git -c core.quotepath=false -C $docsRoot ls-files --cached --others --exclude-standard)
    if ($LASTEXITCODE -ne 0) {
        throw ('Dateibestand des Docs-Repositories konnte nicht gelesen werden: ' + $docsRoot)
    }

    $result = [Collections.Generic.List[string]]::new()
    $seen = [Collections.Generic.HashSet[string]]::new($keyComparer)
    foreach ($gitPath in $gitPaths) {
        if ([string]::IsNullOrWhiteSpace($gitPath)) { continue }
        $relativePath = $gitPath.Replace([char]92, '/').TrimStart('/')
        if (Test-ExcludedPath $relativePath) { continue }

        $fullPath = [IO.Path]::GetFullPath((Join-Path $docsRoot $relativePath))
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) { continue }
        if (-not $seen.Add($relativePath)) {
            throw ('Dokumentpfad ist nicht eindeutig: ' + $relativePath)
        }
        $result.Add($relativePath)
    }

    $paths = $result.ToArray()
    [Array]::Sort($paths, $keyComparer)
    return @($paths)
}

function ConvertTo-Identity([string]$RelativePath) {
    $separator = $RelativePath.LastIndexOf('/')
    if ($separator -lt 0) {
        $path = 'Docs'
        $name = $RelativePath
    } else {
        $path = 'Docs/' + $RelativePath.Substring(0, $separator)
        $name = $RelativePath.Substring($separator + 1)
    }
    return [pscustomobject]@{
        Name = $name
        Path = $path
        Key = $path + '/' + $name
    }
}

function Get-JsonValue([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw ('Inventardatei fehlt: ' + $Path)
    }
    $raw = [IO.File]::ReadAllText($Path)
    if ([string]::IsNullOrWhiteSpace($raw)) {
        throw ('Inventardatei ist leer: ' + $Path)
    }
    try {
        $value = ConvertFrom-Json -InputObject $raw
    } catch {
        throw ('Inventardatei enthaelt ungueltiges JSON: ' + $Path + ' (' + $_.Exception.Message + ')')
    }
    return [pscustomobject]@{
        Raw = $raw
        Value = $value
    }
}

function Get-EntryKey($Entry) {
    return ([string]$Entry.Path) + '/' + ([string]$Entry.Name)
}

function Read-Inventory([string]$Path) {
    $document = Get-JsonValue $Path
    if (-not $document.Raw.TrimStart().StartsWith('[')) {
        throw ('Docs.json muss eine JSON-Liste als Wurzel besitzen: ' + $Path)
    }

    $expectedFields = @('Name', 'Path', 'Description', 'Status', 'Notes')
    $entries = [Collections.Generic.List[object]]::new()
    $byKey = [Collections.Generic.Dictionary[string,object]]::new($keyComparer)
    foreach ($entry in @($document.Value)) {
        if ($null -eq $entry) {
            throw ('Docs.json enthaelt einen leeren Eintrag: ' + $Path)
        }

        $propertyNames = @($entry.PSObject.Properties | ForEach-Object { $_.Name })
        if ($propertyNames.Count -ne $expectedFields.Count) {
            throw ('Inventareintrag besitzt nicht genau die fuenf Pflichtfelder: ' + $Path)
        }
        foreach ($field in $expectedFields) {
            if (-not ($propertyNames -ccontains $field)) {
                throw ('Inventareintrag enthaelt das Pflichtfeld nicht in exakter Schreibweise: ' + $field)
            }
            if ($entry.$field -isnot [string]) {
                throw ('Inventarfeld muss eine Zeichenkette sein: ' + $field)
            }
        }

        if ([string]::IsNullOrWhiteSpace($entry.Name)) {
            throw 'Inventarfeld Name darf nicht leer sein.'
        }
        if ($entry.Name.IndexOf('/') -ge 0 -or $entry.Name.IndexOf([char]92) -ge 0) {
            throw ('Inventarfeld Name darf keinen Pfad enthalten: ' + $entry.Name)
        }
        if ($entry.Path -ne 'Docs' -and
            -not $entry.Path.StartsWith('Docs/', [StringComparison]::Ordinal)) {
            throw ('Inventarfeld Path muss Docs oder Docs/... enthalten: ' + $entry.Path)
        }
        if ($entry.Path.IndexOf([char]92) -ge 0 -or $entry.Path.EndsWith('/')) {
            throw ('Inventarfeld Path ist nicht normalisiert: ' + $entry.Path)
        }
        if ($entry.Status -cne 'New' -and $entry.Status -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
            throw ('Inventarfeld Status muss New oder eine Unterversion sein: ' + $entry.Status)
        }

        $key = Get-EntryKey $entry
        if ($byKey.ContainsKey($key)) {
            throw ('Doppelter Docs.json-Eintrag fuer Path und Name: ' + $key)
        }

        $normalized = [pscustomobject][ordered]@{
            Name = [string]$entry.Name
            Path = [string]$entry.Path
            Description = [string]$entry.Description
            Status = [string]$entry.Status
            Notes = [string]$entry.Notes
        }
        $entries.Add($normalized)
        $byKey.Add($key, $normalized)
    }

    return [pscustomobject]@{
        Entries = @($entries.ToArray())
        ByKey = $byKey
    }
}

function Read-PreviousDescriptions([string]$Path) {
    $document = Get-JsonValue $Path
    $descriptions = [Collections.Generic.Dictionary[string,string]]::new($keyComparer)

    if ($document.Raw.TrimStart().StartsWith('[')) {
        $items = @($document.Value)
    } else {
        $properties = @($document.Value.PSObject.Properties | ForEach-Object { $_.Name })
        if (-not ($properties -contains 'entries')) {
            throw ('Alte Docs.json-Struktur enthaelt keine entries-Liste: ' + $Path)
        }
        $items = @($document.Value.entries)
    }

    foreach ($entry in $items) {
        if ($null -eq $entry -or
            $entry.Name -isnot [string] -or
            $entry.Path -isnot [string]) {
            throw ('Vorhandener Docs.json-Eintrag ist nicht eindeutig zuordenbar: ' + $Path)
        }
        $key = ([string]$entry.Path) + '/' + ([string]$entry.Name)
        if ($descriptions.ContainsKey($key)) {
            throw ('Vorhandene Docs.json enthaelt einen doppelten Eintrag: ' + $key)
        }
        $description = ''
        if ($entry.Description -is [string]) {
            $description = [string]$entry.Description
        }
        $descriptions.Add($key, $description)
    }
    return $descriptions
}

function New-InventoryEntries([string[]]$DocumentFiles, $ExistingByKey, [switch]$InitialMode) {
    $entries = [Collections.Generic.List[object]]::new()
    foreach ($relativePath in $DocumentFiles) {
        $identity = ConvertTo-Identity $relativePath
        if (-not $InitialMode.IsPresent -and $ExistingByKey.ContainsKey($identity.Key)) {
            $existing = $ExistingByKey[$identity.Key]
            $entries.Add([pscustomobject][ordered]@{
                Name = $existing.Name
                Path = $existing.Path
                Description = $existing.Description
                Status = $existing.Status
                Notes = $existing.Notes
            })
            continue
        }

        $description = ''
        if ($InitialMode.IsPresent -and $ExistingByKey.ContainsKey($identity.Key)) {
            $description = [string]$ExistingByKey[$identity.Key]
        }
        $entries.Add([pscustomobject][ordered]@{
            Name = $identity.Name
            Path = $identity.Path
            Description = $description
            Status = 'New'
            Notes = ''
        })
    }
    return @($entries.ToArray())
}

function ConvertTo-JsonString([string]$Value) {
    return ConvertTo-Json -InputObject $Value -Compress
}

function ConvertTo-InventoryText([object[]]$Entries) {
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('[')
    for ($index = 0; $index -lt $Entries.Count; $index++) {
        $entry = $Entries[$index]
        $lines.Add('  {')
        $lines.Add('    "Name": ' + (ConvertTo-JsonString $entry.Name) + ',')
        $lines.Add('    "Path": ' + (ConvertTo-JsonString $entry.Path) + ',')
        $lines.Add('    "Description": ' + (ConvertTo-JsonString $entry.Description) + ',')
        $lines.Add('    "Status": ' + (ConvertTo-JsonString $entry.Status) + ',')
        $lines.Add('    "Notes": ' + (ConvertTo-JsonString $entry.Notes))
        $suffix = if ($index -lt $Entries.Count - 1) { ',' } else { '' }
        $lines.Add('  }' + $suffix)
    }
    $lines.Add(']')
    return (($lines.ToArray() -join "`n") + "`n")
}

function Test-InventoryMatchesFiles($Inventory, [string[]]$DocumentFiles) {
    $expectedKeys = [Collections.Generic.HashSet[string]]::new($keyComparer)
    foreach ($relativePath in $DocumentFiles) {
        $identity = ConvertTo-Identity $relativePath
        [void]$expectedKeys.Add($identity.Key)
    }

    $missing = [Collections.Generic.List[string]]::new()
    foreach ($key in $expectedKeys) {
        if (-not $Inventory.ByKey.ContainsKey($key)) { $missing.Add($key) }
    }
    $obsolete = [Collections.Generic.List[string]]::new()
    foreach ($key in $Inventory.ByKey.Keys) {
        if (-not $expectedKeys.Contains($key)) { $obsolete.Add($key) }
    }

    if ($missing.Count -gt 0) {
        foreach ($key in $missing) { Write-Host ('FEHLT: ' + $key) }
    }
    if ($obsolete.Count -gt 0) {
        foreach ($key in $obsolete) { Write-Host ('NICHT MEHR VORHANDEN: ' + $key) }
    }
    if ($missing.Count -gt 0 -or $obsolete.Count -gt 0) {
        throw ('Docs.json stimmt nicht mit dem Dokumentbestand ueberein. Fehlend: ' +
            $missing.Count + ', nicht mehr vorhanden: ' + $obsolete.Count)
    }

    $keys = @($Inventory.Entries | ForEach-Object { Get-EntryKey $_ })
    $sortedKeys = @($keys)
    [Array]::Sort($sortedKeys, $keyComparer)
    for ($index = 0; $index -lt $keys.Count; $index++) {
        if ($keys[$index] -cne $sortedKeys[$index]) {
            throw ('Docs.json ist nicht deterministisch nach Path und Name sortiert. Erster Unterschied bei: ' + $keys[$index])
        }
    }
}

function Write-InventoryAtomic([object[]]$Entries) {
    $temporaryPath = $inventoryPath + '.tmp.' + [Diagnostics.Process]::GetCurrentProcess().Id
    $backupPath = $inventoryPath + '.backup.' + [Diagnostics.Process]::GetCurrentProcess().Id
    try {
        $text = ConvertTo-InventoryText $Entries
        [IO.File]::WriteAllText($temporaryPath, $text, $utf8NoBom)
        $temporaryInventory = Read-Inventory $temporaryPath
        Test-InventoryMatchesFiles $temporaryInventory (Get-DocumentFiles)

        if (Test-Path -LiteralPath $inventoryPath -PathType Leaf) {
            if (Test-Path -LiteralPath $backupPath -PathType Leaf) {
                throw ('Backup-Pfad des Inventars ist bereits belegt: ' + $backupPath)
            }
            [IO.File]::Replace($temporaryPath, $inventoryPath, $backupPath)
            [IO.File]::Delete($backupPath)
        } else {
            [IO.File]::Move($temporaryPath, $inventoryPath)
        }
    } finally {
        if (Test-Path -LiteralPath $temporaryPath -PathType Leaf) {
            [IO.File]::Delete($temporaryPath)
        }
    }
}

function Invoke-InitialBuild {
    $documentFiles = @(Get-DocumentFiles)
    $descriptions = Read-PreviousDescriptions $inventoryPath
    $entries = @(New-InventoryEntries $documentFiles $descriptions -InitialMode)
    Write-InventoryAtomic $entries
    Write-Host ('Docs-Inventar initial aufgebaut: ' + $entries.Count + ' Dokumente, Status New.')
}

function Invoke-IncrementalUpdate {
    $documentFiles = @(Get-DocumentFiles)
    $inventory = Read-Inventory $inventoryPath
    $actualKeys = [Collections.Generic.HashSet[string]]::new($keyComparer)
    foreach ($relativePath in $documentFiles) {
        [void]$actualKeys.Add((ConvertTo-Identity $relativePath).Key)
    }

    $added = [Collections.Generic.List[string]]::new()
    foreach ($key in $actualKeys) {
        if (-not $inventory.ByKey.ContainsKey($key)) { $added.Add($key) }
    }
    $removed = [Collections.Generic.List[string]]::new()
    foreach ($key in $inventory.ByKey.Keys) {
        if (-not $actualKeys.Contains($key)) { $removed.Add($key) }
    }

    if ($added.Count -eq 0 -and $removed.Count -eq 0) {
        Write-Host ('Docs-Inventar unveraendert: ' + $inventory.Entries.Count + ' Dokumente.')
        return
    }

    foreach ($key in $added) { Write-Host ('NEU: ' + $key) }
    foreach ($key in $removed) { Write-Host ('ENTFERNT: ' + $key) }
    $entries = @(New-InventoryEntries $documentFiles $inventory.ByKey)
    Write-InventoryAtomic $entries
    Write-Host ('Docs-Inventar aktualisiert: +' + $added.Count + ', -' + $removed.Count +
        ', gesamt ' + $entries.Count + '.')
}

function Invoke-Gate {
    $documentFiles = @(Get-DocumentFiles)
    $inventory = Read-Inventory $inventoryPath
    Test-InventoryMatchesFiles $inventory $documentFiles
    Write-Host ('Docs-Inventar-Gate erfolgreich: ' + $inventory.Entries.Count + ' Dokumente.')
}

try {
    if ($Initial.IsPresent) {
        Invoke-InitialBuild
    } elseif ($Check.IsPresent) {
        Invoke-Gate
    } else {
        Invoke-IncrementalUpdate
    }
    exit 0
} catch {
    [Console]::Error.WriteLine('FEHLER: ' + $_.Exception.Message)
    exit 1
}
