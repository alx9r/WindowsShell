Import-Module WindowsShell -Force

InModuleScope WindowsShell {
Describe 'Get-IconReferencePath' {
    Mock Get-StockIconReferencePath -Verifiable
    Context 'StockIconName' {
        Mock Get-StockIconReferencePath { 'stock icon reference path' } -Verifiable
        It 'returns result based on StockIconName' {
            $splat = @{
                StockIconName = 'DocumentNotAssociated'
                IconFilePath = ''
                IconResourceId = 0
            }
            $r = Get-IconReferencePath @splat
            $r | Should be 'stock icon reference path'
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-StockIconReferencePath 1 {
                $StockIconName -eq 'DocumentNotAssociated'
            }
        }
    }
    Context 'IconFilePath' {
        It 'returns result based on IconFilePath' {
            $splat = @{
                StockIconName = ''
                IconFilePath = 'c:\Windows\calc.exe'
                IconResourceId = 1
            }
            $r = Get-IconReferencePath @splat
            $r | Should be 'c:\Windows\calc.exe,1'
        }
        It 'correctly invokes functions' {
            Assert-MockCalled Get-StockIconReferencePath 0 -Exactly
        }
    }
    Context 'neither' {
        It 'returns nothing' {
            $splat = @{
                StockIconName = ''
                IconFilePath = ''
                IconResourceId = 0
            }
            $r = Get-IconReferencePath @splat
            $r | Should beNullOrEmpty
        }
    }
}
}
