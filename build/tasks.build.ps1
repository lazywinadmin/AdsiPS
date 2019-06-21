
task -Name nothing {
    "foo"
}

task -Name setEnvironment {
    # Run test build
    # Read the current environment, populate env vars
    Set-BuildEnvironment -Path $rootpath

    # Read back the env vars
    Get-Item ENV:* | Sort-Object -property Name
}

task -Name build {
    Write-Verbose -Message "Task: Build"
    # Retrieve public functions
    $publicFiles = @(Get-ChildItem -Path $srcPath\public\*.ps1 -ErrorAction SilentlyContinue)
    # Retrieve private functions
    $privateFiles = @(Get-ChildItem -Path $srcPath\private\*.ps1 -ErrorAction SilentlyContinue)

    # Create build output directory if does not exist yet
    if(-not (Test-Path -path $modulePath))
    {
        New-Item -Path $modulePath -ItemType Directory
    }

    # Build PSM1 file with all the functions
    foreach($file in @($publicFiles + $privateFiles))
    {
        Get-Content -Path $($file.fullname) |
            Out-File -FilePath "$modulePath\$moduleName.psm1" -Append -Encoding utf8
    }
    
    # Append existing PSM1 content from source
    if(Test-Path -Path "$srcPath\source.psm1")
    {
        get-content -path "$srcPath\source.psm1"| Out-File -FilePath "$modulePath\$moduleName.psm1" -Append -Encoding utf8
    }

    # Copy the Manifest to the build (psd1)
    Copy-Item -Path "$srcPath\source.psd1" -Destination $modulePath
    Rename-Item -Path "$modulePath\source.psd1" -NewName "$moduleName.psd1" -PassThru

    # Find next module version (BuildHelpers module)
    Write-Verbose -Message "Find next module version (BuildHelpers module)"
    $moduleVersion = Get-NextNugetPackageVersion -Name $moduleName

    $moduleManifestData = @{
        Author = $author
        Description = $Description
        Copyright = "(c) $((Get-Date).year) $author. All rights reserved."
        Path = "$modulepath\$moduleName.psd1"
        FunctionsToExport = $publicFiles.basename
        Rootmodule = "$moduleName.psm1"
        ModuleVersion = $moduleVersion
        ProjectUri = $projectUri
        CompanyName = $CompanyName
        LicenseUri = $licenseUri
        Tags = $tags
    }
    Update-ModuleManifest @moduleManifestData
    Import-Module -Name $modulePath -RequiredVersion $moduleVersion
}

task -Name clean {
    # Output folder
    Remove-Item -confirm:$false -Recurse -path $buildOutputPath -ErrorAction SilentlyContinue
    #Remove-Item -confirm:$false -Recurse -path $dependenciesPath -ErrorAction SilentlyContinue
    dir env:bh*|remove-item
    dir env:modulename|remove-item
    dir env:modulepath|remove-item
}

task -Name deploy {
    Invoke-PSDeploy -Path "$buildPath\.psdeploy.ps1" -Force
}

task -Name test {
    # Run test build
    #Invoke-Pester -Path $TestPath -OutputFormat NUnitXml -OutputFile "$buildOutputPath\$testResult" -PassThru
    Invoke-Pester -Script @{ Path =  $TestPath; Parameters = @{moduleName = $moduleName; modulePath = $modulePath} } -OutputFormat NUnitXml -OutputFile "$buildOutputPath\$testResult" -PassThru
}