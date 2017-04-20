#---------------------------------# 
# Header                          # 
#---------------------------------# 
Write-Host 'Running AppVeyor build script' -ForegroundColor Yellow
Write-Host "ModuleName    : $env:ModuleName"
Write-Host "Build version : $env:APPVEYOR_BUILD_VERSION"
Write-Host "Author        : $env:APPVEYOR_REPO_COMMIT_AUTHOR"
Write-Host "Branch        : $env:APPVEYOR_REPO_BRANCH"

#---------------------------------# 
# BuildScript                     # 
#---------------------------------# 
Write-Host 'Nothing to build, skipping.....'
# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Install-Module Psake, PSDeploy, Pester, BuildHelpers -force -verbose
Import-Module Psake, BuildHelpers -verbose

Write-Host 'Set Build Environment'
Set-BuildEnvironment

#Invoke-psake .\psake.ps1
#exit ( [int]( -not $psake.build_success ) )

Write-host "Get BuildVariables" -ForegroundColor Yellow
Get-BuildVariables 

Write-host "Get-ProjectName" -ForegroundColor Yellow
Get-ProjectName

Write-host "ENV:" -ForegroundColor Yellow
gci env: