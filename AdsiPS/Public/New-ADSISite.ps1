function New-ADSISite
{
<#
.SYNOPSIS
	Function to create a new Site

.DESCRIPTION
	Function to create a new Site

.PARAMETER SiteName
	Specifies the SiteName

.PARAMETER Location
	Specifies the Location of the site

.PARAMETER Credential
	Specifies the alternative credential to use.
	By default it will use the current user windows credentials.

.PARAMETER ForestName
	Specifies the alternative Forest where the subnet should be created
	By default it will use the current forest.

.EXAMPLE
	PS C:\> New-ADSISite -SiteName "MTL01" -Location "Montreal, QC, Canada"

.NOTES
	Francois-Xavier.Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS

.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.activedirectorysite(v=vs.110).aspx
#>
	
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		[Alias('Name')]
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
			IF ($PSCmdlet.ShouldProcess($SiteName, "Create Site"))
			{
				$Site = New-Object -TypeName System.DirectoryServices.ActiveDirectory.ActiveDirectorySite -ArgumentList $Context, $SiteName
				$Site.Location = $Location
				$Site.Save()
				
				#$site.GetDirectoryEntry()
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