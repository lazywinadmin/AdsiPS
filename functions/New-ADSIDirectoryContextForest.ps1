Function New-ADSIDirectoryContextForest
{
<#
    .DESCRIPTION
		Function to create an Active Directory Forest DirectoryContext object

	.SYNOPSIS
        Function to create an Active Directory Forest DirectoryContext object

	.PARAMETER ForestName
		Specifies the forest to query.
		Default is the current forest.

	.PARAMETER Credential
		Specifies the alternative credentials to use.
		It will use the current credential if not specified.

	.EXAMPLE
        New-ADSIDirectoryContextForest
	
    .EXAMPLE
        New-ADSIDirectoryContextForest -ForestName "Contoso.com" -Cred (Get-Credential)
        
    .EXAMPLE
        $Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($(New-ADSIDirectoryContextForest -Credential LazyWinAdmin\francois-xavier.cat)))
        $Forest.FindGlobalCatalog()

	.NOTES
        Francois-Xavier.Cat
        LazyWinAdmin.com
        @lazywinadm
	
		https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.directorycontext(v=vs.110).aspx
#>
	
	[CmdletBinding()]
	PARAM (
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
		
	)
	PROCESS
	{
		# ContextType = Domain
		$ContextType = [System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Forest
		
		TRY
		{
			IF ($PSBoundParameters['Credential'])
			{
				# Query the specified domain or current if not entered, with the specified credentials
				New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ContextType, $ForestName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
			}
			ELSE
			{
				# Query the specified domain or current if not entered, with the current credentials
				New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ContextType, $ForestName
			}
		}#TRY
		CATCH
		{
			
		}
	}#PROCESS
}