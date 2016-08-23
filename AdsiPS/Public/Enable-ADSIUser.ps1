function Enable-ADSIUser
{
<#
.SYNOPSIS
	Function to Enable a User Account

.DESCRIPTION
	Function to Enable a User Account

.PARAMETER Identity
	Specifies the Identity of the User.

	You can provide one of the following properties
		DistinguishedName
		Guid
		Name
		SamAccountName
		Sid
		UserPrincipalName
	
	Those properties come from the following enumeration:
		System.DirectoryServices.AccountManagement.IdentityType

.PARAMETER Credential
	Specifies the alternative credential to use.
	By default it will use the current user windows credentials.

.PARAMETER DomainName
	Specifies the alternative Domain.
	By default it will use the current domain.

.EXAMPLE
	Enable-ADSIUser fxtest02

	This will Enable the fxtest02 account

.EXAMPLE
	Enable-ADSIUser fxtest02 -whatif

	This will emulate the following action: Enable the fxtest02 account

.EXAMPLE
	Enable-ADSIUser fxtest02 -credential (Get-Credential)

	This will enable the fxtest02 account using the credential specified

.EXAMPLE
	Enable-ADSIUser fxtest02 -credential (Get-Credential) -DomainName LazyWinAdmin.local

	This will enable the fxtest02 account using the credential specified in the domain LazyWinAdmin.local

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/ADSIPS
.LINK
	https://msdn.microsoft.com/en-us/library/System.DirectoryServices.AccountManagement.UserPrincipal(v=vs.110).aspx
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	PARAM (
		[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
		$Identity,

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
		
		$Context = New-ADSIPrincipalContext @ContextSplatting -contexttype Domain
	}
	PROCESS
	{
		TRY
		{
			if ($pscmdlet.ShouldProcess("$Identity", "Enable Account"))
			{
				$Account = Get-ADSIUser -Identity $Identity @ContextSplatting
				$Account.Enabled = $true
				$Account.Save()
			}
		}
		CATCH
		{
			Write-Error $Error[0]
		}
	}
}
