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

            .EXAMPLE
            Get-ADSIPrincipalGroupMembership -UserInfos (Get-ADSIUser -Identity "User1")

            Get all ad groups of User1 using type System.DirectoryServices.AccountManagement.AuthenticablePrincipal
    
            .EXAMPLE
            Get-ADSIPrincipalGroupMembership -UserInfos (Get-ADSIUser -Identity "User1" -DomainName "CONTOSO.local")

            Get all ad groups of User1 using type System.DirectoryServices.AccountManagement.AuthenticablePrincipal on a different domain

            .EXAMPLE
            Get-ADSIPrincipalGroupMembership -GroupInfos (Get-ADSIGroup -Identity "Group1")

            Get all ad groups of Group1 using type System.DirectoryServices.AccountManagement.Principal
    
            .EXAMPLE
            Get-ADSIPrincipalGroupMembership -GroupInfos (Get-ADSIGroup -Identity "Group1" -DominName "CONTOSO.local")

            Get all ad groups of Group1 using type System.DirectoryServices.AccountManagement.Principal on a different domain

            .NOTES
            https://github.com/lazywinadmin/ADSIPS
            CHANGE LOG
            - 0.1 | 2019/06/22 | Matt Oestreich (oze4)
                - Initial Change Log creation
                - Fixed issue 70 where primary group was not being pulled in for users
            - 0.2 | 2019/11/04 | Matt Oestreich (oze4)
                - Fixed issue 98
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
        [String]$DomainName
    )

    begin
    {
        # Stores our output
        $ObjectGroups = @()

        switch($PSBoundParameters.Keys)
        {
            'UserInfos'  { 
                $UnderlyingProperties = $UserInfos.GetUnderlyingObject()
                $ObjectGroups += Get-ADSIUserPrimaryGroup -Identity $UserInfos -ReturnNameAndDescriptionOnly
            }

            'GroupInfos' {
                $UnderlyingProperties = $GroupInfos.GetUnderlyingObject()
            }
            
            'Identity'   {

                $ObjectSplatting = @{}
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
                        if ($ObjectSplatting) { $FoundObject = Get-ADSIObject @splat @ObjectSplatting } 
                        else { $FoundObject = Get-ADSIObject @splat }
                    } catch {
                        # do nothing, only here to suppress errors
                    } 
                        
                    if ($FoundObject -ne $null) { 
                        $FoundObjectObjectClass = $FoundObject.objectclass.Split(" ")
                        break; 
                    }
                }
                
                try {
                    if (
                        ($FoundObjectObjectClass -contains "person") -or 
                        ($FoundObjectObjectClass -contains "user") -and 
                        ($FoundObjectObjectClass -notcontains "computer") -and
                        ($FoundObjectObjectClass -notcontains "group")
                    ) {
                        $UserInfos = Get-ADSIUser -Identity $FoundObject.samaccountName
                        $UnderlyingProperties = $UserInfos.GetUnderlyingObject()
                        $ObjectGroups += Get-ADSIUserPrimaryGroup -Identity $UserInfos -ReturnNameAndDescriptionOnly
                    } elseif ($FoundObjectObjectClass -contains "group") {
                        $GroupInfos = Get-ADSIGroup -Identity $FoundObject.samaccountName
                        $UnderlyingProperties = $GroupInfos.GetUnderlyingObject()
                    } elseif ($FoundObjectObjectClass -contains "computer") {
                        $UserInfos = Get-ADSIComputer -Identity $FoundObject.samaccountName 
                        $UnderlyingProperties = $UserInfos.GetUnderlyingObject() 
                        $ObjectGroups += Get-ADSIUserPrimaryGroup -Identity $UserInfos -ReturnNameAndDescriptionOnly 
                    }
                } catch {
                    $PSCmdlet.ThrowTerminatingError($_)                                       
                }
                
            }
        }
    }
    process
    {
    
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
