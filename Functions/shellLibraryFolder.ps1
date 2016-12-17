function Test-ShellLibraryFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [ValidateScript({ $_ | Test-ValidShellLibraryName })]
        $LibraryName,

        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateScript({ $_ | Test-ValidFilePath })]
        $FolderPath
    )
    process
    {
        if ( -not ($LibraryName | Test-ShellLibrary) )
        {
            # the library doesn't even exist
            return $false
        }

        try
        {
            # load the library
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$true)

            if ( -not ($FolderPath | Test-Path -PathType Container -ea Stop ) )
            {
                # the file system folder does not exist
                # search through the list of folders
                foreach ( $folder in $l.GetEnumerator() )
                {
                    if ( $folder.Path -eq $FolderPath )
                    {
                        # the folder exists
                        return $true
                    }
                }

                # the folder does not exist
                return $false
            }
            
            # create a reference to the file system folder that the library understands
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($FolderPath)

            if ( -not $l.Contains($f) )
            {
                # the folder does not exist
                return $false
            }
        }
        finally
        {
            $l.Dispose()
        }
        # new up a [ShellFileSystemFolder] from $FolderPath
        # test if the library .Contains() the folder

        return $true
    }
}

function Add-ShellLibraryFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [ValidateScript({ $_ | Test-ValidShellLibraryName })]
        $LibraryName,

        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateScript({ $_ | Test-ValidFilePath })]
        $FolderPath
    )
    process
    {
        if ( -not ($LibraryName | Test-ShellLibrary) )
        {
            # the library does not exist
            throw [System.IO.IOException]::new(
                "A library named $LibraryName does not exist."
            )
        }

        if ( $LibraryName | Test-ShellLibraryFolder $FolderPath )
        {
            # the folder already exists
            throw [System.IO.IOException]::new(
                "The folder $FolderPath already exists in library $LibraryName"
            )
        }

        if ( $FolderPath | Test-Path -PathType Leaf )
        {
            # the path is to a file
            throw [System.IO.IOException]::new(
                "The path $FolderPath is a file."
            )
        }

        if ( -not ($FolderPath | Test-Path -PathType Container ) )
        {
            # the file system folder does not exist
            throw [System.IO.IOException]::new(
                "The folder $FolderPath does not exist."
            )
        }

        try
        {
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($FolderPath)
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$false)
            $l.Add($f)
        }
        finally
        {
            if ( $null -ne $f ) { $f.Dispose() }
            if ( $null -ne $l ) { $l.Dispose() }
        }
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
        throw [System.NotImplementedException]::new('Remove-ShellLibraryFolder')
        # load the library
        # new up a [ShellFileSystemFolder] from $FolderPath
        # .Remove() it from the library
    }
}

