param(
    [Parameter(Position = 0)]
    [Alias('sn')]
    [string]$shortcutName,
    [Parameter(Position = 1)]
    [Alias('sp')]
    [string]$shortcutPath,
    [Alias('v', 'version')]
    [switch]$versionInfo,
    [Alias('l', 'list')]
    [switch]$showList,
    [Alias('o', 'order', 'sort')]
    [switch]$orderList,
    [Alias('n', 'new_tab')]
    [switch]$newTab,
    [Alias('h', 'help')]
    [switch]$helpUser,
    [Alias('a', 'add', 'append')]
    [switch]$addShortcut,
    [Alias('d', 'r', 'delete', 'remove')]
    [switch]$deleteShortcut,
    [Alias('ra', 'clear')]
    [switch]$clearAll,
    [Alias('en', 'edit_name')]
    [switch]$editName,
    [Alias('ep', 'edit_path')]
    [switch]$editPath,
    [Alias('nf', 'next_folder')]
    [switch]$nextFolder,
    [Alias('pf', 'previous_folder')]
    [switch]$previousFolder,
    [Alias('w', 'where')]
    [switch]$whereAmI
)

Set-StrictMode -Version Latest

function Get-Shortcuts {
    $result = [ordered]@{}
    foreach ($line in Get-Content -LiteralPath $shortcutsFile -Encoding utf8) {
        if ($line -match '^\s*#' -or $line -notmatch '=') { continue }
        $key, $value = $line -split '=', 2
        $result[$key.Trim()] = $value.Trim()
    }
    return $result
}

function Resolve-TargetFolder {
    param([string]$inputPath)

    if ([string]::IsNullOrWhiteSpace($inputPath)) {
        return $null
    }

    $inputPath = $inputPath.Trim()

    if (-not (Test-Path -LiteralPath $inputPath -PathType Container)) {
        return $null
    }

    return (Resolve-Path -LiteralPath $inputPath).Path
}

function Test-ShortcutName {
    param([string]$inputName)

    if ([string]::IsNullOrWhiteSpace($inputName)){
        Write-Error "Name of the new shortcut cannot be empty!"
        return $null
    }
    if ($inputName -match '[=#\s]') {
        Write-Error "Name of the new shortcut cannot contain ('=', ' ', '#')!"
        return $null
    }
    if ($shortcuts.Contains($inputName)){
        Write-Error "Given name already exists in the shortcut list!"
        return $null
    }

    return $inputName
}

function IsListEmpty {
    if ($shortcuts.Count -eq 0) {
        Write-Host "No shortcuts in the list."
        return $true
    }
    return $false
}

function Move-ToSibling {
    param(
        [int]$Direction = 1
    )

    $currentDir = Get-Item -LiteralPath (Get-Location).Path
    $parentDir = $currentDir.Parent

    if (-not $parentDir) {
        Write-Error "Already at root folder; no parent directory found!"
        return $null
    }

    $siblings = @(Get-ChildItem -LiteralPath $parentDir.FullName -Directory | Sort-Object Name)

    if ($siblings.Count -le 1) {
        Write-Host "No other sibling directories found!"
        return $currentDir.FullName
    }

    $currentIndex = -1
    for ($i = 0; $i -lt $siblings.Count; $i++) {
        if ($siblings[$i].FullName -ieq $currentDir.FullName) {
            $currentIndex = $i
            break
        }
    }

    if ($currentIndex -eq -1) {
        Write-Host "Current folder is hidden, so it is not part of the sibling list."
        return $null
    }

    $rawIndex = ($currentIndex + $Direction) % $siblings.Count
    $targetIndex = ($rawIndex + $siblings.Count) % $siblings.Count

    return $siblings[$targetIndex].FullName
}

$shortcutsFile = Join-Path $PSScriptRoot 'shortcuts.txt'
$target = $null

if (-not (Test-Path -LiteralPath $shortcutsFile -PathType Leaf)) {
    New-Item -ItemType File -Path $shortcutsFile | Out-Null
}

$shortcuts = Get-Shortcuts

