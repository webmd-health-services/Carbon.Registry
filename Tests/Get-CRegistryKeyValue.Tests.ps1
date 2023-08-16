
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:rootKey = 'hkcu:\Get-CRegistryValue'
}

Describe 'Get-CRegistryKeyValue' {
    BeforeEach {
        if( -not (Test-Path $script:rootKey -PathType Container) )
        {
            New-Item $script:rootKey -ItemType RegistryKey -Force
        }

        New-ItemProperty -Path $script:rootKey -Name 'String' -Value 'Foobar''ed' -PropertyType 'String'
        New-ItemProperty -Path $script:rootKey -Name 'Binary' -Value ([byte[]]@(1, 2, 3)) -PropertyType 'Binary'
        New-ItemProperty -Path $script:rootKey -Name 'DWord' -Value 1 -PropertyType 'DWord'
        New-ItemProperty -Path $script:rootKey -Name 'QWord' -Value ([Int32]::MaxValue + 1) -PropertyType 'QWord'
        New-ItemProperty -Path $script:rootKey -Name 'ExpandString' -Value '%ComputerName%' -PropertyType 'ExpandString'
        New-ItemProperty -Path $script:rootKey -Name 'MultiString' -Value @('one', 'two', 'three') -PropertyType 'MultiString'
    }

    AfterEach {
        Remove-Item $script:rootKey -Recurse
    }

    It 'should get string value' {
        $value = Get-CRegistryKeyValue -Path $script:rootKey -Name 'String'
        $value | Should -Not -BeNullOrEmpty
        $value.GetType() | Should -Be 'string'
    }

    It 'should get expand string value' {
        $value = Get-CRegistryKeyValue -Path $script:rootKey -Name 'ExpandString'
        $value | Should -Not -BeNullOrEmpty
        $value.GetType() | Should -Be 'string'
        $value | Should -Be $env:ComputerName
    }


    It 'should get multi value' {
        $value = Get-CRegistryKeyValue -Path $script:rootKey -Name 'MultiString'
        $value | Should -Not -BeNullOrEmpty
        $value.GetType() | Should -Be 'System.Object[]'
        $value[0] | Should -Be 'one'
        $value[1] | Should -Be 'two'
        $value[2] | Should -Be 'three'
    }


    It 'should get d word value' {
        $value = Get-CRegistryKeyValue -Path $script:rootKey -Name 'DWord'
        $value | Should -Not -BeNullOrEmpty
        $value.GetType() | Should -Be 'int'
    }

    It 'should get q word value' {
        $value = Get-CRegistryKeyValue -Path $script:rootKey -Name 'QWord'
        $value | Should -Not -BeNullOrEmpty
        $value.GetType() | Should -Be 'long'
    }

    It 'should get binary value' {
        $value = Get-CRegistryKeyValue -Path $script:rootKey -Name 'Binary'
        $value | Should -Not -BeNullOrEmpty
        $value.GetType() | Should -Be 'System.Object[]'
        $value[0] | Should -Be 1
        $value[1] | Should -Be 2
        $value[2] | Should -Be 3
    }

    It 'should get missing value' {
        $value = Get-CRegistryKeyValue $script:rootKey -Name 'fdjskfldsjfklsdjflks'
        $value | Should -BeNullOrEmpty
    }

    It 'should get value in missing key' {
        $value = Get-CRegistryKeyValue (Join-Path $script:rootKey 'fjsdkflsjd') -Name 'fdjskfldsjfklsdjflks'
        $value | Should -BeNullOrEmpty
    }

}
