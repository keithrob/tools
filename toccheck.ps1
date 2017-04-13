<#
.SYNOPSIS
    Validate a given table of contents file for broken links and the repo for unused files.

.DESCRIPTION
    Parse a given TOC.md and note all of the referenced links. Search
    from the directory relative to the TOC.md and validate that all of
    the referenced files exist. Also, report any *.md files not referenced
    by the TOC.md.  Output is written to log.txt.

.PARAMETER tocFile
    The path to the TOC.md that you want to evaluate.

.NOTES
  Author:  Keith Robertson <keithro@gmail.com>

#>
Param(
    [Parameter(Mandatory = $True, HelpMessage = "Please the path to the TOC.md")]
    [string]$tocFile
)

if ( -Not (Test-Path $tocFile) ) {
    [Console]::ForegroundColor = 'red'
    [Console]::Error.WriteLine("ERROR: $tocFile does not exist.  Please supply a valid path.")
    [Console]::ResetColor()
    exit 1
}
$tocDir = (get-item $tocFile).Directory

#
# Find all of the *.md files relative to the TOC.md
#
[System.Collections.ArrayList]$mdfiles = Get-ChildItem -Path $tocDir -Filter *.md -Recurse -File -Name

Write-Host("INFO: There are " + $mdfiles.Count + " *.md files in " + $tocDir)

#
# Time to start looping through the the TOC MD file.
#
[System.Collections.ArrayList]$missingFiles = @()
$linecount = 1
foreach ($line in [System.IO.File]::ReadLines((get-item $tocFile).FullName)) {
    # Write-Host "LINE: $linecount $line"
    $linecount += 1
    $groups = [regex]::Match($line, '^.+\[(.+)\].*?\((.+)\).*?').captures.groups
    if ( $groups -ne $null -and $groups.count -eq 3 ) {
        $mdfile = $groups[2].value.split('?', [System.StringSplitOptions]::RemoveEmptyEntries)[0]
        if ( -Not (Test-Path $mdfile) ) {
            $var = $missingFiles.Add($groups[2].value)
            [Console]::ForegroundColor = 'red'
            [Console]::Error.WriteLine("WARN: Found " + $groups[2].value + " on line $linecount.  It does not exist.")
            [Console]::ResetColor()
        }
        $mdfiles.Remove($mdfile.Replace('/', '\'))
    }
}

Write-Host("INFO: There are " + $mdfiles.Count + " unreferenced *.md files in " + $tocDir)

$logfile = @"
There are no missing or unreferenced files.
===========================================

"@

if ( ( $missingFiles.Count -gt 0 ) -or ( $mdfiles.Count -gt 0 )) {
    $logfile = ""
    if ( $missingFiles.Count -gt 0 ) {
        $logfile = @"
The following files are referenced in $tocFile, but do not exist in $tocDir.
==================================================================================================

"@
        $logfile += $missingFiles -join "`r`n"
        $logfile += "`r`n`r`n"
    }

    if ( $mdfiles.Count -gt 0 ) {
        $logfile += @"
The following files are in $tocDir, but are not referenced in $tocFile.
==================================================================================================

"@
        $logfile += $mdfiles -join "`r`n"
        $logfile += "`r`n`r`n"
    }
}

Write-Host "INFO: log written to log.txt"
$logfile | Out-File 'log.txt'