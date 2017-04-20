function Remove-ADSIComputer
{
<#
.SYNOPSIS
	Function to Remove a Computer Account

.DESCRIPTION
	Function to Remove a Computer Account

.PARAMETER Identity
	Specifies the Identity of the Computer.

	You can provide one of the following:
		DistinguishedName
		Guid
		Name
		SamAccountName
		Sid

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

.EXAMPLE
	Remove-ADSIComputer -identity TESTSERVER01

	This command will Remove the account TESTSERVER01

.EXAMPLE
	Remove-ADSIComputer -identity TESTSERVER01 -recursive

	This command will Remove the account TESTSERVER01 and all the child leaf

.EXAMPLE
	Remove-ADSIComputer -identity TESTSERVER01 -whatif

	This command will emulate removing the account TESTSERVER01

.EXAMPLE
	Remove-ADSIComputer -identity TESTSERVER01 -credential (Get-Credential)

	This command will Remove the account TESTSERVER01 using the alternative credential specified

.EXAMPLE
	Remove-ADSIComputer -identity TESTSERVER01 -credential (Get-Credential) -domain LazyWinAdmin.local

	This command will Remove the account TESTSERVER01 using the alternative credential specified in the domain lazywinadmin.local

.NOTES
	Francois-Xavier.Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS

.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.computerprincipal(v=vs.110).aspx
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
					$Account = Get-ADSIComputer -Identity $Identity @ContextSplatting
					$Account.delete()
				}
			}
			
			# Recursive (if the computer is the parent of one leaf or more)
			if ($PSBoundParameters['Recursive'])
			{
				if ($pscmdlet.ShouldProcess("$Identity", "Remove Account and any child objects"))
				{
					$Account = Get-ADSIComputer -Identity $Identity @ContextSplatting
					$Account.GetUnderlyingObject().deletetree()
				}
			}
			
		}
		CATCH
		{
			Write-Error $Error[0]
		}
	}
}
