function Get-ADSIFsmo
{
<#
.SYNOPSIS
    This function will query Active Directory for all the Flexible Single Master Operation (FSMO) role owner.

.PARAMETER Credential
    Specify the Credential to use

.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query

.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.

.NOTES
    Francois-Xavier Cat
    LazyWinAdmin.com
    @lazywinadm
#>
    [CmdletBinding()]
    PARAM (
        [Parameter()]
        [Alias("Domain", "DomainDN")]
        [String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),

        [Alias("RunAs")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Alias("ResultLimit", "Limit")]
        [int]$SizeLimit = '100'
    )
    BEGIN { }
    PROCESS
    {
        TRY
        {
            # Building the basic search object with some parameters
            $Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
            $Search.SizeLimit = $SizeLimit
            $Search.Filter = "((fSMORoleOwner=*))"

            IF ($PSBoundParameters['DomainDistinguishedName'])
            {
                IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
                Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
                $Search.SearchRoot = $DomainDistinguishedName
            }
            IF ($PSBoundParameters['Credential'])
            {
                Write-Verbose -Message "[PROCESS] Different Credential specified: $($credential.username)"
                $Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
                $Search.SearchRoot = $Cred
            }
            If (-not $PSBoundParameters["SizeLimit"])
            {
                Write-Warning -Message "Default SizeLimit: 100 Results"
            }

            foreach ($FSMO in $($Search.FindAll()))
            {
                # Define the properties
                #  The properties need to be lowercase!!!!!!!!
                $FSMO.properties

                # Output the info
                #New-Object -TypeName PSObject -Property $Properties
<#

#'PDC FSMO
(&(objectClass=domainDNS)(fSMORoleOwner=*))

#'Rid FSMO
(&(objectClass=rIDManager)(fSMORoleOwner=*))

#'Infrastructure FSMO

(&(objectClass=infrastructureUpdate)(fSMORoleOwner=*))


#'Schema FSMO
(&(objectClass=dMD)(fSMORoleOwner=*))
OR [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema().SchemaRoleOwner

'Domain Naming FSMO
(&(objectClass=crossRefContainer)(fSMORoleOwner=*))

#>


            }
        }#TRY
        CATCH
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }#PROCESS
    END
    {
        Write-Verbose -Message "[END] Function Get-ADSIFsmo End."
    }
}