Import-Module WindowsShell -Force

. "$PSScriptRoot\TestFunctions\resourcePlumbing.ps1"

foreach ( $resourceName in 'ShellLibrary','ShellLibraryFolder' )
{
    $params = New-Object psobject -Property @{
        ModuleName = 'WindowsShell'
        ResourceName = $resourceName
        FunctionName = "Invoke-Process$resourceName"
    }
    $params | Test-ResourceObject
    $params | Test-ProcessFunction
    $params | Test-ResourcePlumbing
}