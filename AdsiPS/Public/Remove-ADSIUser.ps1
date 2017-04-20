function Remove-ADSIUser
{
<#
.SYNOPSIS
	Function to delete a User Account

.DESCRIPTION
	Function to delete a User Account

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

.PARAMETER Recursive
    Specifies that any child object should be deleted as well
    Typically you would use this parameter if you get the error "The directory service can perform the requested operation only on a leaf object"
    when you try to delete the object without the -recursive param
	
	Typically used when you have Exchange/ActiveSync in your domain, some users happens to have sub child items.
	
.EXAMPLE
	Remove-ADSIUser -identity fxtest02

	This command will Remove the account fxtest02 from the current domain
	
.EXAMPLE
	Remove-ADSIUser -identity fxtest02 -whatif
	
	This command will emulate removing the account fxtest02
	
.EXAMPLE
	Remove-ADSIUser -identity fxtest02 -credential (Get-Credential)

	This command will Remove the account fxtest02 using the alternative credential specified

.EXAMPLE
	Remove-ADSIUser -identity fxtest02 -credential (Get-Credential) -domain LazyWinAdmin.local

	This command will Remove the account fxtest02 using the alternative credential specified in the domain lazywinadmin.local

.EXAMPLE
	Remove-ADSIUser -identity fxtest02 -recursive

	This command will Remove the account fxtest02 and all the child objects.
	
.NOTES
	Francois-Xavier.Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
	
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

		[String]$DomainName,

		[Switch]$Recursive
	)
	
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
			# Not Recursive
			if (-not $PSBoundParameters['Recursive'])
			{
				if ($pscmdlet.ShouldProcess("$Identity", "Remove Account"))
				{
					(Get-ADSIUser -Identity $Identity @ContextSplatting).Delete()
				}
			}
			
			# Recursive
			if ($PSBoundParameters['Recursive'])
			{
				if ($pscmdlet.ShouldProcess("$Identity", "Remove Account and any child objects"))
				{
					(Get-ADSIUser -Identity $Identity @ContextSplatting).GetUnderlyingObject().deletetree()
				}
			}
		}
		CATCH
		{
			Write-Error $Error[0]
		}
	}
}
