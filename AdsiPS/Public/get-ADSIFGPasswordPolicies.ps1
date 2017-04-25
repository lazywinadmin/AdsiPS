function Get-ADSIFGPassWordPolicy
{
<#
.SYNOPSIS
	This function will query and list Fine-Grained Password Policies in Active Directory

.DESCRIPTION
	This function will query and list Fine-Grained Password Policies in Active Directory

.PARAMETER  PolicyName
	Specify the name of the policy to retreive
	
.PARAMETER Credential
    Specify the Credential to use

.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.EXAMPLE
	Get-ADSIFGPassWordPolicy 
    Retreive all the password policy on the current domain

.EXAMPLE
	Get-ADSIObject -PolicyName Name
    Retreive the password policy nammed 'Name' on the current domain
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
#>
	


    	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "PolicyName")]
		[String]$PolicyName,
			
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


}