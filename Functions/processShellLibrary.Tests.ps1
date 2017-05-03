Import-Module WindowsShell -Force

InModuleScope WindowsShell {

Describe Test-ValidShellLibraryTypeName {
    It 'returns true for valid name' {
        $r = 'Pictures' | Test-ValidShellLibraryTypeName
        $r | Should be $true
    }
    It 'returns true for DoNotSet' {
        $r = 'DoNotSet' | Test-ValidShellLibraryTypeName
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

Describe 'Invoke-ProcessShellLibrary -Ensure Present' {
    Mock Get-IconReferencePath -Verifiable
    Mock Invoke-ProcessPersistentItem { 'return value' } -Verifiable
    Context 'plumbing' {
        Mock Get-IconReferencePath { 'icon reference path' } -Verifiable
        It 'returns exactly one item' {
            $params = New-Object psobject -Property @{
                Mode = 'Set'
                Ensure = 'Present'
                Name = 'name'
                TypeName = 'Pictures'
                StockIconName = 'AudioFiles'
                IconFilePath = 'c:/filepath'
                IconResourceId = 1
            }
            $r = $params | Invoke-ProcessShellLibrary
            $r.Count | Should be 1
            $r | Should be 'return value'
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-IconReferencePath 1 {
                $StockIconName -eq 'AudioFiles' -and
                $IconFilePath -eq 'c:/filepath' -and
                $IconResourceId -eq 1
            }
            Assert-MockCalled Invoke-ProcessPersistentItem 1 {
                $Mode -eq 'Set' -and
                $Ensure -eq 'Present' -and
                $Keys.Name -eq 'name' -and

                #Properties
                $Properties.TypeName -eq 'Pictures' -and
                $Properties.IconReferencePath -eq 'icon reference path' # <- icon
            }
        }
    }
    Context 'omit optional' {
        It 'returns exactly one item' {
            $params = New-Object psobject -Property @{
                Mode = 'Set'
                Ensure = 'Present'
                Name = 'name'
                TypeName = 'DoNotSet'
            }
            $r = $params | Invoke-ProcessShellLibrary
            $r.Count | Should be 1
            $r | Should be 'return value'
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Invoke-ProcessPersistentItem 1 {
                $Mode -eq 'Set' -and
                $Ensure -eq 'Present' -and
                $Keys.Name -eq 'name' -and

                #Properties
                $Properties.Count -eq 0
            }
        }
    }
}
}
