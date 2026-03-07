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
#region PHASE 2: Apply IronPython patches
# WIP
#endregion
#region PHASE 3: Zip into dist/ruamel.yaml.zip
# WIP
#endregion
