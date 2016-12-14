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
        It 'confirm that real library was created' {
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