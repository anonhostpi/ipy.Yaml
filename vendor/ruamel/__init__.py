# Namespace package shim for IronPython in-memory imports.
# The IronPythonEmbedded meta_path importer resolves ruamel.yaml directly;
# pkgutil.extend_path is not needed and would fail in a virtual filesystem.
