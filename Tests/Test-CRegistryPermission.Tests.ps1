
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:identity = 'CRegTestUser2'
    $script:keyPath = $null
    $script:childKeyPath = $null
    $script:testNum = 0
}


Describe 'Test-CRegistryPermission' {
    BeforeEach {
        $script:keyPath = Join-Path -Path 'TestRegistry:' -ChildPath ($script:testNum++)
        Install-CRegistryKey -Path $script:keyPath

        Grant-CRegistryPermission -Identity $script:identity `
                                  -Permission 'ReadKey','WriteKey' `
                                  -Path $script:keyPath `
                                  -ApplyTo SubkeysOnly

        $script:testKeyArgs = @{
            Path = $script:keyPath;
            Identity = $script:identity;
        }

        $script:childKeyPath = Join-Path -Path $script:keyPath -ChildPath 'ChildKey'
        Install-CRegistryKey -Path $script:childKeyPath

        $script:testSubkeyArgs = @{
            Path = $script:childKeyPath;
            Identity = $script:identity;
        }
        $Global:Error.Clear()
    }

    It 'should handle non existent path' {
        Test-CRegistryPermission -Path 'hkcu:\I\Do\Not\Exist' `
                                 -Identity $script:identity `
                                 -Permission FullControl `
                                 -ErrorAction SilentlyContinue |
            Should -BeNullOrEmpty
        $Global:Error | Should -HaveCount 1
        $Global:Error | Should -Match 'path does not exist'
    }

    It 'checks ungranted permission' {
        Test-CRegistryPermission @testKeyArgs -Permission FullControl | Should -BeFalse
    }

    It 'checks granted permission' {
        Test-CRegistryPermission @testKeyArgs -Permission ReadKey | Should -BeTrue
    }

    It 'checks exact partial permission' {
        Test-CRegistryPermission @testKeyArgs -Permission ReadKey -Strict | Should -BeFalse
    }

    It 'checks exact permission' {
        Test-CRegistryPermission @testKeyArgs -Permission ReadKey,WriteKey -Strict | Should -BeTrue
    }

    It 'excludes inherited permission' {
        Test-CRegistryPermission @testSubkeyArgs -Permission ReadKey | Should -BeFalse
    }

    It 'includes inherited permission' {
        Test-CRegistryPermission @testSubkeyArgs -Permission ReadKey -Inherited | Should -BeTrue
    }

    It 'excludes inherited partial permission' {
        Test-CRegistryPermission @testSubkeyArgs -Permission ReadKey -Strict | Should -BeFalse
    }

    It 'includes inherited exact permission' {
        Test-CRegistryPermission @testSubkeyArgs -Permission ReadKey,WriteKey -Inherited -Strict | Should -BeTrue
    }

    It 'checks ungranted inheritance flags' {
        Test-CRegistryPermission @testKeyArgs -Permission ReadKey -ApplyTo KeyAndSubkeys |
            Should -BeFalse
        Test-CRegistryPermission @testKeyArgs -Permission ReadKey -ApplyTo SubkeysOnly -OnlyApplyToChildKeys |
            Should -BeFalse
    }

    It 'checks granted inheritance flags' {
        Test-CRegistryPermission @testKeyArgs -Permission ReadKey -ApplyTo SubkeysOnly | Should -BeTrue
    }

    It 'checks exact ungranted inheritance flags' {
        Test-CRegistryPermission @testKeyArgs -Permission ReadKey,WriteKey -ApplyTo KeyAndSubkeys -Strict |
            Should -BeFalse
    }

    It 'checks exact granted inheritance flags' {
        Test-CRegistryPermission @testKeyArgs -Permission ReadKey,WriteKey -ApplyTo SubkeysOnly -Strict | Should -BeTrue
    }
}
