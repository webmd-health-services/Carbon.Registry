
function Set-CRegistryKeyValue
{
    <#
    .SYNOPSIS
    Sets a value in a registry key.

    .DESCRIPTION
    The `Set-CRegistryKeyValue` function sets the value of a registry key. If the key doesn't exist, it is created
    first. Uses PowerShell's `New-ItemPropery` to create the value if doesn't exist. Otherwise uses `Set-ItemProperty`
    to set the value.

    `DWord` and `QWord` values are stored in the registry as unsigned integers. If you pass a negative integer for the
    `DWord` and `QWord` parameters, PowerShell will convert it to an unsigned integer before storing. You won't get the
    same negative number back.

    To store integer values greater than `[Int32]::MaxValue` or `[Int64]::MaxValue`, use the `UDWord` and `UQWord`
    parameters, respectively, which are unsigned integers. These parameters were in Carbon 2.0.

    In versions of Carbon before 2.0, you'll need to convert these large unsigned integers into signed integers. You
    can't do this with casting. Casting preservers the value, not the bits underneath. You need to re-interpret the
    bits. Here's some sample code:

        # Carbon 1.0
        $bytes = [BitConverter]::GetBytes( $unsignedInt )
        $signedInt = [BitConverter]::ToInt32( $bytes, 0 )  # Or use `ToInt64` if you're working with 64-bit/QWord values
        Set-CRegistryKeyValue -Path $Path -Name 'MyUnsignedDWord' -DWord $signedInt

        # Carbon 2.0
        Set-CRegistryKeyValue -Path $Path -Name 'MyUnsignedDWord' -UDWord $unsignedInt

    .LINK
    Get-CRegistryKeyValue

    .LINK
    Test-CRegistryKeyValue

    .EXAMPLE
    Set-CRegistryKeyValue -Path 'hklm:\Software\Carbon\Test -Name Status -String foobar

    Creates the `Status` string value under the `hklm:\Software\Carbon\Test` key and sets its value to `foobar`.

    .EXAMPLE
    Set-CRegistryKeyValue -Path 'hklm:\Software\Carbon\Test -Name ComputerName -String '%ComputerName%' -Expand

    Creates an expandable string.  When retrieving this value, environment variables will be expanded.

    .EXAMPLE
    Set-CRegistryKeyValue -Path 'hklm:\Software\Carbon\Test -Name Movies -String ('Signs','Star Wars','Raiders of the Lost Ark')

    Sets a multi-string (i.e. array) value.

    .EXAMPLE
    Set-CRegistryKeyValue -Path hklm:\Software\Carbon\Test -Name 'SomeBytes' -Binary ([byte[]]@( 1, 2, 3, 4))

    Sets a binary value (i.e. `REG_BINARY`).

    .EXAMPLE
    Set-CRegistryKeyValue -Path hklm:\Software\Carbon\Test -Name 'AnInt' -DWord 48043

    Sets a binary value (i.e. `REG_DWORD`).

    .EXAMPLE
    Set-CRegistryKeyValue -Path hklm:\Software\Carbon\Test -Name 'AnInt64' -QWord 9223372036854775807

    Sets a binary value (i.e. `REG_QWORD`).

    .EXAMPLE
    Set-CRegistryKeyValue -Path hklm:\Software\Carbon\Test -Name 'AnUnsignedInt' -UDWord [uint32]::MaxValue

    Demonstrates how to set a registry value with an unsigned integer or an integer bigger than `[int]::MaxValue`.

    The `UDWord` parameter was added in Carbon 2.0. In earlier versions of Carbon, you have to convert the unsigned
    int's bits to a signed integer:

        $bytes = [BitConverter]::GetBytes( $unsignedInt )
        $signedInt = [BitConverter]::ToInt32( $bytes, 0 )
        Set-CRegistryKeyValue -Path $Path -Name 'MyUnsignedDWord' -DWord $signedInt

    .EXAMPLE
    Set-CRegistryKeyValue -Path hklm:\Software\Carbon\Test -Name 'AnUnsignedInt64' -UQWord [uint64]::MaxValue

    Demonstrates how to set a registry value with an unsigned 64-bit integer or a 64-bit integer bigger than
    `[long]::MaxValue`.

    The `UQWord parameter was added in Carbon 2.0. In earlier versions of Carbon, you have to convert the unsigned int's
    bits to a signed integer:

        $bytes = [BitConverter]::GetBytes( $unsignedInt )
        $signedInt = [BitConverter]::ToInt64( $bytes, 0 )
        Set-CRegistryKeyValue -Path $Path -Name 'MyUnsignedDWord' -DWord $signedInt

    .EXAMPLE
    Set-CRegistryKeyValue -Path hklm:\Software\Carbon\Test -Name 'UsedToBeAStringNowShouldBeDWord' -DWord 1 -Force

    Uses the `Force` parameter to delete the existing `UsedToBeAStringNowShouldBeDWord` before re-creating it.  This
    flag is useful if you need to change the type of a registry value.
    #>
    [CmdletBinding(SupportsShouldPRocess, DefaultParameterSetName='String')]
    param(
        # The path to the registry key where the value should be set.  Will be created if it doesn't exist.
        [Parameter(Mandatory)]
        [String] $Path,

        # The name of the value being set.
        [Parameter(Mandatory)]
        [String] $Name,

        # The value's data.  Creates a value for holding string data (i.e. `REG_SZ`). If `$null`, the value will be
        # saved as an empty string.
        [Parameter(Mandatory, ParameterSetName='String')]
        [AllowEmptyString()]
        [AllowNull()]
        [String] $String,

        # The string should be expanded when retrieved.  Creates a value for holding expanded string data (i.e.
        # `REG_EXPAND_SZ`).
        [Parameter(ParameterSetName='String')]
        [switch] $Expand,

        # The value's data.  Creates a value for holding binary data (i.e. `REG_BINARY`).
        [Parameter(Mandatory, ParameterSetName='Binary')]
        [byte[]] $Binary,

        # The value's data.  Creates a value for holding a 32-bit integer (i.e. `REG_DWORD`).
        [Parameter(Mandatory, ParameterSetName='DWord')]
        [int] $DWord,

        # The value's data as an unsigned integer (i.e. `UInt32`).  Creates a value for holding a 32-bit integer (i.e.
        # `REG_DWORD`).
        [Parameter(Mandatory, ParameterSetName='DWordAsUnsignedInt')]
        [UInt32] $UDWord,

        # The value's data.  Creates a value for holding a 64-bit integer (i.e. `REG_QWORD`).
        [Parameter(Mandatory, ParameterSetName='QWord')]
        [long] $QWord,

        # The value's data as an unsigned long (i.e. `UInt64`).  Creates a value for holding a 64-bit integer (i.e.
        # `REG_QWORD`).
        [Parameter(Mandatory, ParameterSetName='QWordAsUnsignedInt')]
        [UInt64] $UQWord,

        # The value's data.  Creates a value for holding an array of strings (i.e. `REG_MULTI_SZ`). Pass an empty array
        # or `$null` to set the value to an empty list.
        [Parameter(Mandatory, ParameterSetName='MultiString')]
        [AllowEmptyCollection()]
        [AllowNull()]
        [String[]] $Strings,

        # Removes and re-creates the value.  Useful for changing a value's type.
        [switch] $Force
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $value = $null
    $type = $pscmdlet.ParameterSetName
    switch -Exact ($PSCmdlet.ParameterSetName)
    {
        'String'
        {
            $value = $String
            if( $Expand )
            {
                $type = 'ExpandString'
            }
        }
        'Binary' { $value = $Binary }
        'DWord' { $value = $DWord }
        'QWord' { $value = $QWord }
        'DWordAsUnsignedInt'
        {
            $value = $UDWord
            $type = 'DWord'
        }
        'QWordAsUnsignedInt'
        {
            $value = $UQWord
            $type = 'QWord'
        }
        'MultiString'
        {
            if ($null -eq $Strings)
            {
                $Strings = [String[]]::New(0)
            }
            $value = $Strings
        }
    }

    Install-CRegistryKey -Path $Path

    if ($Force)
    {
        Remove-CRegistryKeyValue -Path $Path -Name $Name
    }

    if (Test-CRegistryKeyValue -Path $Path -Name $Name)
    {
        $updateValue = $false
        $currentValue = Get-CRegistryKeyValue -Path $Path -Name $Name
        if ($PSCmdlet.ParameterSetName -eq 'MultiString')
        {
            [String[]] $currentValues = $currentValue
            if ($null -eq $currentValues)
            {
                $currentValues = @()
            }

            $firstLineWritten = $false
            $msgPrefix = "   ${Path}    ${Name}"
            for ($idx = 0 ; $idx -lt ([Math]::Max($currentValues.Length, $value.Length)) ; ++$idx)
            {
                $fromValue = $null
                $noFromValue = $true
                $toValue = $null
                $noToValue = $true

                $changeMsg = ''
                if ($idx -lt $currentValues.Length)
                {
                    $fromValue = $currentValues[$idx]
                    $noFromValue = $false
                }

                if ($idx -lt $value.Length)
                {
                    $toValue = $value[$idx]
                    $noToValue = $false
                }

                if ($fromValue -eq $toValue)
                {
                    continue
                }

                $changeMsg = "  ${fromValue} -> ${toValue}"
                if ($noFromValue)
                {
                    $changeMsg = "+ ${toValue}"
                }
                elseif ($noToValue)
                {
                    $changeMsg = "- ${fromValue}"
                }

                $updateValue = $true
                $msg = "${msgPrefix}[${idx}]  ${changeMsg}"
                Write-Information $msg

                if (-not $firstLineWritten)
                {
                    $msgPrefix = ' ' * $msgPrefix.Length
                    $firstLineWritten = $true
                }
            }
        }
        else
        {
            $updateValue = ($currentValue -ne $value)
            if ($updateValue)
            {
                Write-Information -Message "   ${Path}    ${Name}  ${currentValue} -> ${value}"
            }
        }

        if ($updateValue)
        {
            Set-ItemProperty -Path $Path -Name $Name -Value $value
        }
    }
    else
    {
        if ($PSCmdlet.ParameterSetName -eq 'MultiString')
        {
            $msgPrefix = "   ${Path}  + ${Name}"
            $firstLineWritten = $false
            for ($idx = 0 ; $idx -lt $value.Length ; ++$idx)
            {
                Write-Information "${msgPrefix}[${idx}]  $($value[$idx])"
                if (-not $firstLineWritten)
                {
                    $firstLineWritten = $true
                    $msgPrefix = ' ' * $msgPrefix.Length
                }
            }
        }
        else
        {
            Write-Information -Message "   ${Path}  + ${Name}  ${value}"
        }
        $null = New-ItemProperty -Path $Path -Name $Name -Value $value -PropertyType $type
    }
}
