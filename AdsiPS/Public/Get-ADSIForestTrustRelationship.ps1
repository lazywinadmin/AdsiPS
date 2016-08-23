function Get-ADSIForestTrustRelationship
{
<#
.SYNOPSIS
	Function to retrieve the Forest Trust Relationship(s)

.DESCRIPTION
	Function to retrieve the Forest Trust Relationship(s)

.PARAMETER Credential
	Specifies the alternative credential to use. Default is the current user.

.PARAMETER ForestName
	Specifies the alternative Forest name to query. Default is the current one.

.NOTES
	Francois-Xavier Cat
	www.lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
	
.EXAMPLE
	Get-ADSIForestTrustRelationship

	Retrieve the Forest Trust Relationship of the current domain

.EXAMPLE
	Get-ADSIForestTrustRelationship -ForestName 'lazywinadmin.com'

	Retrieve the Forest Trust Relationship of the forest lazywinadmin.com

.EXAMPLE
	Get-ADSIForestTrustRelationship -ForestName 'lazywinadmin.com' -credential (Get-Credential)

	Retrieve the Forest Trust Relationship of the forest lazywinadmin.com using the specified credential

.OUTPUTS
	System.DirectoryServices.ActiveDirectory.ForestTrustRelationshipInformation

.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.foresttrustrelationshipinformation(v=vs.110).aspx
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.ActiveDirectory.ForestTrustRelationshipInformation')]
	param
	(
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
	)
	
	PROCESS
	{
		TRY
		{
			Write-Verbose '[Get-ADSIForestTrustRelationship][PROCESS] Credential or FirstName specified'
			(Get-ADSIForest @PSBoundParameters).GetAllTrustRelationships()
		}
		CATCH
		{
			Write-Warning -Message '[Get-ADSIForestTrustRelationship][PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}