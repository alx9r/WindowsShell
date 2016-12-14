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

Describe Test-ValidStockIconName {
    It 'returns true for valid name' {
        $r = 'Application' | Test-ValidStockIconName
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

Describe Invoke-ProcessShellLibrary {
    InModuleScope WindowsShell {
        Context 'not present, Set Present' {
            Mock Get-ShellLibrary -Verifiable
            Mock Add-ShellLibrary {
                New-Object ShellLibrary -Property @{
                    Name = 'libary name'
                }
            } -Verifiable
            Mock Set-ShellLibraryType -Verifiable
            Mock Set-ShellLibraryIcon -Verifiable
            It 'returns nothing' {
                $splat = @{
                    Mode = 'Set'
                    Name = 'library name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
                $r = Invoke-ProcessShellLibrary @splat
                $r | Should beNullOrEmpty
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Set-ShellLibraryType 1 { $TypeName -eq 'Pictures' }
                Assert-MockCalled Set-ShellLibraryIcon 1 { $StockIconName -eq 'Application' }
            }
        }
        Context 'present, Set Present' {
            Mock Get-ShellLibrary {
                New-Object ShellLibrary -Property @{
                    Name = 'libary name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
            } -Verifiable
            Mock Add-ShellLibrary -Verifiable
            Mock Set-ShellLibraryType -Verifiable
            Mock Set-ShellLibraryIcon -Verifiable
            It 'returns nothing' {
                $splat = @{
                    Mode = 'Set'
                    Name = 'library name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
                $r = Invoke-ProcessShellLibrary @splat
                $r | Should beNullOrEmpty
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary -Exactly -Times 0
                Assert-MockCalled Set-ShellLibraryType -Exactly -Times 0
                Assert-MockCalled Set-ShellLibraryIcon -Exactly -Times 0
            }
        }
    }
}