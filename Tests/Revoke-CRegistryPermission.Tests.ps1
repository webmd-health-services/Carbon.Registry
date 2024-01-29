
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    $script:testKeyPath = ''
    $script:testNum = 0
    $script:user = 'CRegTestUser1'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Revoke-CRegistryPermission' {
    BeforeEach {
        $script:testKeyPath = Join-Path -Path 'TestRegistry:' -ChildPath $script:testNum
        Install-CRegistryKey -Path $script:testKeyPath
        Grant-CRegistryPermission -Path $script:testKeyPath -Identity $script:user -Permission FullControl
        $Global:Error.Clear()
    }

    AfterEach {
        $script:testNum += 1
    }

    It 'removes all permissions' {
        Grant-CRegistryPermission -Path $script:testKeyPath -Identity $script:user -Permission ReadKey
        $perm = Get-CRegistryPermission -Path $script:testKeyPath -Identity $script:user
        Mock -CommandName 'Get-CRegistryPermission' `
             -ModuleName 'Carbon.Registry' `
             -MockWith { $perm ; $perm }.GetNewClosure()
        Revoke-CRegistryPermission -Path $script:testKeyPath -Identity $script:user
        $Global:Error | Should -BeNullOrEmpty
        Carbon.Registry\Get-CRegistryPermission -Path $script:testKeyPath -Identity $script:user |
            Should -BeNullOrEmpty
    }

    It 'removes permission' {
        Revoke-CRegistryPermission -Path $script:testKeyPath -Identity $script:user
        $Global:Error | Should -BeNullOrEmpty
        (Test-CRegistryPermission -Path $script:testKeyPath -Identity $script:user -Permission FullControl) |
            Should -BeFalse
    }

    It 'ignores inherited permissions' {
        Get-CRegistryPermission -Path $script:testKeyPath -Inherited |
            Where-Object { $_.IdentityReference -notlike ('*{0}*' -f $script:user) } |
            ForEach-Object {
                $result = Revoke-CRegistryPermission -Path $script:testKeyPath -Identity $_.IdentityReference
                $Global:Error | Should -BeNullOrEmpty
                $result | Should -BeNullOrEmpty
                Test-CRegistryPermission -Identity $_.IdentityReference `
                                         -Path $script:testKeyPath `
                                         -Inherited `
                                         -Permission $_.RegistryRights |
                    Should -BeTrue
            }
    }

    It 'ignores revoking non existent permission' {
        Revoke-CRegistryPermission -Path $script:testKeyPath -Identity $script:user
        (Test-CRegistryPermission -Path $script:testKeyPath -Identity $script:user -Permission 'FullControl') |
            Should -BeFalse
        Revoke-CRegistryPermission -Path $script:testKeyPath -Identity $script:user
        $Global:Error | Should -BeNullOrEmpty
        (Test-CRegistryPermission -Path $script:testKeyPath -Identity $script:user -Permission 'FullControl') |
            Should -BeFalse
    }

    It 'resolve relative path' {
        Push-Location -Path (Split-Path -Parent -Path $script:testKeyPath)
        try
        {
            $path = Join-Path -Path '.' -ChildPath ($script:testKeyPath | Split-Path -Leaf)
            Revoke-CRegistryPermission -Path $path -Identity $script:user
            (Test-CRegistryPermission -Path $script:testKeyPath -Identity $script:user -Permission 'FullControl') |
                Should -BeFalse
        }
        finally
        {
            Pop-Location
        }
    }

    It 'supports WhatIf' {
        Revoke-CRegistryPermission -Path $script:testKeyPath -Identity $script:user -WhatIf
        (Test-CRegistryPermission -Path $script:testKeyPath -Identity $script:user -Permission 'FullControl') |
            Should -BeTrue
    }
}
