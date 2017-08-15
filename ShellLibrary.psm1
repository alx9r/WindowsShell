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
    [LibraryTypeName]
    $TypeName = [LibraryTypeName]::DoNotSet

    [DscProperty()]
    [StockIconName]
    $StockIconName = [StockIconName]::DoNotSet

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