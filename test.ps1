#Requires -Version 7.0
$builder = iwr 'https://raw.githubusercontent.com/anonhostpi/IronPythonEmbedded/main/IronPythonEmbedded.ps1' | iex
$engine = $builder.Build()
$yaml = . "$PSScriptRoot/ipy.Yaml.ps1"
$yaml.'Add-IpyYaml'($engine)
# Test 1: Basic import
# WIP
# Test 2: Round-trip with comment preservation
# WIP
# Test 3: C-extension absence handled gracefully
# WIP
