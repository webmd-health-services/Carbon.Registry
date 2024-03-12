
function Grant-CRegistryPermission
{
    <#
    .SYNOPSIS
    Grants permission on a registry key to a user or group.

    .DESCRIPTION
    The `Grant-CRegistryPermission` functions grants permissions to registry keys. Pass the path to the registry key to
    the `Path` parameter, the user/group name to the `Identity` parameter, and the permission to grant to the
    `Permission` parameter. If that user/group doesn't have any permissions on the registry key, the requested
    permissions are granted. If the user/group does have permissions on the registry key, and the permissions are
    different than the requested permissions, permissions are updated to be the requested permissions. If the user/group
    already has the requested permissions, no error is written and nothing happens.

    To control how the permission is applied to descendent registry keys, use the `ApplyTo` and
    `OnlyApplyToChildRegistryKeys` parameters. By default, permissions are applied to all keys and subkeys.

    Set the `Type` to `Deny` to create a deny permission.

    To clear all other permissions on the registry key, even permissions on other identities, use the `Clear` switch.

    To return the permission as an object, use the `PassThru` switch.

    To always apply the new permission, regardless if it is present or not, use the `Force` switch.

    To allow the user/group to have multiple permissions on the registry key, use the `Append` switch.

    .OUTPUTS
    System.Security.AccessControl.RegistryAccessRule

    .LINK
    Get-CRegistryPermission

    .LINK
    Revoke-CRegistryPermission

    .LINK
    Test-CRegistryPermission

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx

    .LINK
    http://msdn.microsoft.com/en-us/magazine/cc163885.aspx#S3

    .EXAMPLE
    Grant-CRegistryPermission -Identity ENTERPRISE\Engineers -Permission FullControl -Path 'hklm:\EngineRoom'

    Grants the Enterprise's engineering group full control on the engine room. Very important if you want to get
    anywhere.

    .EXAMPLE
    Grant-CRegistryPermission -Identity ENTERPRISE\Interns -Permission ReadKey,QueryValues,EnumerateSubKeys -Path hklm:\system\WarpDrive

    Grants the Enterprise's interns access to read about the warp drive. They need to learn someday, but at least they
    can't change anything.

    .EXAMPLE
    Grant-CRegistryPermission -Identity ENTERPRISE\Engineers -Permission FullControl -Path hklm:\EngineRoom -Clear

    Grants the Enterprise's engineering group full control on the engine room. Any non-inherited, existing access rules
    are removed from `C:\EngineRoom`.

    .EXAMPLE
    Grant-CRegistryPermission -Identity BORG\Locutus -Permission FullControl -Path 'hklm:\EngineRoom' -Type Deny

    Demonstrates how to grant deny permissions on an objecy with the `Type` parameter.

    .EXAMPLE
    Grant-CRegistryPermission -Path hklm:\Bridge -Identity ENTERPRISE\Wesley -Permission 'Read' -ApplyTo KeysAndSubkeys -Append
    Grant-CRegistryPermission -Path hklm:\Bridge -Identity ENTERPRISE\Wesley -Permission 'Write' -ApplyTo KeyOnly -Append

    Demonstrates how to grant multiple access rules to a single identity with the `Append` switch. In this case,
    `ENTERPRISE\Wesley` will be able to read everything in `hklm:\Bridge` and write only in the `hklm:\Bridge` directory, not
    to any sub-directory.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessage('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName='DefaultAppliesToFlags')]
    [OutputType([Security.AccessControl.RegistryAccessRule])]
    param(
        # The registry key path on which the permissions should be granted.
        [Parameter(Mandatory)]
        [String] $Path,

        # The user or group getting the permissions.
        [Parameter(Mandatory)]
        [String] $Identity,

        # The permission: e.g. FullControl, Read, etc. Use values from
        # [System.Security.AccessControl.RegistryRights](http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx).
        [Parameter(Mandatory)]
        [RegistryRights[]] $Permission,

        # How to apply permissions to descendants. This controls the inheritance and propagation flags. Default is full
        # inheritance, e.g. `KeyAndSubkeys`.
        [Parameter(Mandatory, ParameterSetName='SetsAppliesToFlags')]
        [ValidateSet('KeyOnly', 'KeyAndSubkeys', 'SubkeysOnly')]
        [String] $ApplyTo,

        # Only apply the permissions to child keys.
        [Parameter(ParameterSetName='SetsAppliesToFlags')]
        [switch] $OnlyApplyToChildKeys,

        # The type of rule to apply, either `Allow` or `Deny`. The default is `Allow`, which will allow access to the
        # item. The other option is `Deny`, which will deny access to the item.
        [AccessControlType] $Type = [AccessControlType]::Allow,

        # Removes all non-inherited permissions on the item.
        [switch] $Clear,

        # Returns an object representing the permission created or set on the `Path`. The returned object will have a
        # `Path` propery added to it so it can be piped to any cmdlet that uses a path.
        [switch] $PassThru,

        # Grants permissions, even if they are already present.
        [switch] $Force,

        # Add the permissions as a new access rule instead of replacing any existing access rules.
        [switch] $Append
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if (-not $ApplyTo)
    {
        $ApplyTo = 'KeyAndSubkeys'
    }

    $PSBoundParameters['ApplyTo'] = $ApplyTo | ConvertTo-CarbonSecurityApplyTo

    $PSBoundParameters.Remove('OnlyApplyToChildKeys') | Out-Null
    if ($OnlyApplyToChildKeys)
    {
        $PSBoundParameters['OnlyApplyToChildren'] = $true
    }

    Grant-CPermission @PSBoundParameters

}
