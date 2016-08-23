function Test-ADSIUserIsLockedOut
{
<#
.SYNOPSIS
	Function to test if a User is LockedOut

.DESCRIPTION
	Function to test if a User is LockedOut

.PARAMETER Identity
	Specifies the Identity

.PARAMETER Credential
	Specifies alternative credential

.EXAMPLE
	Test-ADSIUserIsLockedOut -Identity 'testaccount'

.EXAMPLE
	Test-ADSIUserIsLockedOut -Identity 'testaccount' -Credential (Get-Credential)

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS 
#>
	
	[CmdletBinding()]
	[OutputType('System.Boolean')]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Identity,
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
	PROCESS
	{
		(Get-ADSIUser @PSBoundParameters).IsAccountLockedOut()
	}
}
