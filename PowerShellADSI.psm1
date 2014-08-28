function Get-ADSIDomainUser
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
.EXAMPLE
	Get-ADSIDomainUser -SamAccountName fxcat
.EXAMPLE
	Get-ADSIDomainUser -DisplayName "Cat, Francois-Xavier"
.EXAMPLE
	Get-ADSIDomainUser -DistinguishedName "CN=Cat\, Francois-Xavier,OU=Admins,DC=FX,DC=local"
.EXAMPLE
    Get-ADSIDomainUser -SamAccountName testuser -Credential (Get-Credential -Credential Msmith)
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "DisplayName")]
		[String]$DisplayName,

		[Parameter(ParameterSetName = "SamAccountName")]
		[String]$SamAccountName,

		[Parameter(ParameterSetName = "DistinguishedName")]
		[String]$DistinguishedName,

        [Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,

		[Parameter()]
		[Alias("DomainDN","Domain")]
        [String]$DomainDistinguishedName=$(([adsisearcher]"").Searchroot.path),

        [Alias("ResultLimit","Limit")]
		[int]$SizeLimit='100'
        
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

			If ($DisplayName)
			{
				$Search.filter = "(&(objectCategory=person)(objectClass=User)(displayname=$DisplayName))"
			}
			IF ($SamAccountName)
			{
				$Search.filter = "(&(objectCategory=person)(objectClass=User)(samaccountname=$SamAccountName))"
			}
			IF ($DistinguishedName)
			{
				$Search.filter = "(&(objectCategory=person)(objectClass=User)(distinguishedname=$distinguishedname))"
			}
            
			IF ($DomainDistinguishedName)
			{
			IF ($DomainDistinguishedName -notlike "LDAP://*") {$DomainDistinguishedName = "LDAP://$DomainDistinguishedName"}#IF
			Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
					$Search.SearchRoot = $DomainDistinguishedName
			}
			
			IF ($PSBoundParameters['Credential'])
			{
			$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName,$($Credential.UserName),$($Credential.GetNetworkCredential().password)
			$Search.SearchRoot = $Cred
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
					"LastLogonTimeStamp" = $user.properties.lastlogontimestamp  -as [string]
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
	END { Write-Verbose -Message "[END] Function Get-ADSIDomainUser End." }
}

function Get-ADSIDomainGroup
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
.PARAMETER Credential
    Specify the Credential to use
.PARAMETER $DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
.PARAMETER SizeLimit
    Specify the number of item(s) to output
.EXAMPLE
	Get-ADSIDomainGroup -SamAccountName TestGroup
.EXAMPLE
	Get-ADSIDomainGroup -Name TestGroup
.EXAMPLE
	Get-ADSIDomainGroup -DistinguishedName "CN=TestGroup,OU=Groups,DC=FX,DC=local"
.EXAMPLE
    Get-ADSIDomainGroup -Name TestGroup -Credential (Get-Credential -Credential 'FX\enduser')
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "Name")]
		[String]$Name,

		[Parameter(ParameterSetName = "SamAccountName")]
		[String]$SamAccountName,

		[Parameter(ParameterSetName = "DistinguishedName")]
		[String]$DistinguishedName,

		[Parameter(ValueFromPipelineByPropertyName=$true)]
		[Alias("Domain","DomainDN")]
	        [String]$DomainDistinguishedName=$(([adsisearcher]"").Searchroot.path),
	
	        [Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,

		[Alias("ResultLimit","Limit")]
		[int]$SizeLimit='100'
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
				$Search.filter = "(&(objectCategory=group)(name=$Name))"
			}
			IF ($SamAccountName)
			{
				$Search.filter = "(&(objectCategory=group)(samaccountname=$SamAccountName))"
			}
			IF ($DistinguishedName)
			{
				$Search.filter = "(&(objectCategory=group)(distinguishedname=$distinguishedname))"
			}
			IF ($DomainDistinguishedName)
			{
			IF ($DomainDistinguishedName -notlike "LDAP://*") {$DomainDistinguishedName = "LDAP://$DomainDistinguishedName"}#IF
				Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
            
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName,$($Credential.UserName),$($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
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
					"Member" = $group.properties.grouptype -as [string]
					"objectcategory" = $group.properties.grouptype -as [string]
					"objectclass" = $group.properties.grouptype -as [string]
					"objectguid" = $group.properties.grouptype -as [string]
					"objectsid" = $group.properties.grouptype -as [string]
<#
adspath
cn
distinguishedname
dscorepropagationdata
grouptype
instancetype
managedby
member
name
objectcategory
objectclass
objectguid
objectsid
samaccountname
samaccounttype
usnchanged
usncreated
whenchanged
whencreated
#>

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
		Write-Verbose -Message "[END] Function Get-ADSIDomainGroup End."
	}
}


