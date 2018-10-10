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
    Get groups of all users in MainGroup 
.EXAMPLE
    Audit-ADSITeamGroups -TeamUsersIdentity @('User1','User2','User3')
    Get groups of all users in the array 
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
    param
    (
        [Parameter(ParameterSetName = 'TeamUsers', Mandatory = $true)]
        [array]$Users,
        
        [Parameter(ParameterSetName = 'Identity', Mandatory = $true)]
        [string]$BaseGroupIdentity,

        [Alias('RunAs')]
        [pscredential]
        [System.Management.Automation.Credential()]
        $Credential = [pscredential]::Empty,

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

        $sw = [Diagnostics.Stopwatch]::StartNew()

        $AllUsersGroups = [Collections.ArrayList]@()

        IF ($PSBoundParameters['BaseGroupIdentity']) 
        {
            $Users = @((Get-ADSIGroupMember -Identity ('{0}' -f $BaseGroupIdentity) -Recurse).SamAccountName)
        }

        Write-Verbose ('{0} - Get-ADSIGroupMember' -f $sw.Elapsed.TotalSeconds)

        $Result = [Collections.ArrayList]@()
        $ResultUsersInfos = [Collections.ArrayList]@()
        $ResultGoupsInfos = [Collections.ArrayList]@()

        foreach ($User in $Users)
        {
            # Get all groups of a user
            $Object = $null
            $UserInfos = Get-ADSIUser -LDAPFilter ('(&(objectClass=user)(samaccountname={0}))' -f $user) -Adsi @ContextSplatting
        
            Write-Verbose ('{0} - {1} Get-ADSIUser' -f $sw.Elapsed.TotalSeconds, $user)


        
            $Usergroups = [Collections.ArrayList]@()

            #Get Primary group

            $BinarySID = $UserInfos.properties.Item('objectSID')
            $SID = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList ($($UserInfos.properties.Item('objectSID')), 0)

            $groupSID = ('{0}-{1}' -f $SID.AccountDomainSid.Value, [string]$UserInfos.properties.Item('primarygroupid'))

            $group = [adsi](('LDAP://<SID={0}>' -f $groupSID))


            $Object = [ordered]@{}
            $Object.name = [string]$group.name
            $Object.description = [string]$group.description
            [void] $Usergroups.add([pscustomobject]$Object)

            $Usermemberof = @(([ADSISEARCHER]('(&(objectCategory=User)(samAccountName={0}))' -f ($user))).Findone().Properties.memberof)
        
            if ($Usermemberof)
            {
                foreach ($item in $Usermemberof)
                {

                    $Object = [ordered]@{}
                    $ADSIusergroup = [adsi]('LDAP://{0}' -f $item)
                    $Object.name = [string]$ADSIusergroup.Properties.name
                    $Object.description = [string]$ADSIusergroup.Properties.description
        
                    [void] $Usergroups.add([pscustomobject]$Object)
                }
            }

            Write-Verbose ('{0} - {1} GetGroups' -f $sw.Elapsed.TotalSeconds, $user)

            [void] $AllUsersGroups.Add($Usergroups)

            $Object = [ordered]@{}
            $Object.SamAccountName = [string]$UserInfos.Properties.Item('SamAccountName')
            $Object.DisplayName = [string]$UserInfos.Properties.Item('DisplayName')
            $Object.Groups = $Usergroups
    
            [void] $ResultUsersInfos.add([pscustomobject]$Object)
        }

        Write-Verbose ('{0} - foreach ($User in $Users)' -f $sw.Elapsed.TotalSeconds)

        $AllUsersGroups = $AllUsersGroups | Sort-Object -Property name -Unique
        $AllUsersGroups = $AllUsersGroups | Sort-Object -Property name
        [void] $ResultGoupsInfos.Addrange($AllUsersGroups)

        Write-Verbose ('{0} - $AllUsersGroups | Sort-Object -Unique' -f $sw.Elapsed.TotalSeconds)

        $ResultAuditUsersGroups = [Collections.ArrayList]@()
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
            Write-Verbose ('{0} - {1} process' -f $sw.Elapsed.TotalSeconds, $item.SamAccountName)

            [void] $ResultAuditUsersGroups.add([pscustomobject]$Object)
        }
        Write-Verbose ('{0} - foreach ($item in $ResultUsersInfos)' -f $sw.Elapsed.TotalSeconds)

        $sw.stop()

        [void] $Result.Add($ResultAuditUsersGroups)
        [void] $Result.Add($ResultGoupsInfos)
        return $Result
    }

}
