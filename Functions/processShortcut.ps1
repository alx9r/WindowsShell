function Invoke-ProcessShortcut
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Set','Test')]
        $Mode,

        [Parameter(Position = 2,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Present','Absent')]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true,
                   Position = 3,
                   ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Target')]
        [string]
        $TargetPath,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $Arguments,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('StartIn','WorkingFolder')]
        [string]
        $WorkingDirectory,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Run')]
        [WindowStyle]
        $WindowStyle,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('ShortcutKey')]
        [string]
        $Hotkey,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $StockIconName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        $IconFilePath,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [int]
        $IconResourceId=0,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Comment')]
        [string]
        $Description
    )
    process
    {
        # pass through shortcut properties
        $properties = @{}
        'TargetPath','Arguments','WorkingDirectory',
        'WindowStyle','Hotkey','Description' |
            ? { $_ -in $PSCmdlet.MyInvocation.BoundParameters.Keys } |
            % { $properties.$_ = Get-Variable $_ -ValueOnly }


        # work out the icon
        $splat = @{
            StockIconName = $StockIconName
            IconFilePath = $IconFilePath
            IconResourceId = $IconResourceId
        }
        if ( $iconReferencePath = Get-IconReferencePath @splat )
        {
            $properties.IconLocation = $iconReferencePath
        }

        # process
        $splat = @{
            Mode = $Mode
            Ensure = $Ensure
            Keys = @{ Path = $Path }
            Properties = $properties
            Getter  = 'Get-ShortCut'
            Adder   = 'Add-ShortCut'
            Remover = 'Remove-ShortCut'
            PropertySetter = 'Set-ShortCutProperty'
            PropertyTest = 'Test-ShortCutProperty'
        }
        Invoke-ProcessPersistentItem @splat
    }
}
