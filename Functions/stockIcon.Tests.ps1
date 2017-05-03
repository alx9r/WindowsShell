Import-Module WindowsShell -Force

Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}

InModuleScope WindowsShell {

Describe Test-ValidStockIconName {
    It 'returns true for valid name' {
        $r = 'Application' | Test-ValidStockIconName
        $r | Should be $true
    }
    It 'returns true for DoNotSet' {
        $r = 'DoNotSet' | Test-ValidStockIconName
        $r | Should be $true
    }
    It 'returns false for invalid name' {
        $r = 'Invalid Icon Name' | Test-ValidStockIconName
        $r | Should be $false
    }
    It 'throws for invalid name' {
        { 'Invalid Type Name' | Test-ValidStockIconName -ea Stop } |
            Should throw 'not a valid'
    }
}
}
