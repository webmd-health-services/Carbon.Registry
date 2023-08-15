
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:rootKey = 'hkcu:\Test-CRegistryKeyValue'
}

Describe 'Test-CRegistryKeyValue' {
    BeforeEach {
        if( -not (Test-Path $script:rootKey -PathType Container) )
        {
            New-Item $script:rootKey -ItemType RegistryKey -Force
        }

        New-ItemProperty -Path $script:rootKey -Name 'Empty' -Value '' -PropertyType 'String'
        New-ItemProperty -Path $script:rootKey -Name 'Null' -Value $null -PropertyType 'String'
        New-ItemProperty -Path $script:rootKey -Name 'State' -Value 'Foobar''ed' -PropertyType 'String'
    }

    AfterEach {
        Remove-Item $script:rootKey -Recurse
    }

    It 'should detect value with empty value' {
        (Test-CRegistryKeyValue -Path $script:rootKey -Name 'Empty') | Should -BeTrue
    }

    It 'should detect value with null value' {
        (Test-CRegistryKeyValue -Path $script:rootKey -Name 'Null') | Should -BeTrue
    }

    It 'should detect value with a value' {
        (Test-CRegistryKeyValue -Path $script:rootKey -Name 'State') | Should -BeTrue
    }

    It 'should detect no value in missing key' {
        (Test-CRegistryKeyValue -Path (Join-Path $script:rootKey fjdsklfjsadf) -Name 'IDoNotExistEither') | Should -BeFalse
    }

    It 'should not detect missing value' {
        Set-StrictMode -Version Latest
        $error.Clear()
        (Test-CRegistryKeyValue -Path $script:rootKey -Name 'BlahBlahBlah' -ErrorAction SilentlyContinue) | Should -BeFalse
        $error.Count | Should -Be 0
    }

    It 'should handle key with no values' {
        Remove-ItemProperty -Path $script:rootKey -Name *
        $error.Clear()
        (Test-CRegistryKeyValue -Path $script:rootKey -Name 'Empty') | Should -BeFalse
        $error.Count | Should -Be 0
    }

}
