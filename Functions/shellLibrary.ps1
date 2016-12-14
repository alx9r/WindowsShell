function Get-ShellLibrary
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [string]
        $Name
    )
    process
    {
        $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($Name,$false)
        $r = New-Object ShellLibrary -Property @{
            Name     = $l.Name
            TypeName = $l.LibraryType
            IconReferencePath = $l.IconResourceId.ReferencePath
        }
        $l.Dispose()
        return $r
    }
}

function Add-ShellLibrary
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        $Name
    )
    process
    {
        throw [System.NotImplementedException]::new('New-ShellLibrary')
    }
}

function Remove-ShellLibrary
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [string]
        $Name
    )
    process
    {
        throw [System.NotImplementedException]::new('Remove-ShellLibrary')
    }
}

function Set-ShellLibraryType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $Name,

        [Parameter(position = 1)]
        [string]
        $TypeName
    )
    process
    {
        throw [System.NotImplementedException]::new('Set-ShellLibraryType')
    }
}

function Set-ShellLibraryStockIcon
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $Name,

        [Parameter(position = 1)]
        [string]
        $StockIconName
    )
    process
    {
        throw [System.NotImplementedException]::new('Set-ShellLibraryStockIcon')
    }
}
