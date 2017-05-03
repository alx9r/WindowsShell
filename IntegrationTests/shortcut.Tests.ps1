Import-Module WindowsShell -Force

InModuleScope WindowsShell {

Describe Get-Shortcut {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $shortcutFilename = "Shortcut-$guidFrag.lnk"
    $tempPath = [System.IO.Path]::GetTempPath()
    $shortcutPath = Join-Path $tempPath $shortcutFilename

    Context 'shortcut exists' {
        It 'manually create a real shortcut' {
            $wshShell = New-Object -comObject WScript.Shell
            $shortcut = $wshShell.CreateShortcut($shortcutPath)
            $shortcut.Save()
        }
        It 'returns exactly one object that looks like a shortcut' {
            $r = $shortcutPath | Get-Shortcut
            $r | Measure | % Count | Should be 1
            $r | Test-ValidShortcutObject |
                Should be $true
        }
        It 'cleanup' {
            Remove-Item $shortcutPath
        }
    }
    Context 'shortcut does not exist' {
        It 'returns nothing' {
            $r = $shortcutPath | Get-Shortcut
            $r | Should beNullOrEmpty
        }
    }
}

Describe Add-Shortcut {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $shortcutFilename = "Shortcut-$guidFrag.lnk"
    $tempPath = [System.IO.Path]::GetTempPath()
    $shortcutPath = Join-Path $tempPath $shortcutFilename

    Context 'shortcut doesn''t exist' {
        It 'returns exactly one object that looks like a shortcut' {
            $r = $shortcutPath | Add-Shortcut
            $r | Measure | % Count | Should be 1
            $r | Test-ValidShortcutObject |
                Should be $true
        }
    }
    Context 'shortcut exists' {
        It 'throws correct exception' {
            { $shortcutPath | Add-Shortcut } |
                Should throw 'already exists'
        }
    }
    It 'cleanup' {
        Remove-Item $shortcutPath
    }
}

Describe Remove-Shortcut {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $shortcutFilename = "Shortcut-$guidFrag.lnk"
    $tempPath = [System.IO.Path]::GetTempPath()
    $shortcutPath = Join-Path $tempPath $shortcutFilename

    Context 'shortcut exists' {
        It 'create the shortcut' {
            $shortcutPath | Add-Shortcut
        }
        It 'the shortcut exists' {
            $shortcutPath | Test-Shortcut | Should be $true
            $shortcutPath | Get-Shortcut | % FullName | Should be $shortcutPath
        }
        It 'returns nothing' {
            $r = $shortcutPath | Remove-Shortcut
            $r | Should beNullOrEmpty
        }
        It 'the shortcut no longer exists' {
            $shortcutPath | Test-Shortcut | Should be $false
            $shortcutPath | Get-Shortcut | Should beNullOrEmpty
        }
    }
    Context 'shortcut does not exist' {
        It 'the shortcut does not exist' {
            $shortcutPath | Test-Shortcut | Should be $false
            $shortcutPath | Get-Shortcut | Should beNullOrEmpty
        }
        It 'throws correct exception' {
            { $shortcutPath | Remove-Shortcut } |
                Should throw 'Shortcut not found'
        }
    }
}


foreach ( $values in @(
        @('TargetPath',      [string]::Empty,'C:\Windows\System32\WindowsPowershell\v1.0\powershell.exe'),
        @('WindowStyle',     1,              7),
        @('Hotkey',          [string]::Empty,'Alt+Ctrl+f'),
        @('IconLocation',    ',0',           'notepad.exe,0'),
        @('Description',     [string]::Empty,'Shortcut script'),
        @('WorkingDirectory',[string]::Empty,[System.IO.Path]::GetTempPath()),
        @('Arguments',       [string]::Empty,'c:\myFile.txt')
    )
)
{
    $propertyName,$initialValue,$propertyValue = $values
    Describe "Set- and Get-ShortcutProperty $propertyName $propertyValue" {
        $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
        $shortcutFilename = "Shortcut-$guidFrag.lnk"
        $tempPath = [System.IO.Path]::GetTempPath()
        $shortcutPath = Join-Path $tempPath $shortcutFilename

        Context 'shortcut exists' {
            It 'create the shortcut' {
                $shortcutPath | Add-Shortcut
            }
            It 'the shortcut exists' {
                $r = $shortcutPath | Test-Shortcut
                $r | Should be $true
            }
            It "the property $propertyName has initial value $initialValue" {
                $r = $shortcutPath | Get-Shortcut
                $initialValue -eq $r.$propertyName | Should be $true
            }
            It 'returns nothing' {
                $r = $shortcutPath | Set-ShortcutProperty $propertyName $propertyValue
                $r | Should beNullOrEmpty
            }
            It 'the property value is correct (Get-Shortcut)' {
                $r = $shortcutPath | Get-Shortcut
                $r.$propertyName | Should be $propertyValue
            }
            It 'the property value is correct (Get-ShortcutProperty)' {
                $r = $shortcutPath | Get-ShortcutProperty $propertyName
                $r | Should be $propertyValue
            }
        }
        Context 'cleanup' {
            It 'remove the shortcut' {
                $shortcutPath | Remove-Shortcut
            }
        }
        Context 'the shortcut does not exist' {
            It 'the shortcut does not exist' {
                $r = $shortcutPath | Test-Shortcut
                $r | Should be $false
            }
            It 'throws correct exception' {
                { $shortcutPath | Set-ShortcutProperty $propertyName $propertyValue } |
                    Should throw 'Shortcut not found'
            }
        }
    }
}

Describe "Get-NormalizedShortcutProperty" {
    foreach ( $values in @(
            @('TargetPath',      'c:/Windows/system32/calc.exe','c:\Windows\system32\calc.exe'),
            @('WindowStyle',     0, 0 ),
            @('Hotkey',          'Ctrl+Alt+f','Alt+Ctrl+f'),
            @('IconLocation',    'c:/Windows/system32/calc.exe,0','c:/Windows/system32/calc.exe,0'),
            @('Description',     'description','description'),
            @('WorkingDirectory','c:/Windows','c:/Windows'),
            @('Arguments',       'arguments','arguments')
        )
    )
    {
        $propertyName,$original,$normalized= $values
        Context "Get-NormalizedShortcutProperty $propertyName $original" {
            It "returns $normalized" {
                $r = Get-NormalizedShortcutProperty $propertyName $original
                $r | Should be $normalized
            }
        }
    }
}
}
