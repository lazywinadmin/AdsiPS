function Get-ADSISiteSubnet
{
<#
	.SYNOPSIS
		Function to retrieve the Active Directory Site subnets
	
	.DESCRIPTION
		Function to retrieve the Active Directory Site subnets
	
	.PARAMETER Credential
		Specifies alternative credential to use. Default is the current user.
	
	.PARAMETER ForestName
		Specifies the ForestName to query. Default is the current one
	
	.PARAMETER Name
		Specifies the Site Name to find.
	
	.EXAMPLE
		Get-ADSISiteSubnet
	
	.EXAMPLE
		Get-ADSISiteSubnet -ForestName lazywinadmin.com
	
	.EXAMPLE
		Get-ADSISiteSubnet -Credential (Get-Credential superAdmin) -Verbose
	
	.EXAMPLE
		Get-ADSISiteSubnet -ForestName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose
	
	.EXAMPLE
		Get-ADSISiteSubnet -Name 'Azure'
	
	.OUTPUTS
		System.DirectoryServices.ActiveDirectory.ActiveDirectorySubnet
	
	.NOTES
		Francois-Xavier Cat
		LazyWinAdmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	[OutputType([System.DirectoryServices.ActiveDirectory.ActiveDirectorySubnet])]
	PARAM
	(
		[System.Management.Automation.Credential()]
		[Alias('RunAs')]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest(),
		
		[Parameter(ValueFromPipelineByPropertyName)]
		[String]$Name
	)
	
	PROCESS
	{
		TRY
		{
			(Get-ADSISite @PSBoundParameters).subnets
		}
		CATCH
		{
			Write-Warning -Message "[Get-ADSISiteSubnet][PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}