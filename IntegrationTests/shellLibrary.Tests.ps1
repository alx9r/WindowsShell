Import-Module WindowsShell -Force

Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}

Describe Get-ShellLibrary {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "MyLibrary-$guidFrag"
    It 'manually create a real library' {
        try
        {
            $overwrite = $false
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$overwrite)
            $l.IconResourceId = [Microsoft.WindowsAPICodePack.Shell.IconReference]::new('C:\WINDOWS\system32\imageres.dll,-94')
            $l.LibraryType = [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::Pictures
        }
        finally
        {
            $l.Dispose()
        }
    }
    It 'returns exactly one ShellLibrary object' {
        $r = $libraryName | Get-ShellLibrary
        $r.Count | Should be 1
        $r.Name | Should be $libraryName
        $r.GetType() | Should be 'ShellLibrary'
    }
    It 'populates type name' {
        $r = $libraryName | Get-ShellLibrary
        $r.TypeName | Should be 'Pictures'
    }
    It 'populates icon reference path' {
        $r = $libraryName | Get-ShellLibrary
        $r.IconReferencePath | Should be 'C:\WINDOWS\system32\imageres.dll,-94'
    }
    It 'manually remove the real library' {
        $librariesPath = [System.IO.Path]::Combine(
            [System.Environment]::GetFolderPath( [System.Environment+SpecialFolder]::ApplicationData ),
            [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::LibrariesKnownFolder.RelativePath
        )
        $libraryPath = [System.IO.Path]::Combine($librariesPath, $libraryName);
        $fullLibraryPath = [System.IO.Path]::ChangeExtension($libraryPath, "library-ms")
        [System.IO.File]::Delete($fullLibraryPath)
    }
}