Describe 'import WindowsShell module' {
    It 'import' {
        Import-Module WindowsShell
    }
    It 'get' {
        $r = Get-Module WindowsShell
        $r | Should not beNullOrEmpty
    }
    It 'an instance from this folder was loaded' {
        $r = (Get-Module WindowsShell).ModuleBase
        $PSScriptRoot | Should be $r
    }
}
Describe 'loading DSC Resources' {
    foreach ( $name in 'Shortcut','ShellLibrary','ShellLibraryFolder' )
    {
        Context $name {
            It 'get' {
                $r = Get-DscResource $name WindowsShell
                $r | Should not beNullOrEmpty
            }
            It 'an instance from this folder was loaded' {
                $r = Get-DscResource $name WindowsShell |
                   ? { $PSScriptRoot -eq $_.Module.ModuleBase }
                $r | Should be $true
            }
            It 'the instance with the latest version is from this folder' {
                $r = Get-DscResource $name WindowsShell |
                    Sort Version |
                    Select -Last 1
                $r.Module.ModuleBase | Should be $PSScriptRoot
            }
        }
    }
}