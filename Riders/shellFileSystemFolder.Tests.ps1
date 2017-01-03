Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}

Describe 'ShellFileSystemFolder' {
    Context 'create folder' {
        $existsPath = "$([System.IO.Path]::GetTempPath())Exists-c04c4e56"
        It 'create a temp folder' {
            New-Item $existsPath -ItemType Directory -Force
        }
        foreach ( $values in @(
                #  throws | path
                @( $false,  [System.IO.Path]::GetTempPath() ),
                @( $true,  "$([System.IO.Path]::GetTempPath())NotExists-c04c4e56" ),
                @( $false, $existsPath )
            )
        )
        {
            $throws, $path = $values
            if ( $throws )
            {
                It "$path throws" {
                    try
                    {
                        { $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($path) } |
                            Should throw
                    }
                    finally
                    {
                        if ( $null -ne $f )
                        {
                            $f.Dispose()
                        }
                    }
                }
                continue
            }
            It "$path succeeds" {
                try
                {
                    $f = [Microsoft.WindowsAPICodePack.Shell.ShellFileSystemFolder]::FromFolderPath($path)
                    $f.Path | Should be $path
                }
                finally
                {
                    if ( $null -ne $f )
                    {
                        $f.Dispose()
                    }
                }
            }
        }
    }
}
