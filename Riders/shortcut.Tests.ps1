Import-Module WindowsShell -Force

InModuleScope WindowsShell {

Describe 'Shortcut object' {
    Context 'create' {
        $h = @{}
        It 'create with no arguments throws' {
            $wshShell = New-Object -ComObject WScript.Shell
            { $wshShell.CreateShortcut() } |
                Should throw 'Cannot find an overload'
        }
        It 'create with bogus file path...' {
            $name = "$([guid]::NewGuid().Guid).lnk"
            $wshShell = New-Object -ComObject WScript.Shell
            $h.shortcut = $wshShell.CreateShortcut($name)
            $h.shortcut.FullName |
                Should match $name.Split('.')[0]
        }
        It '...then changing to another bogus file path fails' {
            $name = "$([guid]::NewGuid().Guid).lnk"
            { $h.shortcut.FullName = $name } |
                Should throw 'Cannot find an overload'
        }
        It 'the .FullName property has no setter' {
            $h.shortcut |
                Get-Member FullName |
                % Definition |
                Should not match 'set'
        }
    }
}
Describe 'Shortcut CRUD' {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $shortcutFilename = "Shortcut-$guidFrag.lnk"
    $tempPath = [System.IO.Path]::GetTempPath()
    $shortcutPath = Join-Path $tempPath $shortcutFilename
    Context 'create' {
        It 'nothing exists at the path' {
            Test-Path $shortcutPath | Should be $false
        }
        It 'create' {
            $wshShell = New-Object -comObject WScript.Shell
            $shortcut = $wshShell.CreateShortcut($shortcutPath)
            $shortcut.Save()
        }
        It 'file exists at the path' {
            Test-Path $shortcutPath | Should be $true
        }
        It 'cleanup' {
            Remove-Item $shortcutPath
        }
    }
    Context 'create using bad path' {
        $badFolderPath = "$tempPath\$guidFrag"
        $badShortcutPath = "$badFolderPath\badpath.lnk"
        It 'the folder for the shortcut doesn''t exist' {
            Test-Path $badFolderPath | Should be $false
        }
        It 'creating a new shortcut throws' {
            $wshShell = New-Object -comObject WScript.Shell
            $shortcut = $wshShell.CreateShortcut($badShortcutPath)
            { $shortcut.Save() } |
                Should throw 'Unable to save shortcut'
        }
        It 'nothing exists at the path' {
            Test-Path $badShortcutPath | Should be $false
        }
    }
    Context 'read and update' {
        It 'create' {
            $wshShell = New-Object -comObject WScript.Shell
            $shortcut = $wshShell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = 'C:\Windows\System32\WindowsPowershell\v1.0\powershell.exe'
            $shortcut.Save()
        }
        It 'creating another shortcut object reads the existing shortcut...' {
            $wshShell = New-Object -comObject WScript.Shell
            $shortcut = $wshShell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath | Should match 'powershell'
        }
        It '...that object can be modified and saved' {
            $wshShell = New-Object -comObject WScript.Shell
            $shortcut = $wshShell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = 'C:\Windows\system32\calc.exe'
            $shortcut.Save()
        }
        It '...the modifications persists.' {
            $wshShell = New-Object -comObject WScript.Shell
            $shortcut = $wshShell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath | Should match 'calc'
        }
        It 'cleanup' {
            Remove-Item $shortcutPath
        }
    }
    Context 'remove' {
        It 'create' {
            $wshShell = New-Object -comObject WScript.Shell
            $shortcut = $wshShell.CreateShortcut($shortcutPath)
            $shortcut.Save()
        }
        It 'exists' {
            Test-Path $shortcutPath | Should be $true
        }
        It 'remove' {
            Remove-Item $shortcutPath
        }
        It 'no longer exists' {
            Test-Path $shortcutPath | Should be $false
        }
    }
}
Describe 'Shortcut properties' {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $shortcutFilename = "Shortcut-$guidFrag.lnk"
    $tempPath = [System.IO.Path]::GetTempPath()
    $shortcutPath = Join-Path $tempPath $shortcutFilename

    foreach ( $values in @(
            @('WindowStyle',1),
            @('Hotkey', 'Alt+Ctrl+f'),
            @('IconLocation','notepad.exe,0'),
            @('Description','Shortcut script'),
            @('WorkingDirectory',$tempPath),
            @('Arguments', 'c:\myFile.txt')
        )
    )
    {
        $propertyName,$value = $values
        Context ".$propertyName = $value" {
            It 'create with property' {
                $wshShell = New-Object -comObject WScript.Shell
                $shortcut = $wshShell.CreateShortcut($shortcutPath)
                $shortcut.$propertyName = $value
                $shortcut.Save()
            }
            It 'the property persists' {
                $wshShell = New-Object -comObject WScript.Shell
                $shortcut = $wshShell.CreateShortcut($shortcutPath)
                $shortcut.$propertyName |
                    Should be $value
            }
        }
    }
    It 'cleanup' {
        Remove-Item $shortcutPath
    }
}

Describe 'Shortcut Hotkey String' {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $shortcutFilename = "Shortcut-$guidFrag.lnk"
    $tempPath = [System.IO.Path]::GetTempPath()
    $shortcutPath = Join-Path $tempPath $shortcutFilename

    foreach ( $values in @(
            @('Ctrl+Alt+f','Alt+Ctrl+f'),
            @('Ctrl+Alt+Shift+f','Alt+Ctrl+Shift+f')
        )
    )
    {
        $original,$final = $values
        Context "$original becomes $final" {
            It "create with $original" {
                $wshShell = New-Object -comObject WScript.Shell
                $shortcut = $wshShell.CreateShortcut($shortcutPath)
                $shortcut.Hotkey = $original
                $shortcut.Save()
            }
            It "reading back results in $final"{
                $wshShell = New-Object -comObject WScript.Shell
                $shortcut = $wshShell.CreateShortcut($shortcutPath)
                $shortcut.Hotkey |
                    Should be $final
            }
        }
    }
    Context 'allowed characters' {
        foreach ( $char in 'azAZ09'.GetEnumerator() )
        {
            $character = $char.ToString()
            It "$character" {
                $wshShell = New-Object -comObject WScript.Shell
                $shortcut = $wshShell.CreateShortcut($shortcutPath)
                $shortcut.Hotkey = $character
                $shortcut.Save()

                $wshShell = New-Object -comObject WScript.Shell
                $shortcut = $wshShell.CreateShortcut($shortcutPath)
                $shortcut.Hotkey |
                    Should be $character
            }
        }
    }
    Context 'disallowed letters' {
        foreach ( $char in '`-=[]\;'',./*-+'.GetEnumerator() )
        {
            $character = $char.ToString()
            It "$character" {
                $wshShell = New-Object -comObject WScript.Shell
                $shortcut = $wshShell.CreateShortcut($shortcutPath)
                { $shortcut.Hotkey = $character } |
                    Should throw 'Value does not fall within the expected range.'
            }
        }
    }
    Context 'use Shell.Shortcut method to normalize' {
        $h = @{}
        It 'create shortcut object' {
            $wshShell = New-Object -ComObject WScript.Shell
            $h.shortcut = $wshShell.CreateShortcut("$([guid]::NewGuid().Guid).lnk")
        }
        It 'set Hotkey property' {
            $h.shortcut.Hotkey = 'Ctrl+Alt+f'
        }
        It 'the string in the property is normalized' {
            $h.shortcut.Hotkey |
                Should be 'Alt+Ctrl+f'
        }
    }
    It 'cleanup' {
        Remove-Item $shortcutPath
    }
}

}
