function Get-StockIconReferencePath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [Microsoft.WindowsAPICodePack.Shell.StockIconIdentifier]
        $StockIconName
    )
    process
    {
        return [StockIconInfo.StockIconInfo]::GetIconRefPath([int]$StockIconName)
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
        if
        (
            $StockIconName -ne 'DoNotSet' -and
            -not [Microsoft.WindowsAPICodePack.Shell.StockIconIdentifier]::TryParse($StockIconName,[ref]$out)
        )
        {
            &(Publish-Failure "$StockIconName is not a valid stock icon name",'IconName' ([System.ArgumentException]))
            return $false
        }
        return $true
    }
}
