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
    Specify the number of item(s) to output Max 1000, but you can specify less 
	Use NoResultLimit for more than 1000 objects

.PARAMETER NoResultLimit
    Remove the SizeLimit of 1000
    SizeLimit is useless, it can't go over the server limit which is 1000 by default
	
.EXAMPLE
	Get-ADSIServerPintQueues -shortServerName TestServer01

.EXAMPLE
	Get-ADSIServerPintQueues -longServerName TestServer01.MyDomain

.EXAMPLE
	Get-ADSIServerPintQueues -shortServerName TestServer01 -NoResultLimit
	
	This example will retrieve all queue on a server without limit of 1000 objects returned.
	
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
		[int]$SizeLimit,

		[Switch]$NoResultLimit
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
			
			IF (-not$PSBoundParameters['NoResultLimit'])
			{
				Write-warning "Result is limited to 1000 entries, specify a specific number on the parameter SizeLimit or 0 to remove the limit"
			}
            else
			{
                # SizeLimit is useless, even if there is a $Searcher.GetUnderlyingSearcher().sizelimit=$SizeLimit
                # the server limit is kept
                $Search.PageSize = 10000
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