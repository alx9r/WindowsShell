[DscResource()]
class Shortcut
{
    [DscProperty(Key)]
    [string]
    $Path

    [DscProperty()]
    [Ensure]
    $Ensure

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
    [int]
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