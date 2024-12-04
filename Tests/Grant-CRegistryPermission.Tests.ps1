
using namespace System.Security.AccessControl

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\PSModules\Carbon.Accounts' -Resolve) `
                  -Function @('Resolve-CPrincipalName') `
                  -Verbose:$false

    $script:testKeyPath = $null
    $script:testNum = 0

    $script:user = 'CRegTestUser1'
    $script:user2 = 'CRegTestUser2'
    $script:keyPath = $null

    function Assert-InheritanceFlags
    {
        param(
            [string]
            $ContainerInheritanceFlags,

            [Security.AccessControl.InheritanceFlags]
            $InheritanceFlags,

            [Security.AccessControl.PropagationFlags]
            $PropagationFlags
        )

        $ace = Get-CRegistryPermission $script:testKeyPath -Identity $script:user

        $ace | Should -Not -BeNullOrEmpty
        $expectedRights = [Security.AccessControl.FileSystemRights]::Read -bor [Security.AccessControl.FileSystemRights]::Synchronize
        $ace.FileSystemRights | Should -Be $expectedRights
        $ace.InheritanceFlags | Should -Be $InheritanceFlags
        $ace.PropagationFlags | Should -Be $PropagationFlags
    }

    function Assert-Permissions
    {
        param(
            $Identity,
            [RegistryRights] $Permission,
            $Path,
            [AccessControlType] $Type = 'Allow',
            [InheritanceFlags] $InheritanceFlag,
            [PropagationFlags] $PropagationFlag
        )


        $ace = Get-CRegistryPermission -Path $Path -Identity $Identity
        $ace | Should -Not -BeNullOrEmpty

        if ($InheritanceFlag)
        {
            $ace.InheritanceFlags | Should -Be $InheritanceFlag
        }

        if ($PropagationFlag)
        {
            $ace.PropagationFlags | Should -Be $PropagationFlag
        }

        ($ace.RegistryRights -band $Permission) | Should -Be $Permission
        $ace.AccessControlType | Should -Be ([AccessControlType]$Type)
    }

    function Invoke-GrantPermissions
    {
        param(
            $Identity,
            $Permissions,
            $Path,
            $ApplyTo,
            [switch] $OnlyApplyToChildKeys,
            [switch] $Clear,
            $ExpectedPermission,
            $Type,
            [InheritanceFlags] $InheritanceFlag,
            [PropagationFlags] $PropagationFlag
        )

        $optionalParams = @{ }
        $assertOptionalParams = @{ }
        if( $ApplyTo )
        {
            $optionalParams['ApplyTo'] = $ApplyTo
        }

        if( $OnlyApplyToChildKeys )
        {
            $optionalParams['OnlyApplyToChildKeys'] = $OnlyApplyToChildKeys
        }

        if( $Clear )
        {
            $optionalParams['Clear'] = $Clear
        }

        if ($InheritanceFlag)
        {
            $assertOptionalParams['InheritanceFlag'] = $InheritanceFlag
        }

        if ($PropagationFlag)
        {
            $assertOptionalParams['PropagationFlag'] = $PropagationFlag
        }

        if( $Type )
        {
            $optionalParams['Type'] = $Type
            $assertOptionalParams['Type'] = $Type
        }

        $expectedRuleType = 'Security.AccessControl.RegistryAccessRule' -as [Type]
        $result = Grant-CRegistryPermission -Identity $Identity `
                                            -Permission $Permissions `
                                            -Path $Path `
                                            -PassThru `
                                            @optionalParams
        $result = $result | Select-Object -Last 1
        $result | Should -Not -BeNullOrEmpty
        $result.IdentityReference | Should -Be (Resolve-CPrincipalName $Identity)
        $result | Should -BeOfType $expectedRuleType
        if( -not $ExpectedPermission )
        {
            $ExpectedPermission = $Permissions
        }

        Assert-Permissions -Identity $Identity `
                           -Permission $ExpectedPermission `
                           -Path $Path `
                           @assertOptionalParams
    }
}

