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

Describe 'Invoke-ProcessShellLibrary -Ensure Present' {
    InModuleScope WindowsShell {
        Mock Get-ShellLibrary -Verifiable
        Mock Add-ShellLibrary -Verifiable
        Mock Remove-ShellLibrary -Verifiable
        Mock Set-ShellLibraryType -Verifiable
        Mock Set-ShellLibraryStockIcon -Verifiable
        Context 'not present, Set' {
            Mock Add-ShellLibrary {
                New-Object ShellLibrary -Property @{
                    Name = 'libary name'
                }
            } -Verifiable
            It 'returns nothing' {
                $splat = @{
                    Name = 'library name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
                $r = Invoke-ProcessShellLibrary Set @splat
                $r | Should beNullOrEmpty
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Remove-ShellLibrary 0 -Exactly
                Assert-MockCalled Set-ShellLibraryType 1 { $TypeName -eq 'Pictures' }
                Assert-MockCalled Set-ShellLibraryStockIcon 1 { $StockIconName -eq 'Application' }
            }
        }
        Context 'not present, Test' {
            It 'returns false' {
                $splat = @{
                    Name = 'library name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
                $r = Invoke-ProcessShellLibrary Test @splat
                $r.Count | Should be 1
                $r | Should be $false
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary 0 -Exactly
                Assert-MockCalled Remove-ShellLibrary 0 -Exactly
                Assert-MockCalled Set-ShellLibraryType 0 -Exactly
                Assert-MockCalled Set-ShellLibraryStockIcon 0 -Exactly
            }
        }
        Context 'present, Set' {
            Mock Get-ShellLibrary {
                New-Object ShellLibrary -Property @{
                    Name = 'libary name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
            } -Verifiable
            It 'returns nothing' {
                $splat = @{
                    Name = 'library name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
                $r = Invoke-ProcessShellLibrary Set @splat
                $r | Should beNullOrEmpty
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary 0 -Exactly
                Assert-MockCalled Remove-ShellLibrary 0 -Exactly
                Assert-MockCalled Set-ShellLibraryType 0 -Exactly
                Assert-MockCalled Set-ShellLibraryStockIcon 0 -Exactly
            }
        }
        Context 'present, Test' {
            Mock Get-ShellLibrary {
                New-Object ShellLibrary -Property @{
                    Name = 'libary name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
            } -Verifiable
            It 'returns true' {
                $splat = @{
                    Name = 'library name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
                $r = Invoke-ProcessShellLibrary Test @splat
                $r.Count | Should be 1
                $r | Should be $true
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary 0 -Exactly
                Assert-MockCalled Remove-ShellLibrary 0 -Exactly
                Assert-MockCalled Set-ShellLibraryType 0 -Exactly
                Assert-MockCalled Set-ShellLibraryStockIcon 0 -Exactly
            }
        }
        Context 'present wrong type, Test' {
            Mock Get-ShellLibrary {
                New-Object ShellLibrary -Property @{
                    Name = 'libary name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
            } -Verifiable
            It 'returns false' {
                $splat = @{
                    Name = 'library name'
                    TypeName = 'Music'
                    StockIconName = 'Application'
                }
                $r = Invoke-ProcessShellLibrary Test @splat
                $r.Count | Should be 1
                $r | Should be $false
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary 0 -Exactly
                Assert-MockCalled Remove-ShellLibrary 0 -Exactly
                Assert-MockCalled Set-ShellLibraryType 0 -Exactly
                Assert-MockCalled Set-ShellLibraryStockIcon 0 -Exactly
            }
        }
        Context 'present wrong icon, Test' {
            Mock Get-ShellLibrary {
                New-Object ShellLibrary -Property @{
                    Name = 'libary name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
            } -Verifiable
            It 'returns false' {
                $splat = @{
                    Name = 'library name'
                    TypeName = 'Pictures'
                    StockIconName = 'Folder'
                }
                $r = Invoke-ProcessShellLibrary Test @splat
                $r.Count | Should be 1
                $r | Should be $false
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary 0 -Exactly
                Assert-MockCalled Remove-ShellLibrary 0 -Exactly
                Assert-MockCalled Set-ShellLibraryType 0 -Exactly
                Assert-MockCalled Set-ShellLibraryStockIcon 0 -Exactly
            }
        }
    }
}

Describe 'Invoke-ProcessShellLibrary -Ensure Absent' {
    InModuleScope WindowsShell {
        Mock Get-ShellLibrary -Verifiable
        Mock Add-ShellLibrary -Verifiable
        Mock Remove-ShellLibrary -Verifiable
        Mock Set-ShellLibraryType -Verifiable
        Mock Set-ShellLibraryStockIcon -Verifiable
        Context 'not present, Set' {
            It 'returns nothing' {
                $splat = @{
                    Name = 'library name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
                $r = Invoke-ProcessShellLibrary Set Absent @splat
                $r | Should beNullOrEmpty
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary 0 -Exactly
                Assert-MockCalled Remove-ShellLibrary 0 -Exactly
                Assert-MockCalled Set-ShellLibraryType 0 -Exactly
                Assert-MockCalled Set-ShellLibraryStockIcon 0 -Exactly
            }
        }
        Context 'not present, Test' {
            It 'returns true' {
                $splat = @{
                    Name = 'library name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
                $r = Invoke-ProcessShellLibrary Test Absent @splat
                $r.Count | Should be 1
                $r | Should be $true
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary 0 -Exactly
                Assert-MockCalled Remove-ShellLibrary 0 -Exactly
                Assert-MockCalled Set-ShellLibraryType 0 -Exactly
                Assert-MockCalled Set-ShellLibraryStockIcon 0 -Exactly
            }
        }
        Context 'present, Set' {
            Mock Get-ShellLibrary {
                New-Object ShellLibrary -Property @{
                    Name = 'libary name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
            } -Verifiable
            It 'returns nothing' {
                $splat = @{
                    Name = 'library name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
                $r = Invoke-ProcessShellLibrary Set Absent @splat
                $r | Should beNullOrEmpty
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary 0 -Exactly
                Assert-MockCalled Remove-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Set-ShellLibraryType 0 -Exactly
                Assert-MockCalled Set-ShellLibraryStockIcon 0 -Exactly
            }
        }
        Context 'present, Test' {
            Mock Get-ShellLibrary {
                New-Object ShellLibrary -Property @{
                    Name = 'libary name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
            } -Verifiable
            It 'returns false' {
                $splat = @{
                    Name = 'library name'
                    TypeName = 'Pictures'
                    StockIconName = 'Application'
                }
                $r = Invoke-ProcessShellLibrary Test Absent @splat
                $r.Count | Should be 1
                $r | Should be $false
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Add-ShellLibrary 0 -Exactly
                Assert-MockCalled Remove-ShellLibrary 0 -Exactly
                Assert-MockCalled Set-ShellLibraryType 0 -Exactly
                Assert-MockCalled Set-ShellLibraryStockIcon 0 -Exactly
            }
        }
    }
}