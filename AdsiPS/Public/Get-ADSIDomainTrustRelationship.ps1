function Get-ADSIDomainTrustRelationship
{
<#
.SYNOPSIS
	Function to retrieve the Trust relationship of a domain. Current one by default.

.DESCRIPTION
	Function to retrieve the Trust relationship of a domain. Current one by default.

.PARAMETER Credential
	Specifies the alternative credential to use. Default is the current user.

.PARAMETER DomainName
	Specifies the alternative domain name to use. Default is the current one.

.EXAMPLE
	Get-ADSIDomainTrustRelationship

	Retrieve the Trust relationship(s) of a current domain

.EXAMPLE
	Get-ADSIDomainTrustRelationship -DomainName FX.lab

	Retrieve the Trust relationship(s) of domain fx.lab
	
.EXAMPLE
	Get-ADSIDomainTrustRelationship -DomainName FX.lab -Credential (Get-Credential)

	Retrieve the Trust relationship(s) of domain fx.lab with the credential specified

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/ADSIPS

.OUTPUTS
	System.DirectoryServices.ActiveDirectory.TrustRelationshipInformation

.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.trustrelationshipinformation(v=vs.110).aspx
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.ActiveDirectory.TrustRelationshipInformation')]
	param
	(
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetcurrentDomain()
	)
	
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['Credential'] -or $PSBoundParameters['DomainName'])
			{
				Write-Verbose '[PROCESS] Credential or FirstName specified'
				$Splatting = @{ }
				IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }
				IF ($PSBoundParameters['DomainName']) { $Splatting.DomainName = $DomainName }
				
				(Get-ADSIDomain @splatting).GetAllTrustRelationships()
				
			}
			ELSE
			{
				(Get-ADSIDomain).GetAllTrustRelationships()
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[Get-ADSIDomainTrustRelationship][PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}