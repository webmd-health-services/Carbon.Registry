
# Carbon.Registry Changelog

## 1.0.0

Migrated Carbon registry functions.

### Upgrade Instructions

All functions now require using the `C` prefix.

* Replace usages of `Get-RegistryKeyValue` with `Get-CRegistryKeyValue`.
* Replace usages of `Remove-RegistryKeyValue` with `Remove-CRegistryKeyValue`.
* Replace usages of `Set-RegistryKeyValue` with `Set-CRegistryKeyValue`.
* Replace usages of `Test-RegistryKeyValue` with `Test-CRegistryKeyValue`.
* Replace usages of `Install-RegistryKey` with `Install-CRegistryKey`.

Remove usages of the `Quiet` switch from usages of `Set-CRegistryKeyValue`. That switch was removed.

### Added

* Replaced verbose-level messages with information-level messages in `Install-CRegistryKey`, `Remove-CRegistryKeyValue`,
and `Set-CRegistryKeyValue` when they make changes.

### Fixed

* `Set-CRegistryKeyValue` fails to set multiline string values to an empty list.

### Removed

* `Get-RegistryKeyValue` (use `Get-CRegistryKeyValue` instead).
* `Remove-RegistryKeyValue` (use `Remove-CRegistryKeyValue` instead).
* `Set-RegistryKeyValue` (use `Set-CRegistryKeyValue` instead).
* `Test-RegistryKeyValue` (use `Test-CRegistryKeyValue` instead).
* `Install-RegistryKey` (use `Install-CRegistryKey` instead).
* Parameter `Quiet` from `Set-CRegistryKeyValue`.