Describe 'Grant-CRegistryPermission' {
    BeforeEach {
        $script:testKeyPath = Join-Path -Path 'TestRegistry:' -ChildPath $script:testNum
        Install-CRegistryKey -Path $script:testKeyPath
        $Global:Error.Clear()
    }

    AfterEach {
        $script:testNum += 1
    }

    It 'sets permission' {
        $Permission = 'ReadKey','WriteKey'

        Invoke-GrantPermissions -Identity $script:user -Permissions $Permission -Path $script:testKeyPath
    }

    It 'clears existing permission' {
        Invoke-GrantPermissions $script:user 'FullControl' -Path $script:testKeyPath
        Invoke-GrantPermissions $script:user2 'FullControl' -Path $script:testKeyPath

        $result = Grant-CRegistryPermission -Identity 'Everyone' `
                                            -Permission 'ReadKey','WriteKey' `
                                            -Path $script:testKeyPath `
                                            -Clear `
                                            -PassThru
        $result | Should -Not -BeNullOrEmpty
        $result.Path | Should -Be $script:testKeyPath

        $acl = Get-Acl -Path $script:testKeyPath

        $rules = $acl.Access | Where-Object { -not $_.IsInherited }
        $rules | Should -Not -BeNullOrEmpty
        $rules.IdentityReference.Value | Should -Be 'Everyone'
    }

    It 'handles clearing no existing permissions' {
        $result = Grant-CRegistryPermission -Identity 'Everyone' `
                                            -Permission 'ReadKey','WriteKey' `
                                            -Path $script:testKeyPath `
                                            -Clear `
                                            -PassThru
        $result | Should -Not -BeNullOrEmpty
        $result.IdentityReference | Should -Be 'Everyone'

        $Global:Error.Count | Should -Be 0

        $acl = Get-Acl -Path $script:testKeyPath
        $rules = $acl.Access | Where-Object { -not $_.IsInherited }
        $rules | Should -Not -BeNullOrEmpty
        ($rules.IdentityReference.Value -like 'Everyone') | Should -BeTrue
    }

    # Applied manually in the Windows Explorer UI to determine corresponding inheritance and propagation flags.
    $testCases = @(
        @{
            ApplyTo = 'KeyOnly';
            InheritanceFlags = 'None';
            PropagationFlags = 'None';
        },
        @{
            ApplyTo = 'KeyAndSubkeys';
            InheritanceFlags = 'ContainerInherit';
            PropagationFlags = 'None';
        },
        @{
            ApplyTo = 'SubkeysOnly';
            InheritanceFlags = 'ContainerInherit';
            PropagationFlags = 'InheritOnly';
        }
    )


    It 'applies to <ApplyTo>' -TestCases $testCases {
        Invoke-GrantPermissions -Identity $script:user `
                                -Path $script:testKeyPath `
                                -Permission ReadKey `
                                -ApplyTo $ApplyTo `
                                -InheritanceFlag $InheritanceFlags `
                                -PropagationFlag $PropagationFlags
    }

    $testCases = @(
        @{
            ApplyTo = 'KeyOnly';
            InheritanceFlags = 'None';
            PropagationFlags = 'None';
        },
        @{
            ApplyTo = 'KeyAndSubkeys';
            InheritanceFlags = 'ContainerInherit';
            PropagationFlags = 'NoPropagateInherit';
        },
        @{
            ApplyTo = 'SubkeysOnly';
            InheritanceFlags = 'ContainerInherit';
            PropagationFlags = 'NoPropagateInherit,InheritOnly';
        }
    )

    It 'applies to <ApplyTo> and only child keys' -TestCases $testCases {
        Invoke-GrantPermissions -Identity $script:user `
                                -Path $script:testKeyPath `
                                -Permission ReadKey `
                                -ApplyTo $ApplyTo `
                                -OnlyApplyToChildKeys `
                                -InheritanceFlag $InheritanceFlags `
                                -PropagationFlag $PropagationFlags
    }

    It 'changes Permission' {
        Invoke-GrantPermissions -Identity $script:user `
                                -Permission FullControl `
                                -Path $script:testKeyPath `
                                -ApplyTo KeyOnly
        Invoke-GrantPermissions -Identity $script:user -Permission ReadKey -Path $script:testKeyPath -ApplyTo KeyOnly
    }

    It 'does not change permission' {
        Invoke-GrantPermissions -Identity $script:user -Permission FullControl -Path $script:testKeyPath

        Mock -CommandName 'Set-Acl' -Verifiable -ModuleName 'Carbon.Security'

        Invoke-GrantPermissions -Identity $script:user -Permission FullControl -Path $script:testKeyPath
        Assert-MockCalled -CommandName 'Set-Acl' -Times 0 -ModuleName 'Carbon.Security'
    }

    It 'when changing applies to' {
        Invoke-GrantPermissions -Identity $script:user `
                                -Permission FullControl `
                                -Path $script:testKeyPath `
                                -ApplyTo KeyAndSubkeys
        Invoke-GrantPermissions -Identity $script:user -Permission ReadKey -Path $script:testKeyPath -ApplyTo KeyOnly
    }

    It 'forces permission change' {
        Invoke-GrantPermissions -Identity $script:user `
                                -Permission FullControl `
                                -Path $script:testKeyPath `
                                -ApplyTo KeyAndSubkeys

        Mock -CommandName 'Set-Acl' -Verifiable -ModuleName 'Carbon.Security'

        Grant-CRegistryPermission -Identity $script:user `
                                  -Permission FullControl `
                                  -Path $script:testKeyPath `
                                  -Apply KeyAndSubkeys `
                                  -Force

        Assert-MockCalled -CommandName 'Set-Acl' -Times 1 -Exactly -ModuleName 'Carbon.Security'
    }

    It 'validates path exists' {
        $result = Grant-CRegistryPermission -Identity $script:user `
                                            -Permission ReadKey `
                                            -Path 'TestRegistry:\I\Do\Not\Exist' `
                                            -PassThru `
                                            -ErrorAction SilentlyContinue
        $result | Should -BeNullOrEmpty
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'path does not exist'
    }

    It 'clears existing Permission' {
        Invoke-GrantPermissions -Identity $script:user -Permission ReadKey -Path $script:testKeyPath
        Invoke-GrantPermissions -Identity $script:user -Permission ReadKey -Path $script:testKeyPath -Clear
        $Global:Error | Should -BeNullOrEmpty
    }

    It 'sets deny rule' {
        Invoke-GrantPermissions -Identity $script:user `
                                -Permissions 'Write' `
                                -Path $script:testKeyPath `
                                -Type 'Deny'
    }

    It 'grants multiple different permissions to a user' {
        Grant-CRegistryPermission -Path $script:testKeyPath `
                                  -Identity $script:user `
                                  -Permission 'ReadKey' `
                                  -ApplyTo KeyAndSubkeys `
                                  -Append
        Grant-CRegistryPermission -Path $script:testKeyPath `
                                  -Identity $script:user `
                                  -Permission 'WriteKey' `
                                  -ApplyTo SubkeysOnly `
                                  -Append
        $perm = Get-CRegistryPermission -Path $script:testKeyPath -Identity $script:user
        $perm | Should -HaveCount 2
    }
}
