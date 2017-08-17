[DscResource()]
class ShellLibrary
{
    [DscProperty(Key,Mandatory)]
    [string]
    $Name

    [DscProperty()]
    [System.Nullable[Ensure]]
    $Ensure = 'Present'

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
    [System.Nullable[int]]
    $IconResourceId

    [void] Set() { $this | Invoke-ProcessShellLibrary Set }
    [bool] Test() { return $this | Invoke-ProcessShellLibrary Test }

    [ShellLibrary] Get() { return $this }
}  