Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}
Describe 'ShellLibrary folder' {
    $libraryName = "Folders-8e6ae476"
    AfterEach { [gc]::Collect() }
    It 'create a ShellLibrary' {
        [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$true)
    }
    Context 'add and remove string, and list pipeline' {
        It 'add a folder' {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r.Add($PSScriptRoot)
        }
        It 'list the folder' {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r = $l | % Name
            $r.Count | Should be 1
            $r | Should be ($PSScriptRoot | Split-Path -Leaf)
        }
        It 'remove the folder' {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $l.Remove($PSScriptRoot)
        }
        It 'the folder is no longer in the list' {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r = $l | % Name
            $r | Should beNullOrEmpty
        }
    }
    Context 'add, test, select, and remove using ShellFileSystemFolder' {
        It 'add a folder' {
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $l.Add($f)
        }
        It 'library contains folder' {
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r = $l.Contains($f)
            $r | Should be $true
        }
        It 'retrieve the folder' {
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $i = $l.IndexOf($f)
            $i | Should be 0
            $r = $l.Item($i)
            $r.Path | Should be $PSScriptRoot
        }
        It 'remove the folder' {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
            $r = $l.Remove($f)
            $r | Should be $true
        }
        It 'library does not contain folder' {
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $r = $l.Contains($f)
            $r | Should be $false
        }
        It 'IndexOf() returns -1 for folder' {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)        
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
            $i = $l.IndexOf($f)
            $i | Should be -1
        }
        It 'remove returns false for folder' {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($PSScriptRoot)
            $r = $l.Remove($f)
            $r | Should be $false
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