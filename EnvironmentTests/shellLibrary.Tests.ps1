<#
Keeping any reference to an object returned by a call to WindowsAPICodePack.Shell.ShellLibrary
can cause errors on subsequent calls.  The solution to this seems to be to relinquish all
references to WindowsAPICodePack.Shell.ShellLibrary then collect garbage between calls.
#>

Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}

Describe "ShellLibrary" {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "MyLibrary-$guidFrag"
    $h = @{}
    Context 'creation' {
        It 'create a new library' {
            try
            {
                $overwrite = $false
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$overwrite)
                $l.GetType() | Should be 'Microsoft.WindowsAPICodePack.Shell.ShellLibrary'
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'get the new library' {
            try
            {
                $readonly = $false
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$readonly)
                $l.GetType() | Should be 'Microsoft.WindowsAPICodePack.Shell.ShellLibrary'
                $l.Name | Should be $libraryName
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'creating the library again without overwrite set throws' {
            { [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$false) } |
                Should throw 'already exists'
        }
    }
    Context 'library type' {
        It 'get the library''s type' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $r = $l.LibraryType
                $r | Should beNullOrEmpty
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'set the new library''s type' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.LibraryType = [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::Pictures
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'modifying the new library''s type with readonly set throws' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$true)
                { $l.LibraryType = [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::Pictures } |
                    Should throw 'Access Denied'
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'get the library''s type' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.LibraryType | Should be 'Pictures'
            }
            finally
            {
                $l.Dispose()
            }
        }
    }
    Context 'icon' {
        It 'get the library''s icon' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.IconResourceId.ReferencePath | Should beNullOrEmpty
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'set the new library''s icon' {
            try
            {
                $i = [Microsoft.WindowsAPICodePack.Shell.IconReference]::new('C:\WINDOWS\system32\imageres.dll,-94')
                $i.GetType() | Should be 'Microsoft.WindowsAPICodePack.Shell.IconReference'
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.IconResourceId = $i
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'get the library''s icon' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.IconResourceId.ReferencePath | Should be 'C:\WINDOWS\system32\imageres.dll,-94'
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'modifying the new library''s icon with readonly set throws' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$true)
                $i = [Microsoft.WindowsAPICodePack.Shell.IconReference]::new('C:\WINDOWS\system32\imageres.dll,-94')
                { $l.IconResourceId = $i } |
                    Should throw 'Access Denied'
            }
            finally
            {
                $l.Dispose()
            }
        }
    }
    Context 'deletion' {
        It 'compose the path to the library' {
            $librariesPath = [System.IO.Path]::Combine(
                [System.Environment]::GetFolderPath( [System.Environment+SpecialFolder]::ApplicationData ),
                [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::LibrariesKnownFolder.RelativePath
            )
            $libraryPath = [System.IO.Path]::Combine($librariesPath, $libraryName);
            $h.NewLibraryPath = [System.IO.Path]::ChangeExtension($libraryPath, "library-ms")
        }
        It 'get the library item' {
            $r = Get-Item $h.NewLibraryPath -ea Stop
            $r | Should not beNullOrEmpty
        }
        It 'remove the new library' {
            [System.IO.File]::Delete($h.NewLibraryPath)
        }
        It 'the library item can no longer be retrieved' {
            { Get-Item $h.NewLibraryPath -ea Stop } |
                Should throw 'it does not exist'
        }
        It 'testing the library path returns false' {
            $r = Test-Path $h.NewLibraryPath -ea Stop
            $r | Should be $false
        }
        It 'the removed library can no longer be loaded' {
            { [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false) } |
                Should throw 'Shell Exception has occurred'
        }
    }
    Context 're-creation' {
        It 'the removed library can be created again without overwrite flag' {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$false)
            $l.Dispose()
        }
        It 'get the library again' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.Name | Should be $libraryName
            }
            finally
            {
                $l.Dispose()
            }
        }
    }
    Context 'overwriting' {
        It 'the library''s type is empty' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.LibraryType | Should beNullOrEmpty        
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'set the library''s type' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.LibraryType = [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::Pictures
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'get the library''s type' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.LibraryType | Should be 'Pictures'
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'overwrite the library' {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$true)
            $l.Dispose()
        }
        It 'the library''s type is empty again' {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $l.LibraryType | Should beNullOrEmpty        
        }
    }
    Context 'cleanup' {
        It 'remove the new library' {
            [System.IO.File]::Delete($h.NewLibraryPath)
        }
    }
}
