Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}
Describe 'KnownFolders' {
    $h = @{}
    It 'retrieves existing Windows Shell libraries' {
        $h.Libraries = [Microsoft.WindowsAPICodePack.Shell.KnownFolders]::Libraries
    }
    It 'contains a common library name' {
        $r = $h.Libraries | % Name
        $presentNames = 'Music','Videos','Documents','Pictures' |
            ? { $r -contains $_ }
        $presentNames.Count | Should beGreaterThan 0
    }
}