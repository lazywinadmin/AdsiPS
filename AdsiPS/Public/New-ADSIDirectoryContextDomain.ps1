Function New-ADSIDirectoryContextDomain
{
<#
    .DESCRIPTION
		Function to create an Active Directory Domain DirectoryContext object

	.SYNOPSIS
        Function to create an Active Directory Domain DirectoryContext object

	.PARAMETER DomainName
		Specifies the domain to query.
		Default is the current domain.

	.PARAMETER Credential
		Specifies the alternative credentials to use.
		It will use the current credential if not specified.

	.EXAMPLE
        New-ADSIDirectoryContextDomain
	
    .EXAMPLE
        New-ADSIDirectoryContextDomain -DomainName "Contoso.com" -Cred (Get-Credential)
        
    .EXAMPLE
        $Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($(New-ADSIDirectoryContextDomain -Credential LazyWinAdmin\francois-xavier.cat))
        $Domain.DomainControllers
        $Domain.InfrastructureRoleOwner

	.NOTES
        Francois-Xavier.Cat
        LazyWinAdmin.com
        @lazywinadm
	
		https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.directorycontext(v=vs.110).aspx
#>
	
	[CmdletBinding()]
	PARAM (
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain()
		
	)
	PROCESS
	{
		# ContextType = Domain
		$ContextType = [System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain
		
		TRY
		{
			IF ($PSBoundParameters['Credential'])
			{
				# Query the specified domain or current if not entered, with the specified credentials
				New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ContextType, $DomainName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
			}
			ELSE
			{
				# Query the specified domain or current if not entered, with the current credentials
				New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ContextType, $DomainName
			}
		}#TRY
		CATCH
		{
			
		}
	}#PROCESS
}