function Test-FolderPathsAreEqual
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        $PathA,

        [Parameter(Mandatory = $true,
                   Position = 2)]
        $PathB
    )
    process
    {
        $a = $PathA | ConvertTo-WindowsShellFolderPathFormat
        $b = $PathB | ConvertTo-WindowsShellFolderPathFormat
        $r = $a -eq $b
        return $r
    }
}

function ConvertTo-WindowsShellFolderPathFormat
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipeline = $true)]
        [string]
        $InputPath
    )
    process
    {
        $splat = @{
            Scheme = 'plain'
            TrailingSlash = $false
        }
        return $InputPath |
            ConvertTo-FilePathObject |
            ConvertTo-FilePathString @splat
    }
}
