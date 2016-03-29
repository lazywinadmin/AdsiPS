function Get-ADSIReplicaDomainInfo
{
	<#  
.SYNOPSIS  
    Get-ADSIReplicaDomainInfo returns information about the connected DC's Domain.

.DESCRIPTION  

      Get-ADSIReplicaDomainInfo returns information about the connected DC's Domain.

      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.

.PARAMETER Recurse

    Recursively retrieves information about child domains

.EXAMPLE

    Get-ADSIReplicaDomainInfo -ComputerName dc1.ad.local

        Forest                  : ad.local
        DomainControllers       : {DC1.ad.local, DC2.ad.local}
        Children                : {}
        DomainMode              : Windows2012R2Domain
        DomainModeLevel         : 6
        Parent                  : 
        PdcRoleOwner            : DC1.ad.local
        RidRoleOwner            : DC1.ad.local
        InfrastructureRoleOwner : DC1.ad.local
        Name                    : ad.local

      Connects to remote domain controller dc1.ad.local using current credentials retrieves domain info.


.NOTES  
    Filename    : Get-ADSIReplicaDomainInfo.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>	
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]
		$Credential = $null,
		
		[Switch]$Recurse
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
		$dc.domain
		if ($Recurse.IsPresent)
		{
			$dc.domain.children | ForEach-Object { $_ }
		}
		
	}
}