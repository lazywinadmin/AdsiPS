function Get-ADSISiteLink
{
<#
.SYNOPSIS
	Function to retrieve the Active Directory Site Link(s)

.DESCRIPTION
	Function to retrieve the Active Directory Site Link(s)

.PARAMETER Credential
	Specifies alternative credential to use. Default is the current user.

.PARAMETER ForestName
	Specifies the ForestName to query. Default is the current one

.PARAMETER Name
	Specifies the Site Name to find.

.EXAMPLE
	Get-ADSISiteLink

.EXAMPLE
	Get-ADSISiteLink -ForestName lazywinadmin.com

.EXAMPLE
	Get-ADSISiteLink -Credential (Get-Credential superAdmin) -Verbose

.EXAMPLE
	Get-ADSISiteLink -ForestName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose

.EXAMPLE
	Get-ADSISiteLink -Name 'Azure'

.OUTPUTS
	System.DirectoryServices.ActiveDirectory.ActiveDirectorySiteLink

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS 
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.ActiveDirectory.ActiveDirectorySiteLink')]
	PARAM
	(
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest(),
		
		[Parameter(ValueFromPipelineByPropertyName=$true)]
		[String]$Name
	)
	
	PROCESS
	{
		TRY
		{
			(Get-ADSISite @PSBoundParameters).Sitelinks
		}
		CATCH
		{
			Write-Warning -Message "[Get-ADSISiteLink][PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}