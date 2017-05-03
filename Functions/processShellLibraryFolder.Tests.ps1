Import-Module WindowsShell -Force

InModuleScope WindowsShell {

Describe 'Invoke-ProcessShellLibraryFolder' {
    Mock Invoke-ProcessPersistentItem { 'return value' } -Verifiable
    Context 'plumbing'{
        It 'returns exactly one item' {
            $params = New-Object psobject -Property @{
                Mode = 'Set'
                Ensure = 'Present'
                FolderPath = 'c:\folder\path'
                LibraryName = 'LibraryName'
            }
            $r = $params | Invoke-ProcessShellLibraryFolder
            $r.Count | Should be 1
            $r | Should be 'return value'
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Invoke-ProcessPersistentItem 1 {
                $Mode -eq 'Set' -and
                $Ensure -eq 'Present' -and
                $_Keys.FolderPath -eq 'c:\folder\path' -and
                $_Keys.LibraryName -eq 'LibraryName' -and

                #Properties
                $Properties.Count -eq 0
            }
        }
    }
}
}

