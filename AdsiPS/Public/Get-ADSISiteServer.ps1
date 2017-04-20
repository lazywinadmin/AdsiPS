function Get-ADSISiteServer
{
<#
.SYNOPSIS
	Function to retrieve the Active Directory Site Servers

.DESCRIPTION
	Function to retrieve the Active Directory Site Servers

.PARAMETER Credential
	Specifies alternative credential to use. Default is the current user.

.PARAMETER ForestName
	Specifies the ForestName to query. Default is the current one

.PARAMETER Name
	Specifies the Site Name to find.

.EXAMPLE
	Get-ADSISiteServer

.EXAMPLE
	Get-ADSISiteServer -ForestName lazywinadmin.com

.EXAMPLE
	Get-ADSISiteServer -Credential (Get-Credential superAdmin) -Verbose

.EXAMPLE
	Get-ADSISiteServer -ForestName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose

.EXAMPLE
	Get-ADSISiteServer -Name 'Azure'

.OUTPUTS
	System.DirectoryServices.ActiveDirectory.DomainController

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS 
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.ActiveDirectory.DomainController')]
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
			(Get-ADSISite @PSBoundParameters).servers
		}
		CATCH
		{
			Write-Warning -Message "[Get-ADSISiteServer][PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}