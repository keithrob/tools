<#
.SYNOPSIS
    A PS script to be used in a VSTS build step to fetch nuget.

.DESCRIPTION
    This tool will look for nuget.exe in the directory indicated by the VSTS
    build agent variable Build.BinariesDirectory.  If there is a version of nuget.exe
    in Build.BinariesDirectory it will be compared against the supplied version.
    If the supplied version is greater than what is found or if no version exists the
    exact version you requested will be fetched from nuget.org.  The version must be available at
    https://dist.nuget.org/win-x86-commandline/v$YOUR-VERSION-HERE/nuget.exe.

    Once downloaded Build.BinariesDirectory will be added to head of env:PATH so that
    subsequent build steps will use it.

.NOTES
  Author:  Keith Robertson <keithro@gmail.com>

.EXAMPLE
    c:\PS> vstsfetchnuget -version 4.3.0
#>
Param(
    [Parameter(Mandatory = $true,
        HelpMessage = "The version in semver format of nuget.exe to fetch.")]
    [System.Version] $Version,
    [Parameter(Mandatory = $false,
        HelpMessage = "The destination directory for the downloaded version of nuget.")]
    [String] $OutputLocation = $env:BUILD_BINARIESDIRECTORY
)

$urlPrefix = "https://dist.nuget.org/win-x86-commandline/v$Version/nuget.exe"
$download = $true

try {
    $installedVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$OutputLocation\nuget.exe").FileVersion
    if ($installedVersion -gt $Version) {
        Write-Host "nuget version $installedVersion is greater than $Version and is already present at $OutputLocation.  Not downloading."
        $download = $false
    }
}
catch {
    Write-Host "nuget version $Version is not present in $OutputLocation"
}

#
# Download nuget.
#
if ($download) {
    Write-Host "Downloading nuget version $Version from $urlPrefix"
    try {
        Invoke-WebRequest $urlPrefix -OutFile "$OutputLocation\nuget.exe"
    }
    catch {
        Write-Error -Message "Failed to download nuget.exe from $urlPrefix.  $($_.Exception.Message)" -ErrorAction Stop
    }
}

#
# Add to the head of $env.Path.
#
if ($env:Path -inotlike "*$OutputLocation*") {
    Write-Host "Adding $OutputLocation to the head of Path so that nuget.exe version $Version can be used by subequent build steps"
    Write-Host "##vso[task.setvariable variable=Path;]$OutputLocation;$env:Path"
}