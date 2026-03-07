#Requires -Version 7.0
return (nmo {
function Add-IpyYaml {
    param(
        [Parameter(Mandatory)] $Engine,
        [string] $ZipPath = "$PSScriptRoot/dist/ruamel.yaml.zip"
    )
    # WIP
}
Export-ModuleMember -Function Add-IpyYaml
})
