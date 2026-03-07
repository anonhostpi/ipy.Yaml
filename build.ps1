#Requires -Version 7.0
param(
    [string] $OutDir = "$PSScriptRoot/dist",
    [string] $WorkDir = "$PSScriptRoot/.build"
)
#region PHASE 1: Download and extract ruamel.yaml 0.15.100
$tarUrl = 'https://files.pythonhosted.org/packages/source/r/ruamel.yaml/ruamel.yaml-0.15.100.tar.gz'
$tarPath = Join-Path $WorkDir 'ruamel.yaml-0.15.100.tar.gz'
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null
Invoke-WebRequest -Uri $tarUrl -OutFile $tarPath
$extractDir = Join-Path $WorkDir 'src'
tar -xzf $tarPath -C $extractDir
#endregion
#region PHASE 2: Copy and patch
$srcDir  = Join-Path $extractDir 'ruamel.yaml-0.15.100'
$destYaml = Join-Path $WorkDir 'ruamel/yaml'
New-Item -ItemType Directory -Force -Path $destYaml | Out-Null
$includes = @('anchor','comments','compat','composer','constructor','dumper',
    'emitter','error','events','loader','main','nodes','parser','reader',
    'representer','resolver','scalarbool','scalarfloat','scalarint',
    'scalarstring','scanner','serializer','timestamp','tokens','util')
foreach ($f in $includes) { Copy-Item "$srcDir/$f.py" "$destYaml/$f.py" }
Copy-Item "$PSScriptRoot/vendor/ruamel/__init__.py" (Join-Path $WorkDir 'ruamel/__init__.py') -Force
Copy-Item "$PSScriptRoot/vendor/ruamel/yaml/__init__.py" "$destYaml/__init__.py" -Force
Copy-Item "$PSScriptRoot/vendor/ruamel/yaml/compat.py" "$destYaml/compat.py" -Force
#endregion
#region PHASE 3: Zip into dist/ruamel.yaml.zip
# WIP
#endregion
