function Get-ADSISchema
{
<#
.SYNOPSIS
	The Get-ADSISchema function gather information about the current Active Directory Schema

.DESCRIPTION
	The Get-ADSISchema function gather information about the current Active Directory Schema

.PARAMETER PropertyType
	Specify the type of property to return

.PARAMETER ClassName
	Specify the name of the Class to retrieve

.PARAMETER AllClasses
	This will list all the property present in the domain

.PARAMETER FindClassName
	Specify the exact or partial name of the class to search

.PARAMETER Credential
	Specifies alternative credential to use

.EXAMPLE
	Get-ADSISchema -PropertyType Mandatory -ClassName user

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS 
#>
	[CmdletBinding(DefaultParameterSetName = 'Default')]
	param
	(
		[Parameter(ParameterSetName = 'Default',
				   Mandatory = $true)]
		[ValidateSet("mandatory", "optional")]
		[String]$PropertyType,
		
		[Parameter(ParameterSetName = 'Default',
				   Mandatory = $true)]
		[String]$ClassName,
		
		[Parameter(ParameterSetName = 'AllClasses',
				   Mandatory = $true)]
		[Switch]$AllClasses,
		
		[Parameter(ParameterSetName = 'FindClasses',
				   Mandatory = $true)]
		[String]$FindClassName,
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
	
	BEGIN
	{
		TRY
		{
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose '[PROCESS] Credential specified'
				$Splatting = @{ }
				IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }
				
				$SchemaContext = New-ADSIDirectoryContext @splatting -contextType Forest
				$schema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetSchema($SchemaContext)
			}
			ELSE
			{
				$schema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
			}			
		}
		CATCH { 
			$pscmdlet.ThrowTerminatingError($_)
		 }
	}
	
	PROCESS
	{
		IF ($PSBoundParameters['AllClasses'])
		{
			$schema.FindAllClasses().Name
		}
		IF ($PSBoundParameters['FindClassName'])
		{
			$schema.FindAllClasses() | Where-Object { $_.name -match $FindClassName } | Select-Object -Property Name
		}
		
		ELSE
		{
			
			Switch ($PropertyType)
			{
				"mandatory"
				{
					($schema.FindClass("$ClassName")).MandatoryProperties
				}
				"optional"
				{
					($schema.FindClass("$ClassName")).OptionalProperties
				}
			}#Switch
		}#ELSE
		
	}#PROCESS
}