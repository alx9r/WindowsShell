$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

# load the Windows API Code Pack Assembly
Add-Type -Path "$moduleRoot\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"

# load the .ps1 files
"$moduleRoot\Functions\*.ps1" |
    Get-Item |
    ? { $_.Name -notmatch 'Tests\.ps1$' } |
    % { . $_.FullName }