Import-Module WindowsShell -Force

Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}

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
    Mock Get-ShellLibrary -Verifiable
    Mock Add-ShellLibrary -Verifiable
    Mock Remove-ShellLibrary -Verifiable
    Mock Get-StockIconReferencePath {
        'C:\WINDOWS\system32\imageres.dll,-152'
    } -Verifiable
    Mock Set-ShellLibraryProperty -Verifiable
    Context 'absent, Set' {
        Mock Add-ShellLibrary {
            New-Object psobject -Property @{
                Name = 'libary name'
            }
        } -Verifiable
        It 'returns nothing' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Pictures'
                StockIconName = 'Application'
            }
            $r = $object | Invoke-ProcessShellLibrary Set
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 1 {
                $PropertyName -eq 'TypeName' -and
                $Value -eq 'Pictures'
            }
            Assert-MockCalled Get-StockIconReferencePath 1 {
                $StockIconName -eq 'Application'
            }
            Assert-MockCalled Set-ShellLibraryProperty 1 {
                $PropertyName -eq 'IconReferencePath' -and
                $Value -eq 'C:\WINDOWS\system32\imageres.dll,-152'
            }
        }
    }
    Context 'IconFilePath' {
        Mock Add-ShellLibrary {
            New-Object ShellLibraryInfo -Property @{
                Name = 'libary name'
            }
        } -Verifiable
        It 'returns nothing' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Pictures'
                IconFilePath = 'c:\folder\some.exe'
                IconResourceId = 0
            }
            $r = $object | Invoke-ProcessShellLibrary Set
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 1 {
                $PropertyName -eq 'TypeName' -and
                $Value -eq 'Pictures'
            }
            Assert-MockCalled Get-StockIconReferencePath 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 1 {
                $PropertyName -eq 'IconReferencePath' -and
                $Value -eq 'C:\folder\some.exe,0'
            }
        }
    }
    Context 'StockIcon and IconFilePath' {
        Mock Add-ShellLibrary {
            New-Object ShellLibraryInfo -Property @{
                Name = 'libary name'
            }
        } -Verifiable
        It 'returns nothing' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Pictures'
                StockIconName = 'Application'
                IconFilePath = 'c:\folder\some.exe'
            }
            $r = $object | Invoke-ProcessShellLibrary Set
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 1 {
                $PropertyName -eq 'TypeName' -and
                $Value -eq 'Pictures'
            }
            Assert-MockCalled Get-StockIconReferencePath 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 1 {
                $PropertyName -eq 'IconReferencePath' -and
                $Value -eq 'C:\folder\some.exe,0'
            }
        }
    }
    Context 'null optional properties' {
        Mock Add-ShellLibrary {
            New-Object ShellLibraryInfo -Property @{
                Name = 'libary name'
            }
        } -Verifiable
        It 'returns nothing' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
            }
            $r = $object | Invoke-ProcessShellLibrary Set
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly
            Assert-MockCalled Get-StockIconReferencePath 0 -Exactly
        }
    }
    Context 'omit optional properties' {
        Mock Add-ShellLibrary {
            New-Object ShellLibraryInfo -Property @{
                Name = 'libary name'
            }
        } -Verifiable
        It 'returns nothing' {
            $r = Invoke-ProcessShellLibrary Set Present 'library name'
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly
            Assert-MockCalled Get-StockIconReferencePath 0 -Exactly
        }
    }
    Context 'absent, Test' {
        It 'returns false' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Pictures'
                StockIconName = 'Application'
            }
            $r = $object | Invoke-ProcessShellLibrary Test
            $r.Count | Should be 1
            $r | Should be $false
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 0 -Exactly
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly
            Assert-MockCalled Get-StockIconReferencePath 0 -Exactly
        }
    }
    Context 'present, Set' {
        Mock Get-ShellLibrary {
            New-Object ShellLibraryInfo -Property @{
                Name = 'libary name'
                TypeName = 'Pictures'
                IconReferencePath = 'C:\WINDOWS\system32\imageres.dll,-152'
            }
        } -Verifiable
        It 'returns nothing' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Pictures'
                StockIconName = 'Application'
            }
            $r = $object | Invoke-ProcessShellLibrary Set
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 0 -Exactly
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'TypeName' }
            Assert-MockCalled Get-StockIconReferencePath 1
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'IconReferencePath' }
        }
    }
    Context 'present, Test' {
        Mock Get-ShellLibrary {
            New-Object ShellLibraryInfo -Property @{
                Name = 'libary name'
                TypeName = 'Pictures'
                IconReferencePath = 'C:\WINDOWS\system32\imageres.dll,-152'
            }
        } -Verifiable
        It 'returns true' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Pictures'
                StockIconName = 'Application'
            }
            $r = $object | Invoke-ProcessShellLibrary Test
            $r.Count | Should be 1
            $r | Should be $true
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 0 -Exactly
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'TypeName' }
            Assert-MockCalled Get-StockIconReferencePath 1
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'IconReferencePath' }
        }
    }
    Context 'present wrong type, Test' {
        Mock Get-ShellLibrary {
            New-Object ShellLibraryInfo -Property @{
                Name = 'libary name'
                TypeName = 'Pictures'
                IconReferencePath = 'C:\WINDOWS\system32\imageres.dll,-152'
            }
        } -Verifiable
        It 'returns false' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Music'
                StockIconName = 'Application'
            }
            $r = $object | Invoke-ProcessShellLibrary Test
            $r.Count | Should be 1
            $r | Should be $false
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 0 -Exactly
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'TypeName' }
            Assert-MockCalled Get-StockIconReferencePath 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'IconReferencePath' }
        }
    }
    Context 'present wrong icon, Test' {
        Mock Get-ShellLibrary {
            New-Object ShellLibraryInfo -Property @{
                Name = 'libary name'
                TypeName = 'Pictures'
                IconReferencePath = 'C:\WINDOWS\system32\imageres.dll,-94'
            }
        } -Verifiable
        It 'returns false' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Pictures'
                StockIconName = 'Application'
            }
            $r = $object | Invoke-ProcessShellLibrary Test
            $r.Count | Should be 1
            $r | Should be $false
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 0 -Exactly
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'TypeName' }
            Assert-MockCalled Get-StockIconReferencePath 1
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'IconReferencePath' }
        }
    }
}

Describe 'Invoke-ProcessShellLibrary -Ensure Absent' {
    Mock Get-ShellLibrary -Verifiable
    Mock Add-ShellLibrary -Verifiable
    Mock Remove-ShellLibrary -Verifiable
    Mock Get-StockIconReferencePath {
        'C:\WINDOWS\system32\imageres.dll,-152'
    } -Verifiable
    Mock Set-ShellLibraryProperty -Verifiable
    Context 'absent, Set' {
        It 'returns nothing' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Pictures'
                StockIconName = 'Application'
                Ensure = 'Absent'
            }
            $r = $object | Invoke-ProcessShellLibrary Set
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 0 -Exactly
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'TypeName' }
            Assert-MockCalled Get-StockIconReferencePath 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'IconReferencePath' }
        }
    }
    Context 'absent, Test' {
        It 'returns true' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Pictures'
                StockIconName = 'Application'
                Ensure = 'Absent'
            }
            $r = $object | Invoke-ProcessShellLibrary Test
            $r.Count | Should be 1
            $r | Should be $true
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 0 -Exactly
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'TypeName' }
            Assert-MockCalled Get-StockIconReferencePath 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'IconReferencePath' }
        }
    }
    Context 'present, Set' {
        Mock Get-ShellLibrary {
            New-Object ShellLibraryInfo -Property @{
                Name = 'libary name'
                TypeName = 'Pictures'
                IconReferencePath = 'C:\WINDOWS\system32\imageres.dll,-152'
            }
        } -Verifiable
        It 'returns nothing' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Pictures'
                StockIconName = 'Application'
                Ensure = 'Absent'
            }
            $r = $object | Invoke-ProcessShellLibrary Set
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 0 -Exactly
            Assert-MockCalled Remove-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'TypeName' }
            Assert-MockCalled Get-StockIconReferencePath 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'IconReferencePath' }
        }
    }
    Context 'present, Test' {
        Mock Get-ShellLibrary {
            New-Object ShellLibraryInfo -Property @{
                Name = 'libary name'
                TypeName = 'Pictures'
                IconReferencePath = 'C:\WINDOWS\system32\imageres.dll,-152'
            }
        } -Verifiable
        It 'returns false' {
            $object = New-Object psobject -Property @{
                Name = 'library name'
                TypeName = 'Pictures'
                StockIconName = 'Application'
                Ensure = 'Absent'
            }
            $r = $object | Invoke-ProcessShellLibrary Test
            $r.Count | Should be 1
            $r | Should be $false
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-ShellLibrary 1 { $Name -eq 'library name' }
            Assert-MockCalled Add-ShellLibrary 0 -Exactly
            Assert-MockCalled Remove-ShellLibrary 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'TypeName' }
            Assert-MockCalled Get-StockIconReferencePath 0 -Exactly
            Assert-MockCalled Set-ShellLibraryProperty 0 -Exactly -ParameterFilter { $PropertyName -eq 'IconReferencePath' }
        }
    }
}
}
