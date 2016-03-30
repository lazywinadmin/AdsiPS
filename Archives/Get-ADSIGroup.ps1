function Get-ADSIGroup
{
<#
.SYNOPSIS
	This function will query Active Directory for group information. You can either specify the DisplayName, SamAccountName or DistinguishedName of the group
	
.PARAMETER SamAccountName
	Specify the SamAccountName of the group
	
.PARAMETER Name
	Specify the Name of the group
	
.PARAMETER DistinguishedName
	Specify the DistinguishedName path of the group

.PARAMETER Empty
	This parameter returns all the empty groups
	
.PARAMETER SystemGroups
	This parameter returns all the System Groups
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.PARAMETER SearchScope
	Specify the scope of the search (One, OneLevel, Subtree). Default is Subtree.
	
.EXAMPLE
	Get-ADSIGroup -SamAccountName TestGroup
	
	This will return the information about the TestGroup
	
.EXAMPLE
	Get-ADSIGroup -Name TestGroup

	This will return the information about the TestGroup
.EXAMPLE
	Get-ADSIGroup -Empty
	
	This will find all the empty groups

.EXAMPLE
	Get-ADSIGroup -DistinguishedName "CN=TestGroup,OU=Groups,DC=FX,DC=local"
	
.EXAMPLE
    Get-ADSIGroup -Name TestGroup -Credential (Get-Credential -Credential 'FX\enduser') -SearchScope Subtree
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding(DefaultParameterSetName = "Name")]
	PARAM (
		[Parameter(Mandatory = $true, ParameterSetName = "Name")]
		[String]$Name,
		
		[Parameter(Mandatory = $true, ParameterSetName = "SamAccountName")]
		[String]$SamAccountName,
		
		[Parameter(Mandatory = $true, ParameterSetName = "DistinguishedName")]
		[String]$DistinguishedName,
		
		[Parameter(Mandatory = $true, ParameterSetName = "Empty")]
		[Switch]$Empty,
		
		[Parameter(Mandatory = $true, ParameterSetName = "SystemGroups")]
		[Switch]$SystemGroups,
		
		[ValidateSet("One", "OneLevel", "Subtree")]
		$SearchScope = "SubTree",
		
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
			$Search.SearchScope = $SearchScope
			
			IF ($PSboundParameters['DomainDistinguishedName'])
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
			If ($PSboundParameters['Empty'])
			{
				$Search.filter = "(&(objectClass=group)(!member=*))"
			}
			If ($PSboundParameters['SystemGroups'])
			{
				$Search.filter = "(&(objectCategory=group)(groupType:1.2.840.113556.1.4.803:=1))"
				$Search.SearchScope = 'subtree'
			}
			If ($PSboundParameters['Name'])
			{
				$Search.filter = "(&(objectCategory=group)(name=$Name))"
			}
			IF ($PSboundParameters['SamAccountName'])
			{
				$Search.filter = "(&(objectCategory=group)(samaccountname=$SamAccountName))"
			}
			IF ($PSboundParameters['DistinguishedName'])
			{
				$Search.filter = "(&(objectCategory=group)(distinguishedname=$distinguishedname))"
			}
			IF (-not $PSboundParameters['SizeLimit'])
			{
				Write-Warning -Message "Note: Default Ouput is 100 results. Use the SizeLimit Paremeter to change it. Value 0 will remove the limit"
			}
			
			foreach ($group in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"Name" = $group.properties.name -as [string]
					"SamAccountName" = $group.properties.samaccountname -as [string]
					"Description" = $group.properties.description -as [string]
					"DistinguishedName" = $group.properties.distinguishedname -as [string]
					"ADsPath" = $group.properties.adspath -as [string]
					"ManagedBy" = $group.properties.managedby -as [string]
					"GroupType" = $group.properties.grouptype -as [string]
					"Member" = $group.properties.member
					"ObjectCategory" = $group.properties.objectcategory
					"ObjectClass" = $group.properties.objectclass
					"ObjectGuid" = $group.properties.objectguid
					"ObjectSid" = $group.properties.objectsid
					"WhenCreated" = $group.properties.whencreated
					"WhenChanged" = $group.properties.whenchanged
					"cn" = $group.properties.cn
					"dscorepropagationdata" = $group.properties.dscorepropagationdata
					"instancetype" = $group.properties.instancetype
					"samaccounttype" = $group.properties.samaccounttype
					"usnchanged" = $group.properties.usnchanged
					"usncreated" = $group.properties.usncreated
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
		Write-Verbose -Message "[END] Function Get-ADSIGroup End."
	}
}