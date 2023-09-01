
function Test-CRegistryKeyPermission
{
    <#
    .SYNOPSIS
    Tests if permissions are set on a file, directory, registry key, or certificate's private key/key container.

    .DESCRIPTION
    Sometimes, you don't want to use `Grant-CRegistryKeyPermission` on a big tree.  In these situations, use `Test-CRegistryKeyPermission` to
    see if permissions are set on a given path.

    This function supports file system, registry, and certificate private key/key container permissions.  You can also
    test the inheritance and propogation flags on containers, in addition to the permissions, with the `ApplyTo`
    parameter.  See [Grant-CRegistryKeyPermission](Grant-CRegistryKeyPermission.html) documentation for an explanation of the `ApplyTo`
    parameter.

    Inherited permissions on *not* checked by default.  To check inherited permission, use the `-Inherited` switch.

    By default, the permission check is not exact, i.e. the user may have additional permissions to what you're
    checking.  If you want to make sure the user has *exactly* the permission you want, use the `-Exact` switch.  Please
    note that by default, NTFS will automatically add/grant `Synchronize` permission on an item, which is handled by
    this function.

    When checking for permissions on certificate private keys/key containers, if a certificate doesn't have a private
    key, `$true` is returned.

    .OUTPUTS
    System.Boolean.

    .LINK
    Carbon_Permission

    .LINK
    ConvertTo-CContainerInheritanceFlag

    .LINK
    Disable-CAclInheritance

    .LINK
    Enable-CAclInheritance

    .LINK
    Get-CRegistryKeyPermission

    .LINK
    Grant-CRegistryKeyPermission

    .LINK
    Revoke-CRegistryKeyPermission

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights.aspx

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.cryptokeyrights.aspx

    .EXAMPLE
    Test-CRegistryKeyPermission -Identity 'STARFLEET\JLPicard' -Permission 'FullControl' -Path 'C:\Enterprise\Bridge'

    Demonstrates how to check that Jean-Luc Picard has `FullControl` permission on the `C:\Enterprise\Bridge`.

    .EXAMPLE
    Test-CRegistryKeyPermission -Identity 'STARFLEET\GLaForge' -Permission 'WriteKey' -Path 'HKLM:\Software\Enterprise\Engineering'

    Demonstrates how to check that Geordi LaForge can write registry keys at `HKLM:\Software\Enterprise\Engineering`.

    .EXAMPLE
    Test-CRegistryKeyPermission -Identity 'STARFLEET\Worf' -Permission 'Write' -ApplyTo 'Container' -Path 'C:\Enterprise\Brig'

    Demonstrates how to test for inheritance/propogation flags, in addition to permissions.

    .EXAMPLE
    Test-CRegistryKeyPermission -Identity 'STARFLEET\Data' -Permission 'GenericWrite' -Path 'cert:\LocalMachine\My\1234567890ABCDEF1234567890ABCDEF12345678'

    Demonstrates how to test for permissions on a certificate's private key/key container. If the certificate doesn't
    have a private key, returns `$true`.
    #>
    [CmdletBinding()]
    param(
        # The registry key path on which the permissions should be checked.
        [Parameter(Mandatory)]
        [String] $Path,

        # The user or group whose permissions to check.
        [Parameter(Mandatory)]
        [String] $Identity,

        # The permission to test for: e.g. FullControl, ReadKey, etc.  For registry items, use values from
        # [System.Security.AccessControl.RegistryRights](http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx).
        [Parameter(Mandatory)]
        [Security.AccessControl.RegistryRights[]] $Permission,

        # The inheritance rules to check. Default is to ignore and not check how the permission inherits.
        [String] $ApplyTo,

        # Check that the permissions are only applied to child keys. Default is to ignore and not check how the
        # permission is applied.
        [switch] $OnlyApplyToChildKeys,

        # Include inherited permissions in the check.
        [switch] $Inherited,

        # Check for the exact permissions, inheritance flags, and propagation flags, i.e. make sure the identity has
        # *only* the permissions you specify.
        [switch] $Exact
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $PSBoundParameters.Remove('ApplyTo') | Out-Null
    $PSBoundParameters.Remove('OnlyApplyToChildKeys') | Out-Null

    Add-FlagsArgument -Argument $PSBoundParameters -ApplyTo $ApplyTo -OnlyApplyToChildKeys:$OnlyApplyToChildKeys

    Test-CPermission @PSBoundParameters
}

