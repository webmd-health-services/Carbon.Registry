
function Add-FlagsArgument
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [IDictionary] $Argument,

        [Parameter(Mandatory)]
        [ValidateSet('KeyOnly', 'KeyAndSubkeys', 'SubkeysOnly')]
        [String] $ApplyTo,

        [switch] $OnlyApplyToChildKeys
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    # ApplyTo        OnlyApplyToChildKeys  InheritanceFlags  PropagationFlags
    # -------        --------------------  ----------------  ----------------
    # KeyOnly        true                  None              None
    # KeyAndSubkeys  true                  ContainerInherit  NoPropagateInherit
    # SubkeysOnly    true                  ContainerInherit  NoPropagateInherit, InheritOnly
    # KeyOnly        false                 None              None
    # KeyAndSubkeys  false                 ContainerInherit  None
    # KeyOnly        false                 ContainerInherit  InheritOnly

    $inheritanceFlags = [InheritanceFlags]::None
    $propagationFlags = [PropagationFlags]::None

    switch ($OnlyApplyToChildKeys.IsPresent)
    {
        $true
        {
            switch ($ApplyTo)
            {
                'KeyOnly'
                {
                    $inheritanceFlags = [InheritanceFlags]::None
                    $propagationFlags = [PropagationFlags]::None
                }
                'KeyAndSubkeys'
                {
                    $inheritanceFlags = [InheritanceFlags]::ContainerInherit
                    $propagationFlags = [PropagationFlags]::NoPropagateInherit
                }
                'SubkeysOnly'
                {
                    $inheritanceFlags = [InheritanceFlags]::ContainerInherit
                    $propagationFlags = [PropagationFlags]::NoPropagateInherit -bor [PropagationFlags]::InheritOnly
                }
            }
        }
        $false
        {
            switch ($ApplyTo)
            {
                'KeyOnly'
                {
                    $inheritanceFlags = [InheritanceFlags]::None
                    $propagationFlags = [PropagationFlags]::None
                }
                'KeyAndSubkeys'
                {
                    $inheritanceFlags = [InheritanceFlags]::ContainerInherit
                    $propagationFlags = [PropagationFlags]::None
                }
                'SubkeysOnly'
                {
                    $inheritanceFlags = [InheritanceFlags]::ContainerInherit
                    $propagationFlags = [PropagationFlags]::InheritOnly
                }
            }
        }
    }

    $Argument['InheritanceFlag'] = $inheritanceFlags
    $Argument['PropagationFlag'] = $propagationFlags
}