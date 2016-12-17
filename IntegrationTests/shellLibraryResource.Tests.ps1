Remove-Module WindowsShell -fo -ea si; Import-Module WindowsShell
Import-Module PSDesiredStateConfiguration

Describe 'ShellLibrary Resource' {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "Resource-$guidFrag"
    $h = @{}
    It 'is available using Get-DscResource' {
        $r = Get-DscResource ShellLibrary WindowsShell
        $r.Name | Should be 'ShellLibrary'
    }
    It 'create object' {
        $h.d = (Get-Module WindowsShell).NewBoundScriptBlock({
            [ShellLibrary]::new()
        }).InvokeReturnAsIs()
    }
    Context 'test, create, test, remove, test' {
        It 'test returns false' {
            $h.d.Name = $libraryName
            $r = $h.d.Test()
            $r | Should be $false
        }
        It 'create' {
            $h.d.Set()
        }
        It 'test returns true' {
            $r = $h.d.Test()
            $r | Should be $true
        }
        It 'remove' {
            $h.d.Ensure = 'Absent'
            $h.d.Set()
        }
        It 'test returns false' {
            $h.d.Ensure = 'Present'
            $r = $h.d.Test()
            $r | Should be $false
        }
    }
    Context 'icon' {
        It 'testing different icon returns false' {
            $h.d.StockIconName = 'Application'
            $r = $h.d.Test()
            $r | Should be $false
        }
        It 'set different icon' {
            $h.d.Set()
        }
        It 'testing different icon returns true' {
            $r = $h.d.Test()
            $r | Should be $true
        }
    }
    Context 'library type' {
        It 'testing different library type returns false' {
            $h.d.TypeName = 'Music'
            $r = $h.d.Test()
            $r | Should be $false
        }
        It 'set different library type' {
            $h.d.Set()
        }
        It 'testing different library type returns true' {
            $r = $h.d.Test()
            $r | Should be $true
        }
    }
    Context 'clean up' {
        It 'remove library' {
            $h.d.Ensure = 'Absent'
            $h.d.Set()
            $h.d.Test() | Should be $true
        }
    }
}