function Get-ADSIDomainGroupIManage
{
<#
.SYNOPSIS
	This function retrieve the group that the current user manage in the ActiveDirectory.
	Typically the function will search for group(s) and look at the 'ManagedBy' property where it matches the current user.
.PARAMETER SamAccountName
	Specify the SamAccountName of the Manager of the group
.EXAMPLE
	Get-ADSIDomainGroupIManage -SamAccountName fxcat

	This will list all the group(s) where fxcat is designated as Manager.
#>
	[CmdletBinding()]
	PARAM ($SamAccountName)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			$search = [adsisearcher]"(&(objectCategory=group)(ManagedBy=$((Get-ADSIDomainUser -SamAccountName $SamAccountName).distinguishedname)))"
			Foreach ($group in $search.FindAll())
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
	END { Write-Verbose -Message "[END] Function Get-ADSIDomainGroupIManage End."}
}


function Get-ADSIDomainGroupMember
{
<#
.SYNOPSIS
	This function will list all the member of the specified group
.PARAMETER SamAccountName
	Specify the SamAccountName of the Group
.EXAMPLE
	Get-ADSIDomainGroupMember -SamAccountName TestGroup
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
				Get-ADSIDomainUser -DistinguishedName $member
				
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
	END { Write-Verbose -Message "[END] Function Get-ADSIDomainGroupMember End." }
}

function Check-ADSIDomainUserIsGroupMember
{
<#
.SYNOPSIS
    This function will check if a domain user is member of a domain group

.EXAMPLE
    Check-ADSIDomainUserIsGroupMember -GroupSamAccountName TestGroup -UserSamAccountName Fxcat

    This will return $true or $false depending if the user Fxcat is member of TestGroup
#>
	PARAM ($GroupSamAccountName, $UserSamAccountName)
	$UserInfo = [ADSI]"$((Get-ADSIDomainUser -SamAccountName $UserSamAccountName).AdsPath)"
	$GroupInfo = [ADSI]"$((Get-ADSIDomainGroup -SamAccountName $GroupSamAccountName).AdsPath)"
	
	#([ADSI]$GroupInfo.ADsPath).IsMember([ADSI]($UserInfo.AdsPath))
	$GroupInfo.IsMember($UserInfo.ADsPath)
	
}


function Add-ADSIDomainGroupMember
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
.PARAMETER UserSamAccountName
    Specify the User SamAccountName
.PARAMETER Credential
    Specify the Credential to use
.PARAMETER DomainDN
    Specify the DistinguishedName of the Domain to query
.PARAMETER SizeLimit
    Specify the number of item(s) to output
.EXAMPLE
    Add-ADSIDomainGroupMember -GroupSamAccountName TestGroup -UserSamAccountName francois-xavier.cat -Credential (Get-Credential -Credential SuperAdmin)
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "Name")]
		[String]$GroupName,

		[Parameter(ParameterSetName = "SamAccountName")]
		[String]$GroupSamAccountName,

		[Parameter(ParameterSetName = "DistinguishedName")]
		[String]$GroupDistinguishedName,

        [string]$UserSamAccountName,

		[Parameter(ValueFromPipelineByPropertyName=$true)]
		[Alias("Domain")]
        [String]$DomainDN=$(([adsisearcher]"").Searchroot.path),

        [Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,

		[Alias("ResultLimit","Limit")]
		[int]$SizeLimit='100'
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


			If ($Name)
			{
				$Search.filter = "(&(objectCategory=group)(name=$Name))"
			}
			IF ($SamAccountName)
			{
				$Search.filter = "(&(objectCategory=group)(samaccountname=$SamAccountName))"
			}
			IF ($DistinguishedName)
			{
				$Search.filter = "(&(objectCategory=group)(distinguishedname=$distinguishedname))"
			}
            IF ($DomainDN)
            {
                IF ($DomainDN -notlike "LDAP://*") {$DomainDN = "LDAP://$DomainDN"}#IF
                Write-Verbose -Message "Different Domain specified: $DomainDN"
				$Search.SearchRoot = $DomainDN
            }
            
            IF ($PSBoundParameters['Credential'])
            {
                $Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN,$($Credential.UserName),$($Credential.GetNetworkCredential().password)
                $Search.SearchRoot = $DomainDN
            }

            Write-Verbose -Message "[PROCESS] Resolve the User: $UserSamAccountName"
            $User = Get-ADSIDomainUser -SamAccountName $UserSamAccountName -ErrorAction stop -ErrorVariable ProcessErrorGetADSIDomainUser


            Foreach ($group in $Search.FindAll())
            {
                $GroupObj=Get-ADSIDomainGroup -SamAccountName ($group.properties.samaccountname -as [String])
                IF (-not (Check-ADSIDomainUserIsGroupMember -GroupSamAccountName $GroupObj.samaccountname -UserSamAccountName $UserSamAccountName))
                {
                    Write-verbose -Message "[PROCESS] Group: $($Group.properties.name -as [string])"
                    # Add the user to the group
				    ([ADSI]"$($Group.properties.adspath)").add($User.adspath)
                }
                ELSE
                {
                    Write-Warning -message "$UserSamAccountName is already member of $($GroupObj.samaccountname)"
                }
            }
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
            if($ProcessErrorGetADSIDomainUser){Write-Warning -Message "[PROCESS] Issue while getting information on the user using Get-ADSIDomainUser"}
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Add-ADSIDomainGroupMember End."
	}
}


