
function Get-CRegistryKeyPermission
{
    <#
    .SYNOPSIS
    Gets the permissions (access control rules) for a registry key.

    .DESCRIPTION
    The `Get-CRegistryKeyPermission` function gets the non-inherited permissions on a registry key. Pass (or pipe) the
    path of registry key to the `Path` parameter. The non-inherited access rules are returned as
    `[System.Security.AccessControl.RegistryAccessRule]` objects.

    To get the permissions for a specific user or group, pass its name to the `Identity` parameter.

    To get inherited permissions, use the `Inherited` switch.

    .OUTPUTS
    System.Security.AccessControl.RegistryAccessRule.

    .LINK
    Get-CRegistryKeyPermission

    .LINK
    Grant-CRegistryKeyPermission

    .LINK
    Revoke-CRegistryKeyPermission

    .LINK
    Test-CRegistryKeyPermission

    .EXAMPLE
    Get-CRegistryKeyPermission -Path 'hklm:\Software'

    Demonstrates how to get all the non-inherited permissions/access rules from a registry key by pass the registry key
    to the `Path` parameter.

    .EXAMPLE
    Get-CRegistryKeyPermission -Path 'hklm:\Software' -Inherited

    Returns `System.Security.AccessControl.RegistryAccessRule` objects for all the inherited and non-inherited rules on
    `hklm:\software`.

    .EXAMPLE
    Get-CRegistryKeyPermission -Path 'hklm:\Software' -Identity 'Administrators

    Demonstrates how to get a specific user/group's permissions on a registry key by passing the name of the user/group
    to the `Idenitity` parameter.
    #>
    [CmdletBinding()]
    [OutputType([Security.AccessControl.RegistryAccessRule])]
    param(
        # The path whose permissions (i.e. access control rules) to return.
        [Parameter(Mandatory, ValueFromPipeline)]
        [String] $Path,

        # The identity whose permissiosn (i.e. access control rules) to return.
        [String] $Identity,

        # Return inherited permissions in addition to explicit permissions.
        [switch] $Inherited
    )

    process
    {
        Set-StrictMode -Version 'Latest'
        Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

        Grant-CPermission @PSBoundParameters
    }
}