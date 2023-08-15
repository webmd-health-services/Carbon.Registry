# Carbon.Registry PowerShell Module

## Overview

The "Carbon.Registry" PowerShell module contains functions that make it easier to work with the Windows registry.

## System Requirements

* Windows PowerShell 5.1 and .NET 4.6.1+
* PowerShell 6+

## Installing

To install globally:

```powershell
Install-Module -Name 'Carbon.Registry'
Import-Module -Name 'Carbon.Registry'
```

To install privately:

```powershell
Save-Module -Name 'Carbon.Registry' -Path '.'
Import-Module -Name '.\Carbon.Registry'
```

## Commands

* `Get-CRegistryKeyValue`
* `Install-CRegistryKey`
* `Remove-CRegistryKeyValue`
* `Set-CRegistryKeyValue`
* `Test-CRegistryKeyValue`
