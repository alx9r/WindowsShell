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
            foreach ( $propertyName in $h.o | Get-Member -MemberType Property | % Name )
            {
                if ( $propertyName -eq 'Ensure' )
                {
                    It 'Ensure : has default value of "Present"' {
                        $h.o.Ensure | Should be 'Present'
                    }
                }
                else
                {
                    It "$propertyName : default value is null" {
                        $null -eq $h.o.$propertyName | Should be $true
                    }
                }
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
            @('Mode',   'design_requires', 'mandatory', $null,    1, 'System.Nullable[Mode]'),
            @('Ensure', $null,             $null,       'Present',2, 'System.Nullable[Ensure]')
        ))
        {
            $name,$designRequires,$mandatory,$defaultValue,$position,$typeName = $values

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
                else
                {
                    It 'does not have a default value' {
                        $r = $function.ScriptBlock.Ast.Body.ParamBlock.Parameters.
                            Where({$_.Name.VariablePath.UserPath -eq $name}).
                            DefaultValue
                        $r | Should beNullOrEmpty
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
                It "is of type $typeName" {
                    $r = $function.Parameters.$name.ParameterType
                    $r | Should be $typeName
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
                
                $parameter_ = $function.ScriptBlock.Ast.Body.ParamBlock.Parameters.
                        Where({$_.Name.VariablePath.UserPath -eq $($parameter.name)})

                if ( $parameter_.StaticType.IsValueType )
                {
                    It 'is a Nullable value type' {
                        $r = $parameter_.StaticType.Name
                        $r | Should be 'Nullable`1'
                    }
                }
                elseif ( $function.Parameters.$($parameter.Name).Attributes | 
                            ? { $_.TypeId.Name -eq 'ParameterAttribute' } |
                            % Mandatory )
                {
                    It 'has a static type' {
                        $parameter_.StaticType |
                            Should not beNullOrEmpty
                    }
                }
                else
                {
                    It 'does not declare a type' {
                        $parameter_.StaticType |
                            Should be 'System.Object'
                    }
                    It 'omit [AllowNull()]' {
                        $r = $parameter.Attributes | 
                            ? {$_.TypeId -match 'AllowNull' }
                        $r | Should beNullOrEmpty
                    }
                    It 'does not use a validation script' {
                        $r = $parameter.Attributes | 
                            ? {$_.TypeId.Name -eq 'ValidateScriptAttribute'} 
                        $r | Should beNullOrEmpty
                    }
                }

            }
        }
        foreach ( $parameter in (
            $function.Parameters.Values | 
                ? {$_.Name -notin (Get-CommonParameterNames)} |
                ? {$_.Name -notin 'Mode','Ensure'}
            )
        )
        {
            Context "Resource Parameters: $($parameter.Name)" {
                It 'has no default value' {
                    $r = $function.ScriptBlock.Ast.Body.ParamBlock.Parameters.
                        Where({$_.Name.VariablePath.UserPath -eq $($parameter.name)}).
                        DefaultValue
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
        It 'the member variable and parameter names match' {
            $memberNames = Get-Member -InputObject $object -MemberType Property |
                % Name |
                Sort
            $parameterNames = $function.Parameters.get_keys() |
                ? { $_ -notin (Get-CommonParameterNames) } |
                ? { $_ -ne 'Mode' } |
                Sort
            $memberNames | Should be $parameterNames
        }
        Context 'the parameter/member correlation' {
            $members = $object.GetType().GetMembers() |
                ? {$_.MemberType -eq 'Property' }
            foreach ( $member in $members )
            {
                $name = $member.Name

                $parameter = $function.Parameters.$name
                $parameter_ = $function.ScriptBlock.Ast.Body.ParamBlock.Parameters.
                        Where({$_.Name.VariablePath.UserPath -eq $name})

                if ( $parameter_.StaticType.IsValueType )
                {
                    It "$name : the parameter type matches the member type" {
                        $memberType = $member.PropertyType
                        $parameterType = $parameter.ParameterType
                    
                        $parameterType | Should be $memberType
                    }
                }
                It "$name : the parameter mandatoriness matches the member mandatoriness" {
                    $parameterMandatory = [bool]($function.Parameters.$name.Attributes | 
                        ? { $_.TypeId.Name -eq 'ParameterAttribute' } |
                        % Mandatory)
                    $memberMandatory = [bool]($object.GetType().DeclaredMembers | 
                        ? {$_.Name -eq $name } | 
                        % CustomAttributes | 
                        ? {$_.AttributeType -match 'DscProperty' } | 
                        % NamedArguments | 
                        ? {$_.MemberName -eq 'Mandatory' } | 
                        % TypedValue | 
                        % Value)
                    $parameterMandatory | Should be $memberMandatory
                }
            }
        }
        
        # compose the parameters
        $parameters = @{}
        foreach ( $variable in $object.GetType().GetProperties() )
        {
            # if it's an enum, use the first value
            if ( $variable.PropertyType.BaseType -eq [System.Enum] )
            {
                $parameters.$($variable.Name) = [System.Enum]::GetValues($variable.PropertyType)[0]
            }
            # if it's a nullable enum, use the first value
            elseif ( $variable.PropertyType.Name -eq 'Nullable`1' -and
                     $variable.PropertyType.GenericTypeArguments.BaseType -eq [System.Enum] )
            {
                $parameters.$($variable.Name) = [System.Enum]::GetValues($variable.PropertyType.GenericTypeArguments[0])[0]
            }
            # if it's a nullable int, use 0
            elseif ( $variable.PropertyType.Name -eq 'Nullable`1' -and
                 $variable.PropertyType.BaseType -eq [System.ValueType] )
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