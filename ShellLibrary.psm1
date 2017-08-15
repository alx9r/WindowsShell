[DscResource()]
class ShellLibrary
{
    [DscProperty(Key)]
    [string]
    $Name

    [DscProperty()]
    [Ensure]
    $Ensure

    [DscProperty()]
    [System.Nullable[LibraryTypeName]]
    $TypeName

    [DscProperty()]
    [System.Nullable[StockIconName]]
    $StockIconName

    [DscProperty()]
    [string]
    $IconFilePath

    [DscProperty()]
    [int]
    $IconResourceId

    [void] Set() { $this | Invoke-ProcessShellLibrary Set }
    [bool] Test() { return $this | Invoke-ProcessShellLibrary Test }

    [ShellLibrary] Get() { return $this }
}  