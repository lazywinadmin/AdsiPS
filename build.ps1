<#
.SYNOPSIS
Used to start the build of a PowerShell Module
.DESCRIPTION
This script will install dependencies using PSDepend module and start the build tasks using InvokeBuild module
.NOTES
Change History
-1.0 | 2019/06/17 | Francois-Xavier Cat (lazywinadmin)
    - Initial version
-1.1 | 2019/06/22 | Matt Oestreich (oze4)
    - Added specific error handling/error message in regards to missing dependencies and how to resolve them
    - Specifically, to use the `-InstallDependencies` switch with `build.ps1`
    - Removed redundant `[string[]]$tasks` parameter.. (param appears to be in use, but there was a duplicate, which was commented out, so I just removed it)
    - Added 'tasks' param check so if user wants to build this locally, they don't have to know to supply the 'tasks' param with a value of @('build')
        - TODO: rewrite this using switch params
-1.2 | 2019/06/22 | Francois-Xavier Cat (lazywinadmin)
    - Make build default value of -tasks
    - Move -tasks as first param
    - Remove Error handling around Invoke-Build, this can cause misleading error if it's unrelated to module dependencies
        For example I got an error "Missing dependencies" because it failed on a Pester Test
    - Added Warning message in the global CATCH related to dependencies
#>
[CmdletBinding()]
Param(
    [string[]]$tasks= @('build'),
    [string]$GalleryRepository,
    [pscredential]$GalleryCredential,
    [string]$GalleryProxy,
    [switch]$InstallDependencies
    )
try{
    ################
    # EDIT THIS PART
    $moduleName = "AdsiPS" # get from source control or module ?
    $author = 'Francois-Xavier Cat' # fetch from source or module
    $description = 'PowerShell module to interact with Active Directory using ADSI and the System.DirectoryServices namespace (.NET Framework)' # fetch from module ?
    $companyName = 'lazywinadmin.com' # fetch from module ?
    $projectUri = "https://github.com/lazywinadmin/$moduleName" # get from module of from source control, env var
    $licenseUri = "https://github.com/lazywinadmin/$moduleName/blob/master/LICENSE.md"
    $tags = @('ADSI', 'ActiveDirectory','LDAP','AD','PSEdition_Desktop')
    ################

    #$rootpath = Split-Path -path $PSScriptRoot -parent
    $rootpath = $PSScriptRoot
    $buildOutputPath = "$rootpath\buildoutput"
    $buildPath = "$rootpath\build"
    $srcPath = "$rootpath\src"
    $testPath = "$rootpath\tests"
    $modulePath = "$buildoutputPath\$moduleName"
    $dependenciesPath = "$rootpath\dependencies" # folder to store modules
    $testResult = "Test-Results.xml"

    $env:moduleName = $moduleName
    $env:modulePath = $modulePath

    $requirementsFilePath = "$buildPath\requirements.psd1" # contains dependencies
    $buildTasksFilePath = "$buildPath\tasks.build.ps1" # contains tasks to execute

    if($InstallDependencies)
    {
        # Setup PowerShell Gallery as PSrepository  & Install PSDepend module
        if (-not(Get-PackageProvider -Name NuGet -ForceBootstrap)) {
            $providerBootstrapParams = @{
                Name = 'nuget'
                force = $true
                ForceBootstrap = $true
            }

            if($PSBoundParameters['verbose']) {$providerBootstrapParams.add('verbose',$verbose)}
            if($GalleryProxy) { $providerBootstrapParams.Add('Proxy',$GalleryProxy) }
            $null = Install-PackageProvider @providerBootstrapParams
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }

        if (-not(Get-Module -Listavailable -Name PSDepend)) {
            Write-verbose "BootStrapping PSDepend"
            "Parameter $buildOutputPath"| Write-verbose
            $InstallPSDependParams = @{
                Name = 'PSDepend'
                AllowClobber = $true
                Confirm = $false
                Force = $true
                Scope = 'CurrentUser'
            }
            if($PSBoundParameters['verbose']) { $InstallPSDependParams.add('verbose',$verbose)}
            if ($GalleryRepository) { $InstallPSDependParams.Add('Repository',$GalleryRepository) }
            if ($GalleryProxy)      { $InstallPSDependParams.Add('Proxy',$GalleryProxy) }
            if ($GalleryCredential) { $InstallPSDependParams.Add('ProxyCredential',$GalleryCredential) }
            Install-Module @InstallPSDependParams
        }

        # Install module dependencies with PSDepend
        $PSDependParams = @{
            Force = $true
            Path = $requirementsFilePath
        }
        if($PSBoundParameters['verbose']) { $PSDependParams.add('verbose',$verbose)}
        Invoke-PSDepend @PSDependParams -Target $dependenciesPath
        Write-Verbose -Message "Project Bootstrapped"
    }

    # Start build using InvokeBuild module
    Write-Verbose -Message "Start Build (using InvokeBuild module)"
    Invoke-Build -Result 'Result' -File $buildTasksFilePath -Task $tasks


    # Return error to CI
    if ($Result.Error)
    {
        $Error[-1].ScriptStackTrace | Out-String
        exit 1
    }
    exit 0
}catch{
    Write-Warning -Message "It is possible you are missing dependencies. Please rerun using 'build.ps1 -InstallDependencies' if you do not have the 'PSDepend' module installed!"
    throw $_
}
