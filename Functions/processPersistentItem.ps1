function Invoke-ProcessPersistentItem
{
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
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
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [hashtable]
        $Keys,

        [Parameter(Mandatory = $true)]
        [string]
        $Getter,

        [Parameter(Mandatory = $true)]
        [string]
        $Adder,

        [Parameter(Mandatory = $true)]
        [string]
        $Remover,

        [Parameter(ParameterSetName = 'with_properties',
                   Mandatory = $true)]
        [hashtable]
        $Properties,

        [Parameter(ParameterSetName = 'with_properties',
                   Mandatory = $true)]
        [string]
        $PropertyGetter,

        [Parameter(ParameterSetName = 'with_properties',
                   Mandatory = $true)]
        [string]
        $PropertySetter,

        [Parameter(ParameterSetName = 'with_properties',
                   Mandatory = $true)]
        [string]
        $PropertyNormalizer
    )
    process
    {
        # retrieve the item
        $item = & $Getter @Keys

        # process item existence
        switch ( $Ensure )
        {
            'Present' {
                if ( -not $item )
                {
                    # add the item
                    switch ( $Mode )
                    {
                        'Set'  { $item = & $Adder @Keys } # create the item
                        'Test' { return $false }              # the item doesn't exist
                    }
                }
            }
            'Absent' {
                switch ( $Mode )
                {
                    'Set'  {
                        if ( $item )
                        {
                            & $Remover @Keys | Out-Null
                        }
                        return
                    }
                    'Test' { return -not $item }
                }
            }
        }

        if ( $PSCmdlet.ParameterSetName -ne 'with_properties' )
        {
            # we are not processing properties
            if ( $Mode -eq 'Test' )
            {
                return $true
            }
            return
        }

        # process the item's properties
        $splat = @{
            Mode = $Mode
            Keys = $Keys
            Properties = $Properties
            PropertyGetter = $PropertyGetter
            PropertySetter = $PropertySetter
            PropertyNormalizer = $PropertyNormalizer
        }
        Invoke-ProcessPersistentItemProperty @splat
    }
}

function Invoke-ProcessPersistentItemProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
                   Position = 1)]
        [ValidateSet('Set','Test')]
        $Mode,

        [Parameter(Mandatory = $true)]
        [hashtable]
        $Keys,

        [hashtable]
        $Properties,

        [Parameter(Mandatory = $true)]
        [string]
        $PropertyGetter,

        [Parameter(Mandatory = $true)]
        [string]
        $PropertySetter,

        [Parameter(Mandatory = $true)]
        [string]
        $PropertyNormalizer
    )
    process
    {
        # process each property
        foreach ( $propertyName in $Properties.Keys )
        {
            # this is the desired value provided by the user
            $desired = $Properties.$propertyName

            # normalize the desired value
            $normalized = & $PropertyNormalizer -PropertyName $propertyName -Value $desired

            # get the existing value
            $existing = & $PropertyGetter @Keys -PropertyName $propertyName

            if ( $existing -ne $normalized )
            {
                if ( $Mode -eq 'Test' )
                {
                    # we're testing and we've found a property mismatch
                    return $false
                }

                # the existing property does not match the desired property
                # so fix it
                & $PropertySetter @Keys -PropertyName $propertyName -Value $desired |
                    Out-Null
            }
        }

        if ( $Mode -eq 'Test' )
        {
            return $true
        }
    }
}
