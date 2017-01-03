Import-Module WindowsShell -Force

Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}

Describe 'Invoke-ProcessShellLibraryFolder -Ensure Present' {
    InModuleScope WindowsShell {
        Mock Test-ShellLibrary { $true } -Verifiable
        Mock Test-ShellLibraryFolder -Verifiable
        Mock Add-ShellLibraryFolder -Verifiable
        Mock Remove-ShellLibraryFolder -Verifiable
        Context 'absent, Set'{
            It 'returns nothing' {
                $r = 'c:\folder' | Invoke-ProcessShellLibraryFolder Set Present 'library name'
                $r | Should beNullOrEmpty
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Test-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Test-ShellLibraryFolder 1 {
                    $LibraryName -eq 'library name' -and
                    $FolderPath -eq 'c:\folder'
                }
                Assert-MockCalled Add-ShellLibraryFolder 1 {
                    $LibraryName -eq 'library name' -and
                    $FolderPath -eq 'c:\folder'
                }
                Assert-MockCalled Remove-ShellLibraryFolder 0 -Exactly
            }
        }
        Context 'library missing, Set' {
            Mock Test-ShellLibrary { $false } -Verifiable
            It 'returns nothing' {
                $r = 'c:\folder' | Invoke-ProcessShellLibraryFolder Set Present 'library name'
                $r | Should beNullOrEmpty
            }
            It 'correctly invokes functions' {
                Assert-MockCalled Test-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Test-ShellLibraryFolder 0 -Exactly
                Assert-MockCalled Add-ShellLibraryFolder 0 -Exactly
                Assert-MockCalled Remove-ShellLibraryFolder 0 -Exactly
            }
        }
        Context 'absent, Test' {
            It 'returns false' {
                $r = 'c:\folder' | Invoke-ProcessShellLibraryFolder Test Present 'library name'
                $r | Should be $false
            }
            It 'correctly invokes functions ' {
                Assert-MockCalled Test-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Test-ShellLibraryFolder 1 {
                    $LibraryName -eq 'library name' -and
                    $FolderPath -eq 'c:\folder'
                }
                Assert-MockCalled Add-ShellLibraryFolder 0 -Exactly
                Assert-MockCalled Remove-ShellLibraryFolder 0 -Exactly
            }
        }
        Context 'present, Set' {
            Mock Test-ShellLibraryFolder { $true } -Verifiable
            It 'returns nothing' {
                $r = 'c:\folder' | Invoke-ProcessShellLibraryFolder Set Present 'library name'
                $r | Should beNullOrEmpty
            }
            It 'correctly invokes functions ' {
                Assert-MockCalled Test-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Test-ShellLibraryFolder 1 {
                    $LibraryName -eq 'library name' -and
                    $FolderPath -eq 'c:\folder'
                }
                Assert-MockCalled Add-ShellLibraryFolder 0 -Exactly
                Assert-MockCalled Remove-ShellLibraryFolder 0 -Exactly
            }
        }
        Context 'present, Test' {
            Mock Test-ShellLibraryFolder { $true } -Verifiable
            It 'returns true' {
                $r = 'c:\folder' | Invoke-ProcessShellLibraryFolder Test Present 'library name'
                $r | Should be $true
            }
            It 'correctly invokes functions ' {
                Assert-MockCalled Test-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Test-ShellLibraryFolder 1 {
                    $LibraryName -eq 'library name' -and
                    $FolderPath -eq 'c:\folder'
                }
                Assert-MockCalled Add-ShellLibraryFolder 0 -Exactly
                Assert-MockCalled Remove-ShellLibraryFolder 0 -Exactly
            }
        }
    }
}
Describe 'Invoke-ProcessShellLibraryFolder -Ensure Absent' {
    InModuleScope WindowsShell {
        Mock Test-ShellLibrary { $true } -Verifiable
        Mock Test-ShellLibraryFolder -Verifiable
        Mock Add-ShellLibraryFolder -Verifiable
        Mock Remove-ShellLibraryFolder -Verifiable
        Context 'absent, Set'{
            It 'returns nothing' {
                $r = 'c:\folder' | Invoke-ProcessShellLibraryFolder Set Absent 'library name'
                $r | Should beNullOrEmpty
            }
            It 'correctly invokes functions ' {
                Assert-MockCalled Test-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Test-ShellLibraryFolder 1 {
                    $LibraryName -eq 'library name' -and
                    $FolderPath -eq 'c:\folder'
                }
                Assert-MockCalled Add-ShellLibraryFolder 0 -Exactly
                Assert-MockCalled Remove-ShellLibraryFolder 0 -Exactly
            }
        }
        Context 'absent, Test' {
            It 'returns true' {
                $r = 'c:\folder' | Invoke-ProcessShellLibraryFolder Test Absent 'library name'
                $r | Should be $true
            }
            It 'correctly invokes functions ' {
                Assert-MockCalled Test-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Test-ShellLibraryFolder 1 {
                    $LibraryName -eq 'library name' -and
                    $FolderPath -eq 'c:\folder'
                }
                Assert-MockCalled Add-ShellLibraryFolder 0 -Exactly
                Assert-MockCalled Remove-ShellLibraryFolder 0 -Exactly
            }
        }
        Context 'present, Set' {
            Mock Test-ShellLibraryFolder { $true } -Verifiable
            It 'returns nothing' {
                $r = 'c:\folder' | Invoke-ProcessShellLibraryFolder Set Absent 'library name'
                $r | Should beNullOrEmpty
            }
            It 'correctly invokes functions ' {
                Assert-MockCalled Test-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Test-ShellLibraryFolder 1 {
                    $LibraryName -eq 'library name' -and
                    $FolderPath -eq 'c:\folder'
                }
                Assert-MockCalled Add-ShellLibraryFolder 0 -Exactly
                Assert-MockCalled Remove-ShellLibraryFolder 1 {
                    $LibraryName -eq 'library name' -and
                    $FolderPath -eq 'c:\folder'
                }
            }
        }
        Context 'present, Test' {
            Mock Test-ShellLibraryFolder { $true } -Verifiable
            It 'returns false' {
                $r = 'c:\folder' | Invoke-ProcessShellLibraryFolder Test Absent 'library name'
                $r | Should be $false
            }
            It 'correctly invokes functions ' {
                Assert-MockCalled Test-ShellLibrary 1 { $Name -eq 'library name' }
                Assert-MockCalled Test-ShellLibraryFolder 1 {
                    $LibraryName -eq 'library name' -and
                    $FolderPath -eq 'c:\folder'
                }
                Assert-MockCalled Add-ShellLibraryFolder 0 -Exactly
                Assert-MockCalled Remove-ShellLibraryFolder 0 -Exactly
            }
        }
    }
}
