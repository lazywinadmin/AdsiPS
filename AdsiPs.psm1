function Move-ADSIObject{
	param(
		[Parameter(mandatory=$true)][String]$ObjectName,
		[Parameter(mandatory=$true)][String]$DestinationPath
		
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain")]
		[String]$DomainDN = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
		$Object = get-ADSIobject $ObjectName
		$ObjectLocation = [adsi]$object.Path
	try{
		$ObjectLocation.MoveTo($DestinationPath) -erroraction stop
		Write-verbose "Object $ObjectName has been moved successfully"
		}
	catch
		{
		write-warning  "$_.exception.message" 
		}
}

﻿Function Get-ADSIComputer
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
	)#PARAM
	
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
						IF ($DomainDN -notlike "LDAP://*") { $DomainDN = "LDAP://$DomainDN" }#IF
						Write-Verbose -Message "Different Domain specified: $DomainDN"
						$Searcher.SearchRoot = $DomainDN
					}#IF ($PSBoundParameters['DomainDN'])
					
					# Alternate Credentials
					IF ($PSBoundParameters['Credential'])
					{
						Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
						$Domain = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $($Credential.UserName), $($Credential.GetNetworkCredential().password) -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCred
						$Searcher.SearchRoot = $Domain
					}#IF ($PSBoundParameters['Credential'])
					
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
						}#New-Object
					}#FOREACH $Computer
					
					Write-Verbose -Message "ADSI Search completed"
				}#TRY
				CATCH
				{
					Write-Warning -Message ('{0}: {1}' -f $item, $_.Exception.Message)
					IF ($ErrProcessNewObjectSearcher) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object" }
					IF ($ErrProcessNewObjectCred) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object" }
					IF ($ErrProcessNewObjectOutput) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object" }
				}#CATCH
			}#FOREACH $item
			
			
		}#IF $ComputerName
		
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
				}#IF ($PSBoundParameters['DomainDN'])
				
				# Alternate Credentials
				IF ($PSBoundParameters['Credential'])
				{
					Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
					$DomainDN = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $Credential.UserName, $Credential.GetNetworkCredential().password -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCredALL
					$Searcher.SearchRoot = $DomainDN
				}#IF ($PSBoundParameters['Credential'])
				
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
						}#New-Object
					}#TRY
					CATCH
					{
						Write-Warning -Message ('{0}: {1}' -f $Computer, $_.Exception.Message)
						IF ($ErrProcessNewObjectOutputALL) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object" }
					}
				}#FOREACH $Computer
				
				Write-Verbose -Message "ADSI Search completed"
				
			}#TRY
			
			CATCH
			{
				Write-Warning -Message "Something Wrong happened"
				IF ($ErrProcessNewObjectSearcherALL) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object" }
				IF ($ErrProcessNewObjectCredALL) { Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object" }
				
			}#CATCH
		}#ELSE
	}#PROCESS
	END { Write-Verbose -Message "Script Completed" }
}

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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIContact End."
	}
}

function Get-ADSICurrentComputerSite
{
	[System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()
}

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
	
	.NOTES
		Francois-Xavier Cat
		LazyWinAdmin.com
		@lazywinadm
	
	.OUTPUTS
		System.DirectoryServices.ActiveDirectory.Domain
#>
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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
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
	
	.NOTES
		Francois-Xavier Cat
		LazyWinAdmin.com
		@lazywinadm
	
	.OUTPUTS
		System.DirectoryServices.ActiveDirectory.Forest
#>
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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
				
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
		}#try
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#Process
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
				IF ($DomainDN -notlike "LDAP://*") { $DomainDN = "LDAP://$DomainDN" }#IF
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
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			#if ($ProcessErrorGetADSIUser) { Write-Warning -Message "[PROCESS] Issue while getting information on the user using Get-ADSIUser" }
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
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
	
.PARAMETER SamAccountName
	Specify the SamAccountName of the Group
	
.EXAMPLE
	Get-ADSIGroupMembership -SamAccountName TestGroup
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding()]
	PARAM ($SamAccountName)
	BEGIN
	{
		$search = [adsisearcher]"(&(objectCategory=group)(SamAccountName=$SamAccountName))"
	}
	PROCESS
	{
		TRY
		{
			foreach ($member in $search.FindOne().properties.member)
			{
				#User
				#Get-ADSIUser -DistinguishedName $member
				Get-ADSIObject -DistinguishedName $member
				
				#Group
				# need to be done here
			}
		}#try
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#process
	END { Write-Verbose -Message "[END] Function Get-ADSIGroupMembership End." }
}

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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSISite End."
	}
}

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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIOrganizationalUnit End."
	}
}

