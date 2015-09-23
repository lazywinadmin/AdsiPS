function Get-ADSIReplicaInfo
{
	<#  
.SYNOPSIS  
    Get-ADSIReplicaInfo retrieves Active Directory replication information

.DESCRIPTION  

      Get-ADSIReplicaInfo connects to an Active Directory Domain Controller and retrieves Active Directory replication information
      such as latency of replication and replication status.
      If no switches are used, latency information is returned.
      
.PARAMETER ComputerName
    Defines the remote computer to connect to.
    If ComputerName and Domain are not used, Get-ADSIReplicaInfo will attempt at connecting to the Active Directory using information
    stored in environment variables.

.PARAMETER Domain
    Defines the domain to connect to. If Domain is used, Get-ADSIReplicaInfo will find a domain controller to connect to. 
    This parameter is ignored if ComputerName is used.

.PARAMETER Credential
    Defines alternate credentials to use. Use Get-Credential to create proper credentials.

.PARAMETER NamingContext
    Defines for which naming context replication information is to be displayed: All, Configuration, Schema, Domain. The default is Domain.

.PARAMETER Neighbors
    Displays replication partners for the current Domain Controller.

.PARAMETER Latency
    Organizes replication latency information by groups, such as Hour, Day, Week, Month, TooLong, Other

.PARAMETER Cursors
    Displays replication cursors for the current Domain Controller.

.PARAMETER DisplayDC
    Displays additional information about the currently connected Domain Controller.

.PARAMETER FormatTable
    Formats the output as a auto-sized table and rearranges elements according to relevance.

    Get-ADSIReplicaInfo -Latency -FormatTable

    Hour                         Day Week Month TooLong Other
    ----                         --- ---- ----- ------- -----
    {DC1.ad.local, DC2.ad.local} {}  {}   {}    {}      {}   

.EXAMPLE
      Get-ADSIReplicaInfo 

      Tries to find a domain to connect to and if it succeeds, it will find a domain controller to retrieve replication information.

.EXAMPLE
      Get-ADSIReplicaInfo -ComputerName dc1.ad.local -Credential $Credential

      Connects to remote domain controller dc1.ad.local using alternate credentials.

.EXAMPLE
      Get-ADSIReplicaInfo -Domain ad.local

      Connects to remote domain controller dc1.ad.local using current credentials.

.EXAMPLE
      Get-ADSIReplicaInfo -Domain ad.local

      Connects to remote domain controller dc1.ad.local using current credentials.


.NOTES  
    Filename    : Get-ADSIReplicaInfo.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>
	[CmdletBinding()]
	param ([string]$ComputerName = $null,
		
		[string]$Domain = $null,
		
		[Management.Automation.PSCredential]
		$Credential = $null,
		
		[ValidateSet("Schema", "Configuration", "Domain", "All")]
		[String]$NamingContext = "Domain",
		
		[Switch]$Neighbors,
		
		[Switch]$Latency,
		
		[Switch]$Cursors,
		
		[Switch]$Errors,
		
		[Switch]$DisplayDC,
		
		[Switch]$FormatTable
	)
	
	
	# Try to determine how to connect to the remote DC. 
	# A few possibilities:
	#      A computername was provided
	#      A domain name was provided
	#      None of the above was provided, so try with either USERDNSDOMAIN or LOGONSERVER
	#      Use alternate credentials if provided
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
	elseif ($domain)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "Domain", $domain, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "Domain", $domain
		}
	}
	elseif ($env:USERDNSDOMAIN)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "Domain", $env:USERDNSDOMAIN, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "Domain", $env:USERDNSDOMAIN
		}
	}
	elseif ($env:LOGONSERVER -ne '\\MicrosoftAccount')
	{
		$logonserver = $env:LOGONSERVER.replace('\\', '')
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $logonserver, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $logonserver
		}
	}
	else
	{
		Write-Error -Message "Could not determine where to connect to"
		return
	}
	
	# If none of switches are present, default to at least one, so we have something to show
	if (!$Latency.IsPresent -and !$Neighbors.IsPresent -and !$Errors.IsPresent -and !$Cursors.IsPresent)
	{
		[switch]$Latency = $true
	}
	
	# Determine which DC to use depending on the context type. 
	# If the context is Directory Server, simply get the provided domain controller,
	# if the context is a domain, then find a DC.
	switch ($context.ContextType)
	{
		"DirectoryServer"{ $dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context) }
		"Domain" { $dc = [System.DirectoryServices.ActiveDirectory.DomainController]::FindOne($context) }
		default { return }
	}
	
	if ($dc)
	{
		if ($DisplayDC.IsPresent)
		{
			Write-Verbose -Message "Information about $($dc.Name)"
			$dc
		}
		$domainDN = ""
		$obj = $domain.Replace(',', '\,').Split('/')
		$obj[0].split(".") | ForEach-Object { $domainDN += ",DC=" + $_ }
		$domainDN = $domainDN.Substring(1)
		
		if ($Cursors.IsPresent)
		{
			foreach ($partition in $dc.Partitions)
			{
				if ($NamingContext -eq "All" -or
				($NamingContext -eq "Domain" -and $partition -eq $domainDN) -or
				($NamingContext -eq "Schema" -and $partition.Contains("Schema")) -or
				($NamingContext -eq "Configuration" -and $partition.split(",")[0].Contains("Configuration"))
				)
				{
					Write-Verbose -Message "Replication cursors for partition $partition on $($dc.Name)"
					
					$dc.GetReplicationCursors($partition) | ForEach-Object { $_ }
					
				}
			}
		}
		if ($Latency.IsPresent)
		{
			foreach ($partition in $dc.Partitions)
			{
				if ($NamingContext -eq "All" -or
				($NamingContext -eq "Domain" -and $partition -eq $domainDN) -or
				($NamingContext -eq "Schema" -and $partition.Contains("Schema")) -or
				($NamingContext -eq "Configuration" -and $partition.split(",")[0].Contains("Configuration"))
				)
				{
					Write-Verbose -Message "Replication latency for partition $partition on $($dc.Name)"
					
					$cursorsArray = $dc.GetReplicationCursors($partition)
					$sortedCursors = $cursorsArray | Sort-Object -Descending -Property LastSuccessfulSyncTime
					
					$hour = @()
					$day = @()
					$week = @()
					$month = @()
					$tooLong = @()
					$other = @()
					
					foreach ($cursor in $sortedCursors)
					{
						$timespan = New-TimeSpan -Start $cursor.LastSuccessfulSyncTime -End $(Get-Date)
						
						if ($timespan)
						{
							if ($timespan.Days -eq 0 -and $timespan.Hours -eq 0)
							{
								$hour += $cursor.SourceServer
							}
							elseif ($timespan.Days -eq 0 -and $timespan.Hours -ge 1)
							{
								$day += $cursor.SourceServer
							}
							elseif ($timespan.Days -lt 7)
							{
								$week += $cursor.SourceServer
							}
							elseif ($timespan.Days -le 30 -and $timespan.Days -gt 7)
							{
								$month += $cursor.SourceServer
							}
							else
							{
								$tooLong += $cursor.SourceServer
							}
						}
						else
						{
							# no timestamp we might have a Windows 2000 server here
							$other += $cursor.SourceServer
						}
					}
					
					$latencyObject = New-Object -TypeName PsCustomObject -Property @{
						Hour = $hour;
						Day = $day;
						Week = $week;
						Month = $month;
						TooLong = $tooLong;
						Other = $other
					}
					if ($FormatTable.IsPresent)
					{
						$latencyObject | Select-Object -Property Hour, Day, Week, Month, TooLong, Other | Format-Table -AutoSize
					}
					else
					{
						$latencyObject
					}
				}
			}
		}
		
		if ($Neighbors.IsPresent -or $Errors.IsPresent)
		{
			$replicationNeighbors = $dc.GetAllReplicationNeighbors()
			
			foreach ($neighbor in $replicationNeighbors)
			{
				if ($NamingContext -eq "All" -or
				($NamingContext -eq "Domain" -and $neighbor.PartitionName -eq $domainDN) -or
				($NamingContext -eq "Schema" -and $neighbor.PartitionName.Contains("Schema")) -or
				($NamingContext -eq "Configuration" -and $neighbor.PartitionName.split(",")[0].Contains("Configuration"))
				)
				{
					Write-Verbose -Message "Replication neighbors for partition $($neighbor.PartitionName) on $($dc.Name)"
					
					if (($Errors.IsPresent -and $neighbor.LastSyncResult -ne 0) -or $Neighbors.IsPresent)
					{
						if ($FormatTable.IsPresent)
						{
							$neighbor | Select-Object SourceServer, LastSyncMessage, LastAttemptedSync, LastSuccessfulSync, PartitionName | Format-Table -AutoSize
						}
						else
						{
							$neighbor
						}
					}
				}
			}
		}
	}
}