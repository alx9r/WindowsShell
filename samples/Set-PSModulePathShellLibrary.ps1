$document = {
    Get-DscResource -Module WindowsShell | Import-DscResource

    $wantedFolderPaths = $env:PSModulePath.Split(';') |
        ? { $_ -notmatch 'Application Virtualization' }
    $unwantedFolderPaths = $env:PSModulePath.Split(';') |
        ? { $_ -match 'Application Virtualization' }

    foreach ( $folderPath in $wantedFolderPaths )
    {
        ShellLibraryFolder ($folderPath -replace '[^a-zA-Z0-9]','-') @{
            LibraryName = 'PSModulePath'
            FolderPath = $folderPath
            DependsOn = '[ShellLibrary]PSModulePath'
        }
    }

    foreach ( $folderPath in $unwantedFolderPaths )
    {
        ShellLibraryFolder ($folderPath -replace '[^a-zA-Z0-9]','-') @{
            Ensure = 'Absent'
            LibraryName = 'PSModulePath'
            FolderPath = $folderPath
            DependsOn = '[ShellLibrary]PSModulePath'
        }
    }
    ShellLibrary PSModulePath @{ 
        Name = 'PSModulePath' 
        IconFilePath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
        LibraryTypeName = 'Documents'
    }
}

Describe 'Create PSModulePath Shell Library' {
    $h = @{}
    It 'create instructions' {
        $h.i = ConfigInstructions PSModulePath $document
    }
    foreach ( $step in $h.i )
    {
        It $step.Message {
            $r = $step | Invoke-ConfigStep
            $r | Should not be 'Failed'
        }
    }
}
