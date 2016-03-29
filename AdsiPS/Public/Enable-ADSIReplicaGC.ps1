function Enable-ADSIReplicaGC
{
<#  
.SYNOPSIS  
    Enable-ADSIReplicaGC enables the GC role on the current DC.

.DESCRIPTION  

      Enable-ADSIReplicaGC enables the GC role on the current DC.
      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Enable-ADSIReplicaGC -ComputerName dc1.ad.local

      Connects to remote domain controller dc1.ad.local using current credentials and enable the GC role.


.NOTES  
    Filename    : Enable-ADSIReplicaGC.ps1
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
		$IsGC = $dc.IsGlobalCatalog()
		if ($IsGC)
		{
			Write-Verbose -Message "$($dc.name) is already a Global Catalog"
		}
		else
		{
			Write-Verbose -Message "Enable the GC role on $($dc.name)"
			$dc.EnableGlobalCatalog()
		}
	}
}