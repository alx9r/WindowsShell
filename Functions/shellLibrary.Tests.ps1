Import-Module WindowsShell -Force

Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}

Describe Test-ValidShellLibraryTypeName {
    It 'returns true for valid name' {
        $r = 'Pictures' | Test-ValidShellLibraryTypeName
        $r | Should be $true
    }
    It 'returns false for invalid name' {
        $r = 'Invalid Type Name' | Test-ValidShellLibraryTypeName
        $r | Should be $false
    }
    It 'throws for invalid name' {
        { 'Invalid Type Name' | Test-ValidShellLibraryTypeName -ea Stop } |
            Should throw 'not a valid'
    }
}