function Get-ShellLibraryPath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [string]
        $Name
    )
    process
    {
        $librariesPath = [System.IO.Path]::Combine(
            [System.Environment]::GetFolderPath( [System.Environment+SpecialFolder]::ApplicationData ),
            [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::LibrariesKnownFolder.RelativePath
        )
        $libraryPath = [System.IO.Path]::Combine($librariesPath, $Name)
        return [System.IO.Path]::ChangeExtension($libraryPath, "library-ms")
    }
}

function Test-ShellLibrary
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [string]
        $Name
    )
    process
    {
        $Name | Get-ShellLibraryPath | Test-Path -ea Stop
    }
}

function Convert-ShellLibraryObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        $InputObject
    )
    process
    {
        New-Object ShellLibraryInfo -Property @{
            Name     = $InputObject.Name
            TypeName = $InputObject.LibraryType
            IconReferencePath = $InputObject.IconResourceId.ReferencePath
        }
    }
}

function Get-ShellLibrary
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [Alias('Key')]
        [string]
        $Name
    )
    process
    {
        if ( -not ( $Name | Test-ShellLibrary ) )
        {
            # the library doesn't exist
            return
        }

        # the library exists
        try
        {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($Name,$true)
            $r = Convert-ShellLibraryObject $l
            return $r
        }
        finally
        {
            if ( $null -ne $l )
            {
                $l.Dispose()
            }
        }
    }
}

function Add-ShellLibrary
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [Alias('Key')]
        $Name
    )
    process
    {
        try
        {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($Name,$false)
            $r = Convert-ShellLibraryObject $l
            return $r
        }
        catch [System.Runtime.InteropServices.COMException]
        {
            if ( $_.Exception -match 'already exists' )
            {
                throw [System.IO.IOException]::new(
                    "Shell library named $Name already exists.",
                    $_.Exception
                )
            }
            throw
        }
        finally
        {
            if ( $null -ne $l )
            {
                $l.Dispose()
            }
        }
    }
}

function Remove-ShellLibrary
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [Alias('Key')]
        [string]
        $Name
    )
    process
    {
        $path = $Name | Get-ShellLibraryPath
        try
        {
            Remove-Item $path -ea Stop | Out-Null
        }
        catch [System.Management.Automation.ItemNotFoundException]
        {
            throw [System.Management.Automation.ItemNotFoundException]::new(
                "Shell library named $Name not found.",
                $_.Exception
            )
        }
    }
}

function Get-ShellLibraryProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        [Alias('Key','Name')]
        $LibraryName,

        [Parameter(Mandatory = $true,
                   position = 1)]
        [ValidateSet('TypeName','IconReferencePath')]
        [string]
        $PropertyName
    )
    process
    {
        ( $LibraryName | Get-ShellLibrary ).$PropertyName
    }
}

function Set-ShellLibraryProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        [Alias('Key','Name')]
        $LibraryName,

        [Parameter(Mandatory = $true,
                   position = 1)]
        [ValidateSet('TypeName','IconReferencePath')]
        [string]
        $PropertyName,

        [Parameter(Mandatory = $true,
                   position = 2)]
        $Value
    )
    process
    {
        if ( -not ( $LibraryName | Test-ShellLibrary ) )
        {
            # the library doesn't exist
            throw [System.Management.Automation.ItemNotFoundException]::new(
                "library named $LibraryName not found"
            )
        }

        # the libary exists
        try
        {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($LibraryName,$false)
            switch ( $PropertyName )
            {
                'TypeName' { $l.LibraryType = $Value }
                'IconReferencePath' {
                    $l.IconResourceId = [Microsoft.WindowsAPICodePack.Shell.IconReference]::new($Value)
                }
            }
        }
        finally
        {
            if ( $null -ne $l )
            {
                $l.Dispose()
            }
        }
    }
}

function Test-ShellLibraryProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        [Alias('Key','Name')]
        $LibraryName,

        [Parameter(Mandatory = $true,
                   position = 1)]
        [ValidateSet('TypeName','IconReferencePath')]
        [string]
        $PropertyName,

        [Parameter(Mandatory = $true,
                   position = 2)]
        $Value
    )
    process
    {
        $Value -eq (Get-ShellLibraryProperty -LibraryName $LibraryName -PropertyName $PropertyName)
    }
}
