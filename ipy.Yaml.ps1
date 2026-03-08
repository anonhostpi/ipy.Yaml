#Requires -Version 7.0
# ipy.Yaml.ps1 -- loads ruamel.yaml 0.16.13 from PyPI into an IronPythonEmbedded engine
$WheelUrl = 'https://files.pythonhosted.org/packages/ed/c3/4c823dac2949a6baf36a4987d04c50d30184147393ba6f4bfb4c67d15a13/ruamel.yaml-0.16.13-py2.py3-none-any.whl'
$namespaceShim = @'
# Namespace package shim for IronPython in-memory imports.
# The IronPythonEmbedded meta_path importer resolves ruamel.yaml directly;
# pkgutil.extend_path is not needed and would fail in a virtual filesystem.
'@
$patchedInit = @'
# coding: utf-8
# ruamel.yaml 0.16.13 __init__.py -- patched for IronPython 3.4.2
# Removed: _package_data (metadata only)
# Removed: cyaml import (C extension, unused in round-trip mode)

from __future__ import print_function, absolute_import, division, unicode_literals

version_info = (0, 16, 13)
__version__ = '0.16.13'
__with_libyaml__ = False

from ruamel.yaml.main import *  # NOQA
'@
$patchedCompat = '' # WIP
function Add-IpyYaml {
    param([Parameter(Mandatory)] $Engine)
    # WIP
}
