function Invoke-ProcessShellLibraryFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Set','Test')]
        $Mode,

        [Parameter(Position = 2,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Present','Absent')]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true,
                   Position = 3,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_ | Test-ValidShellLibraryName })]
        [Alias('Name')]
        [string]
        $LibraryName,

        [Parameter(Mandatory = $true,
                   Position = 4,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_ | Test-ValidFilePath })]
        [string]
        $FolderPath
    )
    process
    {
        $splat = @{
            Mode = $Mode
            Ensure = $Ensure
            Keys = @{
                LibraryName = $LibraryName
                FolderPath = $FolderPath
            }
            Getter  = 'Get-ShellLibraryFolder'
            Adder   = 'Add-ShellLibraryFolder'
            Remover = 'Remove-ShellLibraryFolder'
        }
        Invoke-ProcessPersistentItem @splat
    }
}
