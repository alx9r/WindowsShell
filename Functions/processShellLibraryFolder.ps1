function Invoke-ProcessShellLibraryFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipelineByPropertyName = $true)]
        [System.Nullable[Mode]]
        $Mode,

        [Parameter(Position = 2,
                   ValueFromPipelineByPropertyName = $true)]
        [System.Nullable[Ensure]]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true,
                   Position = 3,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        [Alias('Name')]
        $LibraryName,

        [Parameter(Mandatory = $true,
                   Position = 4,
                   ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $FolderPath
    )
    process
    {
        # validate parameters
        $LibraryName | ? {$_} | Test-ValidShellLibraryName -ea Stop | Out-Null
        $FolderPath | ? {$_} | Test-ValidFilePath -ea Stop | Out-Null

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
