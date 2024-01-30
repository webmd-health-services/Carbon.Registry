
function Get-CRegistryPermission
{
    <#
    .SYNOPSIS
    Gets the permissions (access control rules) for a registry key.

    .DESCRIPTION
    The `Get-CRegistryPermission` function gets the permissions on a registry key. Pass the path to the registry key
    whose permissions to get to the `Path` parameter. By default, all non-inherited permissions are returned. To also
    get inherited permissions, use the `Inherited` switch.

    Permissions for a specific identity can also be returned. Pass the user/group name to the `Identity` parameter. If
    the identity doesn't exist or it doesn't have permissions on the registry key, not error is written and nothing is
    returned.
s
    .OUTPUTS
    System.Security.AccessControl.AccessRule.

    .LINK
    Get-CRegistryPermission

    .LINK
    Grant-CRegistryPermission

    .LINK
    Revoke-CRegistryPermission

    .LINK
    Test-CRegistryPermission

    .EXAMPLE
    Get-CRegistryPermission -Path 'hklm:\Software'

    Demonstrates how to get all non-inherited permissions on a registry key by passing the key's path to the `Path`
    parameter.

    .EXAMPLE
    Get-CRegistryPermission -Path 'hklm:\Software' -Inherited

    Demonstrates how to get inherited permissions by using the `Inherited` switch.

    .EXAMPLE
    Get-CRegistryPermission -Path 'hklm:\Software\Microsoft' -Idenity Administrators

    Demonstrates how to get the permissions for a specific user/group by passing its name to the `Identity` paramter.
    #>
    [CmdletBinding()]
    [OutputType([Security.AccessControl.RegistryAccessRule])]
    param(
        # The registry key path whose permissions (i.e. access control rules) to return. Wildcards supported.
        [Parameter(Mandatory)]
        [String] $Path,

        # The identity whose permissiosn (i.e. access control rules) to return. By default, all non-inherited permissions
        # are returned.
        [String] $Identity,

        # Return inherited permissions in addition to explicit permissions. By default, inherited permissions are not
        # returned.
        [switch] $Inherited
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    Get-CPermission @PSBoundParameters
}

