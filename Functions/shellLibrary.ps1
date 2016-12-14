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
        $l = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($Name,$false)
        $r = Convert-ShellLibraryObject $l
        $l.Dispose()
        return $r
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
        throw [System.NotImplementedException]::new('Remove-ShellLibrary')
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
        throw [System.NotImplementedException]::new('Set-ShellLibraryType')
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
        [string]
        $StockIconName
    )
    process
    {
        throw [System.NotImplementedException]::new('Set-ShellLibraryStockIcon')
    }
}
