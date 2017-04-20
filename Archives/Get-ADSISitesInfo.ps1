function Get-ADSISitesInfo
{
	<#  
.SYNOPSIS  
    Get-ADSISitesInfo returns information about the connected DC's Sites.

.DESCRIPTION  

      Get-ADSISitesInfo returns information about the Sites as seen by the connected DC.
      It returns information such as subnets, sites, sitelinks, ISTG, BH servers etc.

      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Get-ADSISitesInfo -ComputerName dc1.ad.local

        Name                           : Default-First-Site-Name
        Domains                        : {ad.local}
        Subnets                        : {}
        Servers                        : {DC1.ad.local, DC2.ad.local}
        AdjacentSites                  : {}
        SiteLinks                      : {DEFAULTIPSITELINK}
        InterSiteTopologyGenerator     : DC1.ad.local
        Options                        : None
        Location                       : 
        BridgeheadServers              : {}
        PreferredSmtpBridgeheadServers : {}
        PreferredRpcBridgeheadServers  : {}
        IntraSiteReplicationSchedule   : System.DirectoryServices.ActiveDirectory.ActiveDirectorySchedule

      Connects to remote domain controller dc1.ad.local using current credentials retrieves site information.


.NOTES  
    Filename    : Get-ADSISitesInfo.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>	
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]
		$Credential = $null
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
		$dc.forest.sites | ForEach-Object { $_ }
	}
}