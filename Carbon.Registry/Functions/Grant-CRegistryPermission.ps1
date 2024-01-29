
function Grant-CRegistryPermission
{
    <#
    .SYNOPSIS
    Grants permission on a file, directory, registry key, or certificate's private key/key container.

    .DESCRIPTION
    The `Grant-CPermission` functions grants permissions to files, directories, registry keys, and certificate private
    key/key containers. It detects what you are setting permissions on by inspecting the path of the item. If the path
    is relative, it uses the current location to determine if file system, registry, or private keys permissions should
    be set.

    The `Permissions` attribute should be a list of
    [FileSystemRights](http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights.aspx),
    [RegistryRights](http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx), or
    [CryptoKeyRights](http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.cryptokeyrights.aspx), for
    files/directories, registry keys, and certificate private keys, respectively. These commands will show you the
    values for the appropriate permissions for your object:

        [Enum]::GetValues([Security.AccessControl.FileSystemRights])
        [Enum]::GetValues([Security.AccessControl.RegistryRights])
        [Enum]::GetValues([Security.AccessControl.CryptoKeyRights])

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

            C
           / \
          CC CL
         /  \
        GC  GL

    where

     * C is the **C**ontainer permissions are getting set on
     * CC is a **C**hild **C**ontainer
     * CL is a **C**hild **L**eaf
     * GC is a **G**randchild **C**ontainer and includes all sub-containers below it
     * GL is a **G**randchild **L**eaf

    The `ApplyTo` parameter takes one of the following 13 values and applies permissions to:

     * **Container** - The container itself and nothing below it.
     * **SubContainers** - All sub-containers under the container, e.g. CC and GC.
     * **Leaves** - All leaves under the container, e.g. CL and GL.
     * **ChildContainers** - Just the container's child containers, e.g. CC.
     * **ChildLeaves** - Just the container's child leaves, e.g. CL.
     * **ContainerAndSubContainers** - The container and all its sub-containers, e.g. C, CC, and GC.
     * **ContainerAndLeaves** - The container and all leaves under it, e.g. C and CL.
     * **SubContainerAndLeaves** - All sub-containers and leaves, but not the container itself, e.g. CC, CL, GC, and GL.
     * **ContainerAndChildContainers** - The container and all just its child containers, e.g. C and CC.
     * **ContainerAndChildLeaves** - The container and just its child leaves, e.g. C and CL.
     * **ContainerAndChildContainersAndChildLeaves** - The container and just its child containers/leaves, e.g. C, CC,
       and CL.
     * **ContainerAndSubContainersAndLeaves** - Everything, full inheritance/propogation, e.g. C, CC, GC, GL.  **This is
       the default.**
     * **ChildContainersAndChildLeaves**  - Just the container's child containers/leaves, e.g. CC and CL.

    The following table maps `ContainerInheritanceFlags` values to the actual `InheritanceFlags` and `PropagationFlags`
    values used:

        ContainerInheritanceFlags                   InheritanceFlags                 PropagationFlags
        -------------------------                   ----------------                 ----------------
        Container                                   None                             None
        SubContainers                               ContainerInherit                 InheritOnly
        Leaves                                      ObjectInherit                    InheritOnly
        ChildContainers                             ContainerInherit                 InheritOnly, NoPropagateInherit
        ChildLeaves                                 ObjectInherit                    InheritOnly, NoPropagateInherit
        ContainerAndSubContainers                   ContainerInherit                 None
        ContainerAndLeaves                          ObjectInherit                    None
        SubContainerAndLeaves                       ContainerInherit,ObjectInherit   InheritOnly
        ContainerAndChildContainers                 ContainerInherit                 NoPropagateInherit
        ContainerAndChildLeaves                     ObjectInherit                    NoPropagateInherit
        ContainerAndChildContainersAndChildLeaves   ContainerInherit,ObjectInherit   NoPropagateInherit
        ContainerAndSubContainersAndLeaves          ContainerInherit,ObjectInherit   None
        ChildContainersAndChildLeaves               ContainerInherit,ObjectInherit   InheritOnly, NoPropagateInherit

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
    System.Security.AccessControl.AccessRule. When setting permissions on a file or directory, a
    `System.Security.AccessControl.FileSystemAccessRule` is returned. When setting permissions on a registry key, a
    `System.Security.AccessControl.RegistryAccessRule` returned. When setting permissions on a private key, a
    `System.Security.AccessControl.CryptoKeyAccessRule` object is returned.

    .LINK
    Carbon_Permission

    .LINK
    ConvertTo-CContainerInheritanceFlags

    .LINK
    Disable-CAclInheritance

    .LINK
    Enable-CAclInheritance

    .LINK
    Get-CPermission

    .LINK
    Revoke-CPermission

    .LINK
    Test-CPermission

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights.aspx

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.cryptokeyrights.aspx

    .LINK
    http://msdn.microsoft.com/en-us/magazine/cc163885.aspx#S3

    .EXAMPLE
    Grant-CPermission -Identity ENTERPRISE\Engineers -Permission FullControl -Path C:\EngineRoom

    Grants the Enterprise's engineering group full control on the engine room.  Very important if you want to get
    anywhere.

    .EXAMPLE
    Grant-CPermission -Identity ENTERPRISE\Interns -Permission ReadKey,QueryValues,EnumerateSubKeys -Path rklm:\system\WarpDrive

    Grants the Enterprise's interns access to read about the warp drive.  They need to learn someday, but at least they
    can't change anything.

    .EXAMPLE
    Grant-CPermission -Identity ENTERPRISE\Engineers -Permission FullControl -Path C:\EngineRoom -Clear

    Grants the Enterprise's engineering group full control on the engine room.  Any non-inherited, existing access rules
    are removed from `C:\EngineRoom`.

    .EXAMPLE
    Grant-CPermission -Identity ENTERPRISE\Engineers -Permission FullControl -Path 'cert:\LocalMachine\My\1234567890ABCDEF1234567890ABCDEF12345678'

    Grants the Enterprise's engineering group full control on the `1234567890ABCDEF1234567890ABCDEF12345678`
    certificate's private key/key container.

    .EXAMPLE
    Grant-CPermission -Identity BORG\Locutus -Permission FullControl -Path 'C:\EngineRoom' -Type Deny

    Demonstrates how to grant deny permissions on an objecy with the `Type` parameter.

    .EXAMPLE
    Grant-CPermission -Path C:\Bridge -Identity ENTERPRISE\Wesley -Permission 'Read' -ApplyTo ContainerAndSubContainersAndLeaves -Append
    Grant-CPermission -Path C:\Bridge -Identity ENTERPRISE\Wesley -Permission 'Write' -ApplyTo ContainerAndLeaves
    -Append

    Demonstrates how to grant multiple access rules to a single identity with the `Append` switch. In this case,
    `ENTERPRISE\Wesley` will be able to read everything in `C:\Bridge` and write only in the `C:\Bridge` directory, not
    to any sub-directory.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessage('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName='DefaultAppliesToFlags')]
    [OutputType([Security.AccessControl.AccessRule])]
    param(
        [Parameter(Mandatory)]
        # The path on which the permissions should be granted.  Can be a file system, registry, or certificate path.
        [String] $Path,

        [Parameter(Mandatory)]
        # The user or group getting the permissions.
        [String] $Identity,

        [Parameter(Mandatory)]
        # The permission: e.g. FullControl, Read, etc.  For file system items, use values from
        # [System.Security.AccessControl.FileSystemRights](http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights.aspx).
        # For registry items, use values from
        # [System.Security.AccessControl.RegistryRights](http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.registryrights.aspx).
        [RegistryRights[]] $Permission,

        # How to apply container permissions.  This controls the inheritance and propagation flags.  Default is full
        # inheritance, e.g. `ContainersAndSubContainersAndLeaves`. This parameter is ignored if `Path` is to a leaf
        # item.
        [Parameter(Mandatory, ParameterSetName='SetsAppliesToFlags')]
        [ValidateSet('KeyOnly', 'KeyAndSubkeys', 'SubkeysOnly')]
        [String] $ApplyTo,

        # Only apply the permissions to keys in the key, i.e. child keys only.
        [Parameter(ParameterSetName='SetsAppliesToFlags')]
        [switch] $OnlyApplyToChildKeys,

        # The type of rule to apply, either `Allow` or `Deny`. The default is `Allow`, which will allow access to the
        # item. The other option is `Deny`, which will deny access to the item.
        #
        # This parameter was added in Carbon 2.3.0.
        [AccessControlType] $Type = [AccessControlType]::Allow,

        # Removes all non-inherited permissions on the item.
        [switch] $Clear,

        # Returns an object representing the permission created or set on the `Path`. The returned object will have a
        # `Path` propery added to it so it can be piped to any cmdlet that uses a path.
        #
        # The `PassThru` switch is new in Carbon 2.0.
        [switch] $PassThru,

        # Grants permissions, even if they are already present.
        [switch] $Force,

        # When granting permissions on files, directories, or registry items, add the permissions as a new access rule
        # instead of replacing any existing access rules. This switch is ignored when setting permissions on
        # certificates.
        #
        # This switch was added in Carbon 2.7.
        [switch] $Append
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if (-not $ApplyTo)
    {
        $ApplyTo = 'KeyAndSubkeys'
    }

    $PSBoundParameters['ApplyTo'] = $ApplyTo | ConvertTo-CarbonPermissionsApplyTo

    $PSBoundParameters.Remove('OnlyApplyToChildKeys') | Out-Null
    if ($OnlyApplyToChildKeys)
    {
        $PSBoundParameters['OnlyApplyToChildren'] = $true
    }

    Grant-CPermission @PSBoundParameters

}
