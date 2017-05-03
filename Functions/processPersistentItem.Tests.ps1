`Import-Module WindowsShell -Force

InModuleScope WindowsShell {

function Get-PersistentItem    { param ($Key) }
function Add-PersistentItem    { param ($Key) }
function Remove-PersistentItem { param ($Key) }

Describe 'Invoke-ProcessPersistentItem -Ensure Present: ' {
    Mock Get-PersistentItem -Verifiable
    Mock Add-PersistentItem -Verifiable
    Mock Remove-PersistentItem { 'junk' } -Verifiable
    Mock Invoke-ProcessPersistentItemProperty -Verifiable

    $delegates = @{
        Getter = 'Get-PersistentItem'
        Adder = 'Add-PersistentItem'
        Remover = 'Remove-PersistentItem'
        PropertyGetter = 'Get-PersistentItemProperty'
        PropertySetter = 'Set-PersistentItemProperty'
        PropertyNormalizer = 'Get-NormalizedPersistentItemProperty'
    }

    Context '-Ensure Present: absent, Set' {
        Mock Add-PersistentItem { 'item' }
        It 'returns nothing' {
            $splat = @{
                Key = 'key value'
                Properties = @{ P = 'P desired' }
            }
            $r = Invoke-ProcessPersistentItem Set Present @splat @delegates
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-PersistentItem 1 { $Key -eq 'key value' }
            Assert-MockCalled Add-PersistentItem 1 { $Key -eq 'key value' }
            Assert-MockCalled Remove-PersistentItem 0 -Exactly
            Assert-MockCalled Invoke-ProcessPersistentItemProperty 1 {
                $Mode -eq 'Set' -and
                $Key -eq 'key value' -and
                $Properties.P -eq 'P desired' -and
                $PropertyGetter -eq 'Get-PersistentItemProperty' -and
                $PropertySetter -eq 'Set-PersistentItemProperty' -and
                $PropertyNormalizer -eq 'Get-NormalizedPersistentItemProperty'
            }
        }
    }

    Context '-Ensure Present: absent, Test' {
        It 'returns false' {
            $splat = @{ Key = 'key value' }
            $r = Invoke-ProcessPersistentItem Test Present @splat @delegates
            $r | Should be $false
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-PersistentItem 1 { $Key -eq 'key value' }
            Assert-MockCalled Add-PersistentItem 0 -Exactly
            Assert-MockCalled Remove-PersistentItem 0 -Exactly
            Assert-MockCalled Invoke-ProcessPersistentItemProperty 0 -Exactly
        }
    }
    Context '-Ensure Present: present, Set' {
        Mock Get-PersistentItem { 'item' } -Verifiable
        It 'returns nothing' {
            $splat = @{ Key = 'key value' }
            $r = Invoke-ProcessPersistentItem Set Present @splat @delegates
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-PersistentItem 1 { $Key -eq 'key value' }
            Assert-MockCalled Add-PersistentItem 0 -Exactly
            Assert-MockCalled Remove-PersistentItem 0 -Exactly
            Assert-MockCalled Invoke-ProcessPersistentItemProperty 1
        }
    }
    Context '-Ensure Present: present, Test' {
        Mock Get-PersistentItem { 'item' } -Verifiable
        Mock Invoke-ProcessPersistentItemProperty { 'property test result' } -Verifiable
        It 'returns result of properties test' {
            $splat = @{ Key = 'key value' }
            $r = Invoke-ProcessPersistentItem Set Present @splat @delegates
            $r | Should be 'property test result'
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-PersistentItem 1 { $Key -eq 'key value' }
            Assert-MockCalled Add-PersistentItem 0 -Exactly
            Assert-MockCalled Remove-PersistentItem 0 -Exactly
            Assert-MockCalled Invoke-ProcessPersistentItemProperty 1
        }
    }
    Context '-Ensure Absent: absent, Set' {
        It 'returns nothing' {
            $splat = @{ Key = 'key value' }
            $r = Invoke-ProcessPersistentItem Set Absent @splat @delegates
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-PersistentItem 1 { $Key -eq 'key value' }
            Assert-MockCalled Add-PersistentItem 0 -Exactly
            Assert-MockCalled Remove-PersistentItem 0 -Exactly
            Assert-MockCalled Invoke-ProcessPersistentItemProperty 0 -Exactly
        }
    }
    Context '-Ensure Absent: absent, Test' {
        It 'returns true' {
            $splat = @{ Key = 'key value' }
            $r = Invoke-ProcessPersistentItem Test Absent @splat @delegates
            $r | Should be $true
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-PersistentItem 1 { $Key -eq 'key value' }
            Assert-MockCalled Add-PersistentItem 0 -Exactly
            Assert-MockCalled Remove-PersistentItem 0 -Exactly
            Assert-MockCalled Invoke-ProcessPersistentItemProperty 0 -Exactly
        }
    }
    Context '-Ensure Absent: present, Set' {
        Mock Get-PersistentItem { 'item' } -Verifiable
        It 'returns nothing' {
            $splat = @{ Key = 'key value' }
            $r = Invoke-ProcessPersistentItem Set Absent @splat @delegates
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-PersistentItem 1 { $Key -eq 'key value' }
            Assert-MockCalled Add-PersistentItem 0 -Exactly
            Assert-MockCalled Remove-PersistentItem 1 { $Key -eq 'key value' }
            Assert-MockCalled Invoke-ProcessPersistentItemProperty 0 -Exactly
        }
    }
    Context '-Ensure Absent: present, Test' {
        Mock Get-PersistentItem { 'item' } -Verifiable
        It 'returns false' {
            $splat = @{ Key = 'key value' }
            $r = Invoke-ProcessPersistentItem Test Absent @splat @delegates
            $r | Should be $false
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-PersistentItem 1 { $Key -eq 'key value' }
            Assert-MockCalled Add-PersistentItem 0 -Exactly
            Assert-MockCalled Remove-PersistentItem 0 -Exactly
            Assert-MockCalled Invoke-ProcessPersistentItemProperty 0 -Exactly
        }
    }
}


function Get-PersistentItemProperty           { param ($Key,$PropertyName) }
function Set-PersistentItemProperty           { param ($Key,$PropertyName,$Value) }
function Get-NormalizedPersistentItemProperty { param ($PropertyName,$Value) }

Describe 'Invoke-ProcessPersistentItemProperty' {
    Mock Get-NormalizedPersistentItemProperty -Verifiable
    Mock Get-PersistentItemProperty -Verifiable
    Mock Set-PersistentItemProperty { 'junk' } -Verifiable

    $delegates = @{
        PropertyGetter = 'Get-PersistentItemProperty'
        PropertySetter = 'Set-PersistentItemProperty'
        PropertyNormalizer = 'Get-NormalizedPersistentItemProperty'
    }
    Context 'Set, property already correct' {
        Mock Get-NormalizedPersistentItemProperty { 'already correct' } -Verifiable
        Mock Get-PersistentItemProperty { 'already correct' } -Verifiable
        It 'returns nothing' {
            $splat = @{
                Key = 'key value'
                Properties = @{ P = 'already correct' }
            }
            $r = Invoke-ProcessPersistentItemProperty Set @splat @delegates
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-NormalizedPersistentItemProperty 1 {
                $PropertyName -eq 'P' -and
                $Value -eq 'already correct'
            }
            Assert-MockCalled Get-PersistentItemProperty 1 {
                $Key -eq 'key value' -and
                $PropertyName -eq 'P'
            }
            Assert-MockCalled Set-PersistentItemProperty 0 -Exactly
        }
    }
    Context 'Test, property correct' {
        Mock Get-NormalizedPersistentItemProperty { 'correct' } -Verifiable
        Mock Get-PersistentItemProperty { 'correct' } -Verifiable
        It 'returns true' {
            $splat = @{
                Key = 'key value'
                Properties = @{ P = 'correct' }
            }
            $r = Invoke-ProcessPersistentItemProperty Test @splat @delegates
            $r | Should be $true
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-NormalizedPersistentItemProperty 1 {
                $PropertyName -eq 'P' -and
                $Value -eq 'correct'
            }
            Assert-MockCalled Get-PersistentItemProperty 1 {
                $Key -eq 'key value' -and
                $PropertyName -eq 'P'
            }
            Assert-MockCalled Set-PersistentItemProperty 0 -Exactly
        }
    }
    Context 'Set, correcting property' {
        Mock Get-NormalizedPersistentItemProperty { 'normalized' } -Verifiable
        Mock Get-PersistentItemProperty { 'original' } -Verifiable
        It 'returns nothing' {
            $splat = @{
                Key = 'key value'
                Properties = @{ P = 'desired' }
            }
            $r = Invoke-ProcessPersistentItemProperty Set @splat @delegates
            $r | Should beNullOrEmpty
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-NormalizedPersistentItemProperty 1 {
                $PropertyName -eq 'P' -and
                $Value -eq 'desired'
            }
            Assert-MockCalled Get-PersistentItemProperty 1 {
                $Key -eq 'key value' -and
                $PropertyName -eq 'P'
            }
            Assert-MockCalled Set-PersistentItemProperty 1 -Exactly {
                $Key -eq 'key value' -and
                $PropertyName -eq 'P' -and
                $Value -eq 'desired'
            }
        }
    }
    Context 'Test, property incorrect' {
        Mock Get-NormalizedPersistentItemProperty { 'normalized' } -Verifiable
        Mock Get-PersistentItemProperty { 'original' } -Verifiable
        It 'returns false' {
            $splat = @{
                Key = 'key value'
                Properties = @{ P = 'desired' }
            }
            $r = Invoke-ProcessPersistentItemProperty Test @splat @delegates
            $r | Should be $false
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-NormalizedPersistentItemProperty 1 {
                $PropertyName -eq 'P' -and
                $Value -eq 'desired'
            }
            Assert-MockCalled Get-PersistentItemProperty 1 {
                $Key -eq 'key value' -and
                $PropertyName -eq 'P'
            }
            Assert-MockCalled Set-PersistentItemProperty 0 -Exactly
        }
    }
}
}
