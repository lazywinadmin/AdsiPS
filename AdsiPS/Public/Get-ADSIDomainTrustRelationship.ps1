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
	
	.NOTES
		Francois-Xavier Cat
		lazywinadmin.com
		@lazywinadm
		github.com/lazywinadm
#>
	
	[CmdletBinding()]
	[OutputType([System.DirectoryServices.ActiveDirectory.TrustRelationshipInformation])]
	param
	(
		[System.Management.Automation.Credential()]
		[Alias('RunAs')]
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