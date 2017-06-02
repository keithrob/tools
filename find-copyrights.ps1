<#
.SYNOPSIS
    Find copyrighted files in your git repo that aren't produced by your company.

.DESCRIPTION
    Greps files for lines containing "copyright".  If there are matching lines which
    do not contain your company name, do a git info on them to determine who checked 
    them in.

.PARAMETER company
    The case insensitive pattern (i.e. company name) that you want to match.

.PARAMETER extension
    The file extension you want to match.

.PARAMETER outfile
    Optional file write CSV formatted output to.  Default is stdout.

.NOTES
  Author:  Keith Robertson <keithro@gmail.com>

.EXAMPLE
    c:\PS> find-copyright -company foobar -extension .js -outfile data.csv
    c:\PS> cat data.csv
    CommitDate, CommitterEmail, FileName, Copyright
    2016-08-21T09:26:00-04:00; n00b@foobar.com; .\Scripts\lib\jquery-ui.min.js; * Copyright 2014 jQuery Foundation and other contributors; Licensed MIT */ 

#>
Param(
    [Parameter(Mandatory = $True,
               HelpMessage = "Your company's name")]
    [string]$company,
    [Parameter(Mandatory = $True,
               HelpMessage = "File extension (e.g. .js)")]
    [string]$extension,
    [string]$outfile
)


#
# Send to outfile or stdout.
# 
Function Emit-Output  {
    [cmdletbinding()]
    Param ([parameter(ValueFromPipeline)]
           [string]$pattern)
    Process  {
        if ($_.Trim()){
            if ($outfile) {
                $_ | Out-File -filepath $outfile -Append
            } 
            Else {
                Write-Host $_
            } 
        }
    }

}


#
# Main: Admittedly a gnarly chain, but I was fooling around trying to see if I could do it in oneline from the prompt ;)
# 
Get-ChildItem -Filter "*$extension" -Recurse | 
Select-String -Pattern "^(?!.*$company).*copyright.*$" -List | 
% {"CommitDate; CommitterEmail; FileName; CopyrightLine"} { `
    "$(If (&git check-ignore (Get-Item $_.Path | Resolve-Path -Relative)) `
        { Write-verbose "Ignored: $(Get-Item $_.Path | Resolve-Path -Relative)"} ` 
       Else ` 
        {"$(&git log -1 --format="%cI; %ce;" --reverse (Get-Item $_.Path | Resolve-Path -Relative))", `
        "$(Get-Item $_.Path | Resolve-Path -Relative);", `
        $(If ($_.Matches.Value.length -gt 80) `
           {$_.Matches.Value.substring(0,80)} 
          Else `
           {$_.Matches.Value.substring(0,$_.Matches.Value.length)})  }) "} |
Emit-Output




