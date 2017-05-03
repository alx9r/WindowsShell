Import-Module WindowsShell -Force

InModuleScope WindowsShell {

Describe 'Invoke-ProcessShortcut' {
    Mock Get-IconReferencePath -Verifiable
    Mock Invoke-ProcessPersistentItem -Verifiable
    Context 'plumbing' {
        Mock Get-IconReferencePath { 'icon reference path' } -Verifiable
        Mock Invoke-ProcessPersistentItem { 'return value' } -Verifiable
        It 'returns exactly one item' {
            $params = New-Object psobject -Property @{
                Mode = 'Set'
                Ensure = 'Present'
                Path = 'path'
                TargetPath = 'target path'
                Arguments = 'arguments'
                WorkingDirectory = 'working directory'
                WindowStyle = 'Normal'
                Hotkey = 'hotkey'
                StockIconName = 'stock icon name'
                IconFilePath = 'icon file path'
                IconResourceId = 1
                Description = 'description'
            }
            $r = $params | Invoke-ProcessShortcut
            $r.Count | Should be 1
            $r | Should be 'return value'
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-IconReferencePath 1 {
                $StockIconName -eq 'stock icon name' -and
                $IconFilePath -eq 'icon file path' -and
                $IconResourceId -eq 1
            }
            Assert-MockCalled Invoke-ProcessPersistentItem 1 {
                $Mode -eq 'Set' -and
                $Ensure -eq 'Present' -and
                $_Keys.Path -eq 'path' -and

                #Properties
                $Properties.TargetPath -eq 'target path' -and
                $Properties.Arguments -eq 'arguments' -and
                $Properties.WorkingDirectory -eq 'working directory' -and
                $Properties.WindowStyle -eq 'Normal' -and
                $Properties.IconLocation -eq 'icon reference path' -and # <- icon
                $Properties.Description -eq 'description'
            }
        }
    }
    Context 'omit optional' {
        Mock Invoke-ProcessPersistentItem { 'return value' } -Verifiable
        It 'returns exactly one item' {
            $params = New-Object psobject -Property @{
                Mode = 'Set'
                Ensure = 'Present'
                Path = 'path'
            }
            $r = $params | Invoke-ProcessShortcut
            $r.Count | Should be 1
            $r | Should be 'return value'
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Invoke-ProcessPersistentItem 1 {
                $Mode -eq 'Set' -and
                $Ensure -eq 'Present' -and
                $_Keys.Path -eq 'path' -and

                #Properties
                $Properties.Count -eq 0
            }
        }
    }
}
}
