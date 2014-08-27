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
.EXAMPLE
	Get-ADSIDomainUser -SamAccountName fxcat
.EXAMPLE
	Get-ADSIDomainUser -DisplayName "Cat, Francois-Xavier"
.EXAMPLE
	Get-ADSIDomainUser -DistinguishedName "CN=Cat\, Francois-Xavier,OU=Admins,DC=FX,DC=local"
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "DisplayName")]
		[String]$DisplayName,
		[Parameter(ParameterSetName = "SamAccountName")]
		[String]$SamAccountName,
		[Parameter(ParameterSetName = "DistinguishedName")]
		[String]$DistinguishedName
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			If ($DisplayName)
			{
				$Search = [adsisearcher]"(&(objectCategory=person)(objectClass=User)(displayname=$DisplayName))"
			}
			IF ($SamAccountName)
			{
				$Search = [adsisearcher]"(&(objectCategory=person)(objectClass=User)(samaccountname=$SamAccountName))"
			}
			IF ($DistinguishedName)
			{
				$Search = [adsisearcher]"(&(objectCategory=person)(objectClass=User)(distinguishedname=$distinguishedname))"
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
.PARAMETER DisplayName
	Specify the DisplayName of the group
.PARAMETER DistinguishedName
	Specify the DistinguishedName path of the group
.EXAMPLE
	Get-ADSIDomainGroup -SamAccountName TestGroup
.EXAMPLE
	Get-ADSIDomainGroup -DisplayName TestGroup
.EXAMPLE
	Get-ADSIDomainGroup -DistinguishedName "CN=TestGroup,OU=Groups,DC=FX,DC=local"
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "DisplayName")]
		[String]$DisplayName,
		[Parameter(ParameterSetName = "SamAccountName")]
		[String]$SamAccountName,
		[Parameter(ParameterSetName = "DistinguishedName")]
		[String]$DistinguishedName
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			If ($DisplayName)
			{
				$Search = [adsisearcher]"(&(objectCategory=group)(displayname=$DisplayName))"
			}
			IF ($SamAccountName)
			{
				$Search = [adsisearcher]"(&(objectCategory=group)(samaccountname=$SamAccountName))"
			}
			IF ($DistinguishedName)
			{
				$Search = [adsisearcher]"(&(objectCategory=group)(distinguishedname=$distinguishedname))"
			}
			foreach ($group in $($Search.FindAll()))
			{
				
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
    This function will Add Domain user from a Domain Group
.EXAMPLE
    Add-ADSIDomainGroupMember -GroupSamAccountName TestGroup -UserSamAccountName Fxcat

    This will add the domain user fxcat to the group TestGroup
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(Mandatory = $true)]
		$GroupSamAccountName,
		[Parameter(Mandatory = $true)]
		$UserSamAccountName
	)
	
	$UserInfo = [ADSI]"$((Get-ADSIDomainUser -SamAccountName $UserSamAccountName).AdsPath)"
	$GroupInfo = [ADSI]"$((Get-ADSIDomainGroup -SamAccountName $GroupSamAccountName).AdsPath)"
	
	IF (-not (Check-ADSIDomainUserIsGroupMember -GroupSamAccountName $GroupSamAccountName -UserSamAccountName $UserSamAccountName))
	{
		Write-Verbose "Adding $UserSamAccountName from $GroupSamAccountName"
		$GroupInfo.Add($UserInfo.ADsPath)
	}
	ELSE
	{
		
		Write-Verbose "$UserSamAccountName is already member of $GroupSamAccountName"
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
