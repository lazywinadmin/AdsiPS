#region Computer

Function Get-ADSIComputer
{
<#
.SYNOPSIS
	The Get-DomainComputer function allows you to get information from an Active Directory Computer object using ADSI.

.DESCRIPTION
	The Get-DomainComputer function allows you to get information from an Active Directory Computer object using ADSI.
	You can specify: how many result you want to see, which credentials to use and/or which domain to query.

.PARAMETER ComputerName
	Specifies the name(s) of the Computer(s) to query

.PARAMETER SizeLimit
	Specifies the number of objects to output. Default is 100.

.PARAMETER DomainDN
	Specifies the path of the Domain to query.
	Examples: 	"FX.LAB"
				"DC=FX,DC=LAB"
				"Ldap://FX.LAB"
				"Ldap://DC=FX,DC=LAB"

.PARAMETER Credential
	Specifies the alternate credentials to use.

.EXAMPLE
	Get-DomainComputer

	This will show all the computers in the current domain

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation001"

	This will query information for the computer Workstation001.

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation001","Workstation002"

	This will query information for the computers Workstation001 and Workstation002.

.EXAMPLE
	Get-Content -Path c:\WorkstationsList.txt | Get-DomainComputer

	This will query information for all the workstations listed inside the WorkstationsList.txt file.

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation0*" -SizeLimit 10 -Verbose

	This will query information for computers starting with 'Workstation0', but only show 10 results max.
	The Verbose parameter allow you to track the progression of the script.

.EXAMPLE
	Get-DomainComputer -ComputerName "Workstation0*" -SizeLimit 10 -Verbose -DomainDN "DC=FX,DC=LAB" -Credential (Get-Credential -Credential FX\Administrator)

	This will query information for computers starting with 'Workstation0' from the domain FX.LAB with the account FX\Administrator.
	Only show 10 results max and the Verbose parameter allows you to track the progression of the script.

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	
	[CmdletBinding()]
	PARAM (
		[Parameter(ValueFromPipelineByPropertyName = $true,
				   ValueFromPipeline = $true)]
		[Alias("Computer")]
		[String[]]$ComputerName,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100',
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain")]
		[String]$DomainDN = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	) #PARAM
	
	PROCESS
	{
		IF ($ComputerName)
		{
			Write-Verbose -Message "One or more ComputerName specified"
			FOREACH ($item in $ComputerName)
			{
				TRY
				{
					# Building the basic search object with some parameters
					Write-Verbose -Message "COMPUTERNAME: $item"
					$Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectSearcher
					$Searcher.Filter = "(&(objectCategory=Computer)(name=$item))"
					$Searcher.SizeLimit = $SizeLimit
					$Searcher.SearchRoot = $DomainDN
					
					# Specify a different domain to query
					IF ($PSBoundParameters['DomainDN'])
					{
						IF ($DomainDN -notlike "LDAP://*") { $DomainDN = "LDAP://$DomainDN" } #IF
						Write-Verbose -Message "Different Domain specified: $DomainDN"
						$Searcher.SearchRoot = $DomainDN
					} #IF ($PSBoundParameters['DomainDN'])
					
					# Alternate Credentials
					IF ($PSBoundParameters['Credential'])
					{
						Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
						$Domain = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $($Credential.UserName), $($Credential.GetNetworkCredential().password) -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCred
						$Searcher.SearchRoot = $Domain
					} #IF ($PSBoundParameters['Credential'])
					
					# Querying the Active Directory
					Write-Verbose -Message "Starting the ADSI Search..."
					FOREACH ($Computer in $($Searcher.FindAll()))
					{
						Write-Verbose -Message "$($Computer.properties.name)"
						New-Object -TypeName PSObject -ErrorAction 'Continue' -ErrorVariable ErrProcessNewObjectOutput -Property @{
							"Name" = $($Computer.properties.name)
							"DNShostName" = $($Computer.properties.dnshostname)
							"Description" = $($Computer.properties.description)
							"OperatingSystem" = $($Computer.Properties.operatingsystem)
							"WhenCreated" = $($Computer.properties.whencreated)
							"DistinguishedName" = $($Computer.properties.distinguishedname)
						} #New-Object
					} #FOREACH $Computer
					
					Write-Verbose -Message "ADSI Search completed"
				} #TRY
				CATCH
				{
					Write-Warning -Message ('{0}: {1}' -f $item, $_.Exception.Message)
					IF ($ErrProcessNewObjectSearcher) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object" }
					IF ($ErrProcessNewObjectCred) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object" }
					IF ($ErrProcessNewObjectOutput) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object" }
				} #CATCH
			} #FOREACH $item
			
			
		} #IF $ComputerName
		
		ELSE
		{
			Write-Verbose -Message "No ComputerName specified"
			TRY
			{
				# Building the basic search object with some parameters
				Write-Verbose -Message "List All object"
				$Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectSearcherALL
				$Searcher.Filter = "(objectCategory=Computer)"
				$Searcher.SizeLimit = $SizeLimit
				
				# Specify a different domain to query
				IF ($PSBoundParameters['DomainDN'])
				{
					$DomainDN = "LDAP://$DomainDN"
					Write-Verbose -Message "Different Domain specified: $DomainDN"
					$Searcher.SearchRoot = $DomainDN
				} #IF ($PSBoundParameters['DomainDN'])
				
				# Alternate Credentials
				IF ($PSBoundParameters['Credential'])
				{
					Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
					$DomainDN = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $Credential.UserName, $Credential.GetNetworkCredential().password -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCredALL
					$Searcher.SearchRoot = $DomainDN
				} #IF ($PSBoundParameters['Credential'])
				
				# Querying the Active Directory
				Write-Verbose -Message "Starting the ADSI Search..."
				FOREACH ($Computer in $($Searcher.FindAll()))
				{
					TRY
					{
						Write-Verbose -Message "$($Computer.properties.name)"
						New-Object -TypeName PSObject -ErrorAction 'Continue' -ErrorVariable ErrProcessNewObjectOutputALL -Property @{
							"Name" = $($Computer.properties.name)
							"DNShostName" = $($Computer.properties.dnshostname)
							"Description" = $($Computer.properties.description)
							"OperatingSystem" = $($Computer.Properties.operatingsystem)
							"WhenCreated" = $($Computer.properties.whencreated)
							"DistinguishedName" = $($Computer.properties.distinguishedname)
						} #New-Object
					} #TRY
					CATCH
					{
						Write-Warning -Message ('{0}: {1}' -f $Computer, $_.Exception.Message)
						IF ($ErrProcessNewObjectOutputALL) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object" }
					}
				} #FOREACH $Computer
				
				Write-Verbose -Message "ADSI Search completed"
				
			} #TRY
			
			CATCH
			{
				Write-Warning -Message "Something Wrong happened"
				IF ($ErrProcessNewObjectSearcherALL) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object" }
				IF ($ErrProcessNewObjectCredALL) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object" }
				
			} #CATCH
		} #ELSE
	} #PROCESS
	END { Write-Verbose -Message "Script Completed" }
}

function Get-ADSICurrentComputerSite
{
	[System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()
}

#endregion

#region Contact
function Get-ADSIContact
{
<#
.SYNOPSIS
	This function will query Active Directory for Contact objects.

.PARAMETER Name
	Specify the Name of the contact

.PARAMETER SamAccountName
	Specify the SamAccountName of the contact

.PARAMETER All
	Default Parameter. This will list all the contact(s) in the Domain
	
.PARAMETER DistinguishedName
	Specify the DistinguishedName path of the OU
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.
	
.EXAMPLE
	Get-ADSIOrganizationalUnit

    This returns all the OU in the Domain (Result Size is 100 per default)

.EXAMPLE
	Get-ADSIContact -name FX

    This returns the contact with the name FX

.EXAMPLE
	Get-ADSIOrganizationalUnit -SamAccountName FX*

    This returns the Contacts where the SamAccountName starts by FX

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding(DefaultParameterSetName = "All")]
	PARAM (
		[Parameter(ParameterSetName = "Name")]
		[String]$Name,
		
		[Parameter(ParameterSetName = "SamAccountName")]
		$SamAccountName,
		
		[Parameter(ParameterSetName = "DistinguishedName")]
		[String]$DistinguishedName,
		
		[Parameter(ParameterSetName = "All")]
		[String]$All,
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain", "DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDistinguishedName
			
			
			If ($Name)
			{
				Write-Verbose -Message "[PROCESS] Name Parameter"
				$Search.filter = "(&(objectCategory=contact)(name=$Name))"
			}
			If ($SamAccountName)
			{
				Write-Verbose -Message "[PROCESS] SamAccounName Parameter"
				$Search.filter = "(&(objectCategory=contact)(samaccountname=$SamAccountName))"
			}
			IF ($DistinguishedName)
			{
				Write-Verbose -Message "[PROCESS] DistinguishedName Parameter"
				$Search.filter = "(&(objectCategory=contact)(distinguishedname=$distinguishedname))"
			}
			IF ($All)
			{
				Write-Verbose -Message "[PROCESS] All Parameter"
				$Search.filter = "(&(objectCategory=contact))"
			}
			IF ($DomainDistinguishedName)
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose -Message "[PROCESS] Different Credential specified: $($credential.username)"
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			If (-not $PSBoundParameters["SizeLimit"])
			{
				Write-Warning -Message "Default SizeLimit: 100 Results"
			}
			
			foreach ($contact in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"Name" = $contact.properties.name -as [string]
					"DistinguishedName" = $contact.properties.distinguishedname -as [string]
					"ADsPath" = $contact.properties.adspath -as [string]
					"ObjectCategory" = $contact.properties.objectcategory -as [string]
					"ObjectClass" = $contact.properties.objectclass -as [string]
					"ObjectGuid" = $contact.properties.objectguid
					"WhenCreated" = $contact.properties.whencreated -as [string] -as [datetime]
					"WhenChanged" = $contact.properties.whenchanged -as [string] -as [datetime]
					"usncreated" = $contact.properties.usncreated -as [string]
					"usnchanged" = $contact.properties.usnchanged -as [string]
					"dscorepropagationdata" = $contact.properties.dscorepropagationdata
					"instancetype" = $contact.properties.instancetype -as [string]
					"CountryCode" = $contact.properties.countrycode -as [string]
					"PrimaryGroupID" = $contact.properties.primarygroupid -as [string]
					"AdminCount" = $contact.properties.admincount
					"SamAccountName" = $contact.properties.samaccountname -as [string]
					"SamAccountType" = $contact.properties.samaccounttype
					"ObjectSid" = $contact.properties.objectsid
					"Displayname" = $contact.properties.displayname -as [string]
					"Accountexpires" = $contact.properties.accountexpires
					"UserPrincipalName" = $contact.properties.userprincipalname -as [string]
					"GivenName" = $contact.properties.givenname
					"CodePage" = $contact.properties.codepage
					"Description" = $contact.properties.description -as [string]
					"Logoncount" = $contact.properties.logoncount
					"PwdLastSet" = $contact.properties.pwdlastset
					"LastLogonTimeStamp" = $contact.properties.lastlogontimestamp
					"UserAccountControl" = $contact.properties.useraccountcontrol
					"cn" = $contact.properties.cn -as [string]
				}
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			}
		} #TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIContact End."
	}
}
#endregion

