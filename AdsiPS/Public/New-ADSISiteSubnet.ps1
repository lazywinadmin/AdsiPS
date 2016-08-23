function New-ADSISiteSubnet
{
<#
.SYNOPSIS
	Function to create a new Site Subnet

.DESCRIPTION
	Function to create a new Site Subnet

.PARAMETER SubnetName
	Specifies the SubnetName.
	Example '192.168.8.0/24'

.PARAMETER SiteName
	Specifies the SiteName where the subnet will be assigned

.PARAMETER Location
	Specifies the location of the subnet

.PARAMETER Credential
	Specifies the alternative credential to use.
	By default it will use the current user windows credentials.

.PARAMETER ForestName
	Specifies the alternative Forest where the subnet should be created
	By default it will use the current forest.

.EXAMPLE
	PS C:\> New-ADSISiteSubnet -SubnetName "5.5.5.0/24" -SiteName "FX3" -Location "test"

.NOTES
	Francois-Xavier.Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS

.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.activedirectorysubnet(v=vs.110).aspx
#>
	
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		[String]$SubnetName,

		[Parameter(Mandatory = $true)]
		[String]$SiteName,

		[String]$Location,

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
		$ContextSplatting = @{ ContextType = "Forest" }
		
		IF ($PSBoundParameters['Credential']) { $ContextSplatting.Credential = $Credential }
		IF ($PSBoundParameters['ForestName']) { $ContextSplatting.ForestName = $ForestName }
		
		$Context = New-ADSIDirectoryContext @ContextSplatting
	}
	PROCESS
	{
		TRY
		{
			IF ($PSCmdlet.ShouldProcess($SubnetName, "Create new Subnet"))
			{
				$Subnet = New-Object -TypeName System.DirectoryServices.ActiveDirectory.ActiveDirectorysubnet -ArgumentList $Context, $SubnetName, $SiteName

				if ($PSBoundParameters['Location']) 
				{
					$Subnet.Location = $Location
				}
				
				$Subnet.Save()
				
				#$SubnetEntry = $Subnet.GetDirectoryEntry()
				#$SubnetEntry.Description = $subnetdescription 
				#$SubnetEntry.CommitChanges()
				#$SubnetEntry
			}
		}
		CATCH
		{
			$Error[0]
			break
		}
	}
	END
	{
	}
}