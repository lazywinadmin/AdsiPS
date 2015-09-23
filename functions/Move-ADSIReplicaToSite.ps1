function Move-ADSIReplicaToSite
{
	<#  
.SYNOPSIS  
    Move-ADSIReplicaToSite moves the current DC to another site.

.DESCRIPTION  

    Move-ADSIReplicaToSite moves the current DC to another site.

      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Site

    Name of the Active Directory site

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Move-ADSIReplicaToSite -ComputerName dc1.ad.local -site "Paris"

      Connects to remote domain controller dc1.ad.local using current credentials and
      moves it to the site "Paris".


.NOTES  
    Filename    : Move-ADSIReplicaToSite.ps1
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
		[string]$Site = $null
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
		Write-Verbose -Message "Moving $($dc.name) to site $Site"
		$dc.MoveToAnotherSite($Site)
	}
}