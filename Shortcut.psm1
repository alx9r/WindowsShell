[DscResource()]
class Shortcut
{
    [DscProperty(Key,Mandatory)]
    [string]
    $Path

    [DscProperty()]
    [System.Nullable[Ensure]]
    $Ensure = 'Present'

    [DscProperty()]
    [string]
    $TargetPath

    [DscProperty()]
    [string]
    $Arguments

    [DscProperty()]
    [string]
    $WorkingDirectory

    [DscProperty()]
    [System.Nullable[WindowStyle]]
    $WindowStyle

    [DscProperty()]
    [string]
    $Hotkey

    [DscProperty()]
    [System.Nullable[StockIconName]]
    $StockIconName

    [DscProperty()]
    [string]
    $IconFilePath

    [DscProperty()]
    [System.Nullable[int]]
    $IconResourceId

    [DscProperty()]
    [string]
    $Description

    [void] Set() { 
        $this | Invoke-ProcessShortcut Set
    }
    [bool] Test() { 
        return $this | Invoke-ProcessShortcut Test 
    }

    [Shortcut] Get() { return $this }
}  