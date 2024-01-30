
function Test-CRegistryPermission
{
    <#
    .SYNOPSIS
    Tests if a user/group has permissions on a registry key.

    .DESCRIPTION
    The `Test-CRegistryPermission` function tests if a user/gropu has permissions on a registry key. Pass the path to
    the registry key to the `Path` parameter, the user/group name to the `Identity` parameter, and the permission to
    check to the `Permission` parameter. If the user has those permissions, returns `$true`, otherwise returns `$false`.

    By default, the permission check is not exact. For example, if the user/group has `FullControl` access, and
    `ReadKey` is passed as the permission to check, the function would return `$true` because `FullControl` includes the
    `ReadKey` permission. If you want to test if the user/group has the exact permissions passed, use the `Strict`
    switch.

    Inherited permissions on *not* checked by default. To check inherited permission, use the `-Inherited` switch.

    By default, how the permissions are applied to descendent registry keys is ignored. If you also want to check the
    key's "applies to" flags, use tthe `ApplyTo` and `OnlyApplyToChildKeys` parameters.
    .OUTPUTS
    System.Boolean.

    .LINK
    Get-CRegistryPermission

    .LINK
    Grant-CRegistryPermission

    .LINK
    Revoke-CPermission

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx

    .EXAMPLE
    Test-CRegistryPermission -Identity 'STARFLEET\JLPicard' -Permission 'FullControl' -Path 'hklm:\Enterprise\Bridge'

    Demonstrates how to check that Jean-Luc Picard has `FullControl` permission on the `C:\Enterprise\Bridge`.

    .EXAMPLE
    Test-CRegistryPermission -Identity 'STARFLEET\Worf' -Permission 'Write' -ApplyTo 'KeyOnly' -Path 'hlkm:\Enterprise\Brig'

    Demonstrates how to test the "applies to" flags on a registry key by using the `ApplyTo` parameter.
    #>
    [CmdletBinding(DefaultParameterSetName='IgnoreAppliesToFlags')]
    param(
        # The registry key path on which the permissions should be checked.
        [Parameter(Mandatory)]
        [String] $Path,

        # The user or group name whose permissions to check.
        [Parameter(Mandatory)]
        [String] $Identity,

        # The permission to test for: e.g. FullControl, ReadKey, etc. Use values from
        # [System.Security.AccessControl.RegistryRights](http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx).
        [Parameter(Mandatory)]
        [String[]] $Permission,

        # The "applies to" flags to check for. By default, these flags are ignored.
        [Parameter(Mandatory, ParameterSetName='TestAppliesToFlags')]
        [ValidateSet('KeyOnly', 'KeyAndSubkeys', 'SubkeysOnly')]
        [String] $ApplyTo,

        # Check that the permission is applied only to child keys and no further descendants.
        [Parameter(ParameterSetName='TestAppliesToFlags')]
        [switch] $OnlyApplyToChildKeys,

        # Include inherited permissions in the check.
        [switch] $Inherited,

        # Check for the exact permissions, i.e. make sure the identity has *only* the permissions specified.
        [switch] $Strict
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if ($PSCmdlet.ParameterSetName -eq 'TestAppliesToFlags')
    {
        $PSBoundParameters['ApplyTo'] = $ApplyTo | ConvertTo-CarbonPermissionsApplyTo

        $PSBoundParameters.Remove('OnlyApplyToChildKeys') | Out-Null
        if ($OnlyApplyToChildKeys)
        {
            $PSBoundParameters['OnlyApplyToChildren'] = $true
        }
    }

    Test-CPermission @PSBoundParameters
}
