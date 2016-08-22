Function Get-ADSIDomain
{
<#
.SYNOPSIS
	Function to retrieve the current or specified domain

.DESCRIPTION
	Function to retrieve the current or specified domain

.PARAMETER Credential
	Specifies alternative credential to use

.PARAMETER DomainName
	Specifies the DomainName to query

.EXAMPLE
	Get-ADSIDomain

	Retrieve the current domain
.EXAMPLE
	Get-ADSIForest -DomainName lazywinadmin.com

	Retrieve the domain lazywinadmin.com
.EXAMPLE
	Get-ADSIDomain -Credential (Get-Credential superAdmin) -Verbose

	Retrieve the current domain with the specified credential.
.EXAMPLE
	Get-ADSIDomain -DomainName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose

	Retrieve the domain lazywinadmin.com with the specified credential.
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/ADSIPS

.OUTPUTS
	System.DirectoryServices.ActiveDirectory.Domain
.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.domain(v=vs.110).aspx	
#>
	[cmdletbinding()]
	[OutputType('System.DirectoryServices.ActiveDirectory.Domain')]
	PARAM (
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
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
				
				$DomainContext = New-ADSIDirectoryContext @splatting -contextType Domain
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