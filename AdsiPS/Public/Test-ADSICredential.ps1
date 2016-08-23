function Test-ADSICredential
{
<#
.SYNOPSIS
	Function to test credential

.DESCRIPTION
	Function to test credential

.PARAMETER AccountName
	Specifies the AccountName to check

.PARAMETER AccountPassword
	Specifies the AccountName's password

.EXAMPLE
	Test-ADCredential -AccountName 'Xavier' -Password 'Wine and Cheese!'

.EXAMPLE
	PS C:\> New-ADSIUser -SamAccountName "fxtest04" -Enabled -AccountPassword (read-host -AsSecureString -Prompt "AccountPassword") -Passthru

	# You can test the credential using the following function
	Test-ADSICredential -AccountName "fxtest04" -Password "Password1"

.OUTPUTS
	System.Boolean

.NOTES
	Francois-Xavier.Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS 
#>
	[OutputType('System.Boolean')]
	[CmdletBinding()]
	PARAM
	(
		[Parameter(Mandatory)]
		[Alias("UserName")]
		[string]$AccountName,
		
		[Parameter(Mandatory)]
		[System.Security.SecureString]$AccountPassword
	)
	BEGIN
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	}
	PROCESS
	{
		TRY
		{
			$DomainPrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
			
			Write-Verbose -Message "[Test-ADCredential][PROCESS] Validating $AccountName Credential against $($DomainPrincipalContext.ConnectedServer)"
			$DomainPrincipalContext.ValidateCredentials($AccountName, $AccountPassword)
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Issue while running the function"
			$Error[0].Exception.Message
		}
	}
}
