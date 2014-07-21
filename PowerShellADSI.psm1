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


function Get-ADSIMyManagedGroup
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


function Get-ADSIGroupMember
{
    PARAM($SamAccountName)

$search = [adsisearcher]"(&(objectCategory=group)(SamAccountName=$SamAccountName))"

foreach ($member in $search.FindOne().properties.member)
{
    Get-ADSIDomainUser -DistinguishedName $member
}
}

function Add-ADSIGroupMember
{
    PARAM($GroupName,$SamAccountName)


}
