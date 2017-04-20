function Get-ADSIFsmo
{
<#
.SYNOPSIS
	Function to retrieve the Flexible single master operation (FSMO) roles owner(s)

.DESCRIPTION
	Function to retrieve the Flexible single master operation (FSMO) roles owner(s)

.PARAMETER Credential
	Specifies the Alternative credential to use

.PARAMETER ForestName
	Specifies the alternative forest name

.EXAMPLE
	Get-ADSIFsmo

	Retrieve the Flexible single master operation (FSMO) roles owner(s) of the current domain/forest

.EXAMPLE
	Get-ADSIFsmo -ForestName 'lazywinadmin.com'

	Retrieve the Flexible single master operation (FSMO) roles owner(s) of the root domain/forest lazywinadmin.com

.EXAMPLE
	Get-ADSIFsmo -ForestName 'lazywinadmin.com' -credential (Get-Credential)

	Retrieve the Flexible single master operation (FSMO) roles owner(s) of the root domain/forest lazywinadmin.com using
	the specified credential.

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS

.OUTPUTS
	System.Management.Automation.PSCustomObject
#>
	
	[CmdletBinding()]
	[OutputType('System.Management.Automation.PSCustomObject')]
	param
	(
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
				IF ($PSBoundParameters['Credential'])
				{
					$Splatting.Credential = $Credential
				}
				IF ($PSBoundParameters['ForestName'])
				{
					$Splatting.ForestName = $ForestName
				}
				
				# Forest Query
				$Forest = (Get-ADSIForest @splatting)
				
				# Domain Splatting cleanup
				$Splatting.Remove("ForestName")
				$Splatting.DomainName = $Forest.RootDomain.name
				
				# Domain Query
				$Domain = (Get-ADSIDomain @Splatting)
				
			}
			ELSE
			{
				$Forest = Get-ADSIForest
				$Domain = Get-ADSIDomain
			}
			
			[Pscustomobject][ordered]@{
				SchemaRoleOwner = $Forest.SchemaRoleOwner
				NamingRoleOwner = $Forest.NamingRoleOwner
				InfrastructureRoleOwner = $Domain.InfrastructureRoleOwner
				RidRoleOwner = $Domain.RidRoleOwner
				PdcRoleOwner = $Domain.PdcRoleOwner
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}