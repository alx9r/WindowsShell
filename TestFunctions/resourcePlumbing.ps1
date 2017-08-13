function Test-ResourceObject
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 1)]
        $ResourceName,

        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 2)]
        $ModuleName
    )
    Describe "resource object $ResourceName in module $ModuleName" {
        Context 'module and resource registration' {
            It "$ModuleName is a module available with Get-Module" {
                $r = Get-Module $ModuleName -ListAvailable
                $r | Should not beNullOrEmpty
            }
            It "$ModuleName successfully imports" {
                Import-Module $ModuleName
            }
            It "$ResourceName is a nested module of $ModuleName" {
                $r = (Get-Module $ModuleName).NestedModules |
                    ? { $_.Name -eq $ResourceName }
                $r | Should not beNullOrEmpty
                $r.Count | Should be 1
            }
            It "$ResourceName in $ModuleName is a DscResource available with Get-DscResource" {
                $r = Get-DscResource $ResourceName $ModuleName
                $r | Should not beNullOrEmpty
            }
        }
        $modulePath = (Get-Module $ModuleName).NestedModules |
                ? { $_.Name -eq $ResourceName } |
                select -First 1 |
                % Path
        $h = @{}
        Context 'object' {
            It "import $modulePath" {
                Import-Module $modulePath
            }
            It "module $ResourceName is a module availabe with Get-Module" {
                $r = Get-Module $ResourceName
                $r | Should not beNullOrEmpty
            }
            It "an object of type $ResourceName can be created inside $ResourceName module" {
                $h.o = & (Get-Module $ResourceName).NewBoundScriptBlock(
                    [scriptblock]::Create("New-Object $ResourceName")
                )
                $h.o | Should not beNullOrEmpty
            }
            It 'the object''s type has the DscResourceAttribute' {
                $r = $h.o.GetType().CustomAttributes |
                    ? { $_.AttributeType -eq ([System.Management.Automation.DscResourceAttribute]) }
                $r | Should not beNullOrEmpty
            }
        }
        Context 'member functions' {
            foreach ( $values in @(
                @('Get',"$ResourceName Get()"),
                @('Set',"void Set()"),
                @('Test',"bool Test()")
            ))
            {
                $methodName,$signature = $values
                It "the object has a .$methodName() method" {
                    $r = Get-Member -InputObject $h.o -MemberType Method -Name $methodName
                    $r | Should not beNullOrEmpty
                }
                It "the method signature is `"$signature`"" {
                    $r = Get-Member -InputObject $h.o -MemberType Method -Name $methodName |
                        % Definition
                    $r | Should be $signature
                }
            }
        }
        Context 'member variables' {
            It 'has member variables' {
                $r = $h.o.GetType().GetProperties()
                $r | Should not beNullOrEmpty
            }
            It 'has member variables with the DscProperty() attribute' {
                $r = $h.o.GetType().GetProperties() |
                    % CustomAttributes |
                    ? { $_.AttributeType -eq ([System.Management.Automation.DscPropertyAttribute]) }
                $r | Should not beNullOrEmpty
            }
            It 'has at least one DSC property that is a key' {
                $r = $h.o.GetType().GetProperties() |
                    % CustomAttributes |
                    ? { $_.AttributeType -eq ([System.Management.Automation.DscPropertyAttribute]) } |
                    % NamedArguments |
                    ? { $_.MemberName -eq 'Key' }
                $r | Should not beNullOrEmpty
            }
        }
        if ( Get-Member -InputObject $h.o -MemberType Property -Name 'Ensure' )
        {
            Context 'Ensure member variable' {
                It 'has a default value of "Present"' {
                    $h.o.Ensure | Should be 'Present'
                }
            }
        }
        Context 'cleanup' {
            # Removing module causing problems with mocking later.  Should test with removal again
            # once PowerShell GH-2505 is fixed.
            It "remove module $ResourceName" {
                #Remove-Module $ResourceName -ea Stop
            }
            It "module $ResourceName is no longer available with Get-Module" {
                #$r = Get-Module $ResourceName
                #$r | Should beNullOrEmpty
            }
        }
    }
}

function Test-ProcessFunction
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 1)]
        $ModuleName,

        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 2)]
        $FunctionName
    )

    Describe "function $FunctionName in module $ModuleName" {
        Context 'module and function registration' {
            It "$ModuleName is a module available with Get-Module" {
                $r = Get-Module $ModuleName -ListAvailable
                $r | Should not beNullOrEmpty
            }
            It "$ModuleName successfully imports" {
                Import-Module $ModuleName
            }
            It "$ModuleName exports function $FunctionName" {
                $r = (Get-Module $ModuleName).ExportedFunctions.$FunctionName
                $r | Should not beNullOrEmpty
            }
        }
        $function = (Get-Module $ModuleName).ExportedFunctions.$FunctionName
        foreach ( $values in @(
            @('Mode',   'design_requires', 'mandatory', $null,    1, @('Set','Test')),
            @('Ensure', $null,             $null,       'Present',2, @('Present','Absent'))
        ))
        {
            $name,$designRequires,$mandatory,$defaultValue,$position,$validValues = $values

            if ( $designRequires -or 
                 $function.Parameters.get_keys() -contains $name )
            {
            Context "$name parameter" {
                It "the function has a $name parameter" {
                    $r = $function.Parameters.$name
                    $r | Should not beNullOrEmpty
                }
                if ($mandatory) {
                    It 'is mandatory' {
                        $r = $function.Parameters.$name.Attributes | 
                            ? { $_.TypeId.Name -eq 'ParameterAttribute' } |
                            % Mandatory
                        $r | Should be $true
                    }
                }
                if ( $defaultValue )
                {
                    It "has default value $defaultValue" {
                        $r = $function.ScriptBlock.Ast.Body.ParamBlock.Parameters.
                            Where({$_.Name.VariablePath.UserPath -eq $name}).
                            DefaultValue.SafeGetValue()
                        $r | Should be $defaultValue
                    }
                }
                It "is a positional argument" {
                    $r = $function.Parameters.$name.Attributes | 
                        ? { $_.TypeId.Name -eq 'ParameterAttribute' } | 
                        % Position
                    $r | Should BeGreaterThan -1
                }
                It "takes position $position" {
                    $positions = $function.Parameters.Values | 
                        % Attributes | 
                        ? {$_.TypeId.Name -eq 'ParameterAttribute' } | 
                        % Position | 
                        ? { $_ -ge 0 } |
                        Sort
                    $expected = $positions[$position-1]

                    $actual = $function.Parameters.$name.Attributes | 
                        ? { $_.TypeId.Name -eq 'ParameterAttribute' } | 
                        % Position

                    $actual | Should be $expected
                }
                It 'has a ValidateSet attribute' {
                    $r = $function.Parameters.$name.Attributes | 
                        ? {$_.TypeId.Name -eq 'ValidateSetAttribute' }
                    $r | Should not beNullOrEmpty
                }
                It "valid values are $validValues" {
                    $r = $function.Parameters.$name.Attributes | 
                        ? {$_.TypeId.Name -eq 'ValidateSetAttribute' } |
                        % ValidValues
                    $r | Should be $validValues
                }
            }
            }
        }
        foreach ( $parameter in ($function.Parameters.Values | ? {$_.Name -notin (Get-CommonParameterNames)}) )
        {
            Context "All Parameters: $($parameter.Name)" {
                It 'does not bind to values from pipeline' {
                    $r = $parameter.Attributes | 
                        ? { $_.TypeId.Name -eq 'ParameterAttribute' }                    
                    $r.ValueFromPipeline | Should be $false
                }
                It 'binds to properties of objects in pipeline by property name' {
                    $r = $parameter.Attributes | 
                        ? { $_.TypeId.Name -eq 'ParameterAttribute' }                    
                    $r.ValueFromPipelineByPropertyName | Should be $true
                }
                It 'does not use a validation script' {
                    $r = $parameter.Attributes | 
                        ? {$_.TypeId.Name -eq 'ValidateScriptAttribute'} 
                    $r | Should beNullOrEmpty
                }
            }
        }
    }
}

function Test-ResourcePlumbing
{
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 1)]
        $ResourceName,

        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 2)]
        $ModuleName,

        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 3)]
        $FunctionName
    )
    # each of these operations should have already been tested outside this function
    Import-Module $ModuleName
    $modulePath = (Get-Module $ModuleName).NestedModules |
            ? { $_.Name -eq $ResourceName } |
            select -First 1 |
            % Path
    Import-Module $modulePath
    $object = & (Get-Module $ResourceName).NewBoundScriptBlock(
        [scriptblock]::Create("New-Object $ResourceName")
    )
    $function = (Get-Module $ModuleName).ExportedFunctions.$FunctionName

    Describe "resource object $ResourceName in module $ModuleName to function $FunctionName" {
        It 'the member variables names and parameter names match' {
            $memberNames = Get-Member -InputObject $object -MemberType Property |
                % Name |
                Sort
            $parameterNames = $function.Parameters.get_keys() |
                ? { $_ -notin (Get-CommonParameterNames) } |
                ? { $_ -ne 'Mode' } |
                Sort
            $memberNames | Should be $parameterNames
        }
        
        # compose the parameters
        $parameters = @{}
        foreach ( $variable in $object.GetType().GetProperties() )
        {
            # if it's an enum, use the zero value
            if ( $variable.PropertyType.BaseType -eq [System.Enum] )
            {
                $parameters.$($variable.Name) = 0
            }
            # if there is a default value, use it
            elseif ( $object.$($variable.Name)  )
            {
                $parameters.$($variable.Name) = $object.$($variable.Name)
            }
            else
            {
                switch ($variable.PropertyType )
                {
                    ([bool])     { $parameters.$($variable.Name) = $true }
                    ([string])   { $parameters.$($variable.Name) = $variable.Name.ToUpper() }
                    ([string[]]) { $parameters.$($variable.Name) = $variable.Name.ToUpper() }
                    ([int])      { 
                        $parameters.$($variable.Name) = $variable.GetHashCode() 
                    }
                    Default { 
                        throw "Unhandled Type $($variable.GetType())"
                    }
                }
            }
        }

        @{
            ResourceName = $ResourceName
            ModuleName = $ModuleName
            FunctionName = $FunctionName
            Parameters = $parameters
        } | 
            Export-CliXml TestDrive:/values.xml

        InModuleScope $ResourceName {
            $v = Import-Clixml TestDrive:/values.xml 
            foreach ( $values in @(
                @('Test',$true),
                @('Set',$null)
            ))
            {
                $mode,$retVal = $values
                $expectedMode = $mode
                Context "Invoke .$mode()" {
                    Mock $v.FunctionName { $retVal } -Verifiable
                    It 'passes return value' {
                        $o = New-Object $v.ResourceName -Property $v.Parameters

                        $r = $o.$Mode()

                        $r | Should be $retVal
                    }
                    It 'invokes command' {
                        $sb = [scriptblock]::Create(
                            (($v.Parameters.get_keys() | % { "`$$_ -eq '$($v.Parameters.$_)'" }) -join ' -and ')
                        )
                        Assert-MockCalled $v.FunctionName 1 $sb
                    }
                }
            }
        }
    }
    # Removing module causing problems with mocking later.  Should test with removal again
    # once PowerShell GH-2505 is fixed.
    #Remove-Module $ResourceName
}

function Get-CommonParameterNames
{
    [CmdletBinding()]
    param()
    $MyInvocation.MyCommand.Parameters.Keys
}