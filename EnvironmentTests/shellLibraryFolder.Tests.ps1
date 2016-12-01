Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}
Describe 'ShellLibrary folder' {
    $libraryName = "Folders-8e6ae476"
    It 'create a ShellLibrary' {
        [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$true)
    }
    Context 'add and remove string, and list pipeline' {
        It 'add a folder' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.Add($PSScriptRoot)
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'list the folder' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $r = $l | % Name
                $r.Count | Should be 1
                $r | Should be ($PSScriptRoot | Split-Path -Leaf)
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'remove the folder' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.Remove($PSScriptRoot)
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'the folder is no longer in the list' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $r = $l | % Name
                $r | Should beNullOrEmpty
            }
            finally
            {
                $l.Dispose()
            }
        }
    }
    Context 'add, test, select, and remove using ShellFileSystemFolder' {
        It 'add a folder' {
            try
            {
                $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.Add($f)
            }
            finally
            {
                $f.Dispose()
                $l.Dispose()
            }
        }
        It 'library contains folder' {
            try
            {
                $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $r = $l.Contains($f)
                $r | Should be $true
            }
            finally
            {
                $f.Dispose()
                $l.Dispose()
            }
        }
        It 'retrieve the folder' {
            try
            {
                $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $i = $l.IndexOf($f)
                $i | Should be 0
                $r = $l.Item($i)
                $r.Path | Should be $PSScriptRoot
            }
            finally
            {
                $f.Dispose()
                $l.Dispose()
            }
        }
        It 'remove the folder' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
                $r = $l.Remove($f)
                $r | Should be $true
            }
            finally
            {
                $f.Dispose()
                $l.Dispose()
            }
        }
        It 'library does not contain folder' {
            try
            {
                $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $r = $l.Contains($f)
                $r | Should be $false
            }
            finally
            {
                $f.Dispose()
                $l.Dispose()
            }
        }
        It 'IndexOf() returns -1 for folder' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)        
                $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
                $i = $l.IndexOf($f)
                $i | Should be -1
            }
            finally
            {
                $f.Dispose()
                $l.Dispose()
            }
        }
        It 'remove returns false for folder' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
                $r = $l.Remove($f)
                $r | Should be $false
            }
            finally
            {
                $f.Dispose()
                $l.Dispose()
            }
        }
    }
    Context 'cleanup' {
        $h = @{}
        It 'compose the library path' {
            $librariesPath = [System.IO.Path]::Combine(
                [System.Environment]::GetFolderPath( [System.Environment+SpecialFolder]::ApplicationData ),
                [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::LibrariesKnownFolder.RelativePath
            )
            $libraryPath = [System.IO.Path]::Combine($librariesPath, $libraryName);
            $h.FullPath = [System.IO.Path]::ChangeExtension($libraryPath, "library-ms")
        }
        It 'delete the library if it exists' {
            Remove-Item $h.FullPath -ErrorAction SilentlyContinue
        }
    }
}