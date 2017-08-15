@{

# Script module or binary module file associated with this manifest.
RootModule = 'WindowsShell.psm1'
NestedModules = 'Shortcut.psm1','ShellLibrary.psm1','ShellLibraryFolder.psm1'
ScriptsToProcess = @(
    '.\dotNetTypes\ensure.ps1'
    '.\dotNetTypes\mode.ps1'
    '.\dotNetTypes\libraryTypeName.ps1'
    '.\dotNetTypes\stockIconName.ps1'
    '.\dotNetTypes\windowStyle.ps1'
)

DscResourcesToExport = '*'

# Version number of this module.
ModuleVersion = '0.2.1'

# ID used to uniquely identify this module
GUID = '31eacef0-4fab-41fd-ac9e-6c65b0098e1f'

# Author of this module
Author = 'alx9r'

# Copyright statement for this module
Copyright = '(c) 2016-2017 Microsoft. All rights reserved.'

# Description of the functionality provided by this module
# Description = ''

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''
}
