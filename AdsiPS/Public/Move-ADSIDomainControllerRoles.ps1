function Move-ADSIDomainControllerRoles
{
	<#  
.SYNOPSIS  
    Move-ADSIDomainControllerRoles transfers or seizes Active Directory roles to the current DC.

.DESCRIPTION  

    Move-ADSIDomainControllerRoles transfers or seizes Active Directory roles to the current DC.
    By default the cmdlet transfers the role, using the -Force parameter makes it seize the role
      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Roles

    Names of the roles to transfer or seize.
    Can be one or more of the following values:
        
        InfrastructureRole, PDCRole, RidRole, NamingRole, SchemaRole

.PARAMETER Force

    Forces the roles to be seized 

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Move-ADSIDomainControllerRoles -ComputerName dc1.ad.local -Roles "PDCRole"

      Connects to remote domain controller dc1.ad.local using current credentials and
      attempts to transfer the PDCrole to dc1.ad.local.


.EXAMPLE

    Move-ADSIDomainControllerRoles  -ComputerName DC1 -Credential $cred -Verbose -Roles InfrastructureRole,PDCRole,RidRole,NamingRole,SchemaRole -Force

    Connects to remote domain controller dc1.ad.local using alternate credentials and seizes all the roles.


.NOTES  
    Filename    : Move-ADSIDomainControllerRoles.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]
		$Credential = $null,
		
		[Parameter(Mandatory = $true)]
		[ValidateSet("PdcRole", "SchemaRole", "NamingRole", "RidRole", "InfrastructureRole")]
		[String[]]$Roles = $null,
		
		[Switch]$Force
	)
	
	if ($ComputerName)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName
		}
	}
	
	if ($context)
	{
		Write-Verbose -Message "Connecting to $ComputerName"
		$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
	}
	
	if ($dc)
	{
		if ($Force.IsPresent)
		{
			ForEach ($role in $Roles)
			{
				Write-Verbose -Message "Forcing a role transfer of role $role to $($dc.name)"
				$dc.SeizeRoleOwnership([System.DirectoryServices.ActiveDirectory.ActiveDirectoryRole]$role)
			}
		}
		else
		{
			ForEach ($role in $Roles)
			{
				Write-Verbose -Message "Transferring role $role to $($dc.name)"
				$dc.TransferRoleOwnership([System.DirectoryServices.ActiveDirectory.ActiveDirectoryRole]$role)
			}
		}
	}
}