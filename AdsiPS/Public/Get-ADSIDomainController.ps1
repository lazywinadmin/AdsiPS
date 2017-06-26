function Get-ADSIDomainController
{
<#
.SYNOPSIS
	Function to retrieve Domain Controllers

.DESCRIPTION
	Function to retrieve Domain Controllers

.PARAMETER Credential
	Specifies alternative credential

.PARAMETER DomainName
	Specifies the Domain Name where the function should look

.EXAMPLE
	Get-ADSIDomainController

.EXAMPLE
	Get-ADSIDomainController -Credential (Get-Credential)

.EXAMPLE
	Get-ADSIDomainController -DomainName "FXTEST.local"

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/ADSIPS
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.ActiveDirectory.DomainController')]
	param
	(
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
	
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain()
	)
	
	BEGIN
	{
		
		
		IF ($PSBoundParameters['Credential'])
		{
			$Context = New-ADSIDirectoryContext -Credential $Credential -contextType Domain
			if ($PSBoundParameters['DomainName'])
			{
				$Context = New-ADSIDirectoryContext -Credential $Credential -contextType Domain -DomainName $DomainName
			}
		}
		ELSE
		{
			$Context = New-ADSIDirectoryContext -contextType Domain
			if ($PSBoundParameters['DomainName'])
			{
				$Context = New-ADSIDirectoryContext -contextType Domain -DomainName $DomainName
			}
		}
	}
	PROCESS
	{
		[System.DirectoryServices.ActiveDirectory.DomainController]::FindAll($Context)
	}
}