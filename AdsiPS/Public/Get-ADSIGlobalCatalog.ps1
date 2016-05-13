function Get-ADSIGlobalCatalog
{
<#
	.SYNOPSIS
		Function to retrieve the Global Catalog in the Forest
	
	.DESCRIPTION
		Function to retrieve the Global Catalog in the Forest
	
	.PARAMETER Credential
		Specifies the alternative credential to use. Default is the current user.
	
	.PARAMETER ForestName
		Specifies the alternative Forest name to query. Default is the current one.
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	[OutputType([System.DirectoryServices.ActiveDirectory.GlobalCatalog])]
	param
	(
		[System.Management.Automation.Credential()]
		[Alias('RunAs')]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
	)
	
	PROCESS
	{
		TRY
		{
			Write-Verbose '[Get-ADSIGlobalCatalog][PROCESS] Credential or FirstName specified'
			(Get-ADSIForest @PSBoundParameters).GlobalCatalogs
		}
		CATCH
		{
			Write-Warning -Message '[Get-ADSIGlobalCatalog][PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}