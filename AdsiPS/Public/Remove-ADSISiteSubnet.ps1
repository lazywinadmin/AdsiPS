function Remove-ADSISiteSubnet
{
<#
.SYNOPSIS
	function to remove a Subnet

.DESCRIPTION
	function to remove a Subnet

.PARAMETER SubnetName
	Specifies the Subnet Name

.PARAMETER Credential
	Specifies the alternative credential to use.
	By default it will use the current user windows credentials.

.PARAMETER ForestName
	Specifies the alternative Forest where the user should be created
	By default it will use the current Forest.

.EXAMPLE
	Remove-ADSISiteSubnet -SubnetName '192.168.8.0/24'

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
#>
	
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		[String]$SubnetName,

		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,

		[String]$ForestName
	)
	
	BEGIN
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
		# Create Context splatting
		$ContextSplatting = @{ }
		
		IF ($PSBoundParameters['Credential']) { $ContextSplatting.Credential = $Credential }
		IF ($PSBoundParameters['ForestName']) { $ContextSplatting.ForestName = $ForestName }
	}
	PROCESS
	{
		TRY
		{
			IF ($PSCmdlet.ShouldProcess($SubnetName, "Remove Subnet"))
			{
				(Get-ADSISiteSubnet -SubnetName $SubnetName @ContextSplatting).Delete()
			}
		}
		CATCH
		{
			Write-Error $Error[0]
			break
		}
	}
	END
	{
	}
}




