
function Uninstall-CRegistryKey
{
    <#
    .SYNOPSIS
    Deletes a registry key.

    .DESCRIPTION
    The `Uninstall-CRegistryKey` function deletes a registry key. If the key doesn't exist, nothing happens and no
    errors are written. Pass the path to the registry key to the `Path` parameter. To delete the key and all subkeys,
    use the `Recurse` switch.

    .EXAMPLE
    Uninstall-CRegistryKey -Path 'hklm:\Software\Carbon\Test'

    Demonstrates how to delete a registry key. In this example, the 'hklm:\Software\Carbon\Test' key is deleted if it
    exists.

    .EXAMPLE
    Uninstall-CRegistryKey -Path 'hklm:\Software\Carbon\Test' -Recurse

    Demonstrates how to delete a registry key and all its subkeys. In this example, the 'hklm:\Software\Carbon\Test' key
    is deleted if it exists, along with its subkeys.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The path to the registry key to delete.
        [Parameter(Mandatory)]
        [String] $Path,

        # Use to delete the key and all its subkeys. This switch is required if the key has any subkeys.
        [switch] $Recurse
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if (-not (Test-Path -Path $Path))
    {
        return
    }

    $confirmArg = @{}
    if ($PSBoundParameters.ContainsKey('Confirm'))
    {
        $confirmArg['Confirm'] = $PSBoundParameters['Confirm']
    }

    Write-Information " - ${Path}"
    Remove-Item -Path $Path -Recurse:$Recurse -Force @confirmArg
}
