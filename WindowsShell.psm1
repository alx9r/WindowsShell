$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

# dot source the external dependencies...
"$moduleRoot\External\*.ps1" |
    Get-Item |
    ? { $_.Name -notmatch 'Tests\.ps1$' } |
    % { . $_.FullName }

# load the Windows API Code Pack Assembly
Add-Type -Path "$moduleRoot\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"

# load the type files...
. "$moduleRoot\Functions\LoadTypes.ps1"

# ...and then the remaining .ps1 files
"$moduleRoot\Functions\*.ps1" |
    Get-Item |
    ? {
        $_.Name -notmatch 'Tests\.ps1$' -and
        $_.Name -notmatch 'Types?\.ps1$'
    } |
    % { . $_.FullName }

Export-ModuleMember -Function @(
    'Invoke-ProcessShellLibrary'
    'Invoke-ProcessShellLibraryFolder'
    'Invoke-ProcessShortcut'
)
