function Invoke-ProcessShellLibraryFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateSet('Set','Test')]
        $Mode,

        [Parameter(Position = 2)]
        [ValidateSet('Present','Absent')]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        $LibraryName,

        [Parameter(Mandatory = $true)]
        [string]
        $FolderPath
    )
    process
    {
        # Similar pattern to Invoke-ProcessShellLibrary.
        # Should be simpler because we are not processing any
        # properties of the folders whereas the libraries
        # had properties to handle.
    }
}