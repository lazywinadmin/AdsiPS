function Move-ADSIDomainControllerRole
{
<#
.SYNOPSIS
	Function to transfers or Seizes Active Directory roles to the current DC.

.DESCRIPTION
	Function to transfers or Seizes Active Directory roles to the current DC.

.PARAMETER ComputerName
	Specifies the Domain Controller

.PARAMETER Credential
	Specifies alternate credentials to use. Use Get-Credential to create proper credentials.

.PARAMETER Role
	Specifies the Role(s) to transfer to Seize

.PARAMETER Force
	Forces the role(s) to be seized

.EXAMPLE
	Move-ADSIDomainControllerRole -ComputerName dc1.ad.local -Roles "PDCRole"
	
	Connects to remote domain controller dc1.ad.local using current credentials and
	attempts to transfer the PDCrole to dc1.ad.local.

.EXAMPLE
	Move-ADSIDomainControllerRole  -ComputerName DC1 -Credential $cred -Verbose -Roles InfrastructureRole,PDCRole,RidRole,NamingRole,SchemaRole -Force
	
	Connects to remote domain controller dc1.ad.local using alternate credentials and seizes all the roles.

.NOTES
	Version History
	1.0 Initial Version (Micky Balladelli)
	1.1 Update (Francois-Xavier Cat)
		Rename from Move-ADSIDomainControllerRole to Move-ADSIDomainControllerRole
		Add New-ADSIDirectoryContext to take care of the Context
		Other minor modifications
	
	Authors
	Micky Balladelli
	balladelli.com
	micky@balladelli.com
	@mickyballadelli
	
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
#>
	
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$ComputerName,
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Parameter(Mandatory = $true)]
		[System.Directoryservices.ActiveDirectory.ActiveDirectoryRole[]]$Role,
		
		[Switch]$Force
	)
	
	PROCESS
	{
		TRY
		{
			# DirectoryContext Splatting
			$Splatting = $PSBoundParameters.Remove("Force")
			$Splatting = $Splatting.Remove("Role")
			
			# Create the Context
			$Context = New-ADSIDirectoryContext -ContextType 'DirectoryServer' @Splatting
			
			# Get the DomainController
			$DomainController = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($Context)
			
			IF ($PSBoundParameters['Force'])
			{
				ForEach ($RoleObj in $Role)
				{
					Write-Verbose -Message "[Move-ADSIDomainControllerRole][PROCESS] $($DomainController.name) Forcing a role transfer of role $RoleObj"
					$DomainController.SeizeRoleOwnership($RoleObj)
				}
			}
			ELSE
			{
				ForEach ($RoleObj in $Role)
				{
					Write-Verbose -Message "[Move-ADSIDomainControllerRole][PROCESS] $($DomainController.name) Transferring role $RoleObj"
					$DomainController.TransferRoleOwnership($RoleObj)
				}
			}
			Write-Verbose -Message "[Move-ADSIDomainControllerRole][PROCESS] $($DomainController.name)  Done."
		}
		CATCH
		{
			Write-Error -Message "[Enable-ADSIDomainControllerGlobalCatalog][PROCESS] Something wrong happened"
			$Error[0].Exception.Message
		}
	}
}