function Remove-ADSIDomainGroupMember
{
<#
.SYNOPSIS
    This function will remove Domain user from a Domain Group
.EXAMPLE
    Remove-ADSIDomainGroupMember -GroupSamAccountName TestGroup -UserSamAccountName Fxcat

    This will remove the domain user fxcat from the group TestGroup
#>
	[CmdletBinding()]
	PARAM ($GroupSamAccountName, $UserSamAccountName)
	$UserInfo = [ADSI]"$((Get-ADSIDomainUser -SamAccountName $UserSamAccountName).AdsPath)"
	$GroupInfo = [ADSI]"$((Get-ADSIDomainGroup -SamAccountName $GroupSamAccountName).AdsPath)"
	
	IF (Check-ADSIDomainUserIsGroupMember -GroupSamAccountName $GroupSamAccountName -UserSamAccountName $UserSamAccountName)
	{
		Write-Verbose "Removing $UserSamAccountName from $GroupSamAccountName"
		$GroupInfo.Remove($UserInfo.ADsPath)
	}
	ELSE
	{
		
		Write-Verbose "$UserSamAccountName is not member of $GroupSamAccountName"
	}
}

	
function Get-ADSIDomainObject
{
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "SamAccountName")]
		[String]$SamAccountName
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			$Search = [adsisearcher]"(samaccountname=$SamAccountName)"
			# Define the properties
			#  The properties need to be lowercase!!!!!!!!
			$Properties = @{
				"DisplayName" = $group.properties.displayname -as [string]
				"SamAccountName" = $group.properties.samaccountname -as [string]
				"Description" = $group.properties.description -as [string]
				"DistinguishedName" = $group.properties.distinguishedname -as [string]
				"ADsPath" = $group.properties.adspath -as [string]
			}
			
			# Output the info
			New-Object -TypeName PSObject -Property $Properties
		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIDomainObject End."
	}
}


