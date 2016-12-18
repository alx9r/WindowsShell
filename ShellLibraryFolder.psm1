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
    $FolderPath

    [DscProperty(Key)]
    [string]
    $LibraryName

    [DscProperty()]
    [Ensure]
    $Ensure

    [void] Set() { $this | Invoke-ProcessShellLibraryFolder Set }
    [bool] Test() { return $this | Invoke-ProcessShellLibraryFolder Test }

    [ShellLibraryFolder] Get() { return $this }
} 