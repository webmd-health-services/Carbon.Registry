
function Grant-CRegistryKeyPermission
{
    <#
    .SYNOPSIS
    Grants permissions on registry keys.

    .DESCRIPTION
    The `Grant-CRegistryKeyPermission` functions grants permissions to registry keys. Pass the path to the registry key
    to the `Path` parameter, the name of the user/group receiving the permission to the `Identity` parameter, and the
    rights to grant to the `Permission` parameter. If the given user/group already has the permission on the registry
    key, nothing is changed. You can force the permission to be re-applied by using the `Force` switch.

    To change how the permissions are propagated down into registry keys, use the `ApplyTo` parameter.

    Beginning with Carbon 2.0, permissions are only granted if they don't exist on an item (inherited permissions are
    ignored).  If you always want to grant permissions, use the `Force` switch.

    Before Carbon 2.0, this function returned any new/updated access rules set on `Path`. In Carbon 2.0 and later, use
    the `PassThru` switch to get an access rule object back (you'll always get one regardless if the permissions changed
    or not).

    By default, permissions allowing access are granted. Beginning in Carbon 2.3.0, you can grant permissions denying
    access by passing `Deny` as the value of the `Type` parameter.

    Beginning in Carbon 2.7, you can append/add rules instead or replacing existing rules on files, directories, or
    registry items with the `Append` switch.

    ## Directories and Registry Keys

    When setting permissions on a container (directory/registry key) you can control inheritance and propagation flags
    using the `ApplyTo` parameter. This parameter is designed to hide the complexities of the Windows' inheritance and
    propagation flags. There are 13 possible combinations.

    Given this tree

             K
            / \
          CK1 CK2
         /  \
        GK1 GK2

    where

     * K is the **K**ey permissions are getting set on
     * CK1 and CK2 are **C**hild **K**eys
     * GK1 and GK2 are a **G**randchild **K**eys and includes all sub-containers below it

    The `ApplyTo` parameter takes one of the following 13 values and applies permissions to:

     * **Key** - The key itself and nothing below it.
     * **Subkeys** - All keys under the container, e.g. CK1, CK2, GK1, and GK2.
     * **ChildKeys** - Just the key's child keys, e.g. CK1 and CK2.
     * **KeyAndSubKeys** - The key and all its subkeys, e.g. K, CK1, CK2, GK1, and GK2.
     * **KeyAndChildKeys** - The key and all just its child keys, e.g. K and CK1 and CK2.

    The following table maps `[Carbon_Registry_KeyInheritanceFlags]` values to the actual `InheritanceFlags` and
    `PropagationFlags` values used:

        [Carbon_Registry_KeyInheritanceFlags]  InheritanceFlags                 PropagationFlags
        -------------------------------------  ----------------                 ----------------
        Key                                    None                             None
        Subkeys                                ContainerInherit                 InheritOnly
        ChildKeys                              ContainerInherit                 InheritOnly, NoPropagateInherit
        KeyAndSubKeys                          ContainerInherit                 None
        KeyAndChildKeys                        ContainerInherit                 None

    The above information adapated from [Manage Access to Windows Objects with ACLs and the .NET
    Framework](http://msdn.microsoft.com/en-us/magazine/cc163885.aspx#S3), published in the November 2004 copy of *MSDN
    Magazine*.

    If you prefer to speak in `InheritanceFlags` or `PropagationFlags`, you can use the
    `ConvertTo-ContainerInheritaceFlags` function to convert your flags into Carbon's flags.

    ## Certificate Private Keys/Key Containers

    When setting permissions on a certificate's private key/key container, if a certificate doesn't have a private key,
    it is ignored and no permissions are set. Since certificate's are always leaves, the `ApplyTo` parameter is ignored.

    When using the `-Clear` switch, note that the local `Administrators` account will always remain. In testing on
    Windows 2012 R2, we noticed that when `Administrators` access was removed, you couldn't read the key anymore.

    .OUTPUTS
    System.Security.AccessControl.RegistryAccessRule.

    .LINK
    Disable-CAclInheritance

    .LINK
    Enable-CAclInheritance

    .LINK
    Get-CRegistryKeyPermission

    .LINK
    Revoke-CRegistryKeyPermission

    .LINK
    Test-CRegistryKeyPermission

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx

    .LINK
    http://msdn.microsoft.com/en-us/magazine/cc163885.aspx#S3

    .EXAMPLE
    Grant-CRegistryKeyPermission -Identity ENTERPRISE\Engineers -Permission FullControl -Path hklm:\EngineRoom

    Demonstrates how to grant permissions on a registry key. In this example, the `ENTERPRISE\Engineers` identity will
    be given full control to the registry key at `hklm:\EngineRoom`.

    .EXAMPLE
    Grant-CRegistryKeyPermission -Identity ENTERPRISE\Engineers -Permission FullControl -Path C:\EngineRoom -Clear

    Demonstrates how to remove all other permissions on an item by using the `Clear` switch.

    .EXAMPLE
    Grant-CRegistryKeyPermission -Identity BORG\Locutus -Permission FullControl -Path 'C:\EngineRoom' -Type Deny

    Demonstrates how to grant deny permissions on a registry key by passing `Deny` to the `Type` parameter.

    .EXAMPLE
    Grant-CRegistryKeyPermission -Path C:\Bridge -Identity ENTERPRISE\Wesley -Permission 'Read' -ApplyTo ContainerAndSubContainersAndLeaves -Append
    Grant-CRegistryKeyPermission -Path C:\Bridge -Identity ENTERPRISE\Wesley -Permission 'Write' -ApplyTo
    ContainerAndLeaves -Append

    Demonstrates how to grant multiple access rules to a single identity with the `Append` switch. In this case,
    `ENTERPRISE\Wesley` will be able to read everything in `C:\Bridge` and write only in the `C:\Bridge` directory, not
    to any sub-directory.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessage('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Security.AccessControl.RegistryAccessRule])]
    param(
        # The path on which the permissions should be granted. Must be a registry path.
        [Parameter(Mandatory)]
        [String] $Path,

        # The user or group getting the permissions.
        [Parameter(Mandatory)]
        [String] $Identity,

        # The permission: e.g. FullControl, ReadKey, etc. See
        # [System.Security.AccessControl.RegistryRights](http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx)
        # for the full list with descriptions.
        [Parameter(Mandatory)]
        [Security.AccessControl.RegistryRights[]] $Permission,

        # How to apply the permission to the key and subkeys. The default is `KeyAndSubKeys`. Valid options are `Key`,
        # `KeyAndSubkeys`, and `SubkeysOnly`.
        [ValidateSet('Key', 'KeyAndSubkeys', 'SubkeysOnly')]
        [String] $ApplyTo = 'KeyAndSubkeys',

        # Only apply the permission to keys within this key, i.e. child keys.
        [switch] $OnlyApplyToChildKeys,

        # The type of rule to apply, either `Allow` or `Deny`. The default is `Allow`, which will allow access to the
        # item. The other option is `Deny`, which will deny access to the item.
        [Security.AccessControl.AccessControlType] $Type = [Security.AccessControl.AccessControlType]::Allow,

        # Removes all non-inherited permissions on the item.
        [switch] $Clear,

        # Returns a `Security.AccessControl.RegistryAccessRule` representing the permission garnted. The returned object
        # will have a `Path` propery added to it so it can be piped to any cmdlet that uses a path.
        [switch] $PassThru,

        # Grants permissions, even if they are already present.
        [switch] $Force,

        # When set, adds the permission as a new access rule on the registry key instead of replacing an identity's
        # existing access rules.
        [switch] $Append
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $PSBoundParameters.Remove('ApplyTo') | Out-Null
    $PSBoundParameters.Remove('OnlyApplyToChildKeys') | Out-Null

    Add-FlagsArgument -Argument $PSBoundParameters -ApplyTo $ApplyTo -OnlyApplyToChildKeys:$OnlyApplyToChildKeys

    Grant-CPermission @PSBoundParameters
}
