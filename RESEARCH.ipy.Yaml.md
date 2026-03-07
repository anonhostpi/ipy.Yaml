---
topic: ipy.Yaml
phase: discovery
rule: 0
feedback_iteration: 0
baseline_commit: null
last_squashed_commit: null
created: 2026-03-07
branch: null
worktree: null
pr_number: null
pr_url: null
pr_state: null
---

# RESEARCH: ipy.Yaml

## Problem Statement

We need a YAML parser/emitter that works under IronPython 3.4.2 via the IronPythonEmbedded PowerShell module. The module uses in-memory loading (no disk writes) via `sys.meta_path` with `find_module`/`load_module`. The virtual filesystem root is `/ipy/` with site-packages at `/ipy/lib/site-packages/`.

The primary use case is cloud-init YAML templates, which benefit from comment preservation and round-trip editing.

## Context

### IronPythonEmbedded API Surface

From `D:\Orchestrations\IronPythonEmbedded\IronPythonEmbedded.ps1`:

- **`engine.Add(path, content)`** -- Adds content at a virtual path. Content can be:
  - A file path (auto-read from disk)
  - A URL (auto-fetched)
  - A raw string (treated as source code)
  - A byte array
  - A Stream object
  - If the content is a valid zip archive, it is extracted in-memory and entries are mapped under `path`
- **`engine.Has(path)`** -- Checks if a module exists at the given virtual path (checks both loaded and archived stores)
- **`AddArchive(stream, prefixes, root)`** -- Lower-level: extracts a zip, strips prefix directories, maps entries under root
- **`SetFile(root, suffix, bytes)`** -- Directly sets file content as bytes

The import hook (`find_module`/`load_module`) searches these paths in order:
1. `/ipy/`
2. `/ipy/lib/`
3. `/ipy/lib/site-packages/`

For each, it tries:
1. `<dotted.name.as.path>.py` (module)
2. `<dotted.name.as.path>/__init__.py` (package)

When loading, it sets `__path__` for packages to `['<search_root>/<dotted/name/as/path>']`.

### Key Constraints

- **No disk writes** -- everything must be loaded from memory (zips, byte arrays, or strings)
- **No C extensions** -- IronPython cannot load CPython `.so`/`.dll`/`.pyd` extensions
- **Python 3.4 target** -- IronPython 3.4.2 targets Python 3.4 language level
- **No `pkg_resources`** -- not available in IronPython's stdlib
- **No `pkgutil`** -- may or may not be fully available; cannot rely on it
- **Limited stdlib** -- IronPython implements most of stdlib but has gaps (e.g., `ctypes` is limited, no `_ctypes` FFI, no `fcntl`)

## Investigation

### Option 1: ruamel.yaml (recommended)

#### Version Selection

- **ruamel.yaml 0.15.100** is the recommended version (last in the 0.15.x line)
- Python 3.4 support was dropped in 0.15.94, BUT the 0.15.x series uses `# type:` comment annotations, not PEP 526 annotations -- the actual syntax is Python 2.7+ compatible
- The `_package_data` in `__init__.py` lists supported versions as "2.7, 3.5, 3.6, 3.7" but the code itself uses no Python 3.5+ syntax features
- **No f-strings**, **no async/await**, **no PEP 526 annotations** found in the source
- The version check that broke Python 3.4 in 0.15.94 was likely a `python_requires` or setup-time check, not a runtime syntax issue
- Recommendation: use 0.15.100 and patch any version-gating code

#### Files Needed (Pure Python Only)

From the `commx/ruamel-yaml` mirror at tag `0.15.100`, these files go under `ruamel/yaml/`:

| File | Purpose | Include? |
|------|---------|----------|
| `__init__.py` | Package init, version info, C extension fallback | Yes (patch needed) |
| `main.py` | Core YAML class (load/dump/round-trip) | Yes |
| `compat.py` | Python 2/3 compatibility shims | Yes (patch needed) |
| `comments.py` | Comment-preserving data structures | Yes |
| `composer.py` | Node tree composer | Yes |
| `constructor.py` | Node-to-Python-object construction | Yes |
| `dumper.py` | Dumper classes | Yes |
| `emitter.py` | YAML output generation | Yes |
| `error.py` | Exception classes | Yes |
| `events.py` | Event classes | Yes |
| `loader.py` | Loader classes | Yes |
| `nodes.py` | Node classes | Yes |
| `parser.py` | YAML parser | Yes |
| `reader.py` | Stream reader | Yes |
| `representer.py` | Python-object-to-node representation | Yes |
| `resolver.py` | Tag resolution | Yes |
| `scanner.py` | Lexical scanner | Yes |
| `serializer.py` | Node-to-event serialization | Yes |
| `tokens.py` | Token classes | Yes |
| `scalarstring.py` | String scalar types | Yes |
| `scalarint.py` | Integer scalar types | Yes |
| `scalarfloat.py` | Float scalar types | Yes |
| `scalarbool.py` | Boolean scalar types | Yes |
| `timestamp.py` | Timestamp handling | Yes |
| `anchor.py` | Anchor handling | Yes |
| `util.py` | Utility functions | Yes |
| `cyaml.py` | C extension wrappers | **No** (skip) |
| `configobjwalker.py` | ConfigObj integration | **No** (skip) |
| `setup.py` | Package setup | **No** (skip) |
| `_doc/` | Documentation | **No** (skip) |
| `_test/` | Tests | **No** (skip) |
| `ext/` | Extensions | **No** (skip) |

#### C Extension Handling

The `__init__.py` already has graceful fallback:
```python
try:
    from .cyaml import *
    __with_libyaml__ = True
except (ImportError, ValueError):
    __with_libyaml__ = False
```

For round-trip mode (`YAML(typ='rt')`) -- which is the default and the mode we want -- the C extension is **never used**. Round-trip parsing is entirely pure Python. We can safely exclude `cyaml.py` entirely.

#### Namespace Package Handling

ruamel.yaml is a namespace package: `ruamel` is the namespace, `yaml` is the actual package.

The standard `ruamel/__init__.py` uses:
```python
__path__ = __import__('pkgutil').extend_path(__path__, __name__)
```

This will **not work** in our in-memory import system because:
1. `pkgutil.extend_path` scans `sys.path` for filesystem directories
2. Our modules live in virtual memory, not on the filesystem

**Solution:** Create a minimal `ruamel/__init__.py` shim:
```python
# Namespace package shim for IronPython in-memory imports
# No-op: the meta_path importer handles sub-package resolution
```

The IronPythonEmbedded import hook already handles the namespace correctly:
- When importing `ruamel`, it finds `ruamel/__init__.py` and sets `__path__`
- When importing `ruamel.yaml`, it finds `ruamel/yaml/__init__.py` and sets `__path__`
- The `__path__` is set to `['<search_root>/ruamel']` which allows sub-package resolution

The key insight: the in-memory import hook's `find_module` already rasterizes dotted names to paths (`ruamel.yaml` -> `ruamel/yaml`) and checks for `__init__.py`. No `pkgutil` or `pkg_resources` machinery is needed.

### Option 2: PyYAML

#### Version Selection

- **PyYAML 3.13** (July 2018) is the last version with Python 3.4 wheels
- PyYAML 5.1+ dropped Python 3.4 support

#### Files Needed (17 files)

All files from `lib/yaml/`:
`__init__.py`, `composer.py`, `constructor.py`, `cyaml.py`, `dumper.py`, `emitter.py`, `error.py`, `events.py`, `loader.py`, `nodes.py`, `parser.py`, `reader.py`, `representer.py`, `resolver.py`, `scanner.py`, `serializer.py`, `tokens.py`

Same C extension fallback approach -- skip `cyaml.py`.

#### PyYAML Limitations

- **No comment preservation** -- comments are discarded during parsing
- **No round-trip editing** -- load/dump loses formatting, ordering, and comments
- **Simpler API** -- just `yaml.safe_load()` / `yaml.dump()`
- For cloud-init templates where you need to preserve existing comments and structure, this is a significant limitation

#### Historical IronPython Issues

PyYAML on IronPython 1/2 had 7-8 failures and 57 errors in the test suite. While IronPython 3 may have improved, the compatibility is undocumented.

### Option 3: PyYAML + Comment Preservation (pyyaml-pure)

There is a `pyyaml-pure` package that adds YAML 1.2 support and comment preservation to PyYAML. However, it is a newer project and its Python 3.4 compatibility is unknown.

## Proposed Approach: ruamel.yaml 0.15.100

### Rationale

1. **Comment preservation is critical** for cloud-init YAML template editing
2. **Round-trip mode is pure Python** -- no C extension needed
3. **Python 2/3 compat layer** means the syntax is actually Python 2.7+ compatible despite the nominal 3.5+ requirement
4. **Fewer files than expected** -- 25 pure Python files, well-structured
5. **Proven fallback** -- the C extension import is already wrapped in try/except

### Known Compatibility Issues and Fixes

#### 1. `collections.abc` Import (compat.py)

```python
# Current (Python 3.3+ style in compat.py):
from collections.abc import Hashable, MutableSequence, MutableMapping, ...
```

IronPython 3.4 should support `collections.abc` (it was added in Python 3.3), but if not:
```python
try:
    from collections.abc import Hashable, MutableSequence, MutableMapping
except ImportError:
    from collections import Hashable, MutableSequence, MutableMapping
```

This fallback is likely already in `compat.py` since it supports Python 2.7.

#### 2. `ruamel.ordereddict` Import (compat.py)

```python
# compat.py tries:
from ruamel.ordereddict import ordereddict
```

This will fail. Fallback to `collections.OrderedDict` is already present in compat.py. No fix needed if the fallback chain works.

