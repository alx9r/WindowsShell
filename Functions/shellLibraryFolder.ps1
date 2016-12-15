function Add-ShellLibraryFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        $LibraryName,

        [Parameter(Mandatory = $true)]
        $FolderPath
    )
    process
    {
        # load the library
        # new up a [ShellFileSystemFolder] from $FolderPath
        # .Add() the folderpath to the library
    }
}

function Test-ShellLibraryFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        $LibraryName,

        [Parameter(Mandatory = $true)]
        $FolderPath
    )
    process
    {
        # load the library
        # new up a [ShellFileSystemFolder] from $FolderPath
        # test if the library .Contains() the folder
    }
}

function Remove-ShellLibraryFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        $LibraryName,

        [Parameter(Mandatory = $true)]
        $FolderPath
    )
    process
    {
        # load the library
        # new up a [ShellFileSystemFolder] from $FolderPath
        # .Remove() it from the library
    }
}

