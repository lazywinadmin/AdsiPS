function Set-ADSIUserPassword
{
<#
.SYNOPSIS
	Function to change a User's password

.DESCRIPTION
	Function to change a User's password

.PARAMETER Identity
	Specifies the Identity

.PARAMETER Credential
	Specifies alternative credential

.PARAMETER AccountPassword
	Specifies the new password.
    The object needs to be a System.Security.SecureString.
    You can use something like that:
        $AccountPassword = (read-host -AsSecureString -Prompt "AccountPassword")
.PARAMETER DomainName
	Specifies the DomainName to query
	By default it will take the current domain.
	
.EXAMPLE
	Set-ADSIUserPassword -Identity 'testaccount' -AccountPassword (read-host -AsSecureString -Prompt "AccountPassword")

    Change the password of the account 'testaccount' to the specified new password

.EXAMPLE
	Set-ADSIUserPassword -Identity 'testaccount' -AccountPassword (read-host -AsSecureString -Prompt "AccountPassword") -Credential (Get-Credential)

    Change the password of the account 'testaccount' using the credential specified, to the specified new password

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	PARAM (
		[parameter(Mandatory = $true)]
		$Identity,

		[parameter(Mandatory = $true)]
		[System.Security.SecureString]$AccountPassword,

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
		TRY
		{
			if ($pscmdlet.ShouldProcess("$Identity", "Change Account Password"))
			{
				(Get-ADSIUser -Identity $Identity @ContextSplatting).SetPassword("$AccountPassword")
			}
		}
		CATCH
		{
			Write-Error $Error[0]
		}
	}
}