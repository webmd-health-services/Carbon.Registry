
function ConvertTo-CarbonSecurityApplyTo
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [AllowNull()]
        [ValidateSet('KeyOnly', 'KeyAndSubkeys', 'SubkeysOnly')]
        [String] $ApplyTo
    )

    begin
    {
        Set-StrictMode -Version 'Latest'
        Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

        $map = @{
            'KeyOnly' = 'ContainerOnly';
            'KeyAndSubkeys' = 'ContainerAndSubcontainers';
            'SubkeysOnly' = 'SubcontainersOnly';
        }
    }

    process
    {
        if (-not $ApplyTo)
        {
            return
        }

        return $map[$ApplyTo]
    }
}
