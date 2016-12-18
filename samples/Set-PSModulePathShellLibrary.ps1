Describe 'Create PSModulePath Shell Library' {
    $document = {
        Get-DscResource -Module WindowsShell | Import-DscResource
        ShellLibraryFolder AllPSModulePathFolders @{
            LibraryName = 'PSModulePath'
            FolderPath = $env:PSModulePath.Split(';') | ? { $_ -notmatch 'Application Virtualization' }
            DependsOn = '[ShellLibrary]PSModulePath'
        }
        ShellLibraryFolder NoAppV @{
            Ensure = 'Absent'
            LibraryName = 'PSModulePath'
            FolderPath = $env:PSModulePath.Split(';') | ? { $_ -match 'Application Virtualization' }
            DependsOn = '[ShellLibrary]PSModulePath'
        }
        ShellLibrary PSModulePath @{ Name = 'PSModulePath' }
    }
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
