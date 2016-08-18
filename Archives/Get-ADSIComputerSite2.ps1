function Get-ADSIComputerSite
{
<#
	.SYNOPSIS
		Function to retrieve the Active Directory Site(s)
	
	.DESCRIPTION
		Function to retrieve the Active Directory Site(s)
	
	.PARAMETER Credential
		Specifies alternative credential to use. Default is the current user.
	
	.PARAMETER ForestName
		Specifies the ForestName to query. Default is the current one
	
	.PARAMETER Name
		Specifies the Site Name to find.
	
	.EXAMPLE
		Get-ADSIComputerSite
	
	.EXAMPLE
		Get-ADSIComputerSite -ForestName lazywinadmin.com
	
	.EXAMPLE
		Get-ADSIComputerSite -Credential (Get-Credential superAdmin) -Verbose
	
	.EXAMPLE
		Get-ADSIComputerSite -ForestName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose
	
	.EXAMPLE
		Get-ADSIComputerSite -Name 'Montreal'
	
	.OUTPUTS
		System.DirectoryServices.ActiveDirectory.ActiveDirectorySite
	
	.NOTES
		Francois-Xavier Cat
		LazyWinAdmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.ActiveDirectory.ActiveDirectorySite')]
	PARAM
	(
		[System.Management.Automation.Credential()]
		[Alias('RunAs')]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest(),
		
		[String]$ComputerName
	)
	
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['ComputerName'])
			{
				# Remove Name from the PSBoundParameters Splatting
				[Void]$PSBoundParameters.Remove('ComputerName')
				
				# Create a Forest Context
				$Context = New-ADSIDirectoryContext -ContextType Forest @PSBoundParameters
				
				# Get the site name specified
				[System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()
			}
			ELSE
			{
				[Void]$PSBoundParameters.Remove('Name')
				(Get-ADSIForest @PSBoundParameters).Sites
			}
		}
		CATCH
		{
			Write-Warning -Message "[Get-ADSISite][PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}