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
        if ( -not [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::TryParse($TypeName,[ref]$out) )
        {
            &(Publish-Failure "$TypeName is not a valid library type name",'TypeName' ([System.ArgumentException]))
            return $false
        }
        return $true
    }
}
function Test-ValidStockIconName
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true,
                   Mandatory = $true)]
        [string]
        $StockIconName
    )
    process
    {
        $out = New-Object Microsoft.WindowsAPICodePack.Shell.StockIconIdentifier
        if ( -not [Microsoft.WindowsAPICodePack.Shell.StockIconIdentifier]::TryParse($StockIconName,[ref]$out) )
        {
            &(Publish-Failure "$StockIconName is not a valid stock icon name",'IconName' ([System.ArgumentException]))
            return $false
        }
        return $true
    }
}

function Invoke-ProcessShellLibrary
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
        [ValidateScript({ $_ | Test-ValidShellLibraryName })]
        [string]
        $Name,

        [ValidateScript({ $_ | Test-ValidShellLibraryTypeName })]
        [string]
        $TypeName,

        [ValidateScript({ $_ | Test-ValidStockIconName })]
        [string]
        $StockIconName,

        [string[]]
        $FolderOrder
    )
    process
    {
        # retrieve the library
        $library = $Name | Get-ShellLibrary


        # process library existence
        switch ( $Ensure )
        {
            'Present' {
                if ( -not $library )
                {
                    switch( $Mode )
                    {
                        'Set'  { $library = $Name | Add-ShellLibrary } # create the library
                        'Test' { return $false }                       # the library doesn't exist
                    }
                }
            }
            'Absent' {
                switch ( $Mode )
                {
                    'Set'  { 
                        if ( $library )
                        {
                            # the library exists, remove it
                            $Name | Remove-ShellLibrary
                        }
                        return
                    }
                    'Test'
                    {
                        return -not $library
                    }
                }
            }
        }

        # process library type and icon
        foreach
        ( 
            $instruction in @(
                @{
                    PropertyName = 'TypeName'
                    SetterName = 'Set-ShellLibraryType'
                    SetValue = $TypeName 
                }
                @{
                    PropertyName = 'StockIconName'
                    SetterName = 'Set-ShellLibraryStockIcon'
                    SetValue = $StockIconName
                }
            )
        )
        {
            if ( $library.$($instruction.PropertyName) -ne $instruction.SetValue )
            {
                switch ( $Mode )
                {
                    'Set'  { 
                         # correct the property
                        $library | & $instruction.SetterName $instruction.SetValue
                    }
                    'Test' { return $false } # the property is incorrect
                }
            }
        }

        # if a folder order is provided invoke Test-ShellLibraryFoldersSortOrder, Sort-ShellLibraryFolders

        if ( $Mode -eq 'Test' )
        {
            return $true
        }
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