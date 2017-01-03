Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}
Describe 'ShellLibrary folder' {
    $libraryName = "Folders-8e6ae476"
    It 'create a ShellLibrary' {
        try
        {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$true)
        }
        finally
        {
            $l.Dispose()
        }
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
        It '.Item() throws for index past end' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                { $f = $l.Item(1) } |
                    Should throw 'Index was out of range'
            }
            finally
            {
                if ( $f ) { $f.Dispose() }
                if ( $l ) { $l.Dispose() }
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

    foreach ( $values in @(
            # indexOfSucceeds | path
            @( $true, 'c:\temp' ),
            @( $false, [System.IO.Path]::GetTempPath() ),
            @( $false, $env:APPDATA ),
            @( $true, $env:ProgramData ),
            @( $false, $env:USERPROFILE ),
            @( $false, "$env:USERPROFILE\Folder" ),
            @( $true, "$env:USERPROFILE\Documents" )
        )
    )
    {
        $indexOfSucceeds,$path = $values
        $folderPath = Join-Path $path 'Folder-5990a4a9'
        Context "add and retrieve folder $folderPath" {
            It 'create folder' {
                New-Item $folderPath -ItemType Directory -Force
            }
            It 'add a folder to library' {
                try
                {
                    $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folderPath)
                    $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$true)
                    $l.Add($f)
                }
                finally
                {
                    if ( $null -ne $f ) { $f.Dispose() }
                    if ( $null -ne $l ) { $l.Dispose() }
                }
            }
            It '.Contains() succeeds' {
                try
                {
                    $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folderPath)
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
            if ( $indexOfSucceeds )
            {
                It '.IndexOf() retrieving the folder from library succeeds' {
                    try
                    {
                        $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folderPath)
                        $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                        $i = $l.IndexOf($f)
                        $i | Should be 0
                        $r = $l.Item($i)
                        $r.Path | Should be $folderPath
                    }
                    finally
                    {
                        $f.Dispose()
                        $l.Dispose()
                    }
                }
            }
            else
            {
                It 'retrieving the folder from library fails' {
                    try
                    {
                        $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folderPath)
                        $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                        $i = $l.IndexOf($f)
                        $i | Should be -1
                    }
                    finally
                    {
                        $f.Dispose()
                        $l.Dispose()
                    }
                }
            }
            It 'search succeeds' {
                try
                {
                    $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                    $r = $l | ? { $_.Path -eq $folderPath }
                    $r.Path | Should be $folderPath
                    $r.GetType() | Should be 'Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder'
                }
                finally
                {
                    $l.Dispose()
                    $r.Dispose()
                }                
            }
            It 'remove succeeds' {
                try
                {
                    $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folderPath)
                    $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                    $r = $l.Remove($f)
                    $r | Should be $true
                }
                finally
                {
                    $f.Dispose()
                    $l.Dispose()
                }
            }
        }
    }
    Context 'folder order' {
        $tempPath = [System.IO.Path]::GetTempPath()
        $folder1Path = Join-path $tempPath "Folder1-a2cce939"
        $folder2Path = Join-path $tempPath "Folder2-a2cce939"
        It 'create folders' {
            New-Item $folder1Path,$folder2Path -ItemType Directory -Force
        }
        It 'add folders to library in order' {
            try
            {
                $f1 = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folder1Path)
                $f2 = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folder2Path)
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$true)
                $l.Add($f1)
                $l.Add($f2)
            }
            finally
            {
                $f1.Dispose()
                $f2.Dispose()
                $l.Dispose()
            }
        }
        It 'first folder is first, second folder is second' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.Item(0).Path | Should be $folder1Path
                $l.Item(1).Path | Should be $folder2Path
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'add folders to library in opposite order' {
            try
            {
                $f1 = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folder1Path)
                $f2 = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folder2Path)
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$true)
                $l.Add($f2)
                $l.Add($f1)
            }
            finally
            {
                $f1.Dispose()
                $f2.Dispose()
                $l.Dispose()
            }
        }
        It 'first folder is second, second folder is first' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.Item(0).Path | Should be $folder2Path
                $l.Item(1).Path | Should be $folder1Path
            }
            finally
            {
                $l.Dispose()
            }
        }
    }
    Context 'reorder' {
        $tempPath = [System.IO.Path]::GetTempPath()
        $folder1Path = Join-path $tempPath "Folder1-a2cce939"
        $folder2Path = Join-path $tempPath "Folder2-a2cce939"
        It 'create folders' {
            New-Item $folder1Path,$folder2Path -ItemType Directory -Force
        }
        It 'add folders to library in order' {
            try
            {
                $f1 = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folder1Path)
                $f2 = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($folder2Path)
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$true)
                $l.Add($f1)
                $l.Add($f2)
            }
            finally
            {
                $f1.Dispose()
                $f2.Dispose()
                $l.Dispose()
            }
        }
        It 'reverse the order' {
            $stack = [System.Collections.Stack]::new()
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l | % { $stack.Push($_) }
                $l.Dispose()
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$true)
                $stack | % { 
                    $l.Add($_)
                    $_.Dispose()
                }
            }
            finally
            {
                $l.Dispose()
            }
        }
        It 'first folder is second, second folder is first' {
            try
            {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.Item(0).Path | Should be $folder2Path
                $l.Item(1).Path | Should be $folder1Path
            }
            finally
            {
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