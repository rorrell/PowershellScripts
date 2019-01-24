<#
.SYNOPSIS
This script presupposes you have the following branches: develop, master, develop-staging, and master-staging.  It allows you to do one of the following: check if there's anything in develop-staging that's not in develop, the reverse of that, check if there's anything in master-staging that's not in master, or the reverse of that.

.DESCRIPTION
The idea is to let you know if you need to do a merge (if develop is behind develop-staging or master behind master-staging, that usually indicates we need to do a merge)

.PARAMETER branch
Enter develop or master (to deal with develop and develop-staging or master and master-staging)

.PARAMETER repo
This is the git repository you are checking

.PARAMETER reverseStr
This is Y if you want to do a backwards check (check if develop/master is ahead of develop-staging/master-staging instead of behind)

#>

Param(
    [String]$branch = $(Read-Host -prompt "Enter the branch you want to check (develop / master):"),
    [String]$repo = $(Read-Host -Prompt "Enter the repository you want check:"),
    [String]$reverseStr = $(Read-Host -prompt "Enter Y if you would like to check for anything that is in the branch that isn't in staging (rather than the opposite):")
)

function CheckDirectory($directory, $reverse) {
    write-host "$($directory)"
    write-host "--------------------------"
    Set-Location $directory
    git fetch *>$null
    if($reverse) {
        git log origin/$branch --not --remotes=*/$branch-staging --abbrev-commit --oneline
    }
    else {
        git log origin/$branch-staging --not --remotes=*/$branch --abbrev-commit --oneline
    }
    Set-Location $PSScriptRoot;
    write-host "--------------------------"
    write-host ""
}

CheckDirectory($repo, $reverseStr -eq 'Y' -or $reverseStr -eq 'y')

