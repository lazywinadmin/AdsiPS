@{
    PSDependOptions = @{
        #Target = '.\dependencies'
        AddToPath = $true
        #DependencyType = 'PSGalleryNuget'
    }
    Pester = @{
        Name = 'Pester'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }
    PSScriptAnalyzer = 'Latest'
    BuildHelpers = 'Latest'
    PSDeploy = 'Latest'
    InvokeBuild = 'Latest'
}