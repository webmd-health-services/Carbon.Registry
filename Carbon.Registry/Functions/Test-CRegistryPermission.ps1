
function Test-CRegistryPermission
{
    <#
    .SYNOPSIS
    Tests if permissions are set on a file, directory, registry key, or certificate's private key/key container.

    .DESCRIPTION
    Sometimes, you don't want to use `Grant-CPermission` on a big tree.  In these situations, use `Test-CPermission` to
    see if permissions are set on a given path.

    This function supports file system, registry, and certificate private key/key container permissions.  You can also
    test the inheritance and propogation flags on containers, in addition to the permissions, with the `ApplyTo`
    parameter.  See [Grant-CPermission](Grant-CPermission.html) documentation for an explanation of the `ApplyTo`
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
    ConvertTo-CContainerInheritanceFlags

    .LINK
    Disable-CAclInheritance

    .LINK
    Enable-CAclInheritance

    .LINK
    Get-CPermission

    .LINK
    Grant-CPermission

    .LINK
    Revoke-CPermission

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights.aspx

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.cryptokeyrights.aspx

    .EXAMPLE
    Test-CPermission -Identity 'STARFLEET\JLPicard' -Permission 'FullControl' -Path 'C:\Enterprise\Bridge'

    Demonstrates how to check that Jean-Luc Picard has `FullControl` permission on the `C:\Enterprise\Bridge`.

    .EXAMPLE
    Test-CPermission -Identity 'STARFLEET\GLaForge' -Permission 'WriteKey' -Path 'HKLM:\Software\Enterprise\Engineering'

    Demonstrates how to check that Geordi LaForge can write registry keys at `HKLM:\Software\Enterprise\Engineering`.

    .EXAMPLE
    Test-CPermission -Identity 'STARFLEET\Worf' -Permission 'Write' -ApplyTo 'Container' -Path 'C:\Enterprise\Brig'

    Demonstrates how to test for inheritance/propogation flags, in addition to permissions.

    .EXAMPLE
    Test-CPermission -Identity 'STARFLEET\Data' -Permission 'GenericWrite' -Path 'cert:\LocalMachine\My\1234567890ABCDEF1234567890ABCDEF12345678'

    Demonstrates how to test for permissions on a certificate's private key/key container. If the certificate doesn't
    have a private key, returns `$true`.
    #>
    [CmdletBinding(DefaultParameterSetName='IgnoreAppliesToFlags')]
    param(
        # The path on which the permissions should be checked.  Can be a file system or registry path.
        [Parameter(Mandatory)]
        [String] $Path,

        # The user or group whose permissions to check.
        [Parameter(Mandatory)]
        [String] $Identity,

        # The permission to test for: e.g. FullControl, Read, etc.  For file system items, use values from
        # [System.Security.AccessControl.FileSystemRights](http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights.aspx).
        # For registry items, use values from
        # [System.Security.AccessControl.RegistryRights](http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx).
        [Parameter(Mandatory)]
        [String[]] $Permission,

        # The container and inheritance flags to check. Ignored if `Path` is a file. These are ignored if not supplied.
        # See `Grant-CPermission` for detailed explanation of this parameter. This controls the inheritance and
        # propagation flags.  Default is full inheritance, e.g. `ContainersAndSubContainersAndLeaves`. This parameter is
        # ignored if `Path` is to a leaf item.
        [Parameter(Mandatory, ParameterSetName='TestAppliesToFlags')]
        [ValidateSet('KeyOnly', 'KeyAndSubkeys', 'SubkeysOnly')]
        [String] $ApplyTo,

        # Only apply the permissions to keys in the key, i.e. child keys only.
        [Parameter(ParameterSetName='TestAppliesToFlags')]
        [switch] $OnlyApplyToChildKeys,

        # Include inherited permissions in the check.
        [switch] $Inherited,

        # Check for the exact permissions, inheritance flags, and propagation flags, i.e. make sure the identity has
        # *only* the permissions you specify.
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
