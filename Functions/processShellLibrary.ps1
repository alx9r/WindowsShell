Set-Alias Test-ValidShellLibraryName Test-ValidFileName

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
        if
        (
            $TypeName -ne 'DoNotSet' -and
            -not [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::TryParse($TypeName,[ref]$out)
        )
        {
            &(Publish-Failure "$TypeName is not a valid library type name",'TypeName' ([System.ArgumentException]))
            return $false
        }
        return $true
    }
}

function Invoke-ProcessShellLibrary
{
    [CmdletBinding(DefaultParameterSetName='StockIcon')]
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
        [Alias('LibraryName')]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $TypeName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $StockIconName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $IconFilePath,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $IconResourceId=0
    )
    process
    {
        # validate parameters
        $Name | ? {$_} | Test-ValidShellLibraryName -ea Stop | Out-Null
        $IconFilePath | ? {$_} | Test-ValidFilePath -ea Stop | Out-Null
        $TypeName | ? {$_} | Test-ValidShellLibraryTypeName -ea Stop | Out-Null
        $StockIconName | ? {$_} | Test-ValidStockIconName -ea Stop | Out-Null

        # pass through properties
        $properties = @{}
        'TypeName' |
            ? { $_ -in $PSCmdlet.MyInvocation.BoundParameters.Keys } |
            ? { (Get-Variable $_ -ValueOnly) -ne 'DoNotSet' } |
            % { $properties.$_ = Get-Variable $_ -ValueOnly }


        # work out the icon
        $splat = @{
            StockIconName = $StockIconName
            IconFilePath = $IconFilePath
            IconResourceId = $IconResourceId
        }
        if ( $iconReferencePath = Get-IconReferencePath @splat )
        {
            $properties.IconReferencePath = $iconReferencePath
        }

        # process
        $splat = @{
            Mode = $Mode
            Ensure = $Ensure
            Keys = @{ Name = $Name }
            Properties = $properties
            Getter  = 'Get-ShellLibrary'
            Adder   = 'Add-ShellLibrary'
            Remover = 'Remove-ShellLibrary'
            PropertySetter = 'Set-ShellLibraryProperty'
            PropertyTester = 'Test-ShellLibraryProperty'
        }
        Invoke-ProcessPersistentItem @splat
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
