function Test-ADSICredential
{
<#
	.SYNOPSIS
		Function to test credential
	
	.DESCRIPTION
		Function to test credential
	
	.PARAMETER AccountName
		Specifies the AccountName to check
	
	.PARAMETER Password
		Specifies the AccountName's password
	
	.EXAMPLE
		Test-ADCredential -AccountName 'Xavier' -Password 'Wine and Cheese!'
	
	.OUTPUTS
		System.Boolean
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
#>
	[OutputType([System.Boolean])]
	[CmdletBinding()]
	PARAM
	(
		[Parameter(Mandatory)]
		[Alias("UserName")]
		[string]$AccountName,
		
		[Parameter(Mandatory)]
		[string]$Password
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
			$DomainPrincipalContext.ValidateCredentials($AccountName, $Password)
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Issue while running the function"
			$Error[0].Exception.Message
		}
	}
}
