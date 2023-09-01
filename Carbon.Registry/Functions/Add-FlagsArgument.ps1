
function Add-FlagsArgument
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable] $Argument,

        [Parameter(Mandatory)]
        [ValidateSet('Key', 'KeyAndSubkeys', 'SubkeysOnly')]
        [String] $ApplyTo,

        [switch] $OnlyApplyToChildKeys
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    # ApplyTo         OnlyApplyToChildKeys  InheritanceFlags  PropagationFlags
    # -------         --------------------  ----------------  ----------------
    # Key             true                  $null             $null
    # SubkeysOnly     true                  ContainerInherit  NoPropagateInherit, InheritOnly
    # KeyAndSubkeys   true                  ContainerInherit  NoPropagateInherit
    # Key             false                 None              None
    # SubkeysOnly     false                 ContainerInherit  InheritOnly
    # KeyAndSubkeys   false                 ContainerInherit  None

    $inheritanceFlags = $null
    $propagationFlags = $null
    switch ($OnlyApplyToChildKeys)
    {
        $true
        {
            switch ($ApplyTo)
            {
                'Key'
                {
                    $inheritanceFlags = $null
                    $propagationFlags = $null
                }
                'SubKeysOnly'
                {
                    $inheritanceFlags = [InheritanceFlags]::ContainerInherit
                    $propagationFlags = [PropagationFlags]::NoPropagateInherit -bor [PropagationFlags]::InheritOnly
                }
                'KeyAndSubKeys'
                {
                    $inheritanceFlags = [InheritanceFlags]::ContainerInherit
                    $propagationFlags = [PropagationFlags]::NoPropagateInherit
                }
            }
        }
        $false
        {
            switch ($ApplyTo)
            {
                'Key'
                {
                    $inheritanceFlags = [InheritanceFlags]::None
                    $propagationFlags = [PropagationFlags]::None
                }
                'SubKeysOnly'
                {
                    $inheritanceFlags = [InheritanceFlags]::ContainerInherit
                    $propagationFlags = [PropagationFlags]::InheritOnly
                }
                'KeyAndSubKeys'
                {
                    $inheritanceFlags = [InheritanceFlags]::ContainerInherit
                    $propagationFlags = [PropagationFlags]::None
                }
            }
        }
    }

    if ($null -ne $inheritanceFlags)
    {
        $Argument['InheritanceFlags'] = $inheritanceFlags
    }

    if ($null -ne $propagationFlags)
    {
        $Argument['PropagationFlags'] = $propagationFlags
    }
}