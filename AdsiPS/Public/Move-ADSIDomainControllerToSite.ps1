function Move-ADSIDomainControllerToSite
{
<#
.SYNOPSIS
	Move-ADSIDomainControllerToSite moves the current DC to another site.

.DESCRIPTION
	Move-ADSIDomainControllerToSite moves the current DC to another site.
	
	MSDN Documention on 'DirectoryServer.MoveToAnotherSite Method'
	https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.directoryserver.movetoanothersite(v=vs.110).aspx

.PARAMETER ComputerName
	Specifies the Domain Controller

.PARAMETER Credential
	Specifies alternate credentials to use. Use Get-Credential to create proper credentials.

.PARAMETER Site
	Name of the Active Directory site

.EXAMPLE
	Move-ADSIDomainControllerToSite -ComputerName dc1.ad.local -site "Paris"
	
	Connects to remote domain controller dc1.ad.local using current credentials and
	moves it to the site "Paris".

.NOTES
	Micky Balladelli
	balladelli.com
	micky@balladelli.com
	@mickyballadelli
	
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS

	Version History
		1.0 Initial Version (Micky Balladelli)
		1.1 Update (Francois-Xavier Cat)
				Rename from Move-ADSIReplicaToSite to Move-ADSIDomainControllerToSite
				Add New-ADSIDirectoryContext to take care of the Context
				Other minor modifications	
#>
	
	[CmdletBinding()]
	PARAM
	(
		[Parameter(Mandatory)]
		[string]$ComputerName,
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Parameter(Mandatory = $true)]
		[string]$Site
	)
	PROCESS
	{
		TRY
		{
			# DirectoryContext Splatting
			$Splatting = $PSBoundParameters.Remove("Site")
			# Create the Context
			$Context = New-ADSIDirectoryContext -ContextType 'DirectoryServer' @Splatting
			
			$DomainController = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
			
			Write-Verbose -Message "[Move-ADSIDomainControllerToSite][PROCESS] $($DomainController.name) to site $Site"
			$DomainController.MoveToAnotherSite($Site)
		}
		CATCH
		{
			Write-Error -Message "[Move-ADSIDomainControllerToSite][PROCESS] Something wrong happened"
			$Error[0].Exception.Message
		}
	}
}
