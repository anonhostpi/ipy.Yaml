# Plan


### Commit 1: `ipy.Yaml.ps1` - Rename $WheelUrl to $wheel_url [COMPLETE]

### ipy.Yaml.rename-wheel-url

> **File**: `ipy.Yaml.ps1`
> **Type**: MODIFIED
> **Commit**: 1 of 1 for this file

#### Description

Rename $WheelUrl to $wheel_url

#### Diff

```diff
-$WheelUrl = 'https://files.pythonhosted.org/packages/ed/c3/4c823dac2949a6baf36a4987d04c50d30184147393ba6f4bfb4c67d15a13/ruamel.yaml-0.16.13-py2.py3-none-any.whl'
+$wheel_url = 'https://files.pythonhosted.org/packages/ed/c3/4c823dac2949a6baf36a4987d04c50d30184147393ba6f4bfb4c67d15a13/ruamel.yaml-0.16.13-py2.py3-none-any.whl'
```

#### Rule Compliance

> See Operating Procedures for Rules 3-4

| Rule | Check | Status |
|------|-------|--------|
| **Rule 3: Lines** | 2 lines | PASS |
| **Rule 3: Exempt** | N/A | N/A |
| **Rule 4: Atomic** | Single logical unit | YES |

### Commit 2: `ipy.Yaml.ps1` - Rename $namespaceShim to $namespace_shim [COMPLETE]

### ipy.Yaml.rename-namespace-shim

> **File**: `ipy.Yaml.ps1`
> **Type**: MODIFIED
> **Commit**: 1 of 1 for this file

#### Description

Rename $namespaceShim to $namespace_shim

#### Diff

```diff
-$namespaceShim = @'
+$namespace_shim = @'
 # Namespace package shim for IronPython in-memory imports.
 # The IronPythonEmbedded meta_path importer resolves ruamel.yaml directly;
 # pkgutil.extend_path is not needed and would fail in a virtual filesystem.
```

#### Rule Compliance

> See Operating Procedures for Rules 3-4

| Rule | Check | Status |
|------|-------|--------|
| **Rule 3: Lines** | 2 lines | PASS |
| **Rule 3: Exempt** | N/A | N/A |
| **Rule 4: Atomic** | Single logical unit | YES |

### Commit 3: `ipy.Yaml.ps1` - Rename $patchedInit to $patched_init [COMPLETE] [COMPLETE]

### ipy.Yaml.rename-patched-init

> **File**: `ipy.Yaml.ps1`
> **Type**: MODIFIED
> **Commit**: 1 of 1 for this file

#### Description

Rename $patchedInit to $patched_init

#### Diff

```diff
-$patchedInit = @'
+$patched_init = @'
 # coding: utf-8
 # ruamel.yaml 0.16.13 __init__.py -- patched for IronPython 3.4.2
 # Removed: _package_data (metadata only)
```

#### Rule Compliance

> See Operating Procedures for Rules 3-4

| Rule | Check | Status |
|------|-------|--------|
| **Rule 3: Lines** | 2 lines | PASS |
| **Rule 3: Exempt** | N/A | N/A |
| **Rule 4: Atomic** | Single logical unit | YES |

### Commit 4: `ipy.Yaml.ps1` - Rename $patchedCompat to $patched_compat [COMPLETE]

### ipy.Yaml.rename-patched-compat

> **File**: `ipy.Yaml.ps1`
> **Type**: MODIFIED
> **Commit**: 1 of 1 for this file

#### Description

Rename $patchedCompat to $patched_compat

#### Diff

```diff
-$patchedCompat = @'
+$patched_compat = @'
 # coding: utf-8
 
 from __future__ import print_function
```

#### Rule Compliance

> See Operating Procedures for Rules 3-4

| Rule | Check | Status |
|------|-------|--------|
| **Rule 3: Lines** | 2 lines | PASS |
| **Rule 3: Exempt** | N/A | N/A |
| **Rule 4: Atomic** | Single logical unit | YES |

### Commit 5: `ipy.Yaml.ps1` - Update function to use snake_case variable names [COMPLETE] [COMPLETE]

### ipy.Yaml.update-function-calls

> **File**: `ipy.Yaml.ps1`
> **Type**: MODIFIED
> **Commit**: 1 of 1 for this file

#### Description

Update function to use snake_case variable names

#### Diff