#region Context

Function New-ADSIDirectoryContextDomain
{
<#
	.SYNOPSIS
		Function to create an Active Directory Domain DirectoryContext object
	
	.DESCRIPTION
		Function to create an Active Directory Domain DirectoryContext object
	
	.PARAMETER Credential
		Specifies the alternative credentials to use.
		It will use the current credential if not specified.
	
	.PARAMETER DomainName
		Specifies the domain to query.
		Default is the current domain.
	
	.EXAMPLE
		New-ADSIDirectoryContextDomain
	
	.EXAMPLE
		New-ADSIDirectoryContextDomain -DomainName "Contoso.com" -Cred (Get-Credential)
	
	.EXAMPLE
		$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($(New-ADSIDirectoryContextDomain -Credential LazyWinAdmin\francois-xavier.cat))
		$Domain.DomainControllers
		$Domain.InfrastructureRoleOwner
	
	.OUTPUTS
		System.DirectoryServices.ActiveDirectory.DirectoryContext
	
	.NOTES
		Francois-Xavier.Cat
		LazyWinAdmin.com
		@lazywinadm
		
		https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.directorycontext(v=vs.110).aspx
#>
	[OutputType('System.DirectoryServices.ActiveDirectory.DirectoryContext')]
	[CmdletBinding()]
	PARAM (
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain()
		
	)
	PROCESS
	{
		# ContextType = Domain
		$ContextType = [System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain
		
		TRY
		{
			IF ($PSBoundParameters['Credential'])
			{
				# Query the specified domain or current if not entered, with the specified credentials
				New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ContextType, $DomainName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
			}
			ELSE
			{
				# Query the specified domain or current if not entered, with the current credentials
				New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ContextType, $DomainName
			}
		} #TRY
		CATCH
		{
			
		}
	} #PROCESS
}

Function New-ADSIDirectoryContextForest
{
<#
	.SYNOPSIS
		Function to create an Active Directory Forest DirectoryContext object
	
	.DESCRIPTION
		Function to create an Active Directory Forest DirectoryContext object
	
	.PARAMETER Credential
		Specifies the alternative credentials to use.
		It will use the current credential if not specified.
	
	.PARAMETER ForestName
		Specifies the forest to query.
		Default is the current forest.
	
	.EXAMPLE
		New-ADSIDirectoryContextForest
	
	.EXAMPLE
		New-ADSIDirectoryContextForest -ForestName "Contoso.com" -Cred (Get-Credential)
	
	.EXAMPLE
		$Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($(New-ADSIDirectoryContextForest -Credential LazyWinAdmin\francois-xavier.cat)))
		$Forest.FindGlobalCatalog()
	
	.OUTPUTS
		System.DirectoryServices.ActiveDirectory.DirectoryContext
	
	.NOTES
		Francois-Xavier.Cat
		LazyWinAdmin.com
		@lazywinadm
		
		https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.directorycontext(v=vs.110).aspx
#>
	[OutputType('System.DirectoryServices.ActiveDirectory.DirectoryContext')]
	[CmdletBinding()]
	PARAM (
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
		
	)
	PROCESS
	{
		# ContextType = Domain
		$ContextType = [System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Forest
		
		TRY
		{
			IF ($PSBoundParameters['Credential'])
			{
				# Query the specified domain or current if not entered, with the specified credentials
				New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ContextType, $ForestName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
			}
			ELSE
			{
				# Query the specified domain or current if not entered, with the current credentials
				New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ContextType, $ForestName
			}
		} #TRY
		CATCH
		{
			
		}
	} #PROCESS
}

function New-ADSIPrincipalContext
{
<#
	.SYNOPSIS
		Function to create a Principal Context
	
	.DESCRIPTION
		Function to create a Principal Context
	
	.PARAMETER PrincipalContextType
		Specifies the PrincipalContextType to use. Domain, Machine or ApplicationDirectory
	
	.PARAMETER Credential
		Specifies alternative credential
	
	.EXAMPLE
		New-ADSIPrincipalContext -PrincipalContextType "Domain"
	
	.EXAMPLE
		New-ADSIPrincipalContext -PrincipalContextType "Domain" -Credential (Get-Credential SuperAdmin)
	
	.NOTES
		Francois-Xavier.Cat
		LazyWinAdmin.com
		@lazywinadm
	
		Additional information on MSDN
	
		https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.principalcontext(v=vs.110).aspx
#>
	[OutputType('System.DirectoryServices.AccountManagement.PrincipalContext')]
	[CmdletBinding()]
	PARAM (
		[Parameter(Mandatory)]
		[ValidateSet("Domain", "Machine", "ApplicationDirectory")]
		$PrincipalContextType,
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
	BEGIN
	{
		TRY
		{
			Write-Verbose -Message "[New-ADSIPrincipalContext][BEGIN] Loading Assembly 'System.DirectoryServices.AccountManagement'"
			Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		}
		CATCH
		{
			Write-Warning -Message "[New-ADSIPrincipalContext][BEGIN] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose -Message "[New-ADSIPrincipalContext][PROCESS] Creating a $PrincipalContextType Principal Context WITH Credential"
				New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $PrincipalContextType, "", $($Credential.UserName), $($Credential.GetNetworkCredential().password)
			}
			ELSE
			{
				Write-Verbose -Message "[New-ADSIPrincipalContext][PROCESS] Creating a $PrincipalContextType Principal Context WITHOUT Credential"
				New-Object System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $PrincipalContextType
			}
		}
		CATCH
		{
			Write-Warning -Message "[New-ADSIPrincipalContext][PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}

#endregion

#region Domain
Function Get-ADSIDomain
{
<#
	.SYNOPSIS
		Function to retrieve the current or specified domain
	
	.DESCRIPTION
		Function to retrieve the current or specified domain
	
	.PARAMETER Credential
		Specifies alternative credential to use
	
	.PARAMETER ForestName
		Specifies the DomainName to query
	
	.EXAMPLE
		Get-ADSIForest
	
	.EXAMPLE
		Get-ADSIForest -DomainName lazywinadmin.com
	
	.EXAMPLE
		Get-ADSIForest -Credential (Get-Credential superAdmin) -Verbose
	
	.EXAMPLE
		Get-ADSIForest -DomainName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose
	
	.OUTPUTS
		System.DirectoryServices.ActiveDirectory.Domain
	
	.NOTES
		Francois-Xavier Cat
		LazyWinAdmin.com
		@lazywinadm
#>	
	[OutputType('System.DirectoryServices.ActiveDirectory.Domain')]
	[cmdletbinding()]
	PARAM (
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$ForestName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
	)
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['Credential'] -or $PSBoundParameters['DomainName'])
			{
				Write-Verbose '[PROCESS] Credential or DomainName specified'
				$Splatting = @{ }
				IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }
				IF ($PSBoundParameters['DomainName']) { $Splatting.DomainName = $DomainName }
				
				$DomainContext = New-ADSIDirectoryContextDomain @splatting
				[System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($DomainContext)
			}
			ELSE
			{
				[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}

Function Get-ADSIDomainMode
{
	[cmdletbinding()]
	PARAM (
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain()
	)
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['Credential'] -or $PSBoundParameters['DomainName'])
			{
				Write-Verbose '[PROCESS] Credential or DomainName specified'
				$Splatting = @{ }
				IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }
				IF ($PSBoundParameters['DomainName']) { $Splatting.DomainName = $DomainName }
				
				(Get-ADSIDomain @splatting).DomainMode
				
			}
			ELSE
			{
				(Get-ADSIDomain).DomainMode
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}

Function Get-ADSIDomainRoot
{
<#
	.SYNOPSIS
		Retrieve the Root Domain
	
	.DESCRIPTION
		Retrieve the Root Domain
	
	.EXAMPLE
		PS C:\> Get-ADSIDomainRoot
	
	.NOTES
		
#>
	[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().RootDomain
}

Function Get-ADSIDomainTrustRelationship
{
	[cmdletbinding()]
	PARAM (
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetcurrentDomain()
	)
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['Credential'] -or $PSBoundParameters['DomainName'])
			{
				Write-Verbose '[PROCESS] Credential or FirstName specified'
				$Splatting = @{ }
				IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }
				IF ($PSBoundParameters['DomainName']) { $Splatting.DomainName = $DomainName }
				
				(Get-ADSIDomain @splatting).GetAllTrustRelationships()
				
			}
			ELSE
			{
				(Get-ADSIDomain).GetAllTrustRelationships()
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}

function Get-ADSIDomainController
{
<#
.SYNOPSIS
	This function will query Active Directory for all Domain Controllers.
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding()]
	PARAM (
		[Parameter()]
		[Alias("Domain", "DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDistinguishedName
			$Search.Filter = "(&(objectClass=computer)(userAccountControl:1.2.840.113556.1.4.803:=8192))"
			
			IF ($DomainDistinguishedName)
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose -Message "[PROCESS] Different Credential specified: $($credential.username)"
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			If (-not $PSBoundParameters["SizeLimit"])
			{
				Write-Warning -Message "Default SizeLimit: 100 Results"
			}
			
			
			
			foreach ($DC in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$DC.properties
				
                <#
                accountexpires
adspath
cn
codepage
countrycode
distinguishedname
dnshostname
dscorepropagationdata
instancetype
iscriticalsystemobject
lastlogontimestamp
localpolicyflags
msdfsr-computerreferencebl
msds-supportedencryptiontypes
name
objectcategory
objectclass
objectguid
objectsid
operatingsystem
operatingsystemversion
primarygroupid
pwdlastset
ridsetreferences
samaccountname
samaccounttype
serverreferencebl
serviceprincipalname
useraccountcontrol
usnchanged
usncreated
whenchanged
whencreated
                
                #>
				
				
				
				# Output the info
				#New-Object -TypeName PSObject -Property $Properties
			}
		} #TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIContact End."
	}
}

Function Get-ADSIDomainDomainControllers
{
	[cmdletbinding()]
	PARAM (
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetcurrentDomain()
	)
	PROCESS
	{
		TRY
		{
			IF ($PSBoundParameters['Credential'] -or $PSBoundParameters['DomainName'])
			{
				Write-Verbose '[PROCESS] Credential or FirstName specified'
				$Splatting = @{ }
				IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }
				IF ($PSBoundParameters['DomainName']) { $Splatting.DomainName = $DomainName }
				
				(Get-ADSIDomain @splatting).domaincontrollers
				
			}
			ELSE
			{
				(Get-ADSIDomain).domaincontrollers
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}

function Move-ADSIDomainControllerRoles
{
	<#  
.SYNOPSIS  
    Move-ADSIDomainControllerRoles transfers or seizes Active Directory roles to the current DC.

.DESCRIPTION  

    Move-ADSIDomainControllerRoles transfers or seizes Active Directory roles to the current DC.
    By default the cmdlet transfers the role, using the -Force parameter makes it seize the role
      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Roles

    Names of the roles to transfer or seize.
    Can be one or more of the following values:
        
        InfrastructureRole, PDCRole, RidRole, NamingRole, SchemaRole

.PARAMETER Force

    Forces the roles to be seized 

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Move-ADSIDomainControllerRoles -ComputerName dc1.ad.local -Roles "PDCRole"

      Connects to remote domain controller dc1.ad.local using current credentials and
      attempts to transfer the PDCrole to dc1.ad.local.


.EXAMPLE

    Move-ADSIDomainControllerRoles  -ComputerName DC1 -Credential $cred -Verbose -Roles InfrastructureRole,PDCRole,RidRole,NamingRole,SchemaRole -Force

    Connects to remote domain controller dc1.ad.local using alternate credentials and seizes all the roles.


.NOTES  
    Filename    : Move-ADSIDomainControllerRoles.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]$Credential = $null,
		
		[Parameter(Mandatory = $true)]
		[ValidateSet("PdcRole", "SchemaRole", "NamingRole", "RidRole", "InfrastructureRole")]
		[String[]]$Roles = $null,
		
		[Switch]$Force
	)
	
	if ($ComputerName)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName
		}
	}
	
	if ($context)
	{
		Write-Verbose -Message "Connecting to $ComputerName"
		$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
	}
	
	if ($dc)
	{
		if ($Force.IsPresent)
		{
			ForEach ($role in $Roles)
			{
				Write-Verbose -Message "Forcing a role transfer of role $role to $($dc.name)"
				$dc.SeizeRoleOwnership([System.DirectoryServices.ActiveDirectory.ActiveDirectoryRole]$role)
			}
		}
		else
		{
			ForEach ($role in $Roles)
			{
				Write-Verbose -Message "Transferring role $role to $($dc.name)"
				$dc.TransferRoleOwnership([System.DirectoryServices.ActiveDirectory.ActiveDirectoryRole]$role)
			}
		}
	}
}
#endregion

#region Forest
Function Get-ADSIForest
{
<#
	.SYNOPSIS
		Function to retrieve the current or specified forest
	
	.DESCRIPTION
		Function to retrieve the current or specified forest
	
	.PARAMETER Credential
		Specifies alternative credential to use
	
	.PARAMETER ForestName
		Specifies the ForestName to query
	
	.EXAMPLE
		Get-ADSIForest
	
	.EXAMPLE
		Get-ADSIForest -ForestName lazywinadmin.com
	
	.EXAMPLE
		Get-ADSIForest -Credential (Get-Credential superAdmin) -Verbose
	
	.EXAMPLE
		Get-ADSIForest -ForestName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose
	
	.OUTPUTS
		System.DirectoryServices.ActiveDirectory.Forest
	
	.NOTES
		Francois-Xavier Cat
		LazyWinAdmin.com
		@lazywinadm
#>	
	[OutputType('System.DirectoryServices.ActiveDirectory.Forest')]
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
				Write-Verbose "[PROCESS] Credential or FirstName specified"
				$Splatting = @{ }
				IF ($PSBoundParameters['Credential']) { $Splatting.Credential = $Credential }
				IF ($PSBoundParameters['ForestName']) { $Splatting.ForestName = $ForestName }
				
				$ForestContext = New-ADSIDirectoryContextForest @splatting
				[System.DirectoryServices.ActiveDirectory.Forest]::GetForest($ForestContext)
			}
			ELSE
			{
				[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
			}
			
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}

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

Function Get-ADSIForestDomain
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
				
				(Get-ADSIForest @splatting).Domains
				
			}
			ELSE
			{
				(Get-ADSIForest).Domains
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}

Function Get-ADSIForestTrustRelationship
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
				
				(Get-ADSIForest @splatting).GetAllTrustRelationships()
				
			}
			ELSE
			{
				(Get-ADSIForest).GetAllTrustRelationships()
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}

