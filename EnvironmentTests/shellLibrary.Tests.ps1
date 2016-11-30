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
    AfterEach { [gc]::Collect() }
    Context 'creation' {
        It 'create a new library' {
            $overwrite = $false
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$overwrite)
            $r.GetType() | Should be 'Microsoft.WindowsAPICodePack.Shell.ShellLibrary'
        }
        It 'get the new library' {
            $readonly = $false
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$readonly)
            $r.GetType() | Should be 'Microsoft.WindowsAPICodePack.Shell.ShellLibrary'
            $r.Name | Should be $libraryName
        }
        It 'creating the library again without overwrite set throws' {
            { [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$false) } |
                Should throw 'already exists'
        }
    }
    Context 'library type' {
        It 'get the library''s type' {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r = $r.LibraryType
            $r | Should beNullOrEmpty
        }
        It 'set the new library''s type' {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r.LibraryType = [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::Pictures
        }
        It 'modifying the new library''s type with readonly set throws' {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$true)
            { $r.LibraryType = [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::Pictures } |
                Should throw 'Access Denied'
        }
        It 'get the library''s type' {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r.LibraryType | Should be 'Pictures'
        }
    }
    Context 'icon' {
        It 'set the new library''s icon' {
            $i = [Microsoft.WindowsAPICodePack.Shell.IconReference]::new('C:\WINDOWS\system32\imageres.dll,-94')
            $i.GetType() | Should be 'Microsoft.WindowsAPICodePack.Shell.IconReference'
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $l.IconResourceId = $i
        }
        It 'get the library''s icon' {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false).IconResourceId
            $r.ReferencePath | Should be 'C:\WINDOWS\system32\imageres.dll,-94'
        }
        It 'modifying the new library''s icon with readonly set throws' {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$true)
            $i = [Microsoft.WindowsAPICodePack.Shell.IconReference]::new('C:\WINDOWS\system32\imageres.dll,-94')
            { $l.IconResourceId = $i } |
                Should throw 'Access Denied'
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
            [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$false)
        }
        It 'get the library again' {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r.Name | Should be $libraryName
        }
    }
    Context 'overwriting' {
        It 'the library''s type is empty' {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r.LibraryType | Should beNullOrEmpty        
        }
        It 'set the library''s type' {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r.LibraryType = [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::Pictures
        }
        It 'get the library''s type' {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r.LibraryType | Should be 'Pictures'
        }
        It 'overwrite the library' {
            [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$true)
        }
        It 'the library''s type is empty again' {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r.LibraryType | Should beNullOrEmpty        
        }
    }
    Context 'cleanup' {
        It 'remove the new library' {
            [System.IO.File]::Delete($h.NewLibraryPath)
        }
    }
}
