
function Revoke-CRegistryPermission
{
    <#
    .SYNOPSIS
    Revokes *explicit* registry key permissions

    .DESCRIPTION
    The `Revoke-CRegistryPermission` function removes all of a user or group's *explicit* permission on a registry key.
    Inherited permissions are ignored. Pass the registry key path to the `Path` parameter. Pass the identity whose
    permissions to remove to the `Identity` parameter. If the identity doesn't exist, or the user doesn't have any
    permissions on the registry key, no error is written and nothing happens.

    .LINK
    Get-CRegistryPermission

    .LINK
    Grant-CRegistryPermission

    .LINK
    Test-CRegistryPermission

    .EXAMPLE
    Revoke-CRegistryPermission -Identity ENTERPRISE\Engineers -Path 'hklm:\EngineRoom'

    Demonstrates how to revoke all of the 'Engineers' permissions on the `hklm:\EngineRoom` registry key.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessage('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The registry key path on which the permissions should be revoked.
        [Parameter(Mandatory)]
        [String] $Path,

        # The user/group name losing permissions.
        [Parameter(Mandatory)]
        [String] $Identity
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    Revoke-CPermission @PSBoundParameters
}