function Get-ADSIFsmo
{
<#
.SYNOPSIS
	This function will query Active Directory for all the Flexible Single Master Operation (FSMO) role owner.
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding()]
	PARAM (
		[Parameter()]
		[Alias("Domain", "DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.Filter = "((fSMORoleOwner=*))"
			
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose -Message "[PROCESS] Different Credential specified: $($credential.username)"
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			If (-not $PSBoundParameters["SizeLimit"])
			{
				Write-Warning -Message "Default SizeLimit: 100 Results"
			}
			
			foreach ($FSMO in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$FSMO.properties
				
				# Output the info
				#New-Object -TypeName PSObject -Property $Properties
<#

#'PDC FSMO
(&(objectClass=domainDNS)(fSMORoleOwner=*))

#'Rid FSMO
(&(objectClass=rIDManager)(fSMORoleOwner=*))

#'Infrastructure FSMO

(&(objectClass=infrastructureUpdate)(fSMORoleOwner=*))


#'Schema FSMO
(&(objectClass=dMD)(fSMORoleOwner=*))
OR [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema().SchemaRoleOwner

'Domain Naming FSMO
(&(objectClass=crossRefContainer)(fSMORoleOwner=*))

#>
				
				
			}
		} #TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIFsmo End."
	}
}

Function Get-ADSIGlobalCatalogs
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
				
				(Get-ADSIForest @splatting).GlobalCatalogs
				
			}
			ELSE
			{
				(Get-ADSIForest).GlobalCatalogs
			}
			
		}
		CATCH
		{
			Write-Warning -Message '[PROCESS] Something wrong happened!'
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}

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
	
	.EXAMPLE
		Get-ADSISchema -PropertyType Mandatory -ClassName user
	
	.NOTES
		Francois-Xavier Cat
		LazyWinAdmin.com
		@lazywinadm
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
		[String]$FindClassName
	)
	
	BEGIN
	{
		TRY
		{
			$schema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
			
		}
		CATCH { }
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
			} #Switch
		} #ELSE
		
	} #PROCESS
}

#endregion

#region Group

function Get-ADSIGroup
{
<#
.SYNOPSIS
	This function will query Active Directory for group information. You can either specify the DisplayName, SamAccountName or DistinguishedName of the group
	
.PARAMETER SamAccountName
	Specify the SamAccountName of the group
	
.PARAMETER Name
	Specify the Name of the group
	
.PARAMETER DistinguishedName
	Specify the DistinguishedName path of the group

.PARAMETER Empty
	This parameter returns all the empty groups
	
.PARAMETER SystemGroups
	This parameter returns all the System Groups
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.PARAMETER SearchScope
	Specify the scope of the search (One, OneLevel, Subtree). Default is Subtree.
	
.EXAMPLE
	Get-ADSIGroup -SamAccountName TestGroup
	
	This will return the information about the TestGroup
	
.EXAMPLE
	Get-ADSIGroup -Name TestGroup

	This will return the information about the TestGroup
.EXAMPLE
	Get-ADSIGroup -Empty
	
	This will find all the empty groups

.EXAMPLE
	Get-ADSIGroup -DistinguishedName "CN=TestGroup,OU=Groups,DC=FX,DC=local"
	
.EXAMPLE
    Get-ADSIGroup -Name TestGroup -Credential (Get-Credential -Credential 'FX\enduser') -SearchScope Subtree
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding(DefaultParameterSetName = "Name")]
	PARAM (
		[Parameter(Mandatory = $true, ParameterSetName = "Name")]
		[String]$Name,
		
		[Parameter(Mandatory = $true, ParameterSetName = "SamAccountName")]
		[String]$SamAccountName,
		
		[Parameter(Mandatory = $true, ParameterSetName = "DistinguishedName")]
		[String]$DistinguishedName,
		
		[Parameter(Mandatory = $true, ParameterSetName = "Empty")]
		[Switch]$Empty,
		
		[Parameter(Mandatory = $true, ParameterSetName = "SystemGroups")]
		[Switch]$SystemGroups,
		
		[ValidateSet("One", "OneLevel", "Subtree")]
		$SearchScope = "SubTree",
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain", "DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDistinguishedName
			$Search.SearchScope = $SearchScope
			
			IF ($PSboundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			If ($PSboundParameters['Empty'])
			{
				$Search.filter = "(&(objectClass=group)(!member=*))"
			}
			If ($PSboundParameters['SystemGroups'])
			{
				$Search.filter = "(&(objectCategory=group)(groupType:1.2.840.113556.1.4.803:=1))"
				$Search.SearchScope = 'subtree'
			}
			If ($PSboundParameters['Name'])
			{
				$Search.filter = "(&(objectCategory=group)(name=$Name))"
			}
			IF ($PSboundParameters['SamAccountName'])
			{
				$Search.filter = "(&(objectCategory=group)(samaccountname=$SamAccountName))"
			}
			IF ($PSboundParameters['DistinguishedName'])
			{
				$Search.filter = "(&(objectCategory=group)(distinguishedname=$distinguishedname))"
			}
			IF (-not $PSboundParameters['SizeLimit'])
			{
				Write-Warning -Message "Note: Default Ouput is 100 results. Use the SizeLimit Paremeter to change it. Value 0 will remove the limit"
			}
			
			foreach ($group in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"Name" = $group.properties.name -as [string]
					"SamAccountName" = $group.properties.samaccountname -as [string]
					"Description" = $group.properties.description -as [string]
					"DistinguishedName" = $group.properties.distinguishedname -as [string]
					"ADsPath" = $group.properties.adspath -as [string]
					"ManagedBy" = $group.properties.managedby -as [string]
					"GroupType" = $group.properties.grouptype -as [string]
					"Member" = $group.properties.member
					"ObjectCategory" = $group.properties.objectcategory
					"ObjectClass" = $group.properties.objectclass
					"ObjectGuid" = $group.properties.objectguid
					"ObjectSid" = $group.properties.objectsid
					"WhenCreated" = $group.properties.whencreated
					"WhenChanged" = $group.properties.whenchanged
					"cn" = $group.properties.cn
					"dscorepropagationdata" = $group.properties.dscorepropagationdata
					"instancetype" = $group.properties.instancetype
					"samaccounttype" = $group.properties.samaccounttype
					"usnchanged" = $group.properties.usnchanged
					"usncreated" = $group.properties.usncreated
				}
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			}
		} #TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIGroup End."
	}
}

function Get-ADSIGroupManagedBy
{
<#
.SYNOPSIS
	This function retrieve the group that the current user manage in the ActiveDirectory.
	Typically the function will search for group(s) and look at the 'ManagedBy' property where it matches the current user.
	
.PARAMETER SamAccountName
	Specify the SamAccountName of the Manager of the group
    You can also use the alias: ManagerSamAccountName.

.PARAMETER AllManagedGroups
	Specify to search for groups with a Manager (managedby property)

.PARAMETER NoManager
	Specify to search for groups without Manager (managedby property)

.PARAMETER Credential
    Specify the Credential to use for the query
	
.PARAMETER SizeLimit
    Specify the number of item maximum to retrieve
	
.PARAMETER DomainDistinguishedName
    Specify the Domain or Domain DN path to use

.EXAMPLE
	Get-ADSIGroupManagedBy -SamAccountName fxcat

	This will list all the group(s) where fxcat is designated as Manager.

.EXAMPLE
	Get-ADSIGroupManagedBy

	This will list all the group(s) where the current user is designated as Manager.

.EXAMPLE
	Get-ADSIGroupManagedBy -NoManager

	This will list all the group(s) without Manager

.EXAMPLE
	Get-ADSIGroupManagedBy -AllManagedGroup

	This will list all the group(s) without Manager
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding(DefaultParameterSetName = "One")]
	PARAM (
		[Parameter(ParameterSetName = "One")]
		[Alias("ManagerSamAccountName")]
		[String]$SamAccountName = $env:USERNAME,
		
		[Parameter(ParameterSetName = "All")]
		[Switch]$AllManagedGroups,
		
		[Parameter(ParameterSetName = "No")]
		[Switch]$NoManager,
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("DomainDN", "Domain", "SearchBase", "SearchRoot")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDN
			
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				# Fixing the path if needed
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				
				Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			
			IF ($PSBoundParameters['SamAccountName'])
			{
				Write-Verbose -Message "SamAccountName"
				#Look for User DN
				$UserSearch = $search
				$UserSearch.Filter = "(&(SamAccountName=$SamAccountName))"
				$UserDN = $UserSearch.FindOne().Properties.distinguishedname -as [string]
				
				# Define the query to find the Groups managed by this user
				$Search.Filter = "(&(objectCategory=group)(ManagedBy=$UserDN))"
			}
			
			IF ($PSBoundParameters['AllManagedGroups'])
			{
				Write-Verbose -Message "All Managed Groups Param"
				$Search.Filter = "(&(objectCategory=group)(managedBy=*))"
			}
			
			IF ($PSBoundParameters['NoManager'])
			{
				Write-Verbose -Message "No Manager param"
				$Search.Filter = "(&(objectCategory=group)(!(!managedBy=*)))"
			}
			
			IF (-not ($PSBoundParameters['SamAccountName']) -and -not ($PSBoundParameters['AllManagedGroups']) -and -not ($PSBoundParameters['NoManager']))
			{
				Write-Verbose -Message "No parameters used"
				#Look for User DN
				$UserSearch = $search
				$UserSearch.Filter = "(&(SamAccountName=$SamAccountName))"
				$UserDN = $UserSearch.FindOne().Properties.distinguishedname -as [string]
				
				# Define the query to find the Groups managed by this user
				$Search.Filter = "(&(objectCategory=group)(ManagedBy=$UserDN))"
			}
			
			Foreach ($group in $Search.FindAll())
			{
				$Properties = @{
					"SamAccountName" = $group.properties.samaccountname -as [string]
					"DistinguishedName" = $group.properties.distinguishedname -as [string]
					"GroupType" = $group.properties.grouptype -as [string]
					"Mail" = $group.properties.mail -as [string]
				}
				New-Object -TypeName psobject -Property $Properties
			}
		} #try
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #Process
	END { Write-Verbose -Message "[END] Function Get-ADSIGroupManagedBy End." }
}

function Add-ADSIGroupMember
{
<#
.SYNOPSIS
	This function will add a AD object inside a AD Group.
	
.PARAMETER GroupSamAccountName
	Specify the Group SamAccountName of the group
	
.PARAMETER GroupName
	Specify the Name of the group
	
.PARAMETER GroupDistinguishedName
	Specify the DistinguishedName path of the group
	
.PARAMETER MemberSamAccountName
    Specify the member SamAccountName to add
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDN
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.EXAMPLE
    Add-ADSIGroupMember -GroupSamAccountName TestGroup -UserSamAccountName fxcat -Credential (Get-Credential -Credential SuperAdmin)
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding(DefaultParameterSetName = "GroupSamAccountName")]
	PARAM (
		[Parameter(Mandatory = $true, ParameterSetName = "Name")]
		[String]$GroupName,
		
		[Parameter(Mandatory = $true, ParameterSetName = "GroupSamAccountName")]
		[String]$GroupSamAccountName,
		
		[Parameter(Mandatory = $true, ParameterSetName = "DistinguishedName")]
		[String]$GroupDistinguishedName,
		
		[Parameter(Mandatory = $true)]
		[string]$MemberSamAccountName,
		
		[Alias("Domain")]
		[String]$DomainDN = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDN
			
			IF ($PSBoundParameters['DomainDN'])
			{
				IF ($DomainDN -notlike "LDAP://*") { $DomainDN = "LDAP://$DomainDN" } #IF
				Write-Verbose -Message "Different Domain specified: $DomainDN"
				$Search.SearchRoot = $DomainDN
			}
			
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $DomainDN
			}
			
			# Resolve the Object
			Write-Verbose -Message "[PROCESS] Looking for Object: $MemberSamAccountName"
			$ObjectSearch = $Search
			$ObjectSearch.filter = "(samaccountname=$MemberSamAccountName)"
			$ObjectSearchADSPath = $ObjectSearch.FindOne().Properties.adspath -as [string]
			$ObjectSearchADSPathADSI = $ObjectSearchADSPath -as [ADSI]
			$objectResult = $ObjectSearch.FindOne()
			
			If ($PSBoundParameters['GroupName'])
			{
				Write-Verbose -Message "[PROCESS] Parameter GROUPNAME: $GroupName"
				$Search.filter = "(&(objectCategory=group)(name=$GroupName))"
			}
			IF ($PSBoundParameters['GroupSamAccountName'])
			{
				Write-Verbose -Message "[PROCESS] Parameter GROUPSAMACCOUNTNAME: $GroupSamAccountName"
				$Search.filter = "(&(objectCategory=group)(samaccountname=$GroupSamAccountName))"
			}
			IF ($PSBoundParameters['GroupDistinguishedName'])
			{
				Write-Verbose -Message "[PROCESS] Parameter GROUP DISTINGUISHEDNAME: $GroupDistinguishedName"
				$Search.filter = "(&(objectCategory=group)(distinguishedname=$GroupDistinguishedName))"
			}
			
			$Group = $Search.FindOne()
			$Member = $objectResult
			
			# Verify Member and Object exist
			IF (($Group.Count -gt 0) -and $Member.count -gt 0)
			{
				
				# Get the SamAccountName and ADSPATH of the Group
				$GroupAccount = $Group.Properties.samaccountname -as [string]
				$GroupAdspath = $($Group.Properties.adspath -as [string]) -as [ADSI]
				
				# Member
				$MemberAdsPath = [ADSI]"$($member.Properties.adspath)"
				
				# Check if the Object is member of the group
				$IsMember = $GroupAdspath.IsMember($MemberAdsPath.AdsPath)
				IF (-not ($IsMember))
				{
					Write-Verbose -Message "[PROCESS] Group: $($Group.properties.name -as [string])"
					Write-Verbose -Message "[PROCESS] Adding: $($Member.properties.name -as [string])"
					# Add the user to the group
					([ADSI]"$($Group.properties.adspath)").add($($Member.Properties.adspath -as [string]))
				}
				ELSE
				{
					Write-Warning -message "$MemberSamAccountName is already member of $($GroupObj.samaccountname)"
				}
			}
			ELSE
			{
				IF ($Search.FindAll().Count -eq 0) { Write-Warning -Message "[PROCESS] No Group Found" }
				IF ($objectResult.Count -eq 0) { Write-Warning -Message "[PROCESS] $MemberSamAccountName not Found" }
			}
		} #TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			#if ($ProcessErrorGetADSIUser) { Write-Warning -Message "[PROCESS] Issue while getting information on the user using Get-ADSIUser" }
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Add-ADSIGroupMember End."
	}
}