```diff
 function Add-IpyYaml {
     param([Parameter(Mandatory)] $Engine)
-    $Engine.Add('/ipy/lib/site-packages', $WheelUrl)
-    $Engine.Add('/ipy/lib/site-packages/ruamel/__init__.py', $namespaceShim)
-    $Engine.Add('/ipy/lib/site-packages/ruamel/yaml/__init__.py', $patchedInit)
-    $Engine.Add('/ipy/lib/site-packages/ruamel/yaml/compat.py', $patchedCompat)
+    $Engine.Add('/ipy/lib/site-packages', $wheel_url)
+    $Engine.Add('/ipy/lib/site-packages/ruamel/__init__.py', $namespace_shim)
+    $Engine.Add('/ipy/lib/site-packages/ruamel/yaml/__init__.py', $patched_init)
+    $Engine.Add('/ipy/lib/site-packages/ruamel/yaml/compat.py', $patched_compat)
```

#### Rule Compliance

> See Operating Procedures for Rules 3-4

| Rule | Check | Status |
|------|-------|--------|
| **Rule 3: Lines** | 8 lines | PASS |
| **Rule 3: Exempt** | N/A | N/A |
| **Rule 4: Atomic** | Single logical unit | YES |

### Commit 6: `ipy.Yaml.ps1` - Rename Add-IpyYaml to Install-IpyYaml function definition [COMPLETE]

### ipy.Yaml.rename-function-definition

> **File**: `ipy.Yaml.ps1`
> **Type**: MODIFIED
> **Commit**: 1 of 1 for this file

#### Description

Rename Add-IpyYaml to Install-IpyYaml function definition

#### Diff

```diff
-function Add-IpyYaml {
+function Install-IpyYaml {
     param([Parameter(Mandatory)] $Engine)
```

#### Rule Compliance

> See Operating Procedures for Rules 3-4

| Rule | Check | Status |
|------|-------|--------|
| **Rule 3: Lines** | 2 lines | PASS |
| **Rule 3: Exempt** | N/A | N/A |
| **Rule 4: Atomic** | Single logical unit | YES |

### Commit 7: `test.ps1` - Rename Add-IpyYaml to Install-IpyYaml function call in test [COMPLETE]

### test.rename-function-call

> **File**: `test.ps1`
> **Type**: MODIFIED
> **Commit**: 1 of 1 for this file

#### Description

Rename Add-IpyYaml to Install-IpyYaml function call in test

#### Diff

```diff
 . "$PSScriptRoot/ipy.Yaml.ps1"
-Add-IpyYaml -Engine $engine
+Install-IpyYaml -Engine $engine
 # Test 1: Basic import
```

#### Rule Compliance

> See Operating Procedures for Rules 3-4

| Rule | Check | Status |
|------|-------|--------|
| **Rule 3: Lines** | 2 lines | PASS |
| **Rule 3: Exempt** | N/A | N/A |
| **Rule 4: Atomic** | Single logical unit | YES |

### Commit 8: `README.md` - Rename Add-IpyYaml to Install-IpyYaml in README usage examples [COMPLETE]

### README.rename-readme-usage

> **File**: `README.md`
> **Type**: MODIFIED
> **Commit**: 1 of 1 for this file

#### Description

Rename Add-IpyYaml to Install-IpyYaml in README usage examples

#### Diff

```diff
 . ./ipy.Yaml.ps1
-Add-IpyYaml -Engine $engine
+Install-IpyYaml -Engine $engine
 $engine.Execute("import ruamel.yaml; print(ruamel.yaml.__version__)")
```

#### Rule Compliance

> See Operating Procedures for Rules 3-4

| Rule | Check | Status |
|------|-------|--------|
| **Rule 3: Lines** | 2 lines | PASS |
| **Rule 3: Exempt** | markdown | EXEMPT |
| **Rule 4: Atomic** | Single logical unit | YES |

### Commit 9: `README.md` - Rename Add-IpyYaml to Install-IpyYaml in README API documentation [COMPLETE]

### README.rename-readme-api-header

> **File**: `README.md`
> **Type**: MODIFIED
> **Commit**: 1 of 1 for this file

#### Description

Rename Add-IpyYaml to Install-IpyYaml in README API documentation

#### Diff

```diff
 ## API
 
-### `Add-IpyYaml`
+### `Install-IpyYaml`
 
 ```powershell
-Add-IpyYaml -Engine <IronPythonEngine>
+Install-IpyYaml -Engine <IronPythonEngine>
```

#### Rule Compliance

> See Operating Procedures for Rules 3-4

| Rule | Check | Status |
|------|-------|--------|
| **Rule 3: Lines** | 4 lines | PASS |
| **Rule 3: Exempt** | markdown | EXEMPT |
| **Rule 4: Atomic** | Single logical unit | YES |
