# Tools

* find-copyright.ps1: From the current working directory search for all files matching a particular extension that contain a copyright that doesn't match your company.
* downloadnpmpackages.py: Given a directory and a list of packages in a TXT file download all the packages and their versions into the specified directory.
* npmbulkpublish.py: Given a directory containing NPM packages in .tgz format, publish them to the registry provided.
* toccheck.ps1: Given a Markdown table of contents file (e.g. TOC.md), find all of the links in that file and validate that they exist relative to the TOC.md.
* vstsfetchnuget.ps1: This tool will look for nuget.exe in the directory indicated by the VSTS build agent variable Build.BinariesDirectory.  If there is a version of nuget.exe in Build.BinariesDirectory it will be compared against the supplied version. If the supplied version is greater than what is found or if no version exists the exact version you requested will be fetched from nuget.org.  The version must be available at https://dist.nuget.org/win-x86-commandline/v$YOUR-VERSION-HERE/nuget.exe.
