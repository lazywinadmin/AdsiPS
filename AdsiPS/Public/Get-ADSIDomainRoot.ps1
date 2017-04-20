function Get-ADSIDomainRoot
{
<#
.SYNOPSIS
	Function to retrieve the Domain Root in the Forest

.DESCRIPTION
	Function to retrieve the Domain Root in the Forest

.PARAMETER Credential
	Specifies the alternative credential to use. Default is the current one.

.PARAMETER ForestName
	Specifies the alternative forest name to query. Default is the current one.

.EXAMPLE
	Get-ADSIDomainRoot

	Retrieve the current Domain Root

.EXAMPLE
	Get-ADSIDomainRoot -ForestName ForestTest.lab

	Retrieve the Domain root of ForestTest.lab

.EXAMPLE
	Get-ADSIDomainRoot -ForestName ForestTest.lab -credential (Get-Credential)

	Retrieve the Domain root of ForestTest.lab with the specified credential

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/ADSIPS

.OUTPUTS
	System.DirectoryServices.ActiveDirectory.Domain
.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.domain(v=vs.110).aspx	
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.ActiveDirectory.Domain')]
	param
	(
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
	)
	
	(Get-ADSIForest @PSBoundParameters).RootDomain
}