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

.PARAMETER UserInfos
    UserInfos is a UserPrincipal object.
    Type System.DirectoryServices.AccountManagement.AuthenticablePrincipal

.PARAMETER GroupInfos
    GroupInfos is a GroupPrincipal object.
    Type System.DirectoryServices.AccountManagement.Principal

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
    Get-ADSIPrincipalGroupMembership -Identity 'Group1'
    Get all AD groups of group Group1

.EXAMPLE
    Get-ADSIPrincipalGroupMembership -Identity 'Group1' -Credential (Get-Credential)
    Use a different credential to perform the query

.EXAMPLE
    Get-ADSIPrincipalGroupMembership -Identity 'Group1' -DomainName "CONTOSO.local"
    Use a different domain name to perform the query

.EXAMPLE *** this is incorrect ***
    Get-ADSIPrincipalGroupMembership -Identity 'User1' -DomainDistinguishedName 'DC=CONTOSO,DC=local'
    Use a different domain distinguished name to perform the query

.NOTES
    https://github.com/lazywinadmin/ADSIPS

.NOTES (5/22/2019)
    [Matthew Oestreich]::Info(https://mattoestrei.ch, https://github.com/oze4, matthewpoestreich@gmail.com)
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Identity")]
        [string]$Identity,

        [Parameter(Mandatory = $true, ParameterSetName = "UserInfos")]
        [System.DirectoryServices.AccountManagement.AuthenticablePrincipal]$UserInfos,

        [Parameter(Mandatory = $true, ParameterSetName = "GroupInfos")]
        [System.DirectoryServices.AccountManagement.Principal]$GroupInfos,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(ParameterSetName = "Identity")]
        [String]$DomainName,

        [Parameter(ParameterSetName = "Identity")]
        [Switch]$NoResultLimit
    )

    begin
    {

        switch($PSBoundParameters.Keys)
        {
            'UserInfos'  { 
                $UnderlyingProperties = $UserInfos.GetUnderlyingObject() 
            }

            'GroupInfos' {
                $UnderlyingProperties = $GroupInfos.GetUnderlyingObject()
            }
            
            'Identity'   {

                # If the user supplies a GroupPrincipal or UserPrincipal under the 'Identity' parameter
                if (($Identity.GetType().Name -eq "GroupPrincipal") -or ($Identity.GetType().Name -eq "UserPrincipal")) {
                                                
                    $UnderlyingProperties = $Identity.GetUnderlyingObject()                

                } else {
                    
                    $ObjectSplatting  = @{}

                    if ($PSBoundParameters["DomainName"]) {                        
                        # Turn Domain Name into DN
                        $ObjectSplatting.DomainDistinguishedName = ($DomainName.Split(".").ForEach({ "DC=$($_)," }) -join '').TrimEnd(',')                        
                    }

                    if ($PSBoundParameters["Credential"]) {
                        $ObjectSplatting.Credential  = $Credential
                    }
                                    
                    $FoundObject = $null
                    # Get the ADSIObject for what we were provided
                    foreach($IdType in [System.DirectoryServices.AccountManagement.IdentityType].GetEnumNames()) {                        
                        $splat = @{ 
                            $IdType = $Identity
                        }                        
                        
                        try { 
                            $FoundObject = Get-ADSIObject @splat @ObjectSplatting
                        } catch {
                            # do nothing, only here to suppress errors
                        } 
                        
                        if ($FoundObject -ne $null) { 
                            $FoundObjectObjectClass = $FoundObject.objectclass.Split(" ")
                            break; 
                        }
                    }

                    if ($FoundObjectObjectClass -contains "person" -or $FoundObjectObjectClass -contains "user") {
                        $UserInfos = Get-ADSIUser -Identity $FoundObject.samaccountName
                        $UnderlyingProperties = $UserInfos.GetUnderlyingObject()
                    }

                    if ($FoundObjectObjectClass -contains "group") {
                        $GroupInfos = Get-ADSIGroup -Identity $FoundObject.samaccountName
                        $UnderlyingProperties = $GroupInfos.GetUnderlyingObject()
                    }
                }
            }
        }
    }
    process
    {

        # I didn't understand the point in wasting that IO to get Primary Group, when nothing special was done with it.  
        # Getting groups using only the code below returns the same groups with or without the "Get Primary Group" code.
        # In the return of this function, the Primary Group was not returned any different than a regular group.

        $ObjectGroups   = @()        
        $Objectmemberof = $UnderlyingProperties.memberOf

        if ($Objectmemberof)
        {
            foreach ($item in $Objectmemberof)
            {
                $ADSIobjectgroup = [adsi]"LDAP://$item"

                $ObjectGroups += [pscustomobject]@{
                    'name'        = [string]$ADSIobjectgroup.Properties.name
                    'description' = [string]$ADSIobjectgroup.Properties.description
                }
            }
        }
        
        $ObjectGroups
    }
}
