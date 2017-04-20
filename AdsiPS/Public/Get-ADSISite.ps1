function Get-ADSISite
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

.PARAMETER SiteName
	Specifies the Site Name to find.

.EXAMPLE
	Get-ADSISite

.EXAMPLE
	Get-ADSISite -ForestName lazywinadmin.com

.EXAMPLE
	Get-ADSISite -Credential (Get-Credential superAdmin) -Verbose

.EXAMPLE
	Get-ADSISite -ForestName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose

.EXAMPLE
	Get-ADSISite -Name 'Montreal'

.OUTPUTS
	System.DirectoryServices.ActiveDirectory.ActiveDirectorySite

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS 
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.ActiveDirectory.ActiveDirectorySite')]
	PARAM
	(
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest(),
		
        [Alias("Name")]
		[String]$SiteName
	)
	
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['Name'])
			{
				# Remove Name from the PSBoundParameters Splatting
				[Void]$PSBoundParameters.Remove('Name')
				
				# Create a Forest Context
				$Context = New-ADSIDirectoryContext -ContextType Forest @PSBoundParameters
				
				# Get the site name specified
				[System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::FindByName($Context, $Name)
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