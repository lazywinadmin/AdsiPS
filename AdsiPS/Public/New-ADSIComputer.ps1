function New-ADSIComputer
{
<#
.SYNOPSIS
	function to create a new computer

.DESCRIPTION
	function to create a new computer

.PARAMETER Name
	Specifies the property Name

.PARAMETER DisplayName
	Specifies the property DisplayName

.PARAMETER Description
	Specifies the property Description

.PARAMETER Enable
	Specifies you want the account enabled after creation.
	By Default the account is disable

.PARAMETER Passthru
	Specifies if you want to see the object created after running the command.

.PARAMETER Credential
	Specifies if you want to specifies alternative credentials

.PARAMETER DomainName
	Specifies if you want to specifies alternative DomainName

.EXAMPLE
	New-ADSIComputer FXTEST01 -Description 'Dev system'

	Create a new computer account FXTEST01 and add the description 'Dev System'

.EXAMPLE
	New-ADSIComputer FXTEST01 -enable

	Create a new computer account FXTEST01 inside the default Computers Organizational Unit and Enable the account

.EXAMPLE
	New-ADSIComputer FXTEST01 -Description 'Dev system'

	Create a new computer account FXTEST01 and add the description 'Dev System'

.EXAMPLE
	New-ADSIComputer FXTEST01 -Passthru

	Create a new computer account FXTEST01 and return the object created and its properties.

.NOTES
	Francois-Xavier.Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS

.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.computerprincipal(v=vs.110).aspx
#>
	
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		$Name,

		[String]$DisplayName,

		[String]$Description,

		[switch]$Passthru,

		[Switch]$Enable,

		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[String]$DomainName
	)
	
	BEGIN
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
		# Create Context splatting
		$ContextSplatting = @{ ContextType = "Domain" }
		
		IF ($PSBoundParameters['Credential']) { $ContextSplatting.Credential = $Credential }
		IF ($PSBoundParameters['DomainName']) { $ContextSplatting.DomainName = $DomainName }
		
		$Context = New-ADSIPrincipalContext @ContextSplatting
	}
	PROCESS
	{
		TRY
		{
			
			if ($PSCmdlet.ShouldProcess($Name, "Create Computer"))
			{
				$newObject = New-Object -TypeName System.DirectoryServices.AccountManagement.ComputerPrincipal -ArgumentList $Context
				$newObject.SamAccountName = $Name
				
				IF ($PSBoundParameters['Enable'])
				{
					$newObject.Enabled = $true
				}
				
				IF ($PSBoundParameters['Description'])
				{
					$newObject.Description = $Description
				}
				
				IF ($PSBoundParameters['DisplayName'])
				{ $newObject.DisplayName }
				
				# Push to ActiveDirectory
				$newObject.Save($Context)
				
				IF ($PSBoundParameters['Passthru'])
				{
					$ContextSplatting.Remove('ContextType')
					Get-ADSIComputer -Identity $Name @ContextSplatting
				}
			}
		}
		CATCH
		{
			Write-Error $Error[0]
		}
		
	}
	END
	{
		
	}
}
