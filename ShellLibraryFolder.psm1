enum Ensure
{
    Present
    Absent
}

[DscResource()]
class ShellLibraryFolder
{
    [DscProperty(Key)]
    [string]
    $LibraryName

    [DscProperty(Mandatory)]
    [string[]]
    $FolderPath

    [DscProperty()]
    [Ensure]
    $Ensure

    [void] Set()
    {
        $this.FolderPath | 
            Invoke-ProcessShellLibraryFolder Set  $this.Ensure $this.LibraryName
    }
    [bool] Test()
    {
        $numSucceeded = $this.FolderPath |
            Invoke-ProcessShellLibraryFolder Test $this.Ensure $this.LibraryName |
            ? { $_ -eq $true } |
            Measure-Object |
            % Count
        return $numSucceeded -eq $this.FolderPath.Count
    }

    [ShellLibraryFolder] Get() { return $this }
} 