Import-Module WindowsShell -Force

Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}

Describe Get-ShellLibrary {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "Get-ShellLibrary-$guidFrag"
    Context 'library exists' {
        It 'manually create a real library' {
            try
            {
                $overwrite = $false
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$overwrite)
                $l.IconResourceId = [Microsoft.WindowsAPICodePack.Shell.IconReference]::new('C:\WINDOWS\system32\imageres.dll,-94')
                $l.LibraryType = [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::Pictures
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'returns exactly one ShellLibrary object' {
            $r = $libraryName | Get-ShellLibrary
            $r.Count | Should be 1
            $r.Name | Should be $libraryName
            $r.GetType() | Should be 'ShellLibrary'
        }
        It 'populates type name' {
            $r = $libraryName | Get-ShellLibrary
            $r.TypeName | Should be 'Pictures'
        }
        It 'populates icon reference path' {
            $r = $libraryName | Get-ShellLibrary
            $r.IconReferencePath | Should be 'C:\WINDOWS\system32\imageres.dll,-94'
        }
        It 'manually remove the real library' {
            [System.IO.File]::Delete(($libraryName | Get-ShellLibraryPath))
        }
    }
    Context 'library does not exist' {
        It 'returns nothing' {
            $r = $libraryName | Get-ShellLibrary
            $r | Should beNullOrEmpty
        }
    }
}

Describe Add-ShellLibrary {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "Add-ShellLibrary-$guidFrag"
    $h = @{}
    Context 'library doesn''t exist' {
        It 'returns exactly one ShellLibrary object' {
            $h.L = $libraryName | Add-ShellLibrary
            $h.L.Count | Should be 1
            $h.L.GetType() | Should be 'ShellLibrary'
        }
        It 'type name is empty' {
            $h.L.TypeName | Should beNullOrEmpty
        }
        It 'icon reference path is empty' {
            $h.L.IconReferencePath | Should beNullOrEmpty
        }
        It 'that real library was created' {
            $r = $libraryName | Test-ShellLibrary
            $r | Should be $true
            $r = $libraryName | Get-ShellLibrary
            $r.Name | Should be $libraryName
        }
    }
    Context 'library exists' {
        It 'throws correct exception' {
            { $libraryName | Add-ShellLibrary } |
                Should throw "library named $libraryName already exists"
        }
    }
    Context 'cleanup' {
        It 'manually remove the real library' {
            [System.IO.File]::Delete(($libraryName | Get-ShellLibraryPath))
        }
    }
}

Describe Remove-ShellLibrary {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "Remove-ShellLibrary-$guidFrag"
    Context 'library exists' {
        It 'create the library' {
            $libraryName | Add-ShellLibrary
        }
        It 'the library exists' {
            $r = $libraryName | Test-ShellLibrary
            $r | Should be $true
            $r = $libraryName | Get-ShellLibrary
            $r.Name | Should be $libraryName
        }
        It 'returns nothing' {
            $r = $libraryName | Remove-ShellLibrary
            $r | Should beNullOrEmpty
        }
        It 'the library no longer exists' {
            $r = $libraryName | Test-ShellLibrary
            $r | Should be $false
        }
    }
    Context 'library does not exist' {
        It 'the library does not exist' {
            $r = $libraryName | Test-ShellLibrary
            $r | Should be $false
        }
        It 'throws correct exception' {
            { $libraryName | Remove-ShellLibrary } |
                Should throw "library named $libraryName not found"
        }
    }
}

Describe Set-ShellLibraryType {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "Set-ShellLibraryType-$guidFrag"
    Context 'library exists' {
        It 'create the library' {
            $libraryName | Add-ShellLibrary
        }
        It 'the library exists' {
            $r = $libraryName | Test-ShellLibrary
            $r | Should be $true
        }
        It 'the type name is empty' {
            $r = $libraryName | Get-ShellLibrary
            $r.TypeName | Should beNullOrEmpty
        }
        It 'returns nothing' {
            $r = $libraryName | Set-ShellLibraryType 'Pictures'
            $r | Should beNullOrEmpty
        }
        It 'the type name is correct' {
            $r = $libraryName | Get-ShellLibrary
            $r.TypeName | Should be 'Pictures'
        }
    }
    Context 'cleanup' {
        It 'remove the library' {
            $libraryName | Remove-ShellLibrary
        }
    }
    Context 'library does not exist' {
        It 'the library does not exist' {
            $r = $libraryName | Test-ShellLibrary
            $r | Should be $false
        }
        It 'throws correct exception' {
            { $libraryName | Set-ShellLibraryType 'Pictures' } |
                Should throw "library named $libraryName not found"
        }
    }
}

Describe Get-StockIconReferencePath {
    It 'returns correct value' {
        $r = 'World' | Get-StockIconReferencePath
        $r | Should be 'C:\WINDOWS\system32\imageres.dll,-152'
    }
}

Describe Set-ShellLibraryStockIcon {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "Set-ShellLibraryStockIcon-$guidFrag"
    Context 'library exists' {
        It 'create the library' {
            $libraryName | Add-ShellLibrary
        }
        It 'the library exists' {
            $r = $libraryName | Test-ShellLibrary
            $r | Should be $true
        }
        It 'the icon referance path is empty' {
            $r = $libraryName | Get-ShellLibrary
            $r.IconReferencePath | Should beNullOrEmpty
        }
        It 'returns nothing' {
            $r = $libraryName | Set-ShellLibraryStockIcon 'Application'
            $r | Should beNullOrEmpty
        }
        It 'the icon reference path is correct' {
            $r = $libraryName | Get-ShellLibrary
            $r.IconReferencePath | Should be 'C:\WINDOWS\system32\imageres.dll,-15'
        }
    }
    Context 'cleanup' {
        It 'remove the library' {
            $libraryName | Remove-ShellLibrary
        }
    }
    Context 'library does not exist' {
        It 'the library does not exist' {
            $r = $libraryName | Test-ShellLibrary
            $r | Should be $false
        }
        It 'throws correct exception' {
            { $libraryName | Set-ShellLibraryStockIcon 'Application' } |
                Should throw "library named $libraryName not found"
        }
    }
}
