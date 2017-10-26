try {
        Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/v$Version/nuget.exe" -OutFile "$env:BUILD_BINARIESDIRECTORY\nuget.exe"
        Write-Host "Adding $env:BUILD_BINARIESDIRECTORY to the head of Path so that nuget.exe version $Version can be used by subequent build steps"
        Write-Host "##vso[task.setvariable variable=Path;]$env:BUILD_BINARIESDIRECTORY;$env:Path"
}catch {
        Write-Error -Message "Failed to download nuget.exe from $urlPrefix.  $($_.Exception.Message)" -ErrorAction Stop}