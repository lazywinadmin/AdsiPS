function New-ADSIDirectoryContext
{
<#
.SYNOPSIS
	Function to create an Active Directory DirectoryContext objects

.DESCRIPTION
	Function to create an Active Directory DirectoryContext objects

.PARAMETER Credential
	Specifies the alternative credentials to use.
	It will use the current credential if not specified.

.PARAMETER ContextType
	Specifies the ContextType. The following choices are available:
		ApplicationPartition
		ConfigurationSet
		DirectoryServer
		Domain
		Forest

.PARAMETER DomainName
	Specifies the domain to query. Default is the current domain.
	This need to be used with the ContextType Domain

.PARAMETER ForestName
	Specifies the forest to query. Default is the current forest.
	This need to be used with the ContextType Forest

.PARAMETER Server
	Specifies the Domain Controller to use
	This need to be used with the ContextType DirectoryServer

.EXAMPLE
	New-ADSIDirectoryContext -ContextType Domain

	This will create a new Directory Context of type Domain in the current domain

.EXAMPLE
	New-ADSIDirectoryContext -ContextType Domain -DomainName "FXTEST.local"

	This will create a new Directory Context of type Domain in the domain "FXTEST.local"

.EXAMPLE
	New-ADSIDirectoryContext -ContextType Forest

	This will create a new Directory Context of type Forest in the current forest

.EXAMPLE
	New-ADSIDirectoryContext -ContextType Forest -ForestName "FXTEST.local"

	This will create a new Directory Context of type Forest in the forest FXTEST.local

.EXAMPLE
	New-ADSIDirectoryContext -ContextType Forest -ForestName "FXTEST.local" -credential (Get-Credential)

	This will create a new Directory Context of type Forest with Alternative credentials
	
.EXAMPLE
	New-ADSIDirectoryContext -ContextType DirectoryServer -Server "DCSERVER01.FXTEST.local"

	This will create a new Directory Context of type DirectoryServer against the Domain Controller DCSERVER01.FXTEST.local

.EXAMPLE
	$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($(New-ADSIDirectoryContext -ContextType Domain -Credential (Get-Credential)))
	$Domain.DomainControllers
	$Domain.InfrastructureRoleOwner

	This will retrieve all the Domain Controllers and the Infrastructure Role owner (FSMO Role)

.EXAMPLE
	[System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController(New-ADSIDirectoryContext -ContextType DirectoryServer -Server "DC01.FXTEST.local").forest.sites

	This will retrieve all the sites in the forest

.NOTES
	Francois-Xavier.Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
	
	https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.directorycontext(v=vs.110).aspx
#>
	
	[CmdletBinding(DefaultParameterSetName = 'Server')]
	param
	(
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Parameter(Mandatory)]
		[System.DirectoryServices.ActiveDirectory.DirectoryContextType]$ContextType,
		
		[Parameter(ParameterSetName = 'Domain')]
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain(),
		
		[Parameter(ParameterSetName = 'Forest')]
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest(),
		
		[Parameter(ParameterSetName = 'Server')]
		[ValidateNotNullOrEmpty]
		[Alias("ComputerName","DomainController")]
		$Server
	)
	
	PROCESS
	{
		TRY
		{
			switch ($ContextType)
			{
				"Domain" { $ArgumentList = $ContextType,$DomainName }
				"Forest" { $ArgumentList = $ContextType, $ForestName }
				"DirectoryServer" { $ArgumentList = $ContextType, $Server }
				"ApplicationPartition" { $ArgumentList = $ContextType }
				"ConfigurationSet" { $ArgumentList = $ContextType }
			}
			IF ($PSBoundParameters['Credential'])
			{
				# Query the specified domain or current if not entered, with the specified credentials
				$ArgumentList += $($Credential.UserName), $($Credential.GetNetworkCredential().password)
			}
			
				# Query the specified domain or current if not entered, with the current credentials
				New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ArgumentList
			
		} #TRY
		CATCH
		{
			Write-Error -Message "[New-ADSIDirectoryContext][PROCESS] Issue while creating the context"
			$Error[0].Exception.Message
		}
	} #PROCESS
}