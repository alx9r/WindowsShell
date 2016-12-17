function Invoke-ProcessShellLibraryFolder
{
    [CmdletBinding()]
    param
    (

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [ValidateScript({ $_ | Test-ValidFilePath })]
        [string]
        $FolderPath,

        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateSet('Set','Test')]
        $Mode,

        [Parameter(Position = 2)]
        [ValidateSet('Present','Absent')]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true,
                   Position = 3)]
        [ValidateScript({ $_ | Test-ValidShellLibraryName })]
        [string]
        $LibraryName
    )
    process
    {
        if ( -not (Test-ShellLibrary $LibraryName) )
        {
            # the library doesn't exist
            if ( $Mode -eq 'Set' )
            {
                return
            }
            return $false
        }

        $folderExists = $FolderPath | Test-ShellLibraryFolder $LibraryName

        switch ( $Ensure )
        {
            'Present' {
                if ( -not $folderExists )
                {
                    switch ( $Mode )
                    {
                        'Set' { $FolderPath | Add-ShellLibraryFolder $LibraryName } # create the folder
                        'Test' { return $false }                                    # the folder doesn't exist
                    }
                }
                switch ( $Mode )
                {
                    'Set' {}
                    'Test' { return $true } # the folder exists
                }
            }
            'Absent' {
                switch ( $Mode )
                {
                    'Set' {
                        if ( $folderExists )
                        {
                            # the library exists, remove it
                            $FolderPath | Remove-ShellLibraryFolder $LibraryName
                        }
                    }
                    'Test' {
                        return -not $folderExists
                    }
                }
            }
        }
    }
}