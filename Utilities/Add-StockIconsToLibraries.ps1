Describe 'add stock icons to libraries' {
    $guidFrag = '8ecdff81'
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
    foreach ( $value in [Microsoft.WindowsAPICodePack.Shell.StockIconIdentifier].GetEnumValues() )
    {
        Context "Create $value ($([int]$value))" {
            $h = @{}
            $libraryName = "$value-$guidFrag"
            It 'get the IconRefPath' {
                $h.RefPath = [PInvoker.PInvoker]::GetIconRefPath([int]$value)
            }
            It 'create the library' {
                [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$true)
            }
            [gc]::Collect()
            It "set the icon to $($h.RefPath)" {
                $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$false)
                $l.IconResourceId = $h.RefPath
            }
            [gc]::Collect()
        }
    }
}