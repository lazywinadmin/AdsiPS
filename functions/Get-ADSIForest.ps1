Function Get-ADSIForest
{
<#
	.SYNOPSIS
		Function to retrieve the current or specified forest
	
	.DESCRIPTION
		Function to retrieve the current or specified forest
	
	.PARAMETER Credential
		Specifies alternative credential to use
	
	.PARAMETER ForestName
		Specifies the ForestName to query
	
	.EXAMPLE
		Get-ADSIForest
	.EXAMPLE
		Get-ADSIForest -ForestName lazywinadmin.com
	.EXAMPLE
		Get-ADSIForest -Credential (Get-Credential superAdmin) -Verbose
	.EXAMPLE
		Get-ADSIForest -ForestName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose
	
	.NOTES
		Francois-Xavier Cat
		LazyWinAdmin.com
		@lazywinadm
	
	.OUTPUTS
		System.DirectoryServices.ActiveDirectory.Forest
#>
	[cmdletbinding()]
	PARAM (
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
	)
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['Credential'] -or $PSBoundParameters['ForestName'])
			{
				Write-Verbose "[PROCESS] Credential or FirstName specified"
				$Splatting = @{ }
				IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }
				IF ($PSBoundParameters['ForestName']) { $Splatting.ForestName = $ForestName }
				
				$ForestContext = New-ADSIDirectoryContextForest @splatting
				[System.DirectoryServices.ActiveDirectory.Forest]::GetForest($ForestContext)
			}
			ELSE
			{
				[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
			}
			
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}