
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:rootKey = 'hkcu:\Install-CRegistryKey'
}

Describe 'Install-CRegistryKey' {
    BeforeEach {
        if( -not (Test-Path $script:rootKey -PathType Container) )
        {
            New-Item $script:rootKey -ItemType RegistryKey -Force
        }

    }

    AfterEach {
        Remove-Item $script:rootKey -Recurse
    }

    It 'should create key' {
        $keyPath = Join-Path $script:rootKey 'Test-InstallRegistryKey\ShouldCreateKey'
        if( Test-Path $keyPath -PathType Container )
        {
            Remove-Item $keyPath -Recurse
        }

        Install-CRegistryKey -Path $keyPath

        (Test-Path $keyPath -PathType Container) | Should -BeTrue
    }

    It 'should do nothing if key exists' {
        $keyPath = Join-Path $script:rootKey 'Test-InstallRegistryKey\ShouldDoNothingIfKeyExists'
        Install-CRegistryKey -Path $keyPath
        $subKeyPath = Join-Path $keyPath 'SubKey'
        Install-CRegistryKey $subKeyPath
        Install-CRegistryKey -Path $keyPath
        (Test-Path $subKeyPath -PathType Container) | Should -BeTrue
    }

    It 'should support should process' {
        $keyPath = Join-Path $script:rootKey 'Test-InstallRegistryKey\WhatIf'
        Install-CRegistryKey -Path $keyPath -WhatIf
        (Test-Path -Path $keyPath -PathType Container) | Should -BeFalse
    }
}
