Describe 'remove stock icons from libraries' {
    $guidFrag = '8ecdff81'
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
    foreach ( $value in [Microsoft.WindowsAPICodePack.Shell.StockIconIdentifier].GetEnumValues() )
    {
        Context "Create $value ($([int]$value))" {
            $libraryName = "$value-$guidFrag"
            $h = @{}
            It 'compose the library path' {
                $librariesPath = [System.IO.Path]::Combine(
                    [System.Environment]::GetFolderPath( [System.Environment+SpecialFolder]::ApplicationData ),
                    [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::LibrariesKnownFolder.RelativePath
                )
                $libraryPath = [System.IO.Path]::Combine($librariesPath, $libraryName);
                $h.FullPath = [System.IO.Path]::ChangeExtension($libraryPath, "library-ms")
            }
            It 'delete the library if it exists' {
                Remove-Item $h.FullPath -ErrorAction SilentlyContinue
            }
        }
    }
}