function Get-ADSIServerPintQueues
{
<#
.SYNOPSIS
	Function to retrieve all the PrintQueues published in Active Directory for a specific server.

.DESCRIPTION
	Function to retrieve all the PrintQueues published in Active Directory for a specific server.
	You can use shortServerName OR longServerName

.PARAMETER  shortServerName
	Specify the short name of a server
	
.PARAMETER  longServerName
	Specify the long name of a server (with domain name)

.PARAMETER Credential
    Specify the Credential to use

.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.EXAMPLE
	Get-ADSIServerPintQueues -shortServerName TestServer01

.EXAMPLE
	Get-ADSIServerPintQueues -longServerName TestServer01.MyDomain

.NOTES
	Christophe Kumor

	github.com/lazywinadmin/AdsiPS
#>
	
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "shortServerName")]
		[Alias("Name")]
		[String]$shortServerName,
		
		[Parameter(ParameterSetName = "longServerName")]
		[String]$longServerName,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain", "DomainDN", "SearchRoot", "SearchBase")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDistinguishedName
			
			IF ($PSBoundParameters['shortServerName'])
			{
				$Search.filter = "(&(objectClass=printQueue)(shortServerName=$shortServerName))"
			}
			IF ($PSBoundParameters['DistinguishedName'])
			{
				$Search.filter = "(&(objectClass=printQueue)(serverName=$longServerName))"
			}
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
				Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			
			foreach ($Object in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"printerName" = $Object.properties.printername -as [string]
				}
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			}
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIPrintQueue End."
	}
}