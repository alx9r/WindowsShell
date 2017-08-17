[DscResource()]
class ShellLibraryFolder
{
    [DscProperty(Key,Mandatory)]
    [string]
    $LibraryName

    [DscProperty(Mandatory)]
    [string[]]
    $FolderPath

    [DscProperty()]
    [System.Nullable[Ensure]]
    $Ensure = 'Present'

    [void] Set()
    {
        $this.FolderPath |
            % { $this | Invoke-ProcessShellLibraryFolder Set -FolderPath $_ }
    }
    [bool] Test()
    {
        $numSucceeded = $this.FolderPath |
            % { $this | Invoke-ProcessShellLibraryFolder Test -FolderPath $_ }  |
            ? { $_ -eq $true } |
            Measure-Object |
            % Count
        return $numSucceeded -eq $this.FolderPath.Count
    }

    [ShellLibraryFolder] Get() { return $this }
} 