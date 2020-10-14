@{
    PSDependOptions = @{
    #    Target = '.\dependencies'
        AddToPath = $true
    #    DependencyType = 'PSGalleryNuget'
    }
    Pester = '4.10.1'
    <#@{
        Name = 'Pester'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }#>
    PSScriptAnalyzer = 'Latest'
    ScriptAnalyzerRulesLWA = 'Latest'
    BuildHelpers = 'Latest'
    PSDeploy = 'Latest'
    InvokeBuild = 'Latest'
}