Function Get-ADSIDomainTrustRelationship
{
	[cmdletbinding()]
	PARAM (
		[Alias('RunAs')]
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
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}