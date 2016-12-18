if ( -not (Get-Module ZeroDsc -ListAvailable) )
{
    return
}

Remove-Module WindowsShell -fo -ea si; Import-Module WindowsShell
Import-Module PSDesiredStateConfiguration, ZeroDsc

Describe 'Invoke with ZeroDsc' {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName1 = "ZeroDsc1-$guidFrag"
    $libraryName2 = "ZeroDsc2-$guidFrag"
    $folderPath = Join-Path ([System.IO.Path]::GetTempPath()) "Folder-$guidFrag"
    Context 'set up' {
        It 'create file system folder' {
            New-Item $folderPath -ItemType Directory -ea Stop
            Test-Path $folderPath -PathType Container | Should be $true
        }
    }
    Context ShellLibrary {
        $document = [scriptblock]::Create(@"
            Get-DscResource ShellLibrary WindowsShell | Import-DscResource
            ShellLibrary MyLib @{ Name = '$libraryName1' }
"@
        )
        $h = @{}
        It 'create instructions' {
            $h.i = ConfigInstructions SomeName $document
        }
        foreach ( $step in $h.i )
        {
            It $step.Message {
                $r = $step | Invoke-ConfigStep
                $r.Progress | Should not be 'Failed'
            }
        }
    }
    Context ShellLibraryFolder {
        $document = [scriptblock]::Create(@"
            Get-DscResource ShellLibraryFolder WindowsShell | Import-DscResource
            ShellLibraryFolder MyDir @{ 
                LibraryName = '$libraryName1'
                FolderPath = '$folderPath'
            }
"@
        )
        $h = @{}
        It 'create instructions' {
            $h.i = ConfigInstructions SomeName $document
        }
        foreach ( $step in $h.i )
        {
            It $step.Message {
                $r = $step | Invoke-ConfigStep
                $r.Progress | Should not be 'Failed'
            }
        }
    }
    Context 'combined' {
        $document = [scriptblock]::Create(@"
        Get-DscResource -Module WindowsShell | Import-DscResource
        ShellLibraryFolder MyDir @{
            LibraryName = '$libraryName2'
            FolderPath = '$folderPath'
            DependsOn = '[ShellLibrary]MyLib'
        }
        ShellLibrary MyLib @{ Name = '$libraryName2' }
"@
        )
            $h = @{}
        It 'create instructions' {
            $h.i = ConfigInstructions SomeName $document
        }
        foreach ( $step in $h.i )
        {
            It $step.Message {
                $r = $step | Invoke-ConfigStep
                $r.Progress | Should not be 'Failed'
            }
        }
    }
    Context 'clean up' {
        It 'remove the file system folder' {
            Remove-Item $folderPath -ea Stop
            Test-Path $folderPath | Should be $false
        }
        It 'remove the libraries' {
            $libraryName1,$libraryName2 | Invoke-ProcessShellLibrary Set Absent
            ( $libraryName1,$libraryName2 | Invoke-ProcessShellLibrary Test Absent ) -ne
                $true |
                Should beNullOrEmpty
        }
    }
}