
function Remove-CRegistryKeyValue
{
    <#
    .SYNOPSIS
    Removes a value from a registry key, if it exists.

    .DESCRIPTION
    If the given key doesn't exist, nothing happens.

    .EXAMPLE
    Remove-CRegistryKeyValue -Path hklm:\Software\Carbon\Test -Name 'InstallPath'

    Removes the `InstallPath` value from the `hklm:\Software\Carbon\Test` registry key.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The path to the registry key where the value should be removed.
        [Parameter(Mandatory)]
        [String] $Path,

        # The name of the value to remove.
        [Parameter(Mandatory)]
        [String] $Name
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if ((Test-CRegistryKeyValue -Path $Path -Name $Name))
    {
        if ($PSCmdlet.ShouldProcess(('Item: {0} Property: {1}' -f $Path,$Name), 'Remove Property'))
        {
            Remove-ItemProperty -Path $Path -Name $Name
        }
    }
}

