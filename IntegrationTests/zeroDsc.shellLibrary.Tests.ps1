if ( -not (Get-Module ZeroDsc -ListAvailable) )
{
    return
}

Import-Module WindowsShell -Force
Import-Module PSDesiredStateConfiguration, ZeroDsc

Describe 'Invoke with ZeroDsc (ShellLibrary)' {
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
        $h = @{}
        It 'create instructions' {
            $h.i = ConfigInstructions SomeName {
                $r = Get-DscResource ShellLibrary WindowsShell
                $r | Import-DscResource
                ShellLibrary MyLib @{ Name = $libraryName1 }
            }
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
        $h = @{}
        It 'create instructions' {
            $h.i = ConfigInstructions SomeName {
                Get-DscResource ShellLibraryFolder WindowsShell | Import-DscResource
                ShellLibraryFolder MyDir @{
                    LibraryName = $libraryName1
                    FolderPath = $folderPath
                }
            }
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
        $h = @{}
        It 'create instructions' {
            $h.i = ConfigInstructions SomeName {
                Get-DscResource -Module WindowsShell | Import-DscResource
                ShellLibraryFolder MyDir @{
                    LibraryName = $libraryName2
                    FolderPath = $folderPath
                    DependsOn = '[ShellLibrary]MyLib'
                }
                ShellLibrary MyLib @{ Name = $libraryName2 }
            }
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
            $libraryName1,$libraryName2 |  % { Invoke-ProcessShellLibrary Set Absent -Name $_ }
            ( $libraryName1,$libraryName2 | % { Invoke-ProcessShellLibrary Test Absent -Name $_ } ) -ne
                $true |
                Should beNullOrEmpty
        }
    }
}

