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
        New-Object ShellLibrary -Property @{
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

function Set-ShellLibraryType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $Name,

        [Parameter(position = 1)]
        [string]
        $TypeName
    )
    process
    {
        if ( -not ( $Name | Test-ShellLibrary ) )
        {
            # the library doesn't exist
            throw [System.Management.Automation.ItemNotFoundException]::new(
                "library named $Name not found"
            )
        }
        try
        {
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($Name,$false)
            $l.LibraryType = $TypeName
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

function Get-StockIconReferencePath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [Microsoft.WindowsAPICodePack.Shell.StockIconIdentifier]
        $StockIconName
    )
    process
    {
        return [StockIconInfo.StockIconInfo]::GetIconRefPath([int]$StockIconName)
    }
}

function Set-ShellLibraryStockIcon
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $Name,

        [Parameter(position = 1)]
        [Microsoft.WindowsAPICodePack.Shell.StockIconIdentifier]
        $StockIconName
    )
    process
    {
        # retrieve the reference path of the stock icon
        $referencePath = $StockIconName | Get-StockIconReferencePath

        # create the icon reference
        $i = [Microsoft.WindowsAPICodePack.Shell.IconReference]::new($referencePath)

        if ( -not ( $Name | Test-ShellLibrary ) )
        {
            # the library doesn't exist
            throw [System.Management.Automation.ItemNotFoundException]::new(
                "library named $Name not found"
            )
        }

        # the library exists
        try
        {
            # retrieve the library
            $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($Name,$false)

            # assign the icon
            $l.IconResourceId = $i
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
