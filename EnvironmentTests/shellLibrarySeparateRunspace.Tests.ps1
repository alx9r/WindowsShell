Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}

function InvokeInNewRunspace
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        [scriptblock]
        $Scriptblock,

        [Parameter(Position = 1)]
        [hashtable]
        $Parameters
    )
    process
    {
        $runspace = [runspacefactory]::CreateRunspace()
        $ps = [powershell]::Create()
        $ps.Runspace =$runspace
        $runspace.Open() | Out-Null
        $ps.AddScript($Scriptblock) | Out-Null
        foreach ( $parameterName in $Parameters.Keys )
        {
            $ps.AddParameter($parameterName,$Parameters.$parameterName) | Out-Null
        }
        $r = $ps.Invoke()
        $ps.Runspace.Dispose()
        $ps.Dispose()
        return $r
    }
}

Describe 'InvokeInNewRunspace' {
    It 'has same PID' {
        $r = { $pid } | InvokeInNewRunspace
        $r | Should be $pid
    }
    It 'has different runspace ID' {
        $r = { [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.InstanceId.Guid } |
            InvokeInNewRunspace
        $r | Should not be ([System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.InstanceId.Guid)
    }
    It 'handles parameters' {
        $r = { param($param1,$param2) "param1: $param1 param2: $param2" } |
            InvokeInNewRunspace @{ param1 = 'a'; param2 = 'b' }
        $r | Should be 'param1: a param2: b'
    }
}

Describe 'ShellLibrary - SeparateRunspace' {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "MyLibrary-$guidFrag"
    $h = @{}
    BeforeEach { [gc]::Collect() }
    It 'create a new library' {
        $r = {
            param($LibraryName)
            $overwrite = $false
            [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($LibraryName,$overwrite).GetType()
        } |
            InvokeInNewRunspace @{ LibraryName = $libraryName }
        $r | Should be 'Microsoft.WindowsAPICodePack.Shell.ShellLibrary'
    }
    It 'get the new library' {
        $r = {
            param ($LibraryName)
            $readonly = $false
            [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$readonly).Name
        } |
            InvokeInNewRunspace @{ LibraryName = $libraryName }
        $r | Should be $libraryName
    }
    It 'get the new library''s type' {
        $r = {
            param ($LibraryName)
            return [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$false).LibraryType
        } |
            InvokeInNewRunspace @{ LibraryName = $libraryName }
        $r | Should beNullOrEmpty
    }
    It 'set the new library''s type' {
        {
            param($LibraryName)
            $library = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$false)
            $library.LibraryType = [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::Pictures
        } |
            InvokeInNewRunspace @{ LibraryName = $libraryName }
    }
    It 'get the new library''s type' {
        $r = {
            param ($LibraryName)
            return [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$false).LibraryType.ToString()
        } |
            InvokeInNewRunspace @{ LibraryName = $libraryName }
        $r | Should be 'Pictures'
    }
    It 'test the new library''s icon' {
        $r = {
            param ($LibraryName)
            $library = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$false)
            $library.IconResourceId.Equals([Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load('Music',$true).IconResourceId)
        } |
            InvokeInNewRunspace @{ LibraryName = $libraryName }
        $r | Should be $false
    }
    It 'set the new library''s icon' {
        {
            param ($LibraryName)
            $library = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$false)
            $library.IconResourceId = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load('Music',$true).IconResourceId
        } |
            InvokeInNewRunspace @{ LibraryName = $libraryName }
    }
    It 'test the new library''s icon' {
        $r = {
            param ($LibraryName)
            $library = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$false)
            $library.IconResourceId.Equals([Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load('Music',$true).IconResourceId)
        } |
            InvokeInNewRunspace @{ LibraryName = $libraryName }
        $r | Should be $true
    }
    It 'compose the path to the library' {
        $librariesPath = [System.IO.Path]::Combine(
            [System.Environment]::GetFolderPath( [System.Environment+SpecialFolder]::ApplicationData ),
            [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::LibrariesKnownFolder.RelativePath
        )
        $libraryPath = [System.IO.Path]::Combine($librariesPath, $libraryName);
        $h.NewLibraryPath = [System.IO.Path]::ChangeExtension($libraryPath, "library-ms")
    }
    It 'the path tests true' {
        $r = Test-Path $h.NewLibraryPath -ea Stop
        $r | Should be $true
    }
    It 'remove the new library' {
        {
            param ($LibraryPath)
            [System.IO.File]::Delete($LibraryPath)
        } |
            InvokeInNewRunspace @{ LibraryPath = $h.NewLibraryPath }
    }
    It 'the path tests false' {
        $r = Test-Path $h.NewLibraryPath -ea Stop
        $r | Should be $false
    }
}

<#
foreach ( $i in 1..1 )
{
Describe "ShellLibrary - One Runspace ($i)" {
    $guidFrag = [guid]::NewGuid().Guid.Split('-')[0]
    $libraryName = "MyLibrary-$guidFrag"
    $h = @{}
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
#>