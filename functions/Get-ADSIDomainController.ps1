function Get-ADSIDomainController
{
<#
.SYNOPSIS
	This function will query Active Directory for all Domain Controllers.
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding()]
	PARAM (
		[Parameter()]
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
			$Search.Filter = "(&(objectClass=computer)(userAccountControl:1.2.840.113556.1.4.803:=8192))"
			
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
			
			
			
			foreach ($DC in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$DC.properties
				
                <#
                accountexpires
adspath
cn
codepage
countrycode
distinguishedname
dnshostname
dscorepropagationdata
instancetype
iscriticalsystemobject
lastlogontimestamp
localpolicyflags
msdfsr-computerreferencebl
msds-supportedencryptiontypes
name
objectcategory
objectclass
objectguid
objectsid
operatingsystem
operatingsystemversion
primarygroupid
pwdlastset
ridsetreferences
samaccountname
samaccounttype
serverreferencebl
serviceprincipalname
useraccountcontrol
usnchanged
usncreated
whenchanged
whencreated
                
                #>
				
				
				
				# Output the info
				#New-Object -TypeName PSObject -Property $Properties
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