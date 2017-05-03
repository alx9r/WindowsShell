if ( -not (Get-Module ZeroDsc -ListAvailable) )
{
    return
}

Remove-Module WindowsShell -fo -ea si; Import-Module WindowsShell
Import-Module PSDesiredStateConfiguration, ZeroDsc

Describe 'Invoke with ZeroDsc (Shortcut)' {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $shortcutFilename = "Shortcut-$guidFrag.lnk"
    $tempPath = [System.IO.Path]::GetTempPath()
    $shortcutPath = Join-Path $tempPath $shortcutFilename

    $tests = [ordered]@{
        basic = @"
            Get-DscResource Shortcut WindowsShell | Import-DscResource
            Shortcut MyShortcut @{ Path = "$shortcutPath" }
"@
        full = @"
            Get-DscResource Shortcut WindowsShell | Import-DscResource
            Shortcut MyShortcut @{
                Path = "$shortcutPath"
                Arguments = 'arguments'
                Hotkey = 'Ctrl+Alt+f'
                StockIconName = 'AudioFiles'
                TargetPath = 'C:\Windows\System32\calc.exe'
                WindowStyle = 'Maximized'
                WorkingDirectory = 'c:\temp'
                Description = 'some description'
            }
"@
    }
    foreach ( $testName in $tests.Keys )
    {
        Context $testName {
            $document = [scriptblock]::Create($tests.$testName)
            $h = @{}
            It 'create instructions' {
                $h.i = ConfigInstructions SomeName $document
            }
            foreach ( $step in $h.i )
            {
                It $step.Message {
                    $r = $step | Invoke-ConfigStep
                    $r.Progress | Should not be 'failed'
                }
            }
        }
    }
    It 'cleanup' {
        Remove-Item $shortcutPath
    }
}
