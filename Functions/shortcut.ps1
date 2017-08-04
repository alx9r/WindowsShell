function Test-ValidShortcutObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        $InputObject
    )
    process
    {
        $memberNames = $InputObject |
            Get-Member |
            % Name

        foreach ( $expectedMemberName in @(
                'Load','Save','Arguments','Description','FullName','Hotkey',
                'IconLocation','RelativePath','TargetPath','WindowStyle',
                'WorkingDirectory'
            )
        )
        {
            if ( $expectedMemberName -notin $memberNames )
            {
                return $false
            }
        }

        return $true
    }
}

function Get-Shortcut
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        $Path
    )
    process
    {
        if ( -not ($Path | Test-Shortcut) )
        {
            return
        }

        (New-Object -ComObject WScript.Shell).
            CreateShortcut($Path)
    }
}

function Test-Shortcut
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        $Path
    )
    process
    {
        Test-Path $Path -PathType Leaf
    }
}

function Add-Shortcut
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        $Path
    )
    process
    {
        if ( $Path | Test-Shortcut )
        {
            throw [System.IO.IOException]::new(
                "Shortcut at $Path already exists."
            )
        }

        $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($Path)
        $shortcut.Save()
        return $shortcut
    }
}

function Remove-Shortcut
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true)]
        [Alias('Key')]
        $Path
    )
    process
    {
        try
        {
            Remove-Item $Path -ea Stop | Out-Null
        }
        catch [System.Management.Automation.ItemNotFoundException]
        {
            throw [System.Management.Automation.ItemNotFoundException]::new(
                "Shortcut not found at $Path",
                $_.Exception
            )
        }
    }
}

function Get-ShortcutProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true,
                   position = 1)]
        [string]
        $PropertyName
    )
    process
    {
        if ( -not ( $Path | Test-Shortcut ) )
        {
            # the shortcut doesn't exist
            throw [System.Management.Automation.ItemNotFoundException]::new(
                "Shortcut not found at $path"
            )
        }

        # the shortcut exists

        # get the property and return it
        $shortcut = $Path | Get-Shortcut
        $shortcut.$PropertyName
    }
}

function Set-ShortcutProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true,
                   position = 1)]
        [string]
        $PropertyName,

        [Parameter(Mandatory = $true,
                   position = 2)]
        $Value
    )
    process
    {
        if ( -not ( $Path | Test-Shortcut ) )
        {
            # the shortcut doesn't exist
            throw [System.Management.Automation.ItemNotFoundException]::new(
                "Shortcut not found at $path"
            )
        }

        # the shortcut exists

        # change the property and save it
        $shortcut = $Path | Get-Shortcut
        $shortcut.$PropertyName = $Value
        $shortcut.Save()
    }
}

function Get-NormalizedShortcutProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [string]
        $PropertyName,

        [Parameter(Mandatory = $true,
                   Position = 2,
                   ValueFromPipeline = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        $Value
    )
    process
    {
        # create the object we'll use to perform the normalization
        $shortcut = (New-Object -ComObject WScript.Shell).
            CreateShortcut("$([guid]::NewGuid().Guid).lnk")

        # set the property
        $shortcut.$PropertyName = $Value

        # return the normalized property
        return $shortcut.$PropertyName
    }
}

function Test-ShortcutProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true,
                   position = 1)]
        [string]
        $PropertyName,

        [Parameter(Mandatory = $true,
                   position = 2)]
        $Value
    )
    process
    {
        $actualValue = Get-ShortcutProperty -Path $Path -PropertyName $PropertyName
        $normalizedValue = Get-NormalizedShortcutProperty -PropertyName $PropertyName -Value $Value
        return $actualValue -eq $normalizedValue
    }
}
