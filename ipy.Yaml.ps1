#Requires -Version 7.0
return (nmo {
function Add-IpyYaml {
    param(
        [Parameter(Mandatory)] $Engine,
        [string] $ZipPath = "$PSScriptRoot/dist/ruamel.yaml.zip"
    )
    if (-not (Test-Path $ZipPath)) {
        throw "ruamel.yaml zip not found at '$ZipPath'. Run build.ps1 first."
    }
    $zipBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $ZipPath))
    $Engine.Add('/ipy/lib/site-packages', $zipBytes)
    return $Engine
}
Export-ModuleMember -Function Add-IpyYaml
})
