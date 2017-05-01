function Get-ADSIPrintQueue
{
<#
.SYNOPSIS
	Function to retrieve PrintQueue in Active Directory from PrinterQueue name or server name

.DESCRIPTION
	Function to retrieve PrintQueue in Active Directory from PrinterQueue name or server name

.PARAMETER  PrinterQueueName
	Specify the PrinterQueue, you can use * as wildcard

.PARAMETER  ServerName
	Specify the ServerName to use

.PARAMETER  DomainName
	Specify the Domain to use
	
.PARAMETER Credential
    Specify the Credential to use

.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output (1 to 1000)
	Use NoResultLimit for more than 1000 objects

.PARAMETER NoResultLimit
    Remove the SizeLimit of 1000
	Warning : can take time! depend number of queues on your domain
	NoResultLimit parameter override SizeLimit parameter

.EXAMPLE
	Get-ADSIPrintQueue 
	
	Get all published printQueue on your current domain (default function SizeLimit return 100 objects Max)

.EXAMPLE
	Get-ADSIPrintQueue -SizeLimit 200
	
	Get 200 published printQueue on your current domain 

.EXAMPLE
	Get-ADSIPrintQueue -NoResultLimit
	
	Get all published printQueue on your current domain 
	Warning : can take time! depend number of queues on your domain

.EXAMPLE
	Get-ADSIPrintQueue -PrinterQueueName MyPrinterQueue

.EXAMPLE
	Get-ADSIPrintQueue -PrinterQueueName *Printer*

.EXAMPLE
	Get-ADSIPrintQueue -ServerName TestServer01
	
	Get all published printQueue for the server TestServer01 (default function SizeLimit return 100 objects Max)

.EXAMPLE
	Get-ADSIPrintQueue -ServerName TestServer01.contoso.com
	
	Get all published printQueue for the server TestServer01.contoso.com (default function SizeLimit return 100 objects Max)

.EXAMPLE
	Get-ADSIPrintQueue -ServerName TestServer01 -SizeLimit 200
	
	Get only 200 published printQueue for the server TestServer01 

.EXAMPLE
	Get-ADSIPrintQueue -ServerName TestServer01 -NoResultLimit

	This example will retrieve all printQueue on TestServer01 without limit of 1000 objects returned.

.EXAMPLE
	Get-ADSIPrintQueue -DomainDistinguishedName 'OU=Mut,DC=CONTOSO,DC=COM'

	This example will retrieve all printQueue located in the 'Mut' OU  (default function SizeLimit return 100 objects Max)

.EXAMPLE
	Get-ADSIPrintQueue -PrinterQueueName MyPrinterQueue -ServerName TestServer01 -DomainDistinguishedName 'OU=Mut,DC=CONTOSO,DC=COM'

	This define the searchbase to the 'Mut' OU and filter on server and printQueue

.EXAMPLE
	Get-ADSIPrintQueue -ServerName TestServer01 -DomainName contoso2.com -NoResultLimit
	
	You will get all the printQueue from TestServer01 on contoso2.com domain

.NOTES
	Christophe Kumor

	github.com/lazywinadmin/AdsiPS
#>
	
	[CmdletBinding()]
	PARAM (
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		
		[Alias("PrinterQueue")]
		[String]$PrinterQueueName,
		
		[Alias("Server")]
		[String]$ServerName,

		[Alias("Domain")]
		[String]$DomainName,
		
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

	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SearchRoot = $DomainDistinguishedName
			$Search.filter = "(&(objectClass=printQueue))"
			
			IF ($PSBoundParameters['ServerName'])
			{			
				$Search.filter = "(&(objectClass=printQueue)(|(serverName=$ServerName)(shortServerName=$ServerName)))"
			}
		 	ELSEIF ($PSBoundParameters['PrinterQueue']) 
			{
				$Search.filter = "(&(objectClass=printQueue)(printerName=$PrinterQueueName))"
			}
		 	ELSE
		  	{
				$Search.filter = "(objectClass=printQueue)"
			}
			
			IF ($PSBoundParameters['DomainName'])
			{
				$DomainDistinguishedName = "LDAP://DC=$($DomainName.replace(".", ",DC="))"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			ELSEIF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") 
				{ 
					$DomainDistinguishedName = "LDAP://$DomainDistinguishedName" 
				}
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
				$Search.SizeLimit = $SizeLimit
				Write-warning "Result is limited to $SizeLimit entries, specify a specific number on the parameter SizeLimit or use -NoResultLimit switch to remove the limit"
			}
            ELSE
			{

                Write-Verbose -Message "Use NoResultLimit switch, all objects will be returned. no limit"
			    $Search.PageSize = 10000
            }
  			
				
			FOREACH ($Object IN $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
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
					"printStatus" = $Object.properties.printstatus -as [string]

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