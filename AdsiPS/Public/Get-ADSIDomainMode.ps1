Function Get-ADSIDomainMode
{
<#
.SYNOPSIS
	Function to retrieve Domain mode

.DESCRIPTION
	Function to retrieve Domain mode

.PARAMETER Credential
	Specifies alternative credential

.PARAMETER DomainName
	Specifies the Domain Name where the function should look

.EXAMPLE
	Get-ADSIDomainMode

.EXAMPLE
	Get-ADSIDomainMode -Credential (Get-Credential)

.EXAMPLE
	Get-ADSIDomainMode -DomainName "FXTEST.local"

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/ADSIPS
#>
	[cmdletbinding()]
	PARAM (
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain()
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
				
				(Get-ADSIDomain @splatting).DomainMode
				
			}
			ELSE
			{
				(Get-ADSIDomain).DomainMode
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}