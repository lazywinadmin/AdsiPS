function Get-ADSIUser
{
<#
	.SYNOPSIS
		Function to retrieve a User in Active Directory
	
	.DESCRIPTION
		Function to retrieve a User in Active Directory
	
	.PARAMETER Identity
		Specifies the Identity
	
	.PARAMETER Credential
		Specifies alternative credential
	
	.EXAMPLE
		Get-ADSIUser -Identity 'testaccount'
	
	.EXAMPLE
		Get-ADSIUser -Identity 'testaccount' -Credential (Get-Credential)
	
	.EXAMPLE
		$user = Get-ADSIUser -Identity 'testaccount'
		$user.GetUnderlyingObject()| select-object *
		
		Help you find all the extra properties
	
	.NOTES
		Francois-Xavier Cat
		lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	[OutputType([System.DirectoryServices.AccountManagement.UserPrincipal])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Identity,
		
		[System.Management.Automation.Credential()]
		[Alias('RunAs')]
		$Credential = [System.Management.Automation.PSCredential]::Empty
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
		
		[System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, $Identity)
	}
}