if ($helpUser) { # -h
    @'
highway - folder shortcut manager

USAGE
    highway <name>                     Jump to the shortcut's folder
    highway -n <name>                  Open the shortcut in a new terminal tab
    highway -v                         Show version informations
    highway -w                         Outputs the current folder's name on shortcut list 
    highway -l                         List all shortcuts
    highway -l -o                      List all shortcuts alphabetically
    highway -a <name> [path]           Add a shortcut (no path = current folder)
    highway -d <name>                  Delete a shortcut
    highway -ra                        Delete ALL shortcuts (asks for confirmation)
    highway -ep <name> <newpath>       Change the path of a shortcut
    highway -en <newname> <path>       Rename the shortcut that points to <path>
    highway -h                         Show this help
    highway -nf                        Jump to the next sibling folder
    highway -pf                        Jump to the previous sibling folder
    highway -n -nf                     Open next sibling folder in a new terminal tab
    highway -nf <positive integer>     Jump by given number folders forward

SWITCHES AND ALIASES
    -l   -list                         List shortcuts
    -v   -version                       Show version number 
    -w   -whereAmI                      Print current folder's given name 
    -o   -order  -sort                  Order listed shortcuts 
    -n   -new_tab                      Open in a new Windows Terminal tab
    -a   -add, -append                 Add a shortcut
    -d   -r, -delete, -remove          Delete a shortcut
    -ra  -clear                        Clear the whole list
    -ep  -edit_path                    Edit the path of a shortcut
    -en  -edit_name                    Edit the name of a shortcut
    -h   -help                         Show this help
    -nf  -next_folder                  Go to next sibling folder
    -pf  -previous_folder              Go to previous sibling folder

NAME RULES
    Names cannot be empty, cannot contain spaces, '=' or '#',
    and must be unique (case-insensitive).

EXAMPLES
    highway -a work D:\Projects        Save D:\Projects as "work"
    highway work                       Go to D:\Projects
    highway -n work                    Open D:\Projects in a new tab
    highway -ep work D:\Projects\New   Point "work" to a different folder
    highway -en job D:\Projects\New    Rename that shortcut to "job"
    highway -d job                     Remove "job"

NOTES
    Paths are saved as full paths. Shortcuts are stored in shortcuts.txt
    next to the script; lines starting with # are comments.
'@ | Write-Host
    exit 0
}

if ($versionInfo) { # -v
    @'
Name: Highway    
Version: 1.3
Last Updated: 2026-11-8
Developer: Alafrano
'@ | Write-Host
    exit 0
}

if ($whereAmI) { # -w
    if (IsListEmpty) {
        exit 0
    }

    $current_path = (Get-Location).Path
    $name_matches = @()

    foreach ($key in $shortcuts.Keys) {
        if ($shortcuts[$key] -ieq $current_path) {
            $name_matches += $key
        }
    }
    
    if ($name_matches.Count -gt 0) {
        $names = $name_matches -join ", "
        Write-Host "This directory is saved as '$names' in the shortcut list."
    } else {
        Write-Host "This directory is not saved in shortcut list."
    }

    exit 0
}

if ($showList) { # -l
    if (IsListEmpty) {
        exit 0
    }
    $keys = $shortcuts.Keys
    if ($orderList) { # -l -o
        $keys = $keys | Sort-Object
    }
    foreach ($key in $keys) {
        Write-Host ("{0,-15} {1}" -f $key, $shortcuts[$key])
    }
    exit 0
}

if ($addShortcut) { # -a
    $validatedName = Test-ShortcutName $shortcutName
    if (-not $validatedName){
        exit 1
    }
    $shortcutName = $validatedName
    if ([string]::IsNullOrWhiteSpace($shortcutPath)){
        $shortcutPath = (Get-Location).Path
    }
    else {
        $resolved = Resolve-TargetFolder $shortcutPath
        if (-not $resolved) {
            Write-Error "Folder not found: $shortcutPath"
            exit 1
        }
        $shortcutPath = $resolved
    }

    Add-Content -LiteralPath $shortcutsFile -Value "$shortcutName=$shortcutPath" -Encoding utf8
    Write-Host "New shortcut named" $shortcutName "added to shortcut list successfuly."
    exit 0
}

if ($deleteShortcut) { # -d or -r
    if ([string]::IsNullOrWhiteSpace($shortcutName)) {
        Write-Error "Deleting requires name entry!"
        exit 1
    }
    $lines = Get-Content -LiteralPath $shortcutsFile -Encoding utf8
    $newLines = @()
    $found = $false
    foreach ($line in $lines) {
        if ($line -match '^\s*#' -or $line -notmatch '=') {
            $newLines+=$line
            continue 
        }
        $key, $value = $line -split '=', 2
        if ($key.Trim() -ieq $shortcutName) {
            $found = $true
        }
        else{
            $newLines+=$line
        }
    }
    if ($found -eq $false){
        Write-Error "No shortcut with given name found!"
        exit 1
    }
    Set-Content -LiteralPath $shortcutsFile -Value $newLines -Encoding utf8
    Write-Host "Shortcut named" $shortcutName "removed from shortcut list successfully."
    exit 0
}

if ($clearAll) { # -ra
    if (IsListEmpty) {
        exit 0
    }
    $confirmation = Read-Host "This action will clear all of the shortcut list. Are you sure? (y/n)"
    if (-not ($confirmation -ieq 'y' -or $confirmation -ieq 'Yes')) {
        Write-Host "Clearing cancelled."
        exit 0
    }
    $lines = Get-Content -LiteralPath $shortcutsFile -Encoding utf8
    $newLines = @()
    foreach ($line in $lines) {
        if ($line -match '^\s*#' -or $line -notmatch '=') {
            $newLines+=$line
            continue 
        }
    }
    Set-Content -LiteralPath $shortcutsFile -Value $newLines -Encoding utf8
    Write-Host "Shortcut list cleared."
    exit 0
}

