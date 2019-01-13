function Enable-ADSIDomainControllerGlobalCatalog
{
<#
.SYNOPSIS
    Function to enable the Global Catalog role on a Domain Controller

.DESCRIPTION
    Function to enable the Global Catalog role on a Domain Controller

.PARAMETER ComputerName
    Specifies the Domain Controller

.PARAMETER Credential
    Specifies alternate credentials to use. Use Get-Credential to create proper credentials.

.EXAMPLE
    Enable-ADSIDomainControllerGlobalCatalog -ComputerName dc1.ad.local

    Connects to remote domain controller dc1.ad.local using current credentials and enable the GC role.

.EXAMPLE
    Enable-ADSIDomainControllerGlobalCatalog -ComputerName dc2.ad.local -Credential (Get-Credential SuperAdmin)

    Connects to remote domain controller dc2.ad.local using SuperAdmin credentials and enable the GC role.

.NOTES
    https://github.com/lazywinadmin/ADSIPS

    Version History
        1.0 Initial Version (Micky Balladelli)
        1.1 Update (Francois-Xavier Cat)
                Rename from Enable-ADSIReplicaGC to Enable-ADSIDomainControllerGlobalCatalog
                Add New-ADSIDirectoryContext to take care of the Context
                Other minor modifications

#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    process
    {
        try
        {
            $Context = New-ADSIDirectoryContext -ContextType 'DirectoryServer' @PSBoundParameters
            $DomainController = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)

            if ($DomainController.IsGlobalCatalog())
            {
                Write-Verbose -Message "[Enable-ADSIDomainControllerGlobalCatalog][PROCESS] $($DomainController.name) is already a Global Catalog"
            }
            else
            {
                Write-Verbose -Message "[Enable-ADSIDomainControllerGlobalCatalog][PROCESS] $($DomainController.name) Enabling Global Catalog ..."
                $DomainController.EnableGlobalCatalog()
            }

            Write-Verbose -Message "[Enable-ADSIDomainControllerGlobalCatalog][PROCESS] $($DomainController.name) Done."
        }
        catch
        {
            Write-Error -Message "[Enable-ADSIDomainControllerGlobalCatalog][PROCESS] Something wrong happened"
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}