#Requires -Version 7.0
$builder = iwr 'https://raw.githubusercontent.com/anonhostpi/IronPythonEmbedded/main/IronPythonEmbedded.ps1' | iex
$engine = $builder.Build()
. "$PSScriptRoot/ipy.Yaml.ps1"
Add-IpyYaml -Engine $engine
# Test 1: Basic import
$engine.Execute("import ruamel.yaml; print('import OK:', ruamel.yaml.__version__)")
# Test 2: Round-trip comment preservation
$yaml_rt = @'
import ruamel.yaml, io
src = "key: value  # inline comment\n"
y = ruamel.yaml.YAML()
data = y.load(src)
buf = io.StringIO()
y.dump(data, buf)
out = buf.getvalue()
assert '# inline comment' in out, 'Comment lost: ' + out
print('round-trip OK')
'@
$engine.Execute($yaml_rt)
# Test 3: C-extension absence
$engine.Execute(@'
import ruamel.yaml
assert ruamel.yaml.__with_libyaml__ == False, 'Expected no libyaml'
print('no-cyaml OK')
'@)
Write-Host 'All tests passed.'
