Function Compare-ADSITeamGroups
{
    <#
.SYNOPSIS
    Function to compare AD groups of a team

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
    Compare-ADSITeamGroups -BaseGroupIdentity 'MainGroup'

    Get groups of all users in MainGroup

.EXAMPLE
    Compare-ADSITeamGroups -TeamUsersIdentity @('User1','User2','User3')

    Get groups of all users in the array

.EXAMPLE
    Compare-ADSITeamGroups -TeamUsersIdentity @('User1','User2','User3') -Credential (Get-Credential)

    Use a different credential to perform the comparison

.EXAMPLE
    Compare-ADSITeamGroups -TeamUsersIdentity @('User1','User2','User3') -DomainName "CONTOSO.local"

    Use a different domain name to perform the comparison

.EXAMPLE
    Compare-ADSITeamGroups -BaseGroupIdentity 'MainGroup' -DomainDistinguishedName 'DC=CONTOSO,DC=local'

    Use a different domain distinguished name to perform the comparison

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding()]
    param
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
        [ValidateScript( { if ($_ -match '^(?:(?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$')
                {
                    $true
                }
                else
                {
                    throw ("DomainName must be FQDN. Ex: contoso.locale - Hostname like '{0}' is not working" -f $_)
                } })]
        [String]$DomainName
    )

    begin
    {
        # Create Context splatting
        $ContextSplatting = @{ }
        if ($PSBoundParameters['Credential'])
        {
            Write-Verbose "[$FunctionName] Found Credential Parameter"
            $ContextSplatting.Credential = $Credential
        }
        if ($PSBoundParameters['DomainName'])
        {
            Write-Verbose "[$FunctionName] Found DomainName Parameter"
            $ContextSplatting.DomainName = $DomainName
        }
    }
    process
    {
        $AllUsersGroups = @()

        if ($PSBoundParameters['BaseGroupIdentity'])
        {
            Write-Verbose "[$FunctionName] Found BaseGroupIdentity Parameter"
            $TeamUsersIdentity = @((Get-ADSIGroupMember -Identity ('{0}' -f $BaseGroupIdentity) -Recurse).SamAccountName)
        }

        $Result = @()
        $ResultUsersInfos = @()
        $ResultGoupsInfos = @()

        foreach ($User in $TeamUsersIdentity)
        {
            # Get all groups of a user
            Write-Verbose "[$FunctionName] Trying to find All Groups of a user"
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
        $ResultGoupsInfos += $AllUsersGroups

        $ResultAuditUsersGroups = @()
        foreach ($item in $ResultUsersInfos)
        {
            $Object = $null
            $Object = [ordered]@{}
            $Object.SamAccountName = $item.SamAccountName
            $Object.DisplayName = $item.DisplayName

            foreach ($group in $AllUsersGroups)
            {
                if ($item.Groups.name -contains $group.name)
                {
                    $Object.$($group.name) = 'x'
                }
                else
                {
                    $Object.$($group.name) = ''
                }

            }

            $ResultAuditUsersGroups += [pscustomobject]$Object
        }

        $Result += $ResultAuditUsersGroups, $ResultGoupsInfos
        $Result
    }

}