function Reset-ADSIUserPasswordAge
{
<#
	.SYNOPSIS
		Function to reset a User's password age to zero
	
	.DESCRIPTION
		Function to reset a User's password age to zero
	
	.PARAMETER Identity
		Specifies the Identity
	
	.PARAMETER Credential
		Specifies alternative credential
	
	.EXAMPLE
		Reset-ADSIUserPasswordAge -Identity 'testaccount'
	
	.EXAMPLE
		Reset-ADSIUserPasswordAge -Identity 'testaccount' -Credential (Get-Credential)
	
	.NOTES
		Francois-Xavier Cat
		lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	PARAM
	(
		[Parameter(Mandatory = $true)]
		[string]$Identity,
		
		[System.Management.Automation.Credential()]
		[Alias('RunAs')]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
	PROCESS
	{
		(Get-ADSIUser @PSBoundParameters).RefreshExpiredPassword()
	}
}
