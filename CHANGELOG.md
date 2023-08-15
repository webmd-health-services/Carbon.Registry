
# Carbon.Registry Changelog

## 1.0.0

Migrated Carbon registry functions.

### Upgrade Instructions

Aĺl functions now require using the `C` prefix.

* Replace usages of `Get-RegistryKeyValue` with `Get-CRegistryKeyValue`.
* Replace usages of `Remove-RegistryKeyValue` with `Remove-CRegistryKeyValue`.
* Replace usages of `Set-RegistryKeyValue` with `Set-CRegistryKeyValue`.
* Replace usages of `Test-RegistryKeyValue` with `Test-CRegistryKeyValue`.
* Replace usages of `Install-RegistryKey` with `Install-CRegistryKey`.

### Removed

* `Get-RegistryKeyValue` (use `Get-CRegistryKeyValue` instead).
* `Remove-RegistryKeyValue` (use `Remove-CRegistryKeyValue` instead).
* `Set-RegistryKeyValue` (use `Set-CRegistryKeyValue` instead).
* `Test-RegistryKeyValue` (use `Test-CRegistryKeyValue` instead).
* `Install-RegistryKey` (use `Install-CRegistryKey` instead).
