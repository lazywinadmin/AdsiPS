function Get-ADSIDomainUser {
    [CmdletBinding()]
    PARAM(
    [Parameter(ParameterSetName="DisplayName")]
    [String]$DisplayName,
    [Parameter(ParameterSetName="SamAccountName")]
    [String]$SamAccountName,
    [Parameter(ParameterSetName="DistinguishedName")]
    [String]$DistinguishedName
    )

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
    foreach ($user in $($Search.FindAll())){
        
        # Define the properties
        #  The properties need to be lowercase!!!!!!!!
        $Properties = @{
            "DisplayName" = $user.properties.displayname -as [string]
            "SamAccountName"    = $user.properties.samaccountname -as [string]
            "Description" = $user.properties.description -as [string]
            "DistinguishedName" = $user.properties.distinguishedname -as [string]
            "ADsPath" = $user.properties.adspath -as [string]
        }
        
        # Output the info
        New-Object -TypeName PSObject -Property $Properties
    }
}

function Get-ADSIDomainGroup {
    [CmdletBinding()]
    PARAM(
    [Parameter(ParameterSetName="DisplayName")]
    [String]$DisplayName,
    [Parameter(ParameterSetName="SamAccountName")]
    [String]$SamAccountName,
    [Parameter(ParameterSetName="DistinguishedName")]
    [String]$DistinguishedName
    )

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
    foreach ($group in $($Search.FindAll())){
        
        # Define the properties
        #  The properties need to be lowercase!!!!!!!!
        $Properties = @{
            "DisplayName" = $group.properties.displayname -as [string]
            "SamAccountName"    = $group.properties.samaccountname -as [string]
            "Description" = $group.properties.description -as [string]
            "DistinguishedName" = $group.properties.distinguishedname -as [string]
            "ADsPath" = $group.properties.adspath -as [string]
        }
        
        # Output the info
        New-Object -TypeName PSObject -Property $Properties
    }
}


function Get-ADSIDomainGroupIManage
{
PARAM($SamAccountName)

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
}


function Get-ADSIDomainGroupMember
{
    PARAM($SamAccountName)

$search = [adsisearcher]"(&(objectCategory=group)(SamAccountName=$SamAccountName))"

foreach ($member in $search.FindOne().properties.member)
{
    Get-ADSIDomainUser -DistinguishedName $member
}
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
    PARAM($GroupSamAccountName,$UserSamAccountName)
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
    PARAM($GroupSamAccountName,$UserSamAccountName)
    $UserInfo = [ADSI]"$((Get-ADSIDomainUser -SamAccountName $UserSamAccountName).AdsPath)"
    $GroupInfo = [ADSI]"$((Get-ADSIDomainGroup -SamAccountName $GroupSamAccountName).AdsPath)"

    IF (-not(Check-ADSIDomainUserIsGroupMember -GroupSamAccountName $GroupSamAccountName -UserSamAccountName $UserSamAccountName))
    {
        Write-Verbose "Adding $UserSamAccountName from $GroupSamAccountName"
        $GroupInfo.Add($UserInfo.ADsPath)
    }
    ELSE {
    
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
    PARAM($GroupSamAccountName,$UserSamAccountName)
    $UserInfo = [ADSI]"$((Get-ADSIDomainUser -SamAccountName $UserSamAccountName).AdsPath)"
    $GroupInfo = [ADSI]"$((Get-ADSIDomainGroup -SamAccountName $GroupSamAccountName).AdsPath)"

    IF (Check-ADSIDomainUserIsGroupMember -GroupSamAccountName $GroupSamAccountName -UserSamAccountName $UserSamAccountName)
    {
        Write-Verbose "Removing $UserSamAccountName from $GroupSamAccountName"
        $GroupInfo.Remove($UserInfo.ADsPath)
    }
    ELSE {
    
        Write-Verbose "$UserSamAccountName is not member of $GroupSamAccountName"
    }
}
