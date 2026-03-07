# PLAN: ipy.Yaml — vendor ruamel.yaml for IronPython

> Status: planning

## Goal

Vendor ruamel.yaml 0.15.100 (pure Python subset) into this repository so it
can be loaded into an IronPython 3.4.2 engine via IronPythonEmbedded using
in-memory zip extraction — no disk writes, no C extensions.

## Deliverables

| Path | Description |
|------|-------------|
| `vendor/ruamel/__init__.py` | Namespace shim (no-op, replaces pkgutil version) |
| `vendor/ruamel/yaml/__init__.py` | Patched package init |
| `vendor/ruamel/yaml/compat.py` | Patched for IronPython-safe imports |
| `vendor/ruamel/yaml/*.py` | Remaining 22 pure Python source files |
| `dist/ruamel.yaml.zip` | Pre-built zip for `engine.Add()` |
| `ipy.Yaml.ps1` | PowerShell module that loads the zip into an engine |
| `build.ps1` | Reproducible build/patch/zip script |

## Steps

1. Download ruamel.yaml 0.15.100 source from PyPI or commx/ruamel-yaml mirror
2. Copy pure Python files listed in RESEARCH.ipy.Yaml.md (exclude cyaml, tests, docs, ext)
3. Apply patches:
   - `ruamel/__init__.py`: replace with no-op namespace shim
   - `ruamel/yaml/__init__.py`: remove `_package_data`, simplify cyaml fallback
   - `ruamel/yaml/compat.py`: wrap `collections.abc` imports in try/except
4. Build `dist/ruamel.yaml.zip` with correct directory structure
5. Author `ipy.Yaml.ps1` with `Add-IpyYaml` function
6. Smoke-test inside IronPythonEmbedded (import, round-trip, cloud-init)
7. Write `build.ps1` for reproducibility
