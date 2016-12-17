Import-Module WindowsShell -Force

Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}

Describe Test-ShellLibraryFolder {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "Test-ShellLibraryFolder-$guidFrag"
    $folderPath = Join-Path ([System.IO.Path]::GetTempPath()) "folder-$guidFrag"
    Context 'set up' {
        It 'create the library' {
            Invoke-ProcessShellLibrary Set Present $libraryName
            $r = Invoke-ProcessShellLibrary Test Present $libraryName
            $r | Should be $true
        }
        It 'create the file system folder' {
            New-Item $folderPath -ItemType Directory -Force
            Test-Path $folderPath | Should be $true
        }
    }
    Context 'folder doesn''t exist' {
        It 'returns false' {
            $r = $libraryName | Test-ShellLibraryFolder $folderPath
            $r | Should be $false
        }
    }
    Context 'folder exists' {
        It 'create the folder' {
            try
            {
                $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folderPath)
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.Add($f)
            }
            finally
            {
                $f.Dispose()
                $l.Dispose()
            }
        }
        It 'returns true' {
            $r = $libraryName | Test-ShellLibraryFolder $folderPath
            $r | Should be $true
        }
    }
    Context 'the folder exists but underlying file system folder does not' {
        It 'remove the file system folder' {
            Remove-Item $folderPath
            Test-Path $folderPath | Should be $false
        }
        It 'returns true' {
            $r = $libraryName | Test-ShellLibraryFolder $folderPath
            $r | Should be $true
        }
    }
    Context 'the folder exists but the underlying file system path is a file' {
        It 'create the file at the folder path' {
            New-Item $folderPath -ItemType File
            Test-Path $folderPath -PathType Leaf | Should be $true
        }
        It 'returns true' {
            $r = $libraryName | Test-ShellLibraryFolder $folderPath
            $r | Should be $true
        }
    }
    Context 'the folder does not exist and neither does the file system folder' {
        It 'remove what''s at FolderPath' {
            Remove-Item $folderPath
            Test-Path $folderPath | Should be $false
        }
        It 'returns false' {
            $r = $libraryName | Test-ShellLibraryFolder 'c:\c41f5bdb-478a-40d1-9589-b26cf35e1b33'
            $r | Should be $false
        }
    }
    Context 'library doesn''t exist' {
        It 'remove the library' {
            Invoke-ProcessShellLibrary Set Absent $libraryName
            $r = Invoke-ProcessShellLibrary Test Absent $libraryName
            $r | Should be $true
        }
        It 'returns false' {
            $r = $libraryName | Test-ShellLibraryFolder $folderPath
            $r | Should be $false            
        }
    }
}

Describe Add-ShellLibraryFolder {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "Add-ShellLibraryFolder-$guidFrag"
    $folderPath = Join-Path ([System.IO.Path]::GetTempPath()) "folder-$guidFrag"
    Context 'set up' {
        It 'create the file system folder' {
            New-Item $folderPath -ItemType Directory
            Test-Path $folderPath | Should be $true
        }
    }
    Context 'folder doesn''t exist' {
        It 'create the library' {
            Invoke-ProcessShellLibrary Set Present $libraryName
            $r = Invoke-ProcessShellLibrary Test Present $libraryName
            $r | Should be $true
        }
        It 'returns nothing' {
            $r = $libraryName | Add-ShellLibraryFolder $folderPath
            $r | Should beNullOrEmpty
        }
        It 'the folder exists' {
            $r = $libraryName | Test-ShellLibraryFolder $folderPath
            $r | Should be $true
        }
    }
    Context 'folder exists' {
        It 'throws correct exception' {
            { $libraryName | Add-ShellLibraryFolder $folderPath } |
                Should throw "folder $folderPath already exists"
        }
    }
    Context 'library doesn''t exist' {
        It 'throws correct exception' {
            $libraryName = "NotExists-$guidFrag"
            { $libraryName | Add-ShellLibraryFolder $folderPath } |
                Should throw "library named $libraryName does not exist"
        }
    }
    Context 'file system folder does not exist' {
        It 'remove the file system folder' {
            Remove-Item $folderPath -Force
            Test-Path $folderPath | Should be $false
        }
        It 're-create the library' {
            Invoke-ProcessShellLibrary Set Absent $libraryName
            $r = Invoke-ProcessShellLibrary Test Absent $libraryName
            $r | Should be $true
            Invoke-ProcessShellLibrary Set Present $libraryName
            $r = Invoke-ProcessShellLibrary Test Present $libraryName
            $r | Should be $true
        }
        It 'throws correct exception' {
            { $libraryName | Add-ShellLibraryFolder $folderPath } |
                Should throw "folder $folderPath does not exist"
        }
    }
    Context 'item on file system is a file' {
        It 'create the file' {
            New-Item $folderPath -ItemType File
            Test-Path $folderPath -PathType Leaf | Should be $true
        }
        It 'throws correct exception' {
            { $libraryName | Add-ShellLibraryFolder $folderPath } |
                Should throw "$folderPath is a file"
        }
    }
    Context 'clean up' {
        It 'remove the library' {
            Invoke-ProcessShellLibrary Set Absent $libraryName
            $r = Invoke-ProcessShellLibrary Test Absent $libraryName
            $r | Should be $true
        }
    }
}