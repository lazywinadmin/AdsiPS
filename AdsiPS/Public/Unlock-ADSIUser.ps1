function Unlock-ADSIUser
{
<#
.SYNOPSIS
	Function to Unlock a User in Active Directory

.DESCRIPTION
	Function to Unlock a User in Active Directory

.PARAMETER Identity
	Specifies the Identity

.PARAMETER Credential
	Specifies alternative credential

.EXAMPLE
	Unlock-ADSIUser -Identity 'testaccount'

.EXAMPLE
	Unlock-ADSIUser -Identity 'testaccount' -Credential (Get-Credential)

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS 
#>
	[CmdletBinding()]
	param ([Parameter(Mandatory)]
		[string]$Identity,
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
	PROCESS
	{
		
		(Get-ADSIUser @PSBoundParameters).UnlockAccount()
	}
}
