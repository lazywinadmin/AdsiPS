Function Get-ADSIForestMode
{
	[cmdletbinding()]
	PARAM (
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
	)
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['Credential'] -or $PSBoundParameters['ForestName'])
			{
				Write-Verbose '[PROCESS] Credential or FirstName specified'
				$Splatting = @{ }
				IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }
				IF ($PSBoundParameters['ForestName']) { $Splatting.ForestName = $ForestName }
				
				(Get-ADSIForest @splatting).ForestMode
				
			}
			ELSE
			{
				(Get-ADSIForest).ForestMode
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}