# ipy.Yaml

Loads **ruamel.yaml 0.16.13** (pure-Python wheel from PyPI) into an IronPythonEmbedded engine
for use with [IronPythonEmbedded](../IronPythonEmbedded) under IronPython 3.4.2.

## Prerequisites
- PowerShell 7+
- `IronPythonEmbedded.ps1` accessible via `iwr` from GitHub (no build step needed)

## Usage
```powershell
$builder = iwr 'https://raw.githubusercontent.com/anonhostpi/IronPythonEmbedded/main/IronPythonEmbedded.ps1' | iex
$engine = $builder.Build()
. ./ipy.Yaml.ps1
Add-IpyYaml -Engine $engine
$engine.Execute("import ruamel.yaml; print(ruamel.yaml.__version__)")
```

## API

### `Add-IpyYaml`

```powershell
Add-IpyYaml -Engine <IronPythonEngine>
```

Downloads and extracts the ruamel.yaml 0.16.13 wheel from PyPI into the engine's
`/ipy/lib/site-packages` virtual path, then overlays the three IronPython-patched files.
Returns the engine for chaining. No build step or local files required.
