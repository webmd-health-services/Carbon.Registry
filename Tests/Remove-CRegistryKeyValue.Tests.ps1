
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:rootKey = 'hkcu:\Remove-CRegistryKeyValue'
    $script:valueName = 'RegValue'
}


Describe 'Remove-CRegistryKeyValue' {
    BeforeEach {
        if( -not (Test-Path $script:rootKey -PathType Container) )
        {
            New-Item $script:rootKey -ItemType RegistryKey -Force
        }
    }

    AfterEach {
        Remove-Item $script:rootKey -Recurse
    }

    It 'should remove existing registry value' {
        New-ItemProperty $script:rootKey -Name $script:valueName -Value 'it doesn''t matter' -PropertyType 'String'
        (Test-CRegistryKeyValue -Path $script:rootKey -Name $script:valueName) | Should -BeTrue
        Remove-CRegistryKeyValue -Path $script:rootKey -Name $script:valueName
        (Test-CRegistryKeyValue -Path $script:rootKey -Name $script:valueName) | Should -BeFalse
    }

    It 'should remove non existent registry value' {
        (Test-CRegistryKeyValue -Path $script:rootKey -Name 'I do not exist') | Should -BeFalse
        Remove-CRegistryKeyValue -Path $script:rootKey -Name 'I do not exist'
        (Test-CRegistryKeyValue -Path $script:rootKey -Name 'I do not exist') | Should -BeFalse
    }

    It 'should support what if' {
        New-ItemProperty $script:rootKey -Name $script:valueName -Value 'it doesn''t matter' -PropertyType 'String'
        (Test-CRegistryKeyValue -Path $script:rootKey -Name $script:valueName) | Should -BeTrue
        Remove-CRegistryKeyValue -Path $script:rootKey -Name $script:valueName -WhatIf
        (Test-CRegistryKeyValue -Path $script:rootKey -Name $script:valueName) | Should -BeTrue
    }
}
