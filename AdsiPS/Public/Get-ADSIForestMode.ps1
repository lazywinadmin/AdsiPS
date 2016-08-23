Function Get-ADSIForestMode
{
<#
.SYNOPSIS
	Function to retrieve the forest mode

.DESCRIPTION
	Function to retrieve the forest mode

.PARAMETER Credential
	Specifies alternative credential to use

.PARAMETER ForestName
	Specifies the ForestName to query

.EXAMPLE
	Get-ADSIForestMode

	Retrieve the forest mode of the current forest
.EXAMPLE
	Get-ADSIForestMode -ForestName lazywinadmin.com

	Retrieve the forest mode of the forest lazywinadmin.com
.EXAMPLE
	Get-ADSIForestMode -Credential (Get-Credential superAdmin) -Verbose

	Retrieve the forest mode of the current forest using the credentials specified
.EXAMPLE
	Get-ADSIForestMode -ForestName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose

	Retrieve the forest mode of the forest lazywinadmin.com using the credentials specified
.OUTPUTS
	System.directoryservices.activedirectory.forest.forestmode

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/ADSIPS
.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.forest.forestmode(v=vs.110).aspx
#>
	[cmdletbinding()]
	[OutputType('System.directoryservices.activedirectory.forest.forestmode')]
	PARAM (
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
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