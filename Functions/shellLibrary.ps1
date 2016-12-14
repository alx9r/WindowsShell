Set-Alias Test-ValidLibraryName Test-ValidFileName
function Test-ValidShellLibraryTypeName
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [string]
        $TypeName
    )
    process
    {
        $out = New-Object Microsoft.WindowsAPICodePack.Shell.LibraryFolderType
        if ( -not [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::TryParse($TypeName,[ref]$out) )
        {
            &(Publish-Failure "$TypeName not a valid library type name",'TypeName' ([System.ArgumentException]))
            return $false
        }
        return $true
    }
}
function Test-ValidStockIconName { throw [System.NotImplementedException]::new('Test-ShellLibraryName') }

function Set-ShellLibrary
{
    [CmdletBinding()]
    param
    (
        [ValidateSet('Present','Absent')]
        $Ensure='Present',

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [string]
        $TypeName,

        [string]
        $IconName,

        [string[]]
        $FolderOrder
    )
    process
    {
        # test valid name
        # test valid type
        # test valid icon name

        # if ensure is absent just remove the library and return

        # if the library doesn't exist, create it

        # if the type is provided and is incorrect, correct it

        # if the icon is provided and is incorrect, correct it

        # if a folder order is provided invoke Test-ShellLibraryFoldersSortOrder, Sort-ShellLibraryFolders

        throw [System.NotImplementedException]::new('Set-ShellLibrary')
    }
}

function Test-ShellLibraryFoldersSortOrder
{
    [CmdletBinding()]
    param
    (
        [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]
        $Library,

        [string[]]
        $FolderOrder
    )
    process
    {
        # create an ordered list of the folder paths

        # foreach $pattern in $FolderOrder
        #   find the index of the first folder matched
        #   if that index is before a previous index, return false

        # return true

        throw [System.NotImplementedException]::new('Test-ShellLibraryFoldersSortOrder')
    }
}

function Sort-ShellLibraryFolders
{
    [CmdletBinding()]
    param
    (
        [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]
        $Library,

        [string[]]
        $FolderOrder
    )
    process
    {
        # Create a list of the original order.

        # Create a hashtable where the keys are the patterns in $FolderOrder and
        # the values are lists of folder paths that match each pattern.

        # Create a hashtable where the keys are the folder paths and the values
        # are the [ShellFileSystemFolder] objects.

        # Remove all of the folders from the library.

        # foreach $pattern in $FolderOrder
        #    look up the matching folder paths
        #    add the objects corresponding to each folder path to the library,
        #    and remove it from the hashtable

        # add any remaining objects in the original order

        throw [System.NotImplementedException]::new('Sort-ShellLibraryFolders')
    }
}