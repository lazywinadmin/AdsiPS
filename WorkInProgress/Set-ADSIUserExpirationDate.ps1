function Set-ADSIUserExpirationDate
{
<#
.SYNOPSIS
	Function to set a User's expiration date

.DESCRIPTION
	Function to set a User's expiration date

.PARAMETER Identity
	Specifies the Identity

.PARAMETER Credential
	Specifies alternative credential

.PARAMETER AccountExpirationDate
	Specifies the account expiration date
    The object needs to be a DateTime type.

.PARAMETER DomainName
	Specifies the DomainName to query
	By default it will take the current domain.
	
.EXAMPLE
	Set-ADSIUserExpirationDate -Identity 'testaccount' -AccountExpirationDate $((Get-Date).AddDays(10))

    Set the account expiration date of the account 'testaccount' to 10 days from today.

.EXAMPLE
	Set-ADSIUserExpirationDate -Identity 'testaccount' -AccountExpirationDate $((Get-Date).AddDays(10)) -Credential (Get-Credential)

    Set the account expiration date of the account 'testaccount' to 10 days from today using the credential specified

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
		[System.DateTime]$AccountExpirationDate,

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
			if ($pscmdlet.ShouldProcess("$Identity", "Set the Account Expiration Date"))
			{
				$Account = (Get-ADSIUser -Identity $Identity @ContextSplatting)
                $Account.AccountExpirationDate = $AccountExpirationDate
                $Account.save()
			}
		}
		CATCH
		{
			Write-Error $Error[0]
		}
	}
}