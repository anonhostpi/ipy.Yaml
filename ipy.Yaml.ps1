#Requires -Version 7.0
# ipy.Yaml.ps1 -- loads ruamel.yaml 0.16.13 from PyPI into an IronPythonEmbedded engine
$WheelUrl = 'https://files.pythonhosted.org/packages/ed/c3/4c823dac2949a6baf36a4987d04c50d30184147393ba6f4bfb4c67d15a13/ruamel.yaml-0.16.13-py2.py3-none-any.whl'
$namespaceShim = @'
# Namespace package shim for IronPython in-memory imports.
# The IronPythonEmbedded meta_path importer resolves ruamel.yaml directly;
# pkgutil.extend_path is not needed and would fail in a virtual filesystem.
'@
$patchedInit = '' # WIP
$patchedCompat = '' # WIP
function Add-IpyYaml {
    param([Parameter(Mandatory)] $Engine)
    # WIP
}
