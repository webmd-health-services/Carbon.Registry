
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:rootKey = 'hkcu:\Set-CRegistryKeyValue'
}

Describe 'Set-CRegistryKeyValue when the key doesn''t exist' {
    BeforeEach {
        if( -not (Test-Path $script:rootKey -PathType Container) )
        {
            New-Item $script:rootKey -ItemType RegistryKey -Force
        }
    }

    AfterEach {
        Remove-Item $script:rootKey -Recurse
    }

    It 'creates the registry key' {
        $keyPath = Join-Path $script:rootKey 'ShouldCreateNewKeyAndValue'
        $name = 'Title'
        $value = 'This is Sparta!'

        (Test-CRegistryKeyValue -Path $keyPath -Name $name) | Should -BeFalse
        Set-CRegistryKeyValue -Path $keyPath -Name $name -String $value
        (Test-CRegistryKeyValue -Path $keyPath -Name $name) | Should -BeTrue

        $actualValue = Get-CRegistryKeyValue -Path $keyPath -Name $name
        $actualValue | Should -Be $value
    }

    It 'changes existing key value' {
        $name = 'ShouldChangeAnExistingValue'
        $value = 'foobar''ed'

        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -String $value
        (Get-CRegistryKeyValue -Path $script:rootKey -Name $name) | Should -Be $value

        $newValue = 'Ok'
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -String $newValue
        (Get-CRegistryKeyValue -Path $script:rootKey -Name $name) | Should -Be $newValue
    }

    It 'should set binary value' {
        Set-CRegistryKeyValue -Path $script:rootKey -Name 'Binary' -Binary ([byte[]]@( 1, 2, 3, 4))
        $value = Get-CRegistryKeyValue -Path $script:rootKey -Name 'Binary'
        $value | Should -Not -BeNullOrEmpty
        $value.GetType() | Should -Be 'System.Object[]'
        $value[0] | Should -Be 1
        $value[1] | Should -Be 2
        $value[2] | Should -Be 3
        $value[3] | Should -Be 4
    }

    It 'should set dword value' {
        $number = [Int32]::MaxValue
        Set-CRegistryKeyValue -Path $script:rootKey -Name 'DWord' -DWord $number
        $value = Get-CRegistryKeyValue -Path $script:rootKey -Name 'DWord'
        $value | Should -Not -BeNullOrEmpty
        $value.GetType() | Should -Be 'int'
        $value | Should -Be $number
    }

    It 'should set qword value' {
        $number = [Int64]::MaxValue
        Set-CRegistryKeyValue -Path $script:rootKey -Name 'QWord' -QWord $number
        $value = Get-CRegistryKeyValue -Path $script:rootKey -Name 'QWord'
        $value | Should -Not -BeNullOrEmpty
        $value.GetType() | Should -Be 'long'
        $value | Should -Be $number
    }

    It 'should set multi string value' {
        $strings = @( 'Foo', 'Bar' )
        Set-CRegistryKeyValue -Path $script:rootKey -Name 'Strings' -Strings $strings
        $value = Get-CRegistryKeyValue -Path $script:rootKey -Name 'Strings'
        $value | Should -Not -BeNullOrEmpty
        $value.Length | Should -Be $strings.Length
        $value[0] | Should -Be $strings[0]
        $value[1] | Should -Be $strings[1]
    }

    It 'should set expanding string value' {
        Set-CRegistryKeyValue -Path $script:rootKey -Name 'Expandable' -String '%ComputerName%' -Expand
        $value = Get-CRegistryKeyValue -Path $script:rootKey -Name 'Expandable'
        $value | Should -Not -BeNullOrEmpty
        $value | Should -Be $env:ComputerName
    }

    It 'should set to unsigned int64' {
        $name = 'uint64maxvalue'
        $value = [uint64]::MaxValue
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -UQWord $value
        $setValue = Get-CRegistryKeyValue -Path $script:rootKey -Name $name
        $setValue | Should -Be $value
    }

    It 'should set to unsigned int32' {
        $name = 'uint32maxvalue'
        $value = [uint32]::MaxValue
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -UDWord $value
        $setValue = Get-CRegistryKeyValue -Path $script:rootKey -Name $name
        $setValue | Should -Be $value
    }

    It 'should set string value' {
        $name = 'string'
        $value = 'fubarsnafu'
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -String $value
        Test-CRegistryKeyValue -Path $script:rootKey -Name $name | Should -BeTrue
        Get-CRegistryKeyValue -Path $script:rootKey -Name $name | Should -Be $value
    }

    It 'should set string value to null string' {
        $name = 'string'
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -String $null
        Test-CRegistryKeyValue -Path $script:rootKey -Name $name | Should -BeTrue
        Get-CRegistryKeyValue -Path $script:rootKey -Name $name | Should -Be ''
    }

    It 'should set string value to empty string' {
        $name = 'string'
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -String ''
        Test-CRegistryKeyValue -Path $script:rootKey -Name $name | Should -BeTrue
        Get-CRegistryKeyValue -Path $script:rootKey -Name $name | Should -Be ''
    }

    It 'changes a value''s type' {
        $name = 'ShouldChangeAnExistingValue'
        $value = 'foobar''ed'
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -String $value
        (Get-CRegistryKeyValue -Path $script:rootKey -Name $name) | Should -Be $value

        $newValue = 8439
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -DWord $newValue -Force
        $newActualValue = Get-CRegistryKeyValue -Path $script:rootKey -Name $name
        $newActualValue | Should -Be $newValue
        $newActualValue.GetType() | Should -Be 'int'
    }

    It 'allows Force even if not necessary' {
        $name = 'NewWithForce'
        $value = 8439
        (Test-CRegistryKeyValue -Path $script:rootKey -Name $name) | Should -BeFalse
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -DWord $value -Force
        $actualValue = Get-CRegistryKeyValue -Path $script:rootKey -Name $name
        $actualValue | Should -Be $value
        $actualValue.GetType() | Should -Be 'int'
    }

    It 'supports should process' {
        $name = 'newwithwhatif'
        $value = 'value'
        (Test-CRegistryKeyValue -Path $script:rootKey -Name $name) | Should -BeFalse
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -String $value -WhatIf
        (Test-CRegistryKeyValue -Path $script:rootKey -Name $name) | Should -BeFalse

        $newValue = 'newvalue'
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -String $value
        (Test-CRegistryKeyValue -Path $script:rootKey -Name $name) | Should -BeTrue

        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -String $newValue -WhatIf
        (Test-CRegistryKeyValue -Path $script:rootKey -Name $name) | Should -BeTrue
        (Get-CRegistryKeyValue -Path $script:rootKey -Name $name) | Should -Be $value

        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -String $newValue -WhatIf -Force
        (Test-CRegistryKeyValue -Path $script:rootKey -Name $name) | Should -BeTrue
        (Get-CRegistryKeyValue -Path $script:rootKey -Name $name) | Should -Be $value
    }

    $int32Values = @([int32]::MaxValue, 0, -1, [int32]::MinValue, [uint32]::MaxValue, [uint32]::MinValue)
    It ('sets int32 value <_> as a uint32') -ForEach $int32Values {
        $name = 'maxvalue'
        $value = $_
        Write-Debug -Message ('T {0} -is {1}' -f $value,$value.GetType())
        $bytes = [BitConverter]::GetBytes( $value )
        $int32 = [BitConverter]::ToInt32( $bytes, 0 )
        Write-Debug -Message ('T {0} -is {1}' -f $value,$value.GetType())
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -DWord $int32
        $setValue = Get-CRegistryKeyValue -Path $script:rootKey -Name $name
        Write-Debug -Message ('T {0} -is {1}' -f $setValue,$setValue.GetType())
        Write-Debug -Message '-----'
        $uint32 = [BitConverter]::ToUInt32( $bytes, 0 )
        $setValue | Should -Be $uint32
    }

    It 'clears multiline string' {
        $name = 'canclearmultilinestring'
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('one', 'two', 'three')
        Get-CRegistryKeyValue -Path $script:rootKey -Name $name | Should -Be @('one', 'two', 'three')
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @()
        Get-CRegistryKeyValue -Path $script:rootKey -Name $name | Should -Be @()
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('one', 'two', 'three')
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings $null
        Get-CRegistryKeyValue -Path $script:rootKey -Name $name | Should -Be @()
    }

    It 'does not save when multiline string value does not change' {
        $name = 'canclearmultilinestring'
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('one', 'two', 'three')
        Get-CRegistryKeyValue -Path $script:rootKey -Name $name | Should -Be @('one', 'two', 'three')
        Mock -CommandName 'Set-ItemProperty' -ModuleName 'Carbon.Registry'
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('one', 'two', 'three')
        Should -Not -Invoke 'Set-ItemProperty' -ModuleName 'Carbon.Registry'
    }

    It 'writes correct information messages when updating multiline string' {
        $name = 'changemultilinestring'
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('a', 'b', 'c')
        Write-Information "Changing values at index 0 and 2"
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('c', 'b', 'a')
        Write-Information "Removing value at index 2"
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('c', 'b')
        Write-Information "Adding value at index 2"
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('c', 'b', 'a')
        Write-Information "Changing item at index 1, removing item at index 2."
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('c', 'a')
        Write-Information "Changing item at index 1, adding item at index 2"
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('c', 'b', 'a')
        Write-Information "Changing item at index 0 and 1, removing item at index 2."
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('b', 'a')
        Write-Information "changing item at index 0, removing item at index 1"
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('c')
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('c', 'b')
        Set-CRegistryKeyValue -Path $script:rootKey -Name $name -Strings @('c', 'b', 'a', 'd')
    }
}
