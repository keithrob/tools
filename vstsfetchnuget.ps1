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

.PARAMETER version
    The version, in semver format, of nuget you want to fetch.

.NOTES
  Author:  Keith Robertson <keithro@gmail.com>

.EXAMPLE
    c:\PS> vstsfetchnuget -version 4.3.0
#>
Param(
    [Parameter(Mandatory = $True,
               HelpMessage = "The version in semver format of nuget.exe to fetch.")]
    [System.Version]$version
)

$Build = "$env:HOMEDRIVE$env:HOMEPATH\Downloads\CredentialProviderBundle"
$URLPrefix = "https://dist.nuget.org/win-x86-commandline/v$version/nuget.exe"
$download = $TRUE
try {
    $installedVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$Build\nuget.exe").FileVersion  
    if ($installedVersion -gt $version) {
        Write-Host "nuget version $installedVersion is greater than $version and is already present at $build.  Not downloading."
        $download = $FALSE
    }
} catch{
        Write-Host "nuget version $version is not present in $build"
}

#
# Download nuget.
#
if ($download) {
    Write-Host "Downloading nuget version $version from $URLPrefix"
    try{
        Invoke-WebRequest $URLPrefix -OutFile "$Build\NuGet.exe"
    } catch { 
        Write-Error -Message "Failed to download nuget.exe from $URLPrefix.  Http status code is $($_.Exception.Response.StatusCode.Value__)"
        Exit 1
    }
}


#
# Add to the head of $env.Path.
# 
if($env:Path -inotlike "*$Build*") {
    Write-Host "Adding $Build to the head of Path so that nuget.exe version $version can be used by subequent build steps"
    [Environment]::SetEnvironmentVariable("Path","$Build;" + $env:Path,"Process")
}
