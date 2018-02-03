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

.PARAMETER DomainName
	Specifies the alternative Domain where the user should be created
	By default it will use the current domain.

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
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[String]$DomainName)
	BEGIN
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
		# Create Context splatting
		$ContextSplatting = @{ }
		IF ($PSBoundParameters['Credential']) { $ContextSplatting.Credential = $Credential }
		IF ($PSBoundParameters['DomainName']) { $ContextSplatting.DomainName = $DomainName }
	}
	PROCESS
	{
		(Get-ADSIUser -Identity $Identity @ContextSplatting).UnlockAccount()
	}
}
