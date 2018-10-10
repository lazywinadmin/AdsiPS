Function Get-ADSIPrincipalGroupMembership
{
    <#
.SYNOPSIS
    Function to retrieve groups from a user in Active Directory

.DESCRIPTION
    Get all AD groups of a user, primary one and others

.PARAMETER Credential
    Specifies alternative credential

.PARAMETER DomainName
    Specifies the Domain Name where the function should look

.PARAMETER samaccountname
    Specifies the samaccountname of the user

.EXAMPLE
    Get-ADSIPrincipalGroupMembership -Identity 'User1'

    Get all AD groups of user User1

.EXAMPLE
    Get-ADSIPrincipalGroupMembership -Identity 'User1' -Credential (Get-Credential)
    
    Use a different credential to perform the query
    
.EXAMPLE
    Get-ADSIPrincipalGroupMembership -Identity 'User1' -DomainName "CONTOSO.local"

    Use a different domain name to perform the query

.EXAMPLE
    Get-ADSIPrincipalGroupMembership -Identity 'User1' -DomainDistinguishedName 'DC=CONTOSO,DC=local'

    Use a different domain distinguished name to perform the query

.NOTES
    Christophe Kumor
    https://christophekumor.github.io 

    github.com/lazywinadmin/ADSIPS
#>
    
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$samaccountname,

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
                    throw "DomainName must be FQDN. Ex: contoso.locale - Hostname like '$_' is not working"
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
        $Object = $null
        $UserInfos = Get-ADSIUser -LDAPFilter "(&(objectClass=user)(samaccountname=$samaccountname))" -Adsi @ContextSplatting

        $Usergroups = @()

        #Get Primary group
        $BinarySID = $UserInfos.properties.Item('objectSID')
        $SID = New-Object System.Security.Principal.SecurityIdentifier ($($UserInfos.properties.Item('objectSID')), 0)

        $groupSID = ('{0}-{1}' -f $SID.AccountDomainSid.Value, [string]$UserInfos.properties.Item('primarygroupid'))

        $group = [adsi]("LDAP://<SID=$groupSID>")

        $Object = [ordered]@{}
        $Object.name = [string]$group.name
        $Object.description = [string]$group.description

        $Usergroups += [pscustomobject]$Object

        $Usermemberof = @(([ADSISEARCHER]"(&(objectCategory=User)(samAccountName=$($samaccountname)))").Findone().Properties.memberof)
        
        if ($Usermemberof)
        {
            foreach ($item in $Usermemberof)
            {
                $Object = [ordered]@{}
                $ADSIusergroup = [adsi]"LDAP://$item"
                $Object.name = [string]$ADSIusergroup.Properties.name
                $Object.description = [string]$ADSIusergroup.Properties.description

                $Usergroups += [pscustomobject]$Object
            }
        }
        return ,$Usergroups
    }        
}