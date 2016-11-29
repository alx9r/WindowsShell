Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}
foreach ( $i in 1..1 )
{
Describe "ShellLibrary - One Runspace ($i)" {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "MyLibrary-$guidFrag"
    $h = @{}
    BeforeEach { [gc]::Collect() }
    It 'create a new library' {
        $overwrite = $false
        $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$overwrite)
        $r.GetType() | Should be 'Microsoft.WindowsAPICodePack.Shell.ShellLibrary'
    }
    It 'get the new library' {
        $readonly = $false
        $h.NewLibrary = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$readonly)
        $h.NewLibrary.GetType() | Should be 'Microsoft.WindowsAPICodePack.Shell.ShellLibrary'
        $h.NewLibrary.Name | Should be $libraryName
    }
    It 'get the library''s type' {
        $r = $h.NewLibrary.LibraryType
        $r | Should beNullOrEmpty
    }
    It 'setting the new library''s type sometimes throws an exception' {
        try
        { 
            $h.NewLibrary.LibraryType = [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::Pictures
        }
        catch
        {
            $_.Exception | Should match 'Exception setting "LibraryType"'
        }
    }
    It 'get the library''s type' {
        $r = $h.NewLibrary.LibraryType.ToString()
        $r | Should be 'Pictures'
    }
    It 'get an icon resource id' {
        $h.MusicIconResourceId =  [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load('Music',$true).IconResourceId
        $h.MusicIconResourceId.GetType() | Should be 'Microsoft.WindowsAPICodePack.Shell.IconReference'
    }
    It 'setting the new library''s icon sometimes throws an exception' {
        try
        {
            $h.NewLibrary.IconResourceId = $h.MusicIconResourceId
        }
        catch
        {
            $_.Exception | Should match 'Exception setting "IconResourceId"'
        }
    }
    It 'dispose the library' {
        $l = $h.NewLibrary
        $h.Remove('NewLibrary')
        $l.Dispose()
    }
    It 'compose the path to the library' {
        $librariesPath = [System.IO.Path]::Combine(
            [System.Environment]::GetFolderPath( [System.Environment+SpecialFolder]::ApplicationData ),
            [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::LibrariesKnownFolder.RelativePath
        )
        $libraryPath = [System.IO.Path]::Combine($librariesPath, $libraryName);
        $h.NewLibraryPath = [System.IO.Path]::ChangeExtension($libraryPath, "library-ms")
    }
    It 'record the library item' {
        $h.NewLibraryItem = Get-Item $h.NewLibraryPath -ea Stop
    }
    It 'remove the new library' {
        [System.IO.File]::Delete($h.NewLibraryPath)
    }
    It 'the library item can no longer be retrieved' {
        try
        {
            Get-Item $h.NewLibraryPath -ea Stop
        }
        catch
        {
            $_.Exception | Should match '(it does not exist|Access is denied)'
        }
    }
    It 'sometimes testing the library path returns false, sometimes access is denied' {
        try
        {
            $r = Test-Path $h.NewLibraryPath -ea Stop
        }
        catch
        {
            $threw = $true
            $_.Exception | Should match 'Access is denied'
        }
        if ( -not $threw )
        {
            $r | Should be $false
        }
    }
    It 'the removed library can sometimes still be loaded' {
        $readonly = $false
        try
        {
            $r = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$readonly)
        }
        catch
        {
            $threw = $true
            $_.Exception | Should match 'Shell Exception has occurred'
        }
        if ( -not $threw )
        {
            $r.Name | Should be $libraryName
        }
    }
}
}
