function Get-ADSIReplicaForestInfo
{
	<#  
.SYNOPSIS  
    Get-ADSIReplicaForestInfo returns information about the connected DC's Forest.

.DESCRIPTION  

      Get-ADSIForestInfo returns information about the connected DC's Forest.

      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Get-ADSIReplicaForestInfo -ComputerName dc1.ad.local

        Name                  : ad.local
        Sites                 : {Default-First-Site-Name}
        Domains               : {ad.local}
        GlobalCatalogs        : {DC1.ad.local, DC2.ad.local}
        ApplicationPartitions : {DC=DomainDnsZones,DC=ad,DC=local, DC=ForestDnsZones,DC=ad,DC=local}
        ForestModeLevel       : 6
        ForestMode            : Windows2012R2Forest
        RootDomain            : ad.local
        Schema                : CN=Schema,CN=Configuration,DC=ad,DC=local
        SchemaRoleOwner       : DC1.ad.local
        NamingRoleOwner       : DC1.ad.local

      Connects to remote domain controller dc1.ad.local using current credentials retrieves forest info.



.NOTES  
    Micky Balladelli
	micky@balladelli.com
	https://balladelli.com
	
	github.com/lazywinadmin/AdsiPS 
#>	
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName,
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
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
		Write-Verbose -Message "Information about forest $($dc.forest.name)"
		$dc.forest
	}
}