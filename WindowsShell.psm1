Import-Module ToolFoundations -WarningAction SilentlyContinue

$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

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
    'Test-ValidShellLibraryName'
    'Add-ShellLibrary'
    'Add-ShellLibraryFolder'
    'Convert-ShellLibraryObject'
    'Get-ShellLibrary'
    'Get-ShellLibraryPath'
    'Get-StockIconReferencePath'
    'Invoke-ProcessShellLibrary'
    'Invoke-ProcessShellLibraryFolder'
    'Remove-ShellLibrary'
    'Remove-ShellLibraryFolder'
    'Set-ShellLibraryProperty'
    #'Sort-ShellLibraryFolders'
    'Test-ShellLibrary'
    'Test-ShellLibraryFolder'
    'Test-ShellLibraryFoldersSortOrder'
    'Test-ValidShellLibraryTypeName'
    'Test-ValidStockIconName'
)
