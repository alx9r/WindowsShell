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
        throw [System.NotImplementedException]::new('Get-ShellLibrary')
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
