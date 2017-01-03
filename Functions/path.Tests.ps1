Import-Module WindowsShell -Force

InModuleScope WindowsShell {

Describe Test-FolderPathsAreEqual {
    $values = @(
        @('c:\folder\', 'c:\folder',  $true),
        @('c:\folder1', 'c:\folder2', $false),
        @('c:\folder\', 'c:/folder',  $true),
        @('c:/folder',  'c:\folder',  $true),
        @('c:/folder1', 'c:/folder2', $false)
    )
    foreach ( $value in $values )
    {
        $a,$b,$expected = $value
        It "$b -eq $b is $expected" {
            $r = Test-FolderPathsAreEqual $a $b
            $r | Should be $expected
        }
    }
}

Describe ConvertTo-WindowsShellFolderPathFormat {
    $values = @(
        @('c:\folder', 'c:\folder'),
        @('c:/folder', 'c:\folder'),
        @('c:\folder\','c:\folder'),
        @('c:\\folder','c:\folder')
    )
    foreach ( $value in $values )
    {
        $in,$out = $value
        It "$in becomes $out" {
            $r = $in | ConvertTo-WindowsShellFolderPathFormat
            $r | Should be $out
        }
    }
}
}