function Get-ADSIGroupMembership
{
<#
	.SYNOPSIS
		This function will list all the member of the specified group
	
	.DESCRIPTION
		This function will list all the member of the specified group
	
	.PARAMETER Identity
		Specifies the Identity of the group
	
	.PARAMETER Recurse
		Specifies that you want the recursive members of that group.
	
	.PARAMETER Context
		Specifies the Context
	
	.PARAMETER Credential
		A description of the Credential parameter.
	
	.PARAMETER SamAccountName
		Specify the SamAccountName of the Group
	
	.EXAMPLE
		Get-ADSIGroupMembership -Identity "Domain Admins"

	.EXAMPLE
		Get-ADSIGroupMembership -Identity "CN=Domain Users,CN=Users,DC=FX,DC=LAB"
	
	.EXAMPLE
		$TestContext = New-ADSIPrincipalContext -PrincipalContextType Domain -Credential $Cred
		Get-ADSIGroupMembership -Identity "Domain Admins" -ContextObject $TestContext
	
	.OUTPUTS
		System.Object
	
	.NOTES
		Francois-Xavier Cat
		LazyWinAdmin.com
		@lazywinadm
#>
	[OutputType('System.Object')]
	[CmdletBinding()]
	PARAM (
		[Parameter(Mandatory)]
		[Alias("SamAccountName", "DN", "DistinguishedName")]
		[String]$Identity,
		
		[Switch]$Recurse,
		
		$ContextObject,
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
	BEGIN
	{
		TRY
		{
			Write-Verbose -Message "[Get-ADSIGroupMembership][BEGIN] Loading Assembly 'System.DirectoryServices.AccountManagement'"
			Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		}
		CATCH
		{
			Write-Warning -Message "[Get-ADSIGroupMembership][BEGIN] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
	PROCESS
	{
		TRY
		{
			IF (-not $PSBoundParameters['ContextType'])
			{
				IF ($PSBoundParameters['Credential'])
				{
					Write-Verbose -Message "[Get-ADSIGroupMembership][PROCESS] Creating Context with Credential"
					$ContextObject = New-ADSIPrincipalContext -PrincipalContext "Domain" -Credential $Credential
				}
				ELSE
				{
					Write-Verbose -Message "[Get-ADSIGroupMembership][PROCESS] Creating Context without Credential"
					$ContextObject = New-ADSIPrincipalContext -PrincipalContext "Domain"
				}
			}
			IF ($PSBoundParameters['ContextType'])
			{
				IF ($ContextType -isnot [System.DirectoryServices.AccountManagement.PrincipalContext])
				{
					Write-Verbose -Message "[Get-ADSIGroupMembership][PROCESS] ContextType is not a System.DirectoryServices.AccountManagement.PrincipalContext Object."
					Write-Verbose -Message "[Get-ADSIGroupMembership][PROCESS] Creating a System.DirectoryServices.AccountManagement.PrincipalContext Object with $ContextType as argument"
					$ContextObject = New-ADSIPrincipalContext -PrincipalContext $ContextType
				}
			}
			
			
			IF ($PSBoundParameters['Recurse'])
			{
				Write-Verbose -Message "[Get-ADSIGroupMembership][PROCESS] Query (Recursive) of the group $Identity"
				[System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($ContextObject.contexttype, $Identity).GetMembers($Recurse)
			}
			ELSE
			{
				Write-Verbose -Message "[Get-ADSIGroupMembership][PROCESS] Query (Non-Recursive) of the group $Identity"
				[System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($ContextObject.contexttype, $Identity).GetMembers()
			}
		}
		CATCH
		{
			Write-Warning -Message "[Get-ADSIGroupMembership][PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
}

function Remove-ADSIGroupMember
{
<#
.SYNOPSIS
    This function will remove Domain user from a Domain Group
.EXAMPLE
    Remove-ADSIGroupMember -GroupSamAccountName TestGroup -UserSamAccountName Fxcat

    This will remove the domain user fxcat from the group TestGroup
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding()]
	PARAM ($GroupSamAccountName,
		
		$UserSamAccountName)
	$UserInfo = [ADSI]"$((Get-ADSIUser -SamAccountName $UserSamAccountName).AdsPath)"
	$GroupInfo = [ADSI]"$((Get-ADSIGroup -SamAccountName $GroupSamAccountName).AdsPath)"
	
	IF (Test-ADSIUserIsGroupMember -GroupSamAccountName $GroupSamAccountName -UserSamAccountName $UserSamAccountName)
	{
		Write-Verbose "Removing $UserSamAccountName from $GroupSamAccountName"
		$GroupInfo.Remove($UserInfo.ADsPath)
	}
	ELSE
	{
		
		Write-Verbose "$UserSamAccountName is not member of $GroupSamAccountName"
	}
}

#endregion

#region Group Policy Object (GPO)
function Get-ADSIGroupPolicyObject
{
<#
.SYNOPSIS
	This function will query Active Directory Group Policy Objects
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding()]
	PARAM (
		[Parameter()]
		[Alias("Domain", "DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.Filter = "(objectCategory=groupPolicyContainer)"
			
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose -Message "[PROCESS] Different Credential specified: $($credential.username)"
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			If (-not $PSBoundParameters["SizeLimit"])
			{
				Write-Warning -Message "Default SizeLimit: 100 Results"
			}
			
			foreach ($GPO in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$GPO.properties
				
				# Output the info
				#New-Object -TypeName PSObject -Property $Properties
			}
		} #TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSISite End."
	}
}
#endregion

#region Misc

function Get-ADSITokenGroup
{
	<#
	.SYNOPSIS
		Retrieve the list of group present in the tokengroups of a user or computer object.
	
	.DESCRIPTION
		Retrieve the list of group present in the tokengroups of a user or computer object.

		TokenGroups attribute
		https://msdn.microsoft.com/en-us/library/ms680275%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
	
	.PARAMETER SamAccountName
		Specifies the SamAccountName to retrieve
	
	.PARAMETER Credential
		Specifies Credential to use
	
	.PARAMETER DomainDistinguishedName
		Specify the Domain or Domain DN path to use
	
	.PARAMETER SizeLimit
		Specify the number of item maximum to retrieve
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm

		Version History
		1.0 2015/04/02 Initial Version
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(ValueFromPipeline = $true)]
		[Alias('UserName', 'Identity')]
		[String]$SamAccountName,
		
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias('DomainDN', 'Domain')]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias('ResultLimit', 'Limit')]
		[int]$SizeLimit = '100'
	)
	
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDN
			#$Search.Filter = "(&(anr=$SamAccountName))"
			$Search.Filter = "(&((objectclass=user)(samaccountname=$SamAccountName)))"
			
			# Credential
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			
			# Different Domain
			IF ($DomainDistinguishedName)
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			
			FOREACH ($Account in $Search.FindAll())
			{
				
				$AccountGetDirectory = $Account.GetDirectoryEntry();
				
				# Add the properties tokenGroups
				$AccountGetDirectory.GetInfoEx(@("tokenGroups"), 0)
				
				
				FOREACH ($Token in $($AccountGetDirectory.Get("tokenGroups")))
				{
					# Create SecurityIdentifier to translate into group name
					$Principal = New-Object System.Security.Principal.SecurityIdentifier($token, 0)
					
					# Prepare Output
					$Properties = @{
						SamAccountName = $Account.properties.samaccountname -as [string]
						GroupName = $principal.Translate([System.Security.Principal.NTAccount])
					}
					
					# Output Information
					New-Object -TypeName PSObject -Property $Properties
				}
			}
			
		}
		
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END { Write-Verbose -Message "[END] Function Get-ADSITokenGroup End." }
}

function Test-ADSICredential
{
<#
	.SYNOPSIS
		Function to test credential
	
	.DESCRIPTION
		Function to test credential
	
	.PARAMETER AccountName
		Specifies the AccountName to check
	
	.PARAMETER Password
		Specifies the AccountName's password
	
	.EXAMPLE
		Test-ADCredential -AccountName 'Xavier' -Password 'Wine and Cheese!'
	
	.OUTPUTS
		System.Boolean
	
	.NOTES
		Francois-Xavier Cat
		www.lazywinadmin.com
		@lazywinadm
#>
	[OutputType('System.Boolean')]
	[CmdletBinding()]
	PARAM
	(
		[Parameter(Mandatory)]
		[Alias("UserName")]
		[string]$AccountName,
		
		[Parameter(Mandatory)]
		[string]$Password
	)
	BEGIN
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	}
	PROCESS
	{
		TRY
		{
			$DomainPrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
			
			Write-Verbose -Message "[Test-ADCredential][PROCESS] Validating $AccountName Credential against $($DomainPrincipalContext.ConnectedServer)"
			$DomainPrincipalContext.ValidateCredentials($AccountName, $Password)
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Issue while running the function"
			$Error[0].Exception.Message
		}
	}
}

#endregion

#region Objects
function Get-ADSIObject
{
<#
.SYNOPSIS
	This function will query any kind of object in Active Directory

.DESCRIPTION
	This function will query any kind of object in Active Directory

.PARAMETER  SamAccountName
	Specify the SamAccountName of the object.
	This parameter also search in Name and DisplayName properties
	Name and Displayname are alias.

.PARAMETER  DistinguishedName
	Specify the DistinguishedName of the object your are looking for
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER $DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.EXAMPLE
	Get-ADSIObject -SamAccountName Fxcat

.EXAMPLE
	Get-ADSIObject -Name DC*
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "SamAccountName")]
		[Alias("Name", "DisplayName")]
		[String]$SamAccountName,
		
		[Parameter(ParameterSetName = "DistinguishedName")]
		[String]$DistinguishedName,
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain", "DomainDN", "SearchRoot", "SearchBase")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDistinguishedName
			
			IF ($PSBoundParameters['SamAccountName'])
			{
				$Search.filter = "(|(name=$SamAccountName)(samaccountname=$SamAccountName)(displayname=$samaccountname))"
			}
			IF ($PSBoundParameters['DistinguishedName'])
			{
				$Search.filter = "(&(distinguishedname=$DistinguishedName))"
			}
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			
			foreach ($Object in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"DisplayName" = $Object.properties.displayname -as [string]
					"Name" = $Object.properties.name -as [string]
					"ObjectCategory" = $Object.properties.objectcategory -as [string]
					"ObjectClass" = $Object.properties.objectclass -as [string]
					"SamAccountName" = $Object.properties.samaccountname -as [string]
					"Description" = $Object.properties.description -as [string]
					"DistinguishedName" = $Object.properties.distinguishedname -as [string]
					"ADsPath" = $Object.properties.adspath -as [string]
					"LastLogon" = $Object.properties.lastlogon -as [string]
					"WhenCreated" = $Object.properties.whencreated -as [string]
					"WhenChanged" = $Object.properties.whenchanged -as [string]
				}
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			}
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIObject End."
	}
}


#endregion

#region Organizational Unit (OU)

function Get-ADSIOrganizationalUnit
{
<#
.SYNOPSIS
	This function will query Active Directory for Organization Unit Objects

.PARAMETER Name
	Specify the Name of the OU
	
.PARAMETER DistinguishedName
	Specify the DistinguishedName path of the OU
	
.PARAMETER All
	Will show all the OU in the domain
	
.PARAMETER GroupPolicyInheritanceBlocked
	Will show only the OU that have Group Policy Inheritance Blocked enabled.
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER $DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.EXAMPLE
	Get-ADSIOrganizationalUnit

    This returns all the OU in the Domain (Result Size is 100 per default)

.EXAMPLE
	Get-ADSIOrganizationalUnit -name FX

    This returns the OU with the name FX

.EXAMPLE
	Get-ADSIOrganizationalUnit -name FX*

    This returns the OUs where the name starts by FX

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding(DefaultParameterSetName = "All")]
	PARAM (
		[Parameter(ParameterSetName = "Name")]
		[String]$Name,
		
		[Parameter(ParameterSetName = "DistinguishedName")]
		[String]$DistinguishedName,
		
		[Parameter(ParameterSetName = "All")]
		[String]$All,
		
		[Switch]$GroupPolicyInheritanceBlocked,
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain", "DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDistinguishedName
			
			
			If ($Name)
			{
				$Search.filter = "(&(objectCategory=organizationalunit)(name=$Name))"
				IF ($psboundparameters["GroupPolicyInheritanceBlocked"])
				{
					$Search.filter = "(&(objectCategory=organizationalunit)(name=$Name)(gpoptions=1))"
				}
			}
			IF ($DistinguishedName)
			{
				$Search.filter = "(&(objectCategory=organizationalunit)(distinguishedname=$distinguishedname))"
				IF ($psboundparameters["GroupPolicyInheritanceBlocked"])
				{
					$Search.filter = "(&(objectCategory=organizationalunit)(distinguishedname=$distinguishedname)(gpoptions=1))"
				}
			}
			IF ($all)
			{
				$Search.filter = "(&(objectCategory=organizationalunit))"
				IF ($psboundparameters["GroupPolicyInheritanceBlocked"])
				{
					$Search.filter = "(&(objectCategory=organizationalunit)(gpoptions=1))"
				}
			}
			IF ($DomainDistinguishedName)
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			If (-not $PSBoundParameters["SizeLimit"])
			{
				Write-Warning -Message "Default SizeLimit: 100 Results"
			}
			
			foreach ($ou in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"Name" = $ou.properties.name -as [string]
					"DistinguishedName" = $ou.properties.distinguishedname -as [string]
					"ADsPath" = $ou.properties.adspath -as [string]
					"ObjectCategory" = $ou.properties.objectcategory -as [string]
					"ObjectClass" = $ou.properties.objectclass -as [string]
					"ObjectGuid" = $ou.properties.objectguid
					"WhenCreated" = $ou.properties.whencreated -as [string] -as [datetime]
					"WhenChanged" = $ou.properties.whenchanged -as [string] -as [datetime]
					"usncreated" = $ou.properties.usncreated -as [string]
					"usnchanged" = $ou.properties.usnchanged -as [string]
					"dscorepropagationdata" = $ou.properties.dscorepropagationdata
					"instancetype" = $ou.properties.instancetype -as [string]
				}
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			}
		} #TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIOrganizationalUnit End."
	}
}

#endregion

#region Replication

function Enable-ADSIReplicaGC
{
<#  
.SYNOPSIS  
    Enable-ADSIReplicaGC enables the GC role on the current DC.

.DESCRIPTION  

      Enable-ADSIReplicaGC enables the GC role on the current DC.
      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Enable-ADSIReplicaGC -ComputerName dc1.ad.local

      Connects to remote domain controller dc1.ad.local using current credentials and enable the GC role.


.NOTES  
    Filename    : Enable-ADSIReplicaGC.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>	
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]$Credential = $null
	)
	
	if ($ComputerName)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName
		}
	}
	
	if ($context)
	{
		Write-Verbose -Message "Connecting to $ComputerName"
		$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
	}
	
	if ($dc)
	{
		$IsGC = $dc.IsGlobalCatalog()
		if ($IsGC)
		{
			Write-Verbose -Message "$($dc.name) is already a Global Catalog"
		}
		else
		{
			Write-Verbose -Message "Enable the GC role on $($dc.name)"
			$dc.EnableGlobalCatalog()
		}
	}
}

function Get-ADSIReplicaDomainInfo
{
	<#  
.SYNOPSIS  
    Get-ADSIReplicaDomainInfo returns information about the connected DC's Domain.

.DESCRIPTION  

      Get-ADSIReplicaDomainInfo returns information about the connected DC's Domain.

      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.

.PARAMETER Recurse

    Recursively retrieves information about child domains

.EXAMPLE

    Get-ADSIReplicaDomainInfo -ComputerName dc1.ad.local

        Forest                  : ad.local
        DomainControllers       : {DC1.ad.local, DC2.ad.local}
        Children                : {}
        DomainMode              : Windows2012R2Domain
        DomainModeLevel         : 6
        Parent                  : 
        PdcRoleOwner            : DC1.ad.local
        RidRoleOwner            : DC1.ad.local
        InfrastructureRoleOwner : DC1.ad.local
        Name                    : ad.local

      Connects to remote domain controller dc1.ad.local using current credentials retrieves domain info.


.NOTES  
    Filename    : Get-ADSIReplicaDomainInfo.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>	
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]$Credential = $null,
		
		[Switch]$Recurse
	)
	
	if ($ComputerName)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName
		}
	}
	
	if ($context)
	{
		Write-Verbose -Message "Connecting to $ComputerName"
		$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
	}
	
	if ($dc)
	{
		$dc.domain
		if ($Recurse.IsPresent)
		{
			$dc.domain.children | ForEach-Object { $_ }
		}
		
	}
}

function Get-ADSIReplicaForestInfo
{
	<#  
.SYNOPSIS  
    Get-ADSIReplicaForestInfo returns information about the connected DC's Forest.

.DESCRIPTION  

      Get-ADSIForestInfo returns information about the connected DC's Forest.

      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Get-ADSIReplicaForestInfo -ComputerName dc1.ad.local

        Name                  : ad.local
        Sites                 : {Default-First-Site-Name}
        Domains               : {ad.local}
        GlobalCatalogs        : {DC1.ad.local, DC2.ad.local}
        ApplicationPartitions : {DC=DomainDnsZones,DC=ad,DC=local, DC=ForestDnsZones,DC=ad,DC=local}
        ForestModeLevel       : 6
        ForestMode            : Windows2012R2Forest
        RootDomain            : ad.local
        Schema                : CN=Schema,CN=Configuration,DC=ad,DC=local
        SchemaRoleOwner       : DC1.ad.local
        NamingRoleOwner       : DC1.ad.local

      Connects to remote domain controller dc1.ad.local using current credentials retrieves forest info.



.NOTES  
    Filename    : Get-ADSIReplicaForestInfo.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>	
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]$Credential = $null
	)
	
	if ($ComputerName)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName
		}
	}
	
	if ($context)
	{
		Write-Verbose -Message "Connecting to $ComputerName"
		$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
	}
	
	if ($dc)
	{
		Write-Verbose -Message "Information about forest $($dc.forest.name)"
		$dc.forest
	}
}

function Get-ADSIReplicaCurrentTime
{
	<#  
.SYNOPSIS  
    Get-ADSIReplicaCurrentTime retrieves the current time of a given DC.

.DESCRIPTION  

    Get-ADSIReplicaCurrentTime retrieves the current time of a given DC. 
    When using the verbose switch, this cmdlet will display the time difference with the current system.
      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Get-ADSIReplicaCurrentTime -ComputerName dc1.ad.local

      Connects to remote domain controller dc1.ad.local using current credentials and retrieves the current time.


.NOTES  
    Filename    : Get-ADSIReplicaGCInfo.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>	
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]$Credential = $null
	)
	
	if ($ComputerName)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName
		}
	}
	
	if ($context)
	{
		Write-Verbose -Message "Connecting to $ComputerName"
		$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
	}
	
	if ($dc)
	{
		$now = Get-Date
		$minDiff = (New-TimeSpan -start $dc.CurrentTime -end ([System.TimeZoneInfo]::ConvertTimeToUtc($now))).minutes
		Write-Verbose -Message "Difference in minutes between $($dc.name) and current system is $minDiff"
		$dc.CurrentTime
	}
}

function Get-ADSIReplicaGCInfo
{
	<#  
.SYNOPSIS  
    Get-ADSIReplicaGCInfo finds out if a given DC holds the GC role.

.DESCRIPTION  

      Get-ADSIReplicaGCInfo finds out if a given DC holds the Global Catalog role.
      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Get-ADSIReplicaGCInfo -ComputerName dc1.ad.local

      Connects to remote domain controller dc1.ad.local using current credentials retrieves GC info.


.NOTES  
    Filename    : Get-ADSIReplicaGCInfo.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]$Credential = $null
	)
	
	if ($ComputerName)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName
		}
	}
	
	if ($context)
	{
		Write-Verbose -Message "Connecting to $ComputerName"
		$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
	}
	
	if ($dc)
	{
		$IsGC = $dc.IsGlobalCatalog()
		if ($IsGC)
		{
			Write-Verbose -Message "$($dc.name) is a Global Catalog"
		}
		else
		{
			Write-Verbose -Message "$($dc.name) is a normal Domain Controller"
		}
		$IsGC
	}
}

function Get-ADSIReplicaInfo
{
	<#  
.SYNOPSIS  
    Get-ADSIReplicaInfo retrieves Active Directory replication information

.DESCRIPTION  

      Get-ADSIReplicaInfo connects to an Active Directory Domain Controller and retrieves Active Directory replication information
      such as latency of replication and replication status.
      If no switches are used, latency information is returned.
      
.PARAMETER ComputerName
    Defines the remote computer to connect to.
    If ComputerName and Domain are not used, Get-ADSIReplicaInfo will attempt at connecting to the Active Directory using information
    stored in environment variables.

.PARAMETER Domain
    Defines the domain to connect to. If Domain is used, Get-ADSIReplicaInfo will find a domain controller to connect to. 
    This parameter is ignored if ComputerName is used.

.PARAMETER Credential
    Defines alternate credentials to use. Use Get-Credential to create proper credentials.

.PARAMETER NamingContext
    Defines for which naming context replication information is to be displayed: All, Configuration, Schema, Domain. The default is Domain.

.PARAMETER Neighbors
    Displays replication partners for the current Domain Controller.

.PARAMETER Latency
    Organizes replication latency information by groups, such as Hour, Day, Week, Month, TooLong, Other

.PARAMETER Cursors
    Displays replication cursors for the current Domain Controller.

.PARAMETER DisplayDC
    Displays additional information about the currently connected Domain Controller.

.PARAMETER FormatTable
    Formats the output as a auto-sized table and rearranges elements according to relevance.

    Get-ADSIReplicaInfo -Latency -FormatTable

    Hour                         Day Week Month TooLong Other
    ----                         --- ---- ----- ------- -----
    {DC1.ad.local, DC2.ad.local} {}  {}   {}    {}      {}   

.EXAMPLE
      Get-ADSIReplicaInfo 

      Tries to find a domain to connect to and if it succeeds, it will find a domain controller to retrieve replication information.

.EXAMPLE
      Get-ADSIReplicaInfo -ComputerName dc1.ad.local -Credential $Credential

      Connects to remote domain controller dc1.ad.local using alternate credentials.

.EXAMPLE
      Get-ADSIReplicaInfo -Domain ad.local

      Connects to remote domain controller dc1.ad.local using current credentials.

.EXAMPLE
      Get-ADSIReplicaInfo -Domain ad.local

      Connects to remote domain controller dc1.ad.local using current credentials.


.NOTES  
    Filename    : Get-ADSIReplicaInfo.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>
	[CmdletBinding()]
	param ([string]$ComputerName = $null,
		
		[string]$Domain = $null,
		
		[Management.Automation.PSCredential]$Credential = $null,
		
		[ValidateSet("Schema", "Configuration", "Domain", "All")]
		[String]$NamingContext = "Domain",
		
		[Switch]$Neighbors,
		
		[Switch]$Latency,
		
		[Switch]$Cursors,
		
		[Switch]$Errors,
		
		[Switch]$DisplayDC,
		
		[Switch]$FormatTable
	)
	
	
	# Try to determine how to connect to the remote DC. 
	# A few possibilities:
	#      A computername was provided
	#      A domain name was provided
	#      None of the above was provided, so try with either USERDNSDOMAIN or LOGONSERVER
	#      Use alternate credentials if provided
	if ($ComputerName)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName
		}
	}
	elseif ($domain)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "Domain", $domain, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "Domain", $domain
		}
	}
	elseif ($env:USERDNSDOMAIN)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "Domain", $env:USERDNSDOMAIN, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "Domain", $env:USERDNSDOMAIN
		}
	}
	elseif ($env:LOGONSERVER -ne '\\MicrosoftAccount')
	{
		$logonserver = $env:LOGONSERVER.replace('\\', '')
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $logonserver, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $logonserver
		}
	}
	else
	{
		Write-Error -Message "Could not determine where to connect to"
		return
	}
	
	# If none of switches are present, default to at least one, so we have something to show
	if (!$Latency.IsPresent -and !$Neighbors.IsPresent -and !$Errors.IsPresent -and !$Cursors.IsPresent)
	{
		[switch]$Latency = $true
	}
	
	# Determine which DC to use depending on the context type. 
	# If the context is Directory Server, simply get the provided domain controller,
	# if the context is a domain, then find a DC.
	switch ($context.ContextType)
	{
		"DirectoryServer"{ $dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context) }
		"Domain" { $dc = [System.DirectoryServices.ActiveDirectory.DomainController]::FindOne($context) }
		default { return }
	}
	
	if ($dc)
	{
		if ($DisplayDC.IsPresent)
		{
			Write-Verbose -Message "Information about $($dc.Name)"
			$dc
		}
		$domainDN = ""
		$obj = $domain.Replace(',', '\,').Split('/')
		$obj[0].split(".") | ForEach-Object { $domainDN += ",DC=" + $_ }
		$domainDN = $domainDN.Substring(1)
		
		if ($Cursors.IsPresent)
		{
			foreach ($partition in $dc.Partitions)
			{
				if ($NamingContext -eq "All" -or
				($NamingContext -eq "Domain" -and $partition -eq $domainDN) -or
				($NamingContext -eq "Schema" -and $partition.Contains("Schema")) -or
				($NamingContext -eq "Configuration" -and $partition.split(",")[0].Contains("Configuration"))
				)
				{
					Write-Verbose -Message "Replication cursors for partition $partition on $($dc.Name)"
					
					$dc.GetReplicationCursors($partition) | ForEach-Object { $_ }
					
				}
			}
		}
		if ($Latency.IsPresent)
		{
			foreach ($partition in $dc.Partitions)
			{
				if ($NamingContext -eq "All" -or
				($NamingContext -eq "Domain" -and $partition -eq $domainDN) -or
				($NamingContext -eq "Schema" -and $partition.Contains("Schema")) -or
				($NamingContext -eq "Configuration" -and $partition.split(",")[0].Contains("Configuration"))
				)
				{
					Write-Verbose -Message "Replication latency for partition $partition on $($dc.Name)"
					
					$cursorsArray = $dc.GetReplicationCursors($partition)
					$sortedCursors = $cursorsArray | Sort-Object -Descending -Property LastSuccessfulSyncTime
					
					$hour = @()
					$day = @()
					$week = @()
					$month = @()
					$tooLong = @()
					$other = @()
					
					foreach ($cursor in $sortedCursors)
					{
						$timespan = New-TimeSpan -Start $cursor.LastSuccessfulSyncTime -End $(Get-Date)
						
						if ($timespan)
						{
							if ($timespan.Days -eq 0 -and $timespan.Hours -eq 0)
							{
								$hour += $cursor.SourceServer
							}
							elseif ($timespan.Days -eq 0 -and $timespan.Hours -ge 1)
							{
								$day += $cursor.SourceServer
							}
							elseif ($timespan.Days -lt 7)
							{
								$week += $cursor.SourceServer
							}
							elseif ($timespan.Days -le 30 -and $timespan.Days -gt 7)
							{
								$month += $cursor.SourceServer
							}
							else
							{
								$tooLong += $cursor.SourceServer
							}
						}
						else
						{
							# no timestamp we might have a Windows 2000 server here
							$other += $cursor.SourceServer
						}
					}
					
					$latencyObject = New-Object -TypeName PsCustomObject -Property @{
						Hour = $hour;
						Day = $day;
						Week = $week;
						Month = $month;
						TooLong = $tooLong;
						Other = $other
					}
					if ($FormatTable.IsPresent)
					{
						$latencyObject | Select-Object -Property Hour, Day, Week, Month, TooLong, Other | Format-Table -AutoSize
					}
					else
					{
						$latencyObject
					}
				}
			}
		}
		
		if ($Neighbors.IsPresent -or $Errors.IsPresent)
		{
			$replicationNeighbors = $dc.GetAllReplicationNeighbors()
			
			foreach ($neighbor in $replicationNeighbors)
			{
				if ($NamingContext -eq "All" -or
				($NamingContext -eq "Domain" -and $neighbor.PartitionName -eq $domainDN) -or
				($NamingContext -eq "Schema" -and $neighbor.PartitionName.Contains("Schema")) -or
				($NamingContext -eq "Configuration" -and $neighbor.PartitionName.split(",")[0].Contains("Configuration"))
				)
				{
					Write-Verbose -Message "Replication neighbors for partition $($neighbor.PartitionName) on $($dc.Name)"
					
					if (($Errors.IsPresent -and $neighbor.LastSyncResult -ne 0) -or $Neighbors.IsPresent)
					{
						if ($FormatTable.IsPresent)
						{
							$neighbor | Select-Object SourceServer, LastSyncMessage, LastAttemptedSync, LastSuccessfulSync, PartitionName | Format-Table -AutoSize
						}
						else
						{
							$neighbor
						}
					}
				}
			}
		}
	}
}

function Move-ADSIReplicaToSite
{
	<#  
.SYNOPSIS  
    Move-ADSIReplicaToSite moves the current DC to another site.

.DESCRIPTION  

    Move-ADSIReplicaToSite moves the current DC to another site.

      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Site

    Name of the Active Directory site

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Move-ADSIReplicaToSite -ComputerName dc1.ad.local -site "Paris"

      Connects to remote domain controller dc1.ad.local using current credentials and
      moves it to the site "Paris".


.NOTES  
    Filename    : Move-ADSIReplicaToSite.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]$Credential = $null,
		
		[Parameter(Mandatory = $true)]
		[string]$Site = $null
	)
	
	if ($ComputerName)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName
		}
	}
	
	if ($context)
	{
		Write-Verbose -Message "Connecting to $ComputerName"
		$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
	}
	
	if ($dc)
	{
		Write-Verbose -Message "Moving $($dc.name) to site $Site"
		$dc.MoveToAnotherSite($Site)
	}
}

function Start-ADSIReplicationConsistencyCheck
{
	<#  
.SYNOPSIS  
    Start-ADSIReplicationConsistencyCheck starts the knowledge consistency checker on a given DC.

.DESCRIPTION  

      Start-ADSIReplicationConsistencyCheck connects to an Active Directory Domain Controller and starts the KCC to verify if the replication
      topology needs to be optimized.
      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Start-ADSIReplicationConsistencyCheck -ComputerName dc1.ad.local

      Connects to remote domain controller dc1.ad.local using current credentials and starts a KCC check.


.NOTES  
    Filename    : Start-ADSIReplicationConsistencyCheck.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>	
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]$Credential = $null
	)
	
	if ($ComputerName)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName
		}
	}
	
	if ($context)
	{
		Write-Verbose -Message "Connecting to $ComputerName"
		$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
	}
	
	if ($dc)
	{
		$dc.CheckReplicationConsistency()
		Write-Verbose -Message "KCC Check started on $($dc.name)"
	}
}

#endregion

#region Site
function Get-ADSISite
{
<#
.SYNOPSIS
	This function will query Active Directory for all Sites.
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding()]
	PARAM (
		[Parameter()]
		[Alias("Domain", "DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.Filter = "(objectclass=site)"
			
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose -Message "[PROCESS] Different Credential specified: $($credential.username)"
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			If (-not $PSBoundParameters["SizeLimit"])
			{
				Write-Warning -Message "Default SizeLimit: 100 Results"
			}
			
			$Search.SearchRoot = $DomainDistinguishedName -replace "LDAP://", "LDAP://CN=Sites,CN=Configuration,"
			
			foreach ($Site in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Site.properties
				
                <#
     adspath
cn
distinguishedname
dscorepropagationdata
instancetype
name
objectcategory
objectclass
objectguid
showinadvancedviewonly
siteobjectbl
systemflags
usnchanged
usncreated
whenchanged
whencreated
                #>
				
				
				
				# Output the info
				#New-Object -TypeName PSObject -Property $Properties
			}
		} #TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSISite End."
	}
}

function Get-ADSISitesInfo
{
	<#  
.SYNOPSIS  
    Get-ADSISitesInfo returns information about the connected DC's Sites.

.DESCRIPTION  

      Get-ADSISitesInfo returns information about the Sites as seen by the connected DC.
      It returns information such as subnets, sites, sitelinks, ISTG, BH servers etc.

      
.PARAMETER ComputerName

    Defines the remote computer to connect to.

.PARAMETER Credential

    Defines alternate credentials to use. Use Get-Credential to create proper credentials.


.EXAMPLE

      Get-ADSISitesInfo -ComputerName dc1.ad.local

        Name                           : Default-First-Site-Name
        Domains                        : {ad.local}
        Subnets                        : {}
        Servers                        : {DC1.ad.local, DC2.ad.local}
        AdjacentSites                  : {}
        SiteLinks                      : {DEFAULTIPSITELINK}
        InterSiteTopologyGenerator     : DC1.ad.local
        Options                        : None
        Location                       : 
        BridgeheadServers              : {}
        PreferredSmtpBridgeheadServers : {}
        PreferredRpcBridgeheadServers  : {}
        IntraSiteReplicationSchedule   : System.DirectoryServices.ActiveDirectory.ActiveDirectorySchedule

      Connects to remote domain controller dc1.ad.local using current credentials retrieves site information.


.NOTES  
    Filename    : Get-ADSISitesInfo.ps1
    Author      : Micky Balladelli micky@balladelli.com  

.LINK  
    https://balladelli.com
#>	
	[CmdletBinding()]
	param ([Parameter(Mandatory = $true)]
		[string]$ComputerName = $null,
		
		[Management.Automation.PSCredential]$Credential = $null
	)
	
	if ($ComputerName)
	{
		if ($Credential)
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		else
		{
			$context = new-object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList "DirectoryServer", $ComputerName
		}
	}
	
	if ($context)
	{
		Write-Verbose -Message "Connecting to $ComputerName"
		$dc = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
	}
	
	if ($dc)
	{
		Write-Verbose -Message "Information about forest $($dc.forest.name)"
		$dc.forest.sites | ForEach-Object { $_ }
	}
}

function Get-ADSISiteLink
{
<#
.SYNOPSIS
	This function will query Active Directory for all Sites Links
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding()]
	PARAM (
		[Parameter()]
		[Alias("Domain", "DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.Filter = "(objectClass=siteLink)"
			
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose -Message "[PROCESS] Different Credential specified: $($credential.username)"
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			If (-not $PSBoundParameters["SizeLimit"])
			{
				Write-Warning -Message "Default SizeLimit: 100 Results"
			}
			
			$Search.SearchRoot = $DomainDistinguishedName -replace "LDAP://", "LDAP://CN=Sites,CN=Configuration,"
			
			foreach ($SiteLink in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$SiteLink.properties
				
				# Output the info
				#New-Object -TypeName PSObject -Property $Properties
			}
		} #TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSISite End."
	}
}

function Get-ADSISiteServer
{
<#
.SYNOPSIS
	This function will query Active Directory for all Sites Servers
	
.PARAMETER Site
	Specify the name of the Site
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.
	
.EXAMPLE
	Get-ADSISiteServer -Site "Montreal"

.EXAMPLE
	Get-ADSISiteServer -Site "Montreal" -Domain "DC=Contoso,DC=com"
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(Mandatory = $true)]
		$Site,
		
		[Parameter()]
		[Alias("Domain", "DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.Filter = "(objectclass=server)"
			
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose -Message "[PROCESS] Different Credential specified: $($credential.username)"
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			If (-not $PSBoundParameters["SizeLimit"])
			{
				Write-Warning -Message "Default SizeLimit: 100 Results"
			}
			
			$Search.SearchRoot = $DomainDistinguishedName -replace "LDAP://", "LDAP://CN=Servers,CN=$Site,CN=Sites,CN=Configuration,"
			
			foreach ($Site in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!
				$Site.properties
				
                <#

                #>
				
				
				
				# Output the info
				#New-Object -TypeName PSObject -Property $Properties
			}
		} #TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSISite End."
	}
}

function Get-ADSISiteConnection
{
	[CmdletBinding()]
	param (
		[parameter(mandatory = $true, position = 0, ValueFromPipeline = $true)]
		$Domain,
		
		[parameter(mandatory = $true)]
		$Site
	)
	$DomainName = $Domain.Name
	$ADEntry = [system.directoryservices.directoryentry]([ADSI]"LDAP://$DomainName")
	$source = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchRoot = "LDAP://CN=$Site,CN=Sites,CN=Configuration,$DomainName"
	$source.SearchScope = 'Subtree'
	$source.PageSize = 100000
	$source.filter = "(objectclass=nTDSConnection)"
	try
	{
		$SiteConnections = $source.findall()
		if ($SiteConnections -ne $null)
		{
			foreach ($SiteConnection in $SiteConnections)
			{
				$Object = New-Object -TypeName 'PSObject'
				$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
				$Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value $Site
				$Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value $($SiteConnection.Properties.Item("Name"))
				$Object | Add-Member -MemberType 'NoteProperty' -Name 'FromServer' -Value $($SiteConnection.Properties.Item("fromserver") -split ',' -replace 'CN=', '')[3]
				$Object
			}
		}
		else
		{
			$Object = New-Object -TypeName 'PSObject'
			$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
			$Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value $Site
			$Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value ''
			$Object | Add-Member -MemberType 'NoteProperty' -Name 'FromServer' -Value ''
			$Object
		}
	}
	catch
	{
	}
}
#endregion

#region Trust

Function Get-ADSITrustRelationShip
{
	[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().GetAllTrustRelationships()
}

#endregion

#region User

function Get-ADSIUser
{
<#
.SYNOPSIS
	This function will query Active Directory for User information. You can either specify the DisplayName, SamAccountName or DistinguishedName of the user

.PARAMETER SamAccountName
	Specify the SamAccountName of the user
	
.PARAMETER DisplayName
	Specify the DisplayName of the user
	
.PARAMETER DistinguishedName
	Specify the DistinguishedName path of the user
	
.PARAMETER Credential
    Specify the Credential to use for the query
	
.PARAMETER SizeLimit
    Specify the number of item maximum to retrieve
	
.PARAMETER DomainDistinguishedName
    Specify the Domain or Domain DN path to use
	
.PARAMETER MustChangePasswordAtNextLogon
	Find user that must change their password at the next logon
	
.EXAMPLE
	Get-ADSIUser -SamAccountName fxcat
	
.EXAMPLE
	Get-ADSIUser -DisplayName "Cat, Francois-Xavier"
	
.EXAMPLE
	Get-ADSIUser -DistinguishedName "CN=Cat\, Francois-Xavier,OU=Admins,DC=FX,DC=local"
	
.EXAMPLE
    Get-ADSIUser -SamAccountName testuser -Credential (Get-Credential -Credential Msmith)
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding(DefaultParameterSetName = "SamAccountName")]
	PARAM (
		[Parameter(ParameterSetName = "DisplayName", Mandatory = $true)]
		[String]$DisplayName,
		
		[Parameter(ParameterSetName = "SamAccountName", Mandatory = $true)]
		[String]$SamAccountName,
		
		[Parameter(ParameterSetName = "DistinguishedName", Mandatory = $true)]
		[String]$DistinguishedName,
		
		[Parameter(ParameterSetName = "MustChangePasswordAtNextLogon", Mandatory = $true)]
		[Switch]$MustChangePasswordAtNextLogon,
		
		[Parameter(ParameterSetName = "PasswordNeverExpires", Mandatory = $true)]
		[Switch]$PasswordNeverExpires,
		
		[Parameter(ParameterSetName = "NeverLoggedOn", Mandatory = $true)]
		[Switch]$NeverLoggedOn,
		
		[Parameter(ParameterSetName = "DialIn", Mandatory = $true)]
		[boolean]$DialIn,
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Parameter()]
		[Alias("DomainDN", "Domain")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
		
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDN
			
			If ($PSBoundParameters['DisplayName'])
			{
				$Search.filter = "(&(objectCategory=person)(objectClass=User)(displayname=$DisplayName))"
			}
			IF ($PSBoundParameters['SamAccountName'])
			{
				$Search.filter = "(&(objectCategory=person)(objectClass=User)(samaccountname=$SamAccountName))"
			}
			IF ($PSBoundParameters['DistinguishedName'])
			{
				$Search.filter = "(&(objectCategory=person)(objectClass=User)(distinguishedname=$distinguishedname))"
			}
			
			IF ($DomainDistinguishedName)
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" } #IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			
			IF ($PSBoundParameters['MustChangePasswordAtNextLogon'])
			{
				$Search.Filter = "(&(objectCategory=person)(objectClass=user)(pwdLastSet=0))"
			}
			
			IF ($PSBoundParameters['PasswordNeverExpires'])
			{
				$Search.Filter = "(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=65536))"
			}
			IF ($PSBoundParameters['NeverLoggedOn'])
			{
				$Search.Filter = "(&(objectCategory=person)(objectClass=user))(|(lastLogon=0)(!(lastLogon=*)))"
			}
			
			IF ($PSBoundParameters['DialIn'])
			{
				$Search.Filter = "(objectCategory=user)(msNPAllowDialin=$dialin)"
			}
			
			foreach ($user in $($Search.FindAll()))
			{
				
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"DisplayName" = $user.properties.displayname -as [string]
					"SamAccountName" = $user.properties.samaccountname -as [string]
					"Description" = $user.properties.description -as [string]
					"DistinguishedName" = $user.properties.distinguishedname -as [string]
					"ADsPath" = $user.properties.adspath -as [string]
					"MemberOf" = $user.properties.memberof
					"Location" = $user.properties.l -as [string]
					"Country" = $user.properties.co -as [string]
					"PostalCode" = $user.Properties.postalcode -as [string]
					"Mail" = $user.properties.mail -as [string]
					"TelephoneNumber" = $user.properties.telephonenumber -as [string]
					"LastLogonTimeStamp" = $user.properties.lastlogontimestamp -as [string]
					"ObjectCategory" = $user.properties.objectcategory -as [string]
					"Manager" = $user.properties.manager -as [string]
					"HomeDrive" = $user.properties.homedrive -as [string]
					"LogonCount" = $user.properties.logoncount -as [string]
					"DirectReport" = $user.properties.l -as [string]
					"useraccountcontrol" = $user.properties.useraccountcontrol -as [string]
					
					<#
					lastlogoff
					codepage
					c
					department
					msexchrecipienttypedetails
					primarygroupid
					objectguid
					title
					msexchumdtmfmap
					whenchanged
					distinguishedname
					targetaddress
					homedirectory
					dscorepropagationdata
					msexchremoterecipienttype
					instancetype
					memberof
					usnchanged
					usncreated
					description
					streetaddress
					directreports
					samaccountname
					logoncount
					co
					msexchpoliciesexcluded
					userprincipalname
					countrycode
					homedrive
					manager
					samaccounttype
					showinaddressbook
					badpasswordtime
					msexchversion
					objectsid
					objectclass
					proxyaddresses
					objectcategory
					extensionattribute3
					givenname
					pwdlastset
					managedobjects
					st
					whencreated
					physicaldeliveryofficename
					legacyexchangedn
					lastlogon
					accountexpires
					useraccountcontrol
					badpwdcount
					postalcode
					displayname
					msexchrecipientdisplaytype
					sn
					mail
					lastlogontimestamp
					company
					adspath
					name
					telephonenumber
					cn
					msexchsafesendershash
					mailnickname
					l
					
					#>
				} #Properties
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			} #FOREACH
		} #TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	} #PROCESS
	END { Write-Verbose -Message "[END] Function Get-ADSIUser End." }
}

function Test-ADSIUserIsGroupMember
{
<#
.SYNOPSIS
    This function will check if a domain user is member of a domain group

.EXAMPLE
    Test-ADSIUserIsGroupMember -GroupSamAccountName TestGroup -UserSamAccountName Fxcat

    This will return $true or $false depending if the user Fxcat is member of TestGroup
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	PARAM ($GroupSamAccountName,
		
		$UserSamAccountName)
	$UserInfo = [ADSI]"$((Get-ADSIUser -SamAccountName $UserSamAccountName).AdsPath)"
	$GroupInfo = [ADSI]"$((Get-ADSIGroup -SamAccountName $GroupSamAccountName).AdsPath)"
	
	#([ADSI]$GroupInfo.ADsPath).IsMember([ADSI]($UserInfo.AdsPath))
	$GroupInfo.IsMember($UserInfo.ADsPath)
	
}

#endregion

Export-ModuleMember -Function *
