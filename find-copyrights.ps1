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
           [string]$line)
    Process  {
        if ($line.Trim()){
            if ($outfile) {
                $line | Out-File -filepath $outfile -Append
            } 
            Else {
                Write-Host $line
            } 
        }
    }

}



#
# Fix git log -1
# 
Function Get-Author  {
    [cmdletbinding()]
    Param ([parameter(ValueFromPipeline)]
           [string]$filePath)
    Process  {
        # git -1 doesn't do what you would expect.  It returns the last line printed not the first.
        return &git log -2 --format="%cd; %ce" --reverse (Get-Item $filePath | Resolve-Path -Relative) | Select-Object -first 1
    }
}


#
# Get the matching line from the file.
# 
Function Get-MatchingLine  {
    [cmdletbinding()]
    Param ([parameter(ValueFromPipeline)]
           [string]$line)
    Process  {
        [string]$retVal = ""
        if ($line.length -gt 80) {
            $retVal = $line.substring(0,80)
        }else {
            $retVal = $line.substring(0,$line.length)
        } 
        # Remove semicolons since that is our CSV delimiter
        return $retVal.Replace(';','')
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
        {"$(Get-Author $_.Path)", `
        "$(Get-Item $_.Path | Resolve-Path -Relative);", `
        $(Get-MatchingLine $_)  })"} |
Emit-Output




