Remove-Module WindowsShell -fo -ea si; Import-Module WindowsShell
Import-Module PSDesiredStateConfiguration

Describe 'ShellLibraryFolder Resource' {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "FolderResource-$guidFrag"
    $folderPath = Join-Path ([System.IO.Path]::GetTempPath()) "Folder-$guidFrag"
    $h = @{}
    It 'is available using Get-DscResource' {
        $r = Get-DscResource ShellLibraryFolder WindowsShell
        $r.Name | Should be 'ShellLibraryFolder'
    }
    Context 'set up' {
        It 'create object' {
            $h.d = (Get-Module WindowsShell).NewBoundScriptBlock({
                [ShellLibraryFolder]::new()
            }).InvokeReturnAsIs()
        }
        It 'create file system folder' {
            New-Item $folderPath -ItemType Directory -ea Stop
            Test-Path $folderPath -PathType Container | Should be $true
        }
        It 'create the library' {
            $libraryName | Invoke-ProcessShellLibrary Set
            $r = $libraryName | Invoke-ProcessShellLibrary Test
            $r | Should be $true
        }
    }
    Context 'test, create, test, remove, test' {
        It 'test returns false' {
            $h.d.LibraryName = $libraryName
            $h.d.FolderPath = $folderPath
            $r = $h.d.Test()
            $r | Should be $false
        }
        It 'create' {
            $h.d.Set()
        }
        It 'test returns true' {
            $r = $h.d.Test()
            $r | Should be $true
        }
        It 'remove' {
            $h.d.Ensure = 'Absent'
            $r = $h.d.Set()
        }
        It 'test returns false' {
            $h.d.Ensure = 'Present'
            $r = $h.d.Test()
            $r | Should be $false
        }
    }
    Context 'clean up' {
        It 'remove the file system folder' {
            Remove-Item $folderPath -ea Stop
            Test-Path $folderPath | Should be $false
        }
        It 'remove the library' {
            $libraryName | Invoke-ProcessShellLibrary Set Absent
            $r = $libraryName | Invoke-ProcessShellLibrary Test Absent
            $r | Should be $true
        }
    }
}