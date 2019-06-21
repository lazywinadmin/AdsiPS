# Get public and private function definition files.
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
Foreach ($import in @($Public + $Private))
{
    TRY
    {
        . $import.fullname
    }
    CATCH
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Try to add necessary assembly during module import - fixes issue where params rely on types within this assembly
# If this assembly was not loaded prior to running Get-ADSIGroup, for example, you were not able to use that function
# If adding this assembly fails, we still allow the user to import the module, but we show them a helpful warning
TRY 
{
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
} 
CATCH 
{
    Write-Warning "[AdsiPS] Unable to add assembly 'System.DirectoryServices.AccountManagement'.`r`nPlease manually add this assembly into your session or you may encounter issues! `r`n`r`nRun the following command: 'Add-Type -AssemblyName System.DirectoryServices.AccountManagement'"
}

# Export all the functions
Export-ModuleMember -Function $Public.Basename -Alias *
