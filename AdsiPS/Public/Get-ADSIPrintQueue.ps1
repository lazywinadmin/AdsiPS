function Get-ADSIPrintQueue
{
<#
.SYNOPSIS
	Function to retrieve a PrintQueue in Active Directory

.DESCRIPTION
	Function to retrieve a PrintQueue in Active Directory, you can use * as wildcard

.PARAMETER PrinterQueue
	Specify the printerqueue name.

.PARAMETER ServerName
	Specify the ServerName

.PARAMETER Credential
    Specify the Credential to use

.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.EXAMPLE
	Get-ADSIPrintQueue

	Returns all the printqueue(s) present in the current domain

.EXAMPLE
	Get-ADSIPrintQueue -printerName *MyPrinter*

	Returns the printqueue(s) present in the current domain with the specified name
	
.NOTES
	Christophe Kumor

	github.com/lazywinadmin/AdsiPS
#>
	
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "PrinterQueue")]
		[String]$PrinterQueue,

		[Parameter(ParameterSetName = "ServerName")]
		[Alias("Name")]
		[String]$ServerName,

		[Parameter(ParameterSetName = "Domain")]
		[Alias("Domain")]
		[String]$Domain,
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("DomainDN", "SearchRoot", "SearchBase")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100',

		[Switch]$NoResultLimit
	)
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDistinguishedName
			$Search.filter = "(&(objectClass=printQueue))"
			
			IF ($PSBoundParameters['ServerName'])
			{			
				$Search.filter = "(&(objectClass=printQueue)(|(serverName=$ServerName)(shortServerName=$ServerName)))"

				IF($PSBoundParameters['PrinterQueue']){
					$Search.filter = "(&(objectClass=printQueue)(printerName=$PrinterQueue)(|(serverName=$ServerName)(shortServerName=$ServerName)))"
				}
			}
			
			IF ($PSBoundParameters['Domain'])
			{
				$DomainDistinguishedName = "LDAP://DC=$($Domain.replace(".", ",DC="))"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			ELSEIF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") {
					$DomainDistinguishedName = "LDAP://$DomainDistinguishedName"
				}#IF

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
				Write-warning "Result is limited to $SizeLimit entries, specify a specific number on the parameter SizeLimit or use -NoResultLimit switch to remove the limit"
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
					IF ($PSBoundParameters['ServerName'])
			{
				$Properties = @{
					"printerName" = $Object.properties.printername -as [string]
				}	
			 }
			 else {
				$Properties = @{
					"DisplayName" = $Object.properties.displayname -as [string]
					"Name" = $Object.properties.name -as [string]
					"printerName" = $Object.properties.printername -as [string]
					"location" = $Object.properties.location -as [string]
					"Description" = $Object.properties.description -as [string]
					"portName" = $Object.properties.portname -as [string] 
					"driverName"  = $Object.properties.drivername -as [string] 
					"ObjectCategory" = $Object.properties.objectcategory -as [string]
					"ObjectClass" = $Object.properties.objectclass -as [string]
					"DistinguishedName" = $Object.properties.distinguishedname -as [string]
					"WhenCreated" = $Object.properties.whencreated -as [string]
					"WhenChanged" = $Object.properties.whenchanged -as [string]
					"serverName" = $Object.properties.servername -as [string]
					"uNCName" = $Object.properties.uncname -as [string]
					"printShareName" = $Object.properties.printsharename -as [string]


			} 
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