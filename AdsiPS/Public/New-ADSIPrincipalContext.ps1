function New-ADSIPrincipalContext
{
<#
.SYNOPSIS
	Function to create an Active Directory PrincipalContext object

.DESCRIPTION
	Function to create an Active Directory PrincipalContext object

.PARAMETER Credential
	Specifies the alternative credentials to use.
	It will use the current credential if not specified.

.PARAMETER ContextType
	Specifies which type of Context to use. Domain, Machine or ApplicationDirectory.

.PARAMETER DomainName
	Specifies the domain to query. Default is the current domain.
	Should only be used with the Domain ContextType.

.PARAMETER Container
	Specifies the scope. Example: "OU=MyOU"

.PARAMETER ContextOptions
	Specifies the ContextOptions.
	Negotiate
	Sealing
	SecureSocketLayer
	ServerBind
	Signing
	SimpleBind

.EXAMPLE
	New-ADSIPrincipalContext -ContextType 'Domain'

.EXAMPLE
	New-ADSIPrincipalContext -ContextType 'Domain' -DomainName "Contoso.com" -Cred (Get-Credential)

.NOTES
	Francois-Xavier.Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
	
	https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.principalcontext(v=vs.110).aspx
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.AccountManagement.PrincipalContext')]
	PARAM
	(
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Parameter(Mandatory = $true)]
		[System.DirectoryServices.AccountManagement.ContextType]$ContextType,
		
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain(),
		
		$Container,
		
		[System.DirectoryServices.AccountManagement.ContextOptions[]]$ContextOptions
	)
	
	BEGIN
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	}
	PROCESS
	{
		TRY
		{
			switch ($ContextType)
			{
				"Domain" { $ArgumentList = $ContextType, $DomainName }
				"Machine" { $ArgumentList = $ContextType, $ComputerName }
				"ApplicationDirectory" { $ArgumentList = $ContextType }
			}
			
			IF ($PSBoundParameters['Container'])
			{
				$ArgumentList += $Container
			}
			
			IF ($PSBoundParameters['ContextOptions'])
			{
				$ArgumentList += $($ContextOptions)
			}
			
			IF ($PSBoundParameters['Credential'])
			{
				# Query the specified domain or current if not entered, with the specified credentials
				$ArgumentList += $($Credential.UserName), $($Credential.GetNetworkCredential().password)
			}
			
			# Query 
			New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $ArgumentList
			
		} #TRY
		CATCH
		{
			Write-Error -Message "[New-ADSIPrincipalContext][PROCESS] Issue while creating the context"
			$Error[0].Exception.Message
		}
	} #PROCESS
}