#### 3. `__init__.py` Patches

- Remove or skip `cyaml` import entirely (not just catch the ImportError)
- Remove `_package_data` dict (metadata only, not needed at runtime)
- Simplify `from ruamel.yaml.main import *` to work with in-memory imports

#### 4. Potential `io` Module Issues

ruamel.yaml uses `io.StringIO` and `io.BytesIO`. These should be available in IronPython 3.4, but verify during testing.

#### 5. `platform` Module

Some version/compat checks may use `platform.python_implementation()`. IronPython 3.4 supports this and returns `'IronPython'`.

#### 6. `textwrap.dedent` and Other Stdlib

Used in some files. Should be available in IronPython 3.4.

### Vendoring Strategy

#### Repository Structure

```
ipy.Yaml/
  ipy.Yaml.ps1              # Main PowerShell module
  vendor/
    ruamel.yaml-0.15.100/    # Extracted source (for reference/updating)
      ruamel/
        __init__.py          # Original namespace init
        yaml/
          *.py               # Original source files
  dist/
    ruamel.yaml.zip          # Pre-built zip for AddArchive
```

#### PowerShell Module Architecture

```powershell
# ipy.Yaml.ps1 - Single-file PowerShell module
# Exports a function or object that:
# 1. Takes an IronPythonEmbedded engine
# 2. Calls engine.Add() with the vendored zip
# 3. Returns the engine (or a wrapper)
```

#### Zip Structure

The zip should contain files at paths that, when extracted under a root, produce:
```
ruamel/__init__.py           # Namespace shim (empty or minimal)
ruamel/yaml/__init__.py      # Patched package init
ruamel/yaml/main.py          # Core
ruamel/yaml/compat.py        # Patched compat
ruamel/yaml/comments.py
ruamel/yaml/composer.py
ruamel/yaml/constructor.py
ruamel/yaml/dumper.py
ruamel/yaml/emitter.py
ruamel/yaml/error.py
ruamel/yaml/events.py
ruamel/yaml/loader.py
ruamel/yaml/nodes.py
ruamel/yaml/parser.py
ruamel/yaml/reader.py
ruamel/yaml/representer.py
ruamel/yaml/resolver.py
ruamel/yaml/scanner.py
ruamel/yaml/serializer.py
ruamel/yaml/tokens.py
ruamel/yaml/scalarstring.py
ruamel/yaml/scalarint.py
ruamel/yaml/scalarfloat.py
ruamel/yaml/scalarbool.py
ruamel/yaml/timestamp.py
ruamel/yaml/anchor.py
ruamel/yaml/util.py
```

#### Loading via IronPythonEmbedded

```powershell
# Using engine.Add with a zip:
$engine.Add("/ipy/lib/site-packages", $zipPathOrBytes)

# This will extract the zip and map entries under /ipy/lib/site-packages/
# So ruamel/yaml/__init__.py -> /ipy/lib/site-packages/ruamel/yaml/__init__.py
```

The `AddArchive` method (called internally by `Add` when content is a valid zip) maps zip entries under the specified root path. No prefix stripping needed if the zip already has the correct directory structure.

### Testing Plan

1. **Basic import test:** `import ruamel.yaml` -- verify namespace package resolution
2. **Round-trip test:** Load YAML with comments, dump it back, verify comments preserved
3. **Cloud-init test:** Load a real cloud-init YAML file, modify a value, dump back
4. **Error handling:** Verify that C extension absence is handled gracefully
5. **Edge cases:** Anchors, aliases, multi-document streams, flow vs block style

## Files to Modify/Create

| File | Change |
|------|--------|
| `ipy.Yaml.ps1` | Create: main PowerShell module that vendors ruamel.yaml into an IronPythonEmbedded engine |
| `vendor/ruamel/__init__.py` | Create: minimal namespace shim (empty body) |
| `vendor/ruamel/yaml/__init__.py` | Create: patched version of ruamel.yaml's `__init__.py` |
| `vendor/ruamel/yaml/compat.py` | Create: patched version with IronPython-safe imports |
| `vendor/ruamel/yaml/*.py` | Copy: remaining 22 pure Python source files from 0.15.100 |
| `build.ps1` (optional) | Create: script to download, patch, and zip the vendor files |

## Open Questions

- Does IronPython 3.4.2 fully support `collections.abc`? (Python 3.3+ feature, should work)
- Does `io.StringIO` work correctly in IronPython 3.4.2? (should work, but verify)
- Are there any `os.path` or filesystem-dependent codepaths in ruamel.yaml that would fail in a virtual filesystem? (need to audit `reader.py` and `main.py`)
- Does `ruamel.yaml.util` import anything problematic?
- Should we pre-patch files and commit them, or patch at build/zip time?

---

**Status**: Rule 0 - Discovery (awaiting approval to proceed to Rule 1)
