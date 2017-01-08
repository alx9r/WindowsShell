function Test-ShellLibraryFolder
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [ValidateScript({ $_ | Test-ValidFilePath })]
        $FolderPath,

        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateScript({ $_ | Test-ValidShellLibraryName })]
        $LibraryName
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

            # safely test if the path exists
            try
            {
                # Test-Path can throw an exception for UNC paths
                $folderPathExists = $FolderPath | Test-Path -PathType Container
            }
            catch {}

            if ( -not ( $folderPathExists ) )
            {
                # the file system folder does not exist
                # search through the list of folders
                foreach ( $folder in $l.GetEnumerator() )
                {
                    if ( Test-FolderPathsAreEqual $folder.Path $FolderPath )
                    {
                        # the folder exists
                        return $true
                    }
                }

                # the folder does not exist
                return $false
            }

            # create a reference to the file system folder that the library understands
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath((
                $FolderPath | ConvertTo-WindowsShellFolderPathFormat
            ))

            if ( -not $l.Contains($f) )
            {
                # the folder does not exist
                return $false
            }
        }
        finally
        {
            if ( $null -ne $l ) { $l.Dispose() }
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
        [ValidateScript({ $_ | Test-ValidFilePath })]
        $FolderPath,

        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateScript({ $_ | Test-ValidShellLibraryName })]
        $LibraryName
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

        if ( $FolderPath | Test-ShellLibraryFolder $LibraryName )
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
            # load the library
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$false)

            # create a reference to the file system folder that the library understands
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath((
                $FolderPath | ConvertTo-WindowsShellFolderPathFormat
            ))

            # add the folder
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
        [ValidateScript({ $_ | Test-ValidFilePath })]
        $FolderPath,

        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateScript({ $_ | Test-ValidShellLibraryName })]
        $LibraryName
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

        try
        {
            # load the library
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$false)

            if ( -not ($FolderPath | Test-Path -PathType Container -ea Stop ) )
            {
                # the file system folder does not exist
                # search through the list of folders
                foreach ( $f in $l.GetEnumerator() )
                {
                    if ( Test-FolderPathsAreEqual $f.Path $FolderPath )
                    {
                        # the folder exists, remove it
                        $l.Remove($f) | Out-Null
                        return
                    }
                }

                # the folder does not exist
                throw [System.IO.IOException]::new(
                    "The folder $FolderPath does not exist in library named $LibraryName."
                )
            }

            # create a reference to the file system folder that the library understands
            $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath((
                $FolderPath | ConvertTo-WindowsShellFolderPathFormat
            ))

            if ( -not $l.Contains($f) )
            {
                throw [System.IO.IOException]::new(
                    "The folder $FolderPath does not exist in library named $LibraryName."
                )
            }

            # remove the folder
            $l.Remove($f) | Out-Null
        }
        finally
        {
            if ( $null -ne $f ) { $f.Dispose() }
            if ( $null -ne $l ) { $l.Dispose() }
        }
    }
}