if ($editPath) { # -ep
    if (-not $shortcutName) {
        Write-Error "Editing requires name entry!"
        exit 1
    }
    if ([string]::IsNullOrWhiteSpace($shortcutPath)) {
        Write-Error "Editing requires path entry!"
        exit 1
    }
    $lines = Get-Content -LiteralPath $shortcutsFile -Encoding utf8
    $newLines = @()
    $nameFound = $false
    $resolvedPath = Resolve-TargetFolder $shortcutPath
    if (-not $resolvedPath) {
        Write-Error "Folder not found: $shortcutPath"
        exit 1
    }
    $shortcutPath = $resolvedPath
    foreach ($line in $lines) {
        if ($line -match '^\s*#' -or $line -notmatch '=') {
            $newLines+=$line
            continue 
        }
        $key, $value = $line -split '=', 2
        if ($key.Trim() -ieq $shortcutName) {
            $nameFound = $true
            $line = "$($key.Trim())=$shortcutPath"
        }
        $newLines+=$line
    }
    if ($nameFound -eq $false){
        Write-Error "No shortcut with given name found!"
        exit 1
    }
    Set-Content -LiteralPath $shortcutsFile -Value $newLines -Encoding utf8
    if ($nameFound -eq $true) {
        Write-Host "Path of shortcut named" $shortcutName "changed to" $shortcutPath "successfully."
        exit 0
    }
}

if ($editName) { # -en
    $validatedName = Test-ShortcutName $shortcutName
    if (-not $validatedName){
        exit 1
    }
    $shortcutName = $validatedName
    if ([string]::IsNullOrWhiteSpace($shortcutPath)) {
        Write-Error "Editing requires path entry!"
        exit 1
    }
    $lines = Get-Content -LiteralPath $shortcutsFile -Encoding utf8
    $newLines = @()
    $numPathsFound = 0
    $resolvedPath = Resolve-TargetFolder $shortcutPath
    if (-not $resolvedPath) {
        Write-Error "Folder not found: $shortcutPath"
        exit 1
    }
    $shortcutPath = $resolvedPath
    foreach ($line in $lines) {
        if ($line -match '^\s*#' -or $line -notmatch '=') {
            $newLines+=$line
            continue 
        }
        $key, $value = $line -split '=', 2
        if ($value.Trim() -ieq $shortcutPath) {
            $numPathsFound++
            $line = "$shortcutName=$($value.Trim())"
        }
        $newLines+=$line
    }
    if ($numPathsFound -eq 0){
        Write-Error "No shortcut with given path found!"
        exit 1
    }
    elseif ($numPathsFound -eq 1) {
        Set-Content -LiteralPath $shortcutsFile -Value $newLines -Encoding utf8
        Write-Host "Name of shortcut pointed to" $shortcutPath "changed to" $shortcutName "successfully."
        exit 0
    }
    else {
        Write-Error "Multiple shortcuts pointed to given path found!"
        exit 1
    }
}

if ($nextFolder -or $previousFolder) { # -nf & -pf
    $step = 1
    if (-not [string]::IsNullOrWhiteSpace($shortcutName)) {
        if (-not [int]::TryParse($shortcutName, [ref]$step) -or $step -lt 1) {
            Write-Error "Invalid step count: '$shortcutName'. Must be a positive integer!"
            exit 1
        }
    }

    $direction = if ($nextFolder) { 
        $step 
    } else { 
        -$step 
    }
    $target = Move-ToSibling -Direction $direction
    if (-not $target) { 
        exit 1 
    }
}
elseif ($shortcuts.Contains($shortcutName)) {
    $target = $shortcuts[$shortcutName]
}

if (-not $target) {
    if ([string]::IsNullOrWhiteSpace($shortcutName)) {
        Write-Error "Shortcut name cannot be empty. Run 'highway -h' for usage."
        exit 1
    }
    Write-Error "No shortcut named `"$shortcutName`". Run 'highway -h' for usage."
    exit 1
}

if (-not (Test-Path -LiteralPath $target -PathType Container)) {
    Write-Error "Folder not found: $target!"
    exit 1
}

if ($newTab) {
    $exists = Get-Command wt -ErrorAction SilentlyContinue
    if (-not $exists){
        Write-Error "Windows Terminal (wt) is required for opening shortcuts in new tab!"
        exit 1
    }
    wt -w 0 new-tab -d $target
    exit 0
}

Set-Location -LiteralPath $target
