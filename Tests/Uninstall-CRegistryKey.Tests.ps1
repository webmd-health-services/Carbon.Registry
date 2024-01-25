
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:rootKey = 'hkcu:\Uninstall-CRegistryKey'

    function GivenKey
    {
        param(
            [String] $Named
        )

        Install-CRegistryKey -Path (Join-Path -Path $script:rootKey -ChildPath $Named)
    }

    function ThenKey
    {
        param(
            [String] $Named,

            [switch] $Not,

            [switch] $Exists
        )

        Join-Path -Path $script:rootKey -ChildPath $Named | Should -Not:$Not -Exist
    }

    function ThenNoError
    {
        param(
        )

        $Global:Error | Should -BeNullOrEmpty
    }

    function WhenUninstalling
    {
        param(
            [String] $Named,

            [switch] $Recursively,

            [switch] $WithWhatIf
        )

        $optionalArgs = @{}
        if ($Recursively)
        {
            $optionalArgs['Recurse'] = $true
        }

        if ($WithWhatIf)
        {
            $optionalArgs['WhatIf'] = $true
        }

        Uninstall-CRegistryKey -Path (Join-Path -Path $script:rootKey -ChildPath $Named) @optionalArgs
    }
}

Describe 'Install-CRegistryKey' {
    BeforeEach {
        $Global:Error.Clear()
    }

    It 'deletes key' {
        GivenKey 'test1'
        WhenUninstalling 'test1'
        ThenNoError
        ThenKey 'test1' -Not -Exists
    }

    It 'deletes recursively' {
        GivenKey 'test3/subkey/subkey/subkey'
        WhenUninstalling 'test3' -Recursively
        ThenNoError
        ThenKey 'test3/subkey/subkey/subkey' -Not -Exists
        ThenKey 'test3/subkey/subkey' -Not -Exists
        ThenKey 'test3/subkey' -Not -Exists
        ThenKey 'test3' -Not -Exists
    }

    It 'supports WhatIf' {
        GivenKey 'test4'
        WhenUninstalling 'test4' -WithWhatIf
        ThenNoError
        ThenKey 'test4' -Exists
    }

    It 'writes no errors for non-existent key' {
        WhenUninstalling 'IDoNotExist'
        ThenNoError
    }
}
