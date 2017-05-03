Import-Module WindowsShell -Force

InModuleScope WindowsShell {

Describe Test-ValidShortcutObject {
    It 'returns false' {
        $r = 'not a shortcut object' | Test-ValidShortcutObject
        $r | Should be $false
    }

    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $shortcutFilename = "Shortcut-$guidFrag.lnk"
    $tempPath = [System.IO.Path]::GetTempPath()
    $shortcutPath = Join-Path $tempPath $shortcutFilename
    It 'returns true' {
        $r = $shortcutPath |
            Add-Shortcut |
            Test-ValidShortcutObject
        $r | Should be $true
    }
}

Describe Get-NormalizedShortcutProperty {
    It 'Hotkey' {
        $r = 'Ctrl+Alt+f' | Get-NormalizedShortcutProperty Hotkey
        $r | Should be 'Alt+Ctrl+f'
    }
    It 'TargetPath' {
        $r = 'c:/bogus/path.exe' | Get-NormalizedShortcutProperty TargetPath
        $r | Should be 'c:\bogus\path.exe'
    }
}
}
