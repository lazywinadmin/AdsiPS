function New-ADSIGroup
{
<#
.SYNOPSIS
	function to create a new group

.DESCRIPTION
	function to create a new group

.PARAMETER Name
	Specifies the property Name

.PARAMETER DisplayName
	Specifies the property DisplayName

.PARAMETER UserPrincipalName
	Specifies the property UserPrincipalName

.PARAMETER Description
	Specifies the property Description

.PARAMETER GroupScope
	Specifies the Group Scope (Global, Local or Universal)

.PARAMETER IsSecurityGroup
	Specify if you want to create a Security Group.
	By default this is $true.

.PARAMETER Passthru
	Specifies if you want to see the object created after running the command.

.PARAMETER Credential
	Specifies if you want to specifies alternative credentials

.PARAMETER DomainName
	Specifies if you want to specifies alternative DomainName

.EXAMPLE
	PS C:\> New-ADSIGroup -Name "TestfromADSIPS3" -Description "some description" -GroupScope Local -IsSecurityGroup

.NOTES
	Francois-Xavier.Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS

.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.groupprincipal(v=vs.110).aspx
#>
	
	[CmdletBinding(SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $true)]
		$Name,

		[String]$DisplayName,

		[String]$UserPrincipalName,

		[String]$Description,

		[Parameter(Mandatory = $true)]
		[system.directoryservices.accountmanagement.groupscope]$GroupScope,
		[switch]$IsSecurityGroup = $true,

		[switch]$Passthru,

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
			
			if ($PSCmdlet.ShouldProcess($Name, "Create Group"))
			{
				$newGroup = [System.DirectoryServices.AccountManagement.GroupPrincipal]::new($Context, $Name)
				$newGroup.Description = $Description
				$newGroup.GroupScope = $GroupScope
				$newGroup.IsSecurityGroup = $IsSecurityGroup
				$newGroup.DisplayName
				#$newGroup.DistinguishedName = 
				#$newGroup.Members
				$newGroup.SamAccountName = $Name
				
				IF ($PSBoundParameters['UserPrincipalName']) { $newGroup.UserPrincipalName = $UserPrincipalName }
				
				# Push to ActiveDirectory
				$newGroup.Save($Context)
				
				IF ($PSBoundParameters['Passthru'])
				{
					$ContextSplatting.Remove('ContextType')
					Get-ADSIGroup -Identity $Name @ContextSplatting
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