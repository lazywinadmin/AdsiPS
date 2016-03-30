function Get-ADSIGroup
{
<#
	.SYNOPSIS
		Function to retrieve a group in Active Directory
	
	.DESCRIPTION
		Function to retrieve a group in Active Directory
	
	.PARAMETER Identity
		Specifies the Identity of the group
	
	.PARAMETER Credential
		Specifies alternative credential
	
	.EXAMPLE
		Get-ADSIGroup -Identity 'SERVER01'
	
	.EXAMPLE
		Get-ADSIGroup -Identity 'SERVER01' -Credential (Get-Credential)
	
	.EXAMPLE
		$Comp = Get-ADSIGroup -Identity 'SERVER01'
		$Comp.GetUnderlyingObject()| select-object *
	
		Help you find all the extra properties
	
	.NOTES
		Francois-Xavier Cat
		lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	[CmdletBinding()]
	param ([Parameter(Mandatory)]
		[string]$Identity,
		
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
	
		$SearchBase
	)
	BEGIN
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
		IF ($PSBoundParameters['Credential'])
		{
			$Context = New-ADSIPrincipalContext -contexttype Domain -Credential $Credential
			IF ($PSBoundParameters['SearchBase'])
			{
				$Context = New-ADSIPrincipalContext -contexttype Domain -Credential $Credential -Container $SearchBase
			}
		}
		ELSE
		{
			$Context = New-ADSIPrincipalContext -contexttype Domain
			
			IF ($PSBoundParameters['SearchBase'])
			{
				$Context = New-ADSIPrincipalContext -contexttype Domain -Container $SearchBase
			}
		}
	}
	PROCESS
	{
		[System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Identity)
	}
}