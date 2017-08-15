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
    [WindowStyle]
    $WindowStyle=[WindowStyle]::Normal

    [DscProperty()]
    [string]
    $Hotkey

    [DscProperty()]
    [StockIconName]
    $StockIconName = [StockIconName]::DoNotSet

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