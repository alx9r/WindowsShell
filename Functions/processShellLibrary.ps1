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
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_ | Test-ValidShellLibraryName })]
        [Alias('LibraryName')]
        [string]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $TypeName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $StockIconName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $IconFilePath,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [int]
        $IconResourceId=0,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $FolderOrder
    )
    process
    {
        # validate parameters
        $IconFilePath | ? {$_} | Test-ValidFilePath -ea Stop | Out-Null
        $TypeName | ? {$_} | Test-ValidShellLibraryTypeName -ea Stop | Out-Null
        $StockIconName | ? {$_} | Test-ValidStockIconName -ea Stop | Out-Null

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

        # process library type
        if
        (
            ( $TypeName -ne [string]::Empty -and $TypeName -ne 'DoNotSet' ) -and
            $library.TypeName -ne $TypeName
        )
        {
            switch ( $Mode )
            {
                'Set' {
                    # correct the property
                    $library | Set-ShellLibraryProperty TypeName $TypeName
                }
                'Test' { return $false } # the property is incorrect
            }
        }

        # process the icon name
        if
        (
            ( $StockIconName -ne [string]::Empty -and $StockIconName -ne 'DoNotSet' ) -or
            $IconFilePath
        )
        {
            # compose the icon reference path
            if ( $IconFilePath )
            {
                $iconReferencePath = "$IconFilePath,$IconResourceId"
            }
            else
            {
                $iconReferencePath = $StockIconName | Get-StockIconReferencePath
            }

            if ( $library.IconReferencePath -ne $iconReferencePath )
            {
                switch ( $Mode )
                {
                    'Set' {
                        # correct the property
                        $library | Set-ShellLibraryProperty IconReferencePath $iconReferencePath
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
