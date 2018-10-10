Function Get-ADSIPrincipalGroupMembership
{
    <#
.SYNOPSIS
    Function to retrieve groups from a user in Active Directory

.DESCRIPTION
    Get all AD groups of a user, primary one and others

.PARAMETER Identity
    Specifies the Identity of the User

    You can provide one of the following properties
    DistinguishedName
    Guid
    Name
    SamAccountName
    Sid
    UserPrincipalName

    Those properties come from the following enumeration:
    System.DirectoryServices.AccountManagement.IdentityType

.PARAMETER Credential
    Specifies the alternative credential to use.
    By default it will use the current user windows credentials.

.PARAMETER DomainName
    Specifies the alternative Domain where the user should be created
    By default it will use the current domain.

.PARAMETER NoResultLimit
    Remove the SizeLimit of 1000

    SizeLimit is useless, it can't go over the server limit which is 1000 by default

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
        [Parameter(Mandatory = $true, ParameterSetName = "Identity")]
        [string]$Identity,
        
        [Parameter(Mandatory = $true, ParameterSetName = "UserInfos")]
        $UserInfos,
        
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(ParameterSetName = "Identity")]
        [String]$DomainName,
        
        [Parameter(ParameterSetName = "Identity")]
        [Switch]$NoResultLimit
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
        IF ($PSBoundParameters['NoResultLimit'])
        {
            $ContextSplatting.NoResultLimit = $true 
        }
    }
    PROCESS
    {
        $Object = $Usergroups = $null
        
        IF ($PSBoundParameters['UserInfos'])
        {
            $UserInfosMoreProperties = $UserInfos.GetUnderlyingObject()
        }
        else
        {
            $UserInfos = Get-ADSIUser -Identity $Identity @ContextSplatting
            $UserInfosMoreProperties = $UserInfos.GetUnderlyingObject()
            
        }

        $Usergroups = @()

        #Get Primary group
        $SID = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList ($($UserInfosMoreProperties.properties.Item('objectSID')), 0)
        $groupSID = ('{0}-{1}' -f $SID.AccountDomainSid.Value, [string]$UserInfosMoreProperties.properties.Item('primarygroupid'))
        $group = [adsi]("LDAP://<SID=$groupSID>")

        $Object = [ordered]@{}
        $Object.name = [string]$group.name
        $Object.description = [string]$group.description

        $Usergroups += [pscustomobject]$Object

        $Usermemberof = $UserInfosMoreProperties.memberOf
        
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
        return , $Usergroups
    }        
}