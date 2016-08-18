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
	
	.NOTES
		Francois-Xavier Cat
		lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.ActiveDirectory.Domain')]
	param
	(
		[System.Management.Automation.Credential()]
		[Alias('RunAs')]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
	)
	
	(Get-ADSIForest @PSBoundParameters).RootDomain
}