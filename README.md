# ipy.Yaml

Vendors **ruamel.yaml 0.15.100** (pure-Python subset) for use with
[IronPythonEmbedded](../IronPythonEmbedded) under IronPython 3.4.2.

## Prerequisites
- PowerShell 7+
- `IronPythonEmbedded.ps1` accessible via `iwr` from GitHub

## Build
```powershell
./build.ps1          # produces dist/ruamel.yaml.zip
```

## Usage
```powershell
$builder = iwr 'https://raw.githubusercontent.com/anonhostpi/IronPythonEmbedded/main/IronPythonEmbedded.ps1' | iex
$engine = $builder.Build()
$yaml = . ./ipy.Yaml.ps1
$yaml.'Add-IpyYaml'($engine)
$engine.Execute("import ruamel.yaml; print(ruamel.yaml.__version__)")
```

## API

### `Add-IpyYaml`

```powershell
Add-IpyYaml -Engine <IronPythonEngine> [-ZipPath <string>]
```

Loads the vendored `ruamel.yaml.zip` into the IronPython engine's
`/ipy/lib/site-packages` virtual path. Returns the engine for chaining.
