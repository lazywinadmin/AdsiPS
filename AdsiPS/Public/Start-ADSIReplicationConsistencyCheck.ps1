function Start-ADSIReplicationConsistencyCheck
{
	<#  
.SYNOPSIS  
    Start-ADSIReplicationConsistencyCheck starts the knowledge consistency checker on a given DC.

.DESCRIPTION  

      Start-ADSIReplicationConsistencyCheck connects to an Active Directory Domain Controller and starts the KCC to verify if the replication
      topology needs to be optimized.
      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Start-ADSIReplicationConsistencyCheck -ComputerName dc1.ad.local

      Connects to remote domain controller dc1.ad.local using current credentials and starts a KCC check.


.NOTES  
    Filename    : Start-ADSIReplicationConsistencyCheck.ps1
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
		$dc.CheckReplicationConsistency()
		Write-Verbose -Message "KCC Check started on $($dc.name)"
	}
}