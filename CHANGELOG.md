<!--markdownlint-disable MD012 no-multiple-blanks-->

# Carbon.Registry Changelog

## 1.2.0

> Unreleased

Added `Get-CRegistryPermission`, `Grant-CRegistryPermission`, `Revoke-CRegistryPermission`, and
`Test-CRegistryPermission`, migrated from Carbon's `Get-CPermission`, `Grant-CPermission`, `Revoke-CPermission`, and
`Test-CPermission`. If you are switching from Carbon to Carbon.Registry, do the following:

* Rename usages of `Get-CPermission`, `Grant-CPermission`, `Revoke-CPermission`, and `Test-CPermission` that operate on
  registry keys/paths to `Get-CRegistryPermission`, `Grant-CRegistryPermission`, `Revoke-CRegistryPermission`, and
  `Test-CRegistryPermission`.
* Replace usages of the `Test-CRegistryPermission` function's `-Exact` switch to `-Strict`.
* Using the table below, replace usages of `Grant-CRegistryPermission` and `Test-CRegistryPermission` arguments in the
  left column with the new arguments from the right column.
  | Old Argument                                            | New Argument(s)
  |---------------------------------------------------------|---------------------------------------------------------
  | `-Permission Container`                                 | `-Permission KeyOnly`
  | `-Permission SubContainers`                             | `-Permission SubkeysOnly`
  | `-Permission ChildContainers`                           | `-Permission SubkeysOnly -OnlyApplyToChildKeys`
  | `-Permission ContainerAndSubContainers`                 | `-Permission KeyAndSubkeys`
  | `-Permission ContainerAndChildContainers`               | `-Permission KeyAndSubkeys -OnlyApplyToChildKeys`


## 1.1.0

> Released 26 Jan 2024

Added `Uninstall-CRegistryKey` function for deleting a registry key without errors if it doesn't exist.


## 1.0.0

> Released 16 Aug 2023

Migrated Carbon registry functions.

### Upgrade Instructions

All functions now require using the `C` prefix.

* Replace usages of `Get-RegistryKeyValue` with `Get-CRegistryKeyValue`.
* Replace usages of `Remove-RegistryKeyValue` with `Remove-CRegistryKeyValue`.
* Replace usages of `Set-RegistryKeyValue` with `Set-CRegistryKeyValue`.
* Replace usages of `Test-RegistryKeyValue` with `Test-CRegistryKeyValue`.
* Replace usages of `Install-RegistryKey` with `Install-CRegistryKey`.

Remove usages of the `Quiet` switch from usages of `Set-CRegistryKeyValue`. That switch was removed.

### Changed

* Replaced verbose-level messages with information-level messages in `Install-CRegistryKey`, `Remove-CRegistryKeyValue`,
and `Set-CRegistryKeyValue` when saving changes.
* `Set-CRegistryKeyValue` accepts `$null` as the value of a multi-line string, which sets the value to an empty list.

### Fixed

* `Set-CRegistryKeyValue` fails to set multiline string values to an empty list.
* `Set-CRegistryKeyValue` sets the value of a multiline string even if the value hasn't changed.

### Removed

* `Get-RegistryKeyValue` (use `Get-CRegistryKeyValue` instead).
* `Remove-RegistryKeyValue` (use `Remove-CRegistryKeyValue` instead).
* `Set-RegistryKeyValue` (use `Set-CRegistryKeyValue` instead).
* `Test-RegistryKeyValue` (use `Test-CRegistryKeyValue` instead).
* `Install-RegistryKey` (use `Install-CRegistryKey` instead).
* Parameter `Quiet` from `Set-CRegistryKeyValue`.
