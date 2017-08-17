function Invoke-ProcessShortcut
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1,
                   ValueFromPipelineByPropertyName = $true)]
        [System.Nullable[Mode]]
        $Mode,

        [Parameter(Position = 2,
                   ValueFromPipelineByPropertyName = $true)]
        [System.Nullable[Ensure]]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true,
                   Position = 3,
                   ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        $Path,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Target')]
        $TargetPath,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $Arguments,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('StartIn','WorkingFolder')]
        $WorkingDirectory,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Run')]
        [System.Nullable[WindowStyle]]
        $WindowStyle,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('ShortcutKey')]
        $Hotkey,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [System.Nullable[StockIconName]]
        $StockIconName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $IconFilePath,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [System.Nullable[int]]
        $IconResourceId,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Comment')]
        $Description
    )
    process
    {
        # pass through shortcut properties
        $properties = @{}
        'TargetPath','Arguments','WorkingDirectory',
        'WindowStyle','Hotkey','Description' |
            ? { Get-Variable $_ -ValueOnly } |
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
