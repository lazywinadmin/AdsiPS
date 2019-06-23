function Get-ADSIUserPrimaryGroup
{
    <#
            .SYNOPSIS
            Function to retrieve User's primary group

            .DESCRIPTION
            Get primary AD group of a user

            .PARAMETER Identity
            Specifies the Identity of the User
            Uses the return of "Get-ADSIUser"

            .PARAMETER ReturnNameAndDescriptionOnly
            Returns a PSCustomObject of just the name and description
            ex: $return = [pscustomobject]@{
            'name'        = [string]$primaryGroup.Properties.name
            'description' = [string]$primaryGroup.Properties.description
            }

            .EXAMPLE
            Get-ADSIUserPrimaryGroup -Identity (Get-ADSIUser 'User1')

            Get primary AD group of user User1

            .NOTES
            https://github.com/lazywinadmin/ADSIPS
            CHANGE LOG
            -1.0 | 2019/06/22 | Matt Oestreich (oze4)
                - Initial creation
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [System.DirectoryServices.AccountManagement.AuthenticablePrincipal]$Identity,
        
        [Parameter(Mandatory=$false)]
        [switch]$ReturnNameAndDescriptionOnly
    )

    try { 
        $UnderlyingProperties = $Identity.GetUnderlyingObject()
        $userSid  = (New-Object System.Security.Principal.SecurityIdentifier ($($UnderlyingProperties.properties.objectSID), 0)).AccountDomainSid.Value
        $groupSid = ('{0}-{1}' -f $userSid, $UnderlyingProperties.properties.primarygroupid.ToString())
        $primaryGroup = [adsi]("LDAP://<SID=$groupSid>")
        if ($PSBoundParameters["ReturnNameAndDescriptionOnly"]) {
            [pscustomobject]@{
                'name'        = [string]$primaryGroup.Properties.name
                'description' = [string]$primaryGroup.Properties.description
            }
        } else {
            $primaryGroup
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }

}
