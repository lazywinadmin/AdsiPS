function Get-ADSIReplicaCurrentTime
{
	<#  
.SYNOPSIS  
    Get-ADSIReplicaCurrentTime retrieves the current time of a given DC.

.DESCRIPTION  

    Get-ADSIReplicaCurrentTime retrieves the current time of a given DC. 
    When using the verbose switch, this cmdlet will display the time difference with the current system.
      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Get-ADSIReplicaCurrentTime -ComputerName dc1.ad.local

      Connects to remote domain controller dc1.ad.local using current credentials and retrieves the current time.


.NOTES  
    Filename    : Get-ADSIReplicaGCInfo.ps1
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
		$now = Get-Date
		$minDiff = (New-TimeSpan -start $dc.CurrentTime -end ([System.TimeZoneInfo]::ConvertTimeToUtc($now))).minutes
		Write-Verbose -Message "Difference in minutes between $($dc.name) and current system is $minDiff"
		$dc.CurrentTime
	}
}