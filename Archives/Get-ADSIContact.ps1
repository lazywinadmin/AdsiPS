function Get-ADSIContact
{
<#
.SYNOPSIS
	This function will query Active Directory for Contact objects.

.PARAMETER Name
	Specify the Name of the contact

.PARAMETER SamAccountName
	Specify the SamAccountName of the contact

.PARAMETER All
	Default Parameter. This will list all the contact(s) in the Domain
	
.PARAMETER DistinguishedName
	Specify the DistinguishedName path of the OU
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.
	
.EXAMPLE
	Get-ADSIOrganizationalUnit

    This returns all the OU in the Domain (Result Size is 100 per default)

.EXAMPLE
	Get-ADSIContact -name FX

    This returns the contact with the name FX

.EXAMPLE
	Get-ADSIOrganizationalUnit -SamAccountName FX*

    This returns the Contacts where the SamAccountName starts by FX

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding(DefaultParameterSetName = "All")]
	PARAM (
		[Parameter(ParameterSetName = "Name")]
		[String]$Name,
		
		[Parameter(ParameterSetName = "SamAccountName")]
		$SamAccountName,
		
		[Parameter(ParameterSetName = "DistinguishedName")]
		[String]$DistinguishedName,
		
		[Parameter(ParameterSetName = "All")]
		[String]$All,
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain", "DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
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
			
			
			If ($Name)
			{
				Write-Verbose -Message "[PROCESS] Name Parameter"
				$Search.filter = "(&(objectCategory=contact)(name=$Name))"
			}
			If ($SamAccountName)
			{
				Write-Verbose -Message "[PROCESS] SamAccounName Parameter"
				$Search.filter = "(&(objectCategory=contact)(samaccountname=$SamAccountName))"
			}
			IF ($DistinguishedName)
			{
				Write-Verbose -Message "[PROCESS] DistinguishedName Parameter"
				$Search.filter = "(&(objectCategory=contact)(distinguishedname=$distinguishedname))"
			}
			IF ($All)
			{
				Write-Verbose -Message "[PROCESS] All Parameter"
				$Search.filter = "(&(objectCategory=contact))"
			}
			IF ($DomainDistinguishedName)
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose -Message "[PROCESS] Different Credential specified: $($credential.username)"
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			If (-not $PSBoundParameters["SizeLimit"])
			{
				Write-Warning -Message "Default SizeLimit: 100 Results"
			}
			
			foreach ($contact in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"Name" = $contact.properties.name -as [string]
					"DistinguishedName" = $contact.properties.distinguishedname -as [string]
					"ADsPath" = $contact.properties.adspath -as [string]
					"ObjectCategory" = $contact.properties.objectcategory -as [string]
					"ObjectClass" = $contact.properties.objectclass -as [string]
					"ObjectGuid" = $contact.properties.objectguid
					"WhenCreated" = $contact.properties.whencreated -as [string] -as [datetime]
					"WhenChanged" = $contact.properties.whenchanged -as [string] -as [datetime]
					"usncreated" = $contact.properties.usncreated -as [string]
					"usnchanged" = $contact.properties.usnchanged -as [string]
					"dscorepropagationdata" = $contact.properties.dscorepropagationdata
					"instancetype" = $contact.properties.instancetype -as [string]
					"CountryCode" = $contact.properties.countrycode -as [string]
					"PrimaryGroupID" = $contact.properties.primarygroupid -as [string]
					"AdminCount" = $contact.properties.admincount
					"SamAccountName" = $contact.properties.samaccountname -as [string]
					"SamAccountType" = $contact.properties.samaccounttype
					"ObjectSid" = $contact.properties.objectsid
					"Displayname" = $contact.properties.displayname -as [string]
					"Accountexpires" = $contact.properties.accountexpires
					"UserPrincipalName" = $contact.properties.userprincipalname -as [string]
					"GivenName" = $contact.properties.givenname
					"CodePage" = $contact.properties.codepage
					"Description" = $contact.properties.description -as [string]
					"Logoncount" = $contact.properties.logoncount
					"PwdLastSet" = $contact.properties.pwdlastset
					"LastLogonTimeStamp" = $contact.properties.lastlogontimestamp
					"UserAccountControl" = $contact.properties.useraccountcontrol
					"cn" = $contact.properties.cn -as [string]
				}
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			}
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIContact End."
	}
}