function Get-IconReferencePath
{
    [CmdletBinding()]
    param
    (
        [string]
        $StockIconName,

        [string]
        $IconFilePath,

        [int]
        $IconResourceId
    )
    process
    {
        # return based on the StockIconName
        if ( $StockIconName -and $StockIconName -ne 'DoNotSet' )
        {
            return Get-StockIconReferencePath $StockIconName
        }

        # return based on IconFilePath
        if ( $IconFilePath )
        {
            return "$IconFilePath,$IconResourceId"
        }
    }
}
