Function Audit-ADSITeamGroups
{
    <#
.SYNOPSIS
    Function to Audit AD groups of a team 

.DESCRIPTION
    See if all your team's members have the same AD groups. Make a snapshot of your team's members current AD groups

.PARAMETER Credential
    Specifies alternative credential

.PARAMETER DomainName
    Specifies the Domain Name where the function should look

.PARAMETER BaseGroupIdentity
    Specifies the Identity of one team's users group
    You can provide one of the following properties
    DistinguishedName
    Guid
    Name
    SamAccountName
    Sid
    UserPrincipalName
    Those properties come from the following enumeration:
    System.DirectoryServices.AccountManagement.IdentityType

.PARAMETER TeamUsersIdentity
    Specifies the Identity of team's users (array)

.EXAMPLE
    Audit-ADSITeamGroups -BaseGroupIdentity 'MainGroup'

    Get groups of all users IN MainGroup 

.EXAMPLE
    Audit-ADSITeamGroups -TeamUsersIdentity @('User1','User2','User3')

    Get groups of all users IN the array 

.EXAMPLE
    Audit-ADSITeamGroups -TeamUsersIdentity @('User1','User2','User3') -Credential (Get-Credential)

    Use a different credential to perform the audit

.EXAMPLE
    Audit-ADSITeamGroups -TeamUsersIdentity @('User1','User2','User3') -DomainName "CONTOSO.local"

    Use a different domain name to perform the audit

.EXAMPLE
    Audit-ADSITeamGroup -BaseGroupIdentity 'MainGroup' -DomainDistinguishedName 'DC=CONTOSO,DC=local'

    Use a different domain distinguished name to perform the audit

.NOTES
    Christophe Kumor
    https://christophekumor.github.io 
    github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(ParameterSetName = 'TeamUsers', Mandatory = $true)]
        [array]$TeamUsersIdentity,
        
        [Parameter(ParameterSetName = 'Identity', Mandatory = $true)]
        [string]$BaseGroupIdentity,

        [Alias('RunAs')]
        [System.Management.Automation.pscredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.pscredential]::Empty,

        [Alias('Domain')]
        [ValidateScript( { IF ($_ -match '^(?:(?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$')
                {
                    $true
                }
                ELSE
                {
                    THROW ("DomainName must be FQDN. Ex: contoso.locale - Hostname like '{0}' is not working" -f $_)
                } })]
        [String]$DomainName
    )

    BEGIN
    {
        # Create Context splatting
        $ContextSplatting = @{ }
        IF ($PSBoundParameters['Credential'])
        {
            $ContextSplatting.Credential = $Credential
        }
        IF ($PSBoundParameters['DomainName'])
        {
            $ContextSplatting.DomainName = $DomainName
        }
    }
    PROCESS
    {
        $AllUsersGroups = @()

        IF ($PSBoundParameters['BaseGroupIdentity'])
        {
            $TeamUsersIdentity = @((Get-ADSIGroupMember -Identity ('{0}' -f $BaseGroupIdentity) -Recurse).SamAccountName)
        }

        $Result = @()
        $ResultUsersInfos = @()
        $ResultGoupsInfos = @()

        FOREACH ($User IN $TeamUsersIdentity)
        {
            # Get all groups of a user
            $Usergroups = $null
            $UserInfos = Get-ADSIUser -Identity $user @ContextSplatting

            $Usergroups = Get-ADSIPrincipalGroupMembership -UserInfos $UserInfos

            $AllUsersGroups += $Usergroups

            $ResultUsersInfos += [pscustomobject]@{
                SamAccountName = [string]$UserInfos.name
                DisplayName    = [string]$UserInfos.description
                Groups         = $Usergroups
            }
        }

        $AllUsersGroups = $AllUsersGroups | Sort-Object -Property name -Unique
        #$AllUsersGroups = $AllUsersGroups | Sort-Object -Property name
        $ResultGoupsInfos += $AllUsersGroups

        $ResultAuditUsersGroups = @()
        FOREACH ($item IN $ResultUsersInfos)
        {
            $Object = $null
            $Object = [ordered]@{}
            $Object.SamAccountName = $item.SamAccountName
            $Object.DisplayName = $item.DisplayName

            FOREACH ($group IN $AllUsersGroups)
            {
                IF ($item.Groups.name -contains $group.name)
                {
                    $Object.$($group.name) = 'x'
                }
                ELSE
                {
                    $Object.$($group.name) = ''
                }

            }

            $ResultAuditUsersGroups += [pscustomobject]$Object
        }

        $Result += ,$ResultAuditUsersGroups
        $Result += ,$ResultGoupsInfos
        $Result
    }

}