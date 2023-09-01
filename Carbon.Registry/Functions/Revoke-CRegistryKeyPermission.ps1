
function Revoke-CRegistryKeyPermission
{
    <#
    .SYNOPSIS
    Revokes *explicit* permissions on a registry key.

    .DESCRIPTION
    Revokes all of a user or group's *explicit* permissions on a registry key. Inherited permissions are ignored.

    If the identity doesn't have permission, nothing happens, not even errors written out.

    .LINK
    Get-CRegistryKeyPermission

    .LINK
    Grant-CRegistryKeyPermission

    .LINK
    Test-CRegistryKeyPermission

    .EXAMPLE
    Revoke-CRegistryKeyPermission -Identity ENTERPRISE\Interns -Path 'hklm:\system\WarpDrive'

    Demonstrates how to revoke permission on a registry key.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessage('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The path on which the permissions should be revoked.
        [Parameter(Mandatory, ValueFromPipeline)]
        [String] $Path,

        # The identity losing permissions.
        [Parameter(Mandatory)]
        [String] $Identity
    )

    process
    {
        Set-StrictMode -Version 'Latest'
        Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

        Revoke-CPermission @PSBoundParameters
    }
}