Function Get-ADSIDomainComputer {
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
		NAME:	FUNCT-AD-COMPUTER-Get-DomainComputer.ps1
		AUTHOR:	Francois-Xavier CAT 
		DATE:	2013/10/26
		EMAIL:	info@lazywinadmin.com
		WWW:	www.lazywinadmin.com
		TWITTER:@lazywinadm

		VERSION HISTORY:
		1.0 2013.10.26
			Initial Version
#>

    [CmdletBinding()]
    PARAM(
        [Parameter(ValueFromPipelineByPropertyName=$true,
					ValueFromPipeline=$true)]
		[Alias("Computer")]
        [String[]]$ComputerName,
        
		[Alias("ResultLimit","Limit")]
		[int]$SizeLimit='100',
		
		[Parameter(ValueFromPipelineByPropertyName=$true)]
		[Alias("Domain")]
        [String]$DomainDN=$(([adsisearcher]"").Searchroot.path),
	
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty

	)#PARAM

    PROCESS{
		IF ($ComputerName){
			Write-Verbose -Message "One or more ComputerName specified"
            FOREACH ($item in $ComputerName){
				TRY{
					# Building the basic search object with some parameters
                    Write-Verbose -Message "COMPUTERNAME: $item"
					$Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectSearcher
					$Searcher.Filter = "(&(objectCategory=Computer)(name=$item))"
                    $Searcher.SizeLimit = $SizeLimit
					$Searcher.SearchRoot = $DomainDN
				
				    # Specify a different domain to query
                    IF ($PSBoundParameters['DomainDN']){
                        IF ($DomainDN -notlike "LDAP://*") {$DomainDN = "LDAP://$DomainDN"}#IF
                        Write-Verbose -Message "Different Domain specified: $DomainDN"
					    $Searcher.SearchRoot = $DomainDN}#IF ($PSBoundParameters['DomainDN'])
				
				    # Alternate Credentials
				    IF ($PSBoundParameters['Credential']) {
					    Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
					    $Domain = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN,$($Credential.UserName),$($Credential.GetNetworkCredential().password) -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCred
					    $Searcher.SearchRoot = $Domain}#IF ($PSBoundParameters['Credential'])

					# Querying the Active Directory
					Write-Verbose -Message "Starting the ADSI Search..."
	                FOREACH ($Computer in $($Searcher.FindAll())){
                        Write-Verbose -Message "$($Computer.properties.name)"
	                    New-Object -TypeName PSObject -ErrorAction 'Continue' -ErrorVariable ErrProcessNewObjectOutput -Property @{
	                        "Name" = $($Computer.properties.name)
	                        "DNShostName"    = $($Computer.properties.dnshostname)
	                        "Description" = $($Computer.properties.description)
                            "OperatingSystem"=$($Computer.Properties.operatingsystem)
                            "WhenCreated" = $($Computer.properties.whencreated)
                            "DistinguishedName" = $($Computer.properties.distinguishedname)}#New-Object
	                }#FOREACH $Computer

					Write-Verbose -Message "ADSI Search completed"
	            }#TRY
				CATCH{ 
					Write-Warning -Message ('{0}: {1}' -f $item, $_.Exception.Message)
					IF ($ErrProcessNewObjectSearcher){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object"}
					IF ($ErrProcessNewObjectCred){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object"}
					IF ($ErrProcessNewObjectOutput){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object"}
				}#CATCH
            }#FOREACH $item
			

		}#IF $ComputerName
		
		ELSE {
			Write-Verbose -Message "No ComputerName specified"
            TRY{
				# Building the basic search object with some parameters
                Write-Verbose -Message "List All object"
				$Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectSearcherALL
				$Searcher.Filter = "(objectCategory=Computer)"
                $Searcher.SizeLimit = $SizeLimit
				
				# Specify a different domain to query
                IF ($PSBoundParameters['DomainDN']){
                    $DomainDN = "LDAP://$DomainDN"
                    Write-Verbose -Message "Different Domain specified: $DomainDN"
					$Searcher.SearchRoot = $DomainDN}#IF ($PSBoundParameters['DomainDN'])
				
				# Alternate Credentials
				IF ($PSBoundParameters['Credential']) {
					Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
					$DomainDN = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $Credential.UserName,$Credential.GetNetworkCredential().password -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCredALL
					$Searcher.SearchRoot = $DomainDN}#IF ($PSBoundParameters['Credential'])
				
				# Querying the Active Directory
                Write-Verbose -Message "Starting the ADSI Search..."
	            FOREACH ($Computer in $($Searcher.FindAll())){
					TRY{
	                    Write-Verbose -Message "$($Computer.properties.name)"
	                    New-Object -TypeName PSObject -ErrorAction 'Continue' -ErrorVariable ErrProcessNewObjectOutputALL -Property @{
	                        "Name" = $($Computer.properties.name)
	                        "DNShostName"    = $($Computer.properties.dnshostname)
	                        "Description" = $($Computer.properties.description)
	                        "OperatingSystem"=$($Computer.Properties.operatingsystem)
	                        "WhenCreated" = $($Computer.properties.whencreated)
	                        "DistinguishedName" = $($Computer.properties.distinguishedname)}#New-Object
					}#TRY
					CATCH{
						Write-Warning -Message ('{0}: {1}' -f $Computer, $_.Exception.Message)
						IF ($ErrProcessNewObjectOutputALL){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object"}
					}
                }#FOREACH $Computer

				Write-Verbose -Message "ADSI Search completed"
				
            }#TRY
			
            CATCH{
				Write-Warning -Message "Something Wrong happened"
				IF ($ErrProcessNewObjectSearcherALL){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object"}
				IF ($ErrProcessNewObjectCredALL){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object"}
				
            }#CATCH
		}#ELSE
    }#PROCESS
    END{Write-Verbose -Message "Script Completed"}
}#function Get-ADSIDomainComputer
