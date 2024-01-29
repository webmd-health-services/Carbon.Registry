
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:user = 'CRegTestUser1'
    $script:group1 = 'CRegTestGroup1'
    $script:keyPath = $null
    $script:childKeyPath = $null
    $script:testNum = 0

}

Describe 'Get-CRegistryPermission' {
    BeforeEach {
        $script:keyPath = Join-Path -Path 'TestRegistry:' -ChildPath ($script:testNum++)

        Install-CRegistryKey $script:keyPath
        Grant-CRegistryPermission -Path $script:keyPath -Identity $script:group1 -Permission ReadKey

        $script:childKeyPath = Join-Path -Path $script:keyPath -ChildPath 'Child1'
        Install-CRegistryKey -Path $script:childKeyPath
        Grant-CRegistryPermission -Path $script:childKeyPath -Identity $script:user -Permission ReadKey

        $Global:Error.Clear()
    }

    It 'gets permissions' {
        $perms = Get-CRegistryPermission -Path $script:childKeyPath
        $perms | Should -Not -BeNullOrEmpty
        $group1Perms = $perms | Where-Object { $_.IdentityReference.Value -like "*\$script:group1" }
        $group1Perms | Should -BeNullOrEmpty

        $userPerms = $perms | Where-Object { $_.IdentityReference.Value -like "*\$script:user" }
        $userPerms | Should -Not -BeNullOrEmpty
        $userPerms | Should -BeOfType [Security.AccessControl.RegistryAccessRule]
    }

    It 'gets inherited permissions' {
        $perms = Get-CRegistryPermission -Path $script:childKeyPath -Inherited
        $perms | Should -Not -BeNullOrEmpty
        $group1Perms = $perms | Where-Object { $_.IdentityReference.Value -like "*\$script:group1" }
        $group1Perms | Should -Not -BeNullOrEmpty
        $group1Perms | Should -BeOfType [Security.AccessControl.RegistryAccessRule]

        $userPerms = $perms | Where-Object { $_.IdentityReference.Value -like "*\$script:user" }
        $userPerms | Should -Not -BeNullOrEmpty
        $userPerms | Should -BeOfType [Security.AccessControl.RegistryAccessRule]
    }

    It 'gets specific user permissions' {
        $perms = Get-CRegistryPermission -Path $script:childKeyPath -Identity $script:group1
        $perms | Should -BeNullOrEmpty

        $perms = @( Get-CRegistryPermission -Path $script:childKeyPath -Identity $script:user )
        $perms | Should -Not -BeNullOrEmpty
        $perms | Should -HaveCount 1
        $perms[0] | Should -Not -BeNullOrEmpty
        $perms[0] | Should -BeOfType [Security.AccessControl.RegistryAccessRule]
    }

    It 'gets specific users inherited permissions' {
        $perms = Get-CRegistryPermission -Path $script:childKeyPath -Identity $script:group1 -Inherited
        $perms | Should -Not -BeNullOrEmpty
        $perms | Should -BeOfType [Security.AccessControl.RegistryAccessRule]
    }

    It 'gets permissions on registry key' {
        $perms = Get-CRegistryPermission -Path 'hkcu:\'
        $perms | Should -Not -BeNullOrEmpty
        $perms | Should -BeOfType [Security.AccessControl.RegistryAccessRule]
    }
}