Function Get-ADSIRootDomain
{
	[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().RootDomain
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
		[String]
		$PropertyType,
		[Parameter(ParameterSetName = 'Default',
				   Mandatory = $true)]
		[String]
		$ClassName,
		[Parameter(ParameterSetName = 'AllClasses',
				   Mandatory = $true)]
		[Switch]
		$AllClasses,
		[Parameter(ParameterSetName = 'FindClasses',
				   Mandatory = $true)]
		[String]
		$FindClassName
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
			}#Switch
		}#ELSE
		
	}#PROCESS
}

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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSISite End."
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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
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
		[String]
		$SamAccountName,
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		[Alias('DomainDN', 'Domain')]
		[String]
		$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		[Alias('ResultLimit', 'Limit')]
		[int]
		$SizeLimit = '100'
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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
	}#PROCESS
	END { Write-Verbose -Message "[END] Function Get-ADSITokenGroup End." }
}#Function

Function Get-ADSITrustRelationShip
{
	[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().GetAllTrustRelationships()
}

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
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
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
				}#Properties
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			}#FOREACH
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
	END { Write-Verbose -Message "[END] Function Get-ADSIUser End." }
}

Function New-ADSIDirectoryContextDomain
{
<#
    .DESCRIPTION
		Function to create an Active Directory Domain DirectoryContext object

	.SYNOPSIS
        Function to create an Active Directory Domain DirectoryContext object

	.PARAMETER DomainName
		Specifies the domain to query.
		Default is the current domain.

	.PARAMETER Credential
		Specifies the alternative credentials to use.
		It will use the current credential if not specified.

	.EXAMPLE
        New-ADSIDirectoryContextDomain
	
    .EXAMPLE
        New-ADSIDirectoryContextDomain -DomainName "Contoso.com" -Cred (Get-Credential)
        
    .EXAMPLE
        $Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($(New-ADSIDirectoryContextDomain -Credential LazyWinAdmin\francois-xavier.cat))
        $Domain.DomainControllers
        $Domain.InfrastructureRoleOwner

	.NOTES
        Francois-Xavier.Cat
        LazyWinAdmin.com
        @lazywinadm
	
		https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.directorycontext(v=vs.110).aspx
#>
	
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
		}#TRY
		CATCH
		{
			
		}
	}#PROCESS
}

Function New-ADSIDirectoryContextForest
{
<#
    .DESCRIPTION
		Function to create an Active Directory Forest DirectoryContext object

	.SYNOPSIS
        Function to create an Active Directory Forest DirectoryContext object

	.PARAMETER ForestName
		Specifies the forest to query.
		Default is the current forest.

	.PARAMETER Credential
		Specifies the alternative credentials to use.
		It will use the current credential if not specified.

	.EXAMPLE
        New-ADSIDirectoryContextForest
	
    .EXAMPLE
        New-ADSIDirectoryContextForest -ForestName "Contoso.com" -Cred (Get-Credential)
        
    .EXAMPLE
        $Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($(New-ADSIDirectoryContextForest -Credential LazyWinAdmin\francois-xavier.cat)))
        $Forest.FindGlobalCatalog()

	.NOTES
        Francois-Xavier.Cat
        LazyWinAdmin.com
        @lazywinadm
	
		https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.directorycontext(v=vs.110).aspx
#>
	
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
		}#TRY
		CATCH
		{
			
		}
	}#PROCESS
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
	PARAM ($GroupSamAccountName, $UserSamAccountName)
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
	PARAM ($GroupSamAccountName, $UserSamAccountName)
	$UserInfo = [ADSI]"$((Get-ADSIUser -SamAccountName $UserSamAccountName).AdsPath)"
	$GroupInfo = [ADSI]"$((Get-ADSIGroup -SamAccountName $GroupSamAccountName).AdsPath)"
	
	#([ADSI]$GroupInfo.ADsPath).IsMember([ADSI]($UserInfo.AdsPath))
	$GroupInfo.IsMember($UserInfo.ADsPath)
	
}

Export-ModuleMember -Function *


