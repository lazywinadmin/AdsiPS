function Get-ADSIRIDinformation
{
<#
    .SYNOPSIS
    Function to retrieve RID Master information like role owner, RIDs issued, propagation date and remaining RIDs

    .DESCRIPTION
    Function to retrieve RID Master information like role owner, RIDs issued, propagation date and remaining RIDs
    Relative ID is the incremental part of a Security ID, SID (the other part is the Domain Identifier). RID are distribued by pool of 500 by the RID master
    There is 2^30 RIDs for a domain and once a pool is issued, the RID are never reused
    Return a PS Object with
        RIDIssued
        RIDRoleOwner
        RIDLastPropagation
        RIDRemaining

    .PARAMETER Credential
        Specifies alternative credential to use

    .PARAMETER DomainName
        Specifies the DomainName to query

    .EXAMPLE
        Get-ADSIRidinformation
        Retrieve RID information for the current domain
    .EXAMPLE
        Get-ADSIRidinformation -DomainName mytest.local
        Retrieve RID information for the domain mytest.local
    .EXAMPLE
        Get-ADSIRidinformation -Credential (Get-Credential superAdmin) -Verbose
        Retrieve RID information for the current domain with the specified credential.
    .EXAMPLE
        Get-ADSIRidinformation -DomainName mytest.local -Credential (Get-Credential superAdmin) -Verbose
        Retrieve RID information for the domain mytest.local with the specified credential.
    .NOTES
        https://github.com/lazywinadmin/ADSIPS
    .OUTPUTS
        [pscustomobject]
#>
    [cmdletbinding()]
    [OutputType('pscustomobject')]
    param (
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        $DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().name
    )

    process {
        try {

            $FunctionName = (Get-Variable -Name MyInvocation -ValueOnly -Scope 0).MyCommand


            if ($PSBoundParameters['Credential']){
                Write-Verbose -Message "[$FunctionName] Create ActiveDirectory Context with Credential"
                $ContextObjectType = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext($ContextObjectType, $DomainName, $Credential.UserName, $Credential.GetNetworkCredential().password)
            } else {
                Write-Verbose -Message "[$FunctionName] Create ActiveDirectory Context"
                $ContextObjectType = [System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain
            }

            Write-Verbose -Message "[$FunctionName] Create ActiveDirectory Domain Object"
            $DomainObject = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($ContextObjectType)


            $DomainDN = $DomainObject.GetDirectoryEntry().distinguishedName

            $AdsiRidManagerObject = [ADSI]"LDAP://CN=RID Manager$,CN=System,$($DomainDN)"

            Write-Verbose -Message "[$FunctionName] Create a request to LDAP://CN=RID Manager$,CN=System,$($DomainDN)"
            $LdapResultObject = new-object system.DirectoryServices.DirectorySearcher($AdsiRidManagerObject)

            Write-Verbose -Message "[$FunctionName] Retreive RID Manager properties"
            $RidProperties = ($LdapResultObject.FindOne()).properties

            [int32]$SIDtotal = $($RidProperties.ridavailablepool) / ([math]::Pow(2,32))

            [int64]$Int64Tempvar = $SIDtotal * ([math]::Pow(2,32))

            [int32]$RIDPoolCount = $($RidProperties.ridavailablepool)  - $Int64Tempvar

            $RemaningRID = $SIDtotal - $currentRIDPoolCount

            $RIDMagangerInfo =   [pscustomobject]@{
                RIDLastPropagation  = $RidProperties.dscorepropagationdata
                RIDRoleOwner        = $RidProperties.fsmoroleowner
                RIDIssued           = $RIDPoolCount
                RIDRemaining        = $RemaningRID
            }

            return $RIDMagangerInfo
        }
        catch {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }

}