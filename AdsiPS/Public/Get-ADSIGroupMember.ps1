function Get-ADSIGroupMember
{
<#
	.SYNOPSIS
		Function to retrieve the members from a specific group in Active Directory
	
	.DESCRIPTION
		Function to retrieve the members from a specific group in Active Directory
	
	.PARAMETER Identity
		Specifies the Identity of the Group
	
	.PARAMETER Credential
		Specifies alternative credential
	
	.EXAMPLE
		Get-ADSIGroupMember -Identity 'SERVER01'
	
	.EXAMPLE
		Get-ADSIGroupMember -Identity 'SERVER01' -Credential (Get-Credential)
	
	.EXAMPLE
		$Comp = Get-ADSIGroupMember -Identity 'SERVER01'
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
		[Switch]$Recurse
	)
	BEGIN
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
		IF ($PSBoundParameters['Credential'])
		{
			$Context = New-ADSIPrincipalContext -contexttype Domain -Credential $Credential
		}
		ELSE
		{
			$Context = New-ADSIPrincipalContext -contexttype Domain
		}
	}
	PROCESS
	{
		
		([System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Identity)).GetMembers($Recurse)
	}
}