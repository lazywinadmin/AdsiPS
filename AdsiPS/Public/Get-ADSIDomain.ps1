Function Get-ADSIDomain
{
<#
	.SYNOPSIS
		Function to retrieve the current or specified domain
	
	.DESCRIPTION
		Function to retrieve the current or specified domain
	
	.PARAMETER Credential
		Specifies alternative credential to use
	
	.PARAMETER ForestName
		Specifies the DomainName to query
	
	.EXAMPLE
		Get-ADSIForest
	.EXAMPLE
		Get-ADSIForest -DomainName lazywinadmin.com
	.EXAMPLE
		Get-ADSIForest -Credential (Get-Credential superAdmin) -Verbose
	.EXAMPLE
		Get-ADSIForest -DomainName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose
	
	.NOTES
		Francois-Xavier Cat
		LazyWinAdmin.com
		@lazywinadm
	
	.OUTPUTS
		System.DirectoryServices.ActiveDirectory.Domain
#>
	[cmdletbinding()]
	PARAM (
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
	)
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['Credential'] -or $PSBoundParameters['DomainName'])
			{
				Write-Verbose '[PROCESS] Credential or DomainName specified'
				$Splatting = @{ }
				IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }
				IF ($PSBoundParameters['DomainName']) { $Splatting.DomainName = $DomainName }
				
				$DomainContext = New-ADSIDirectoryContextDomain @splatting
				[System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($DomainContext)
			}
			ELSE
			{
				[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}