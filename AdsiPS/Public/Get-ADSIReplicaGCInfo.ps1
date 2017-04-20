function Get-ADSIReplicaGCInfo
{
	<#  
.SYNOPSIS  
    Get-ADSIReplicaGCInfo finds out if a given DC holds the GC role.

.DESCRIPTION  

      Get-ADSIReplicaGCInfo finds out if a given DC holds the Global Catalog role.
      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Get-ADSIReplicaGCInfo -ComputerName dc1.ad.local

      Connects to remote domain controller dc1.ad.local using current credentials retrieves GC info.


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
		$IsGC = $dc.IsGlobalCatalog()
		if ($IsGC)
		{
			Write-Verbose -Message "$($dc.name) is a Global Catalog"
		}
		else
		{
			Write-Verbose -Message "$($dc.name) is a normal Domain Controller"
		}
		$IsGC
	}
}