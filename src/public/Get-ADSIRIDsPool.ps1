function Get-ADSIRIDsPool
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
        Get-ADSIRIDsPool
        Retrieve RID information for the current domain
        return :
            RIDLastPropagation : {1/1/1601 12:00:00 AM}
            RIDRoleOwner       : {CN=NTDS Settings,CN=reqlab01,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=adsips,DC=local}
            RIDIssued          : 2100
            RIDRemaining       : 1073741823
    .EXAMPLE
        Get-ADSIRIDsPool -DomainName mytest.local
        Retrieve RID information for the domain mytest.local
    .EXAMPLE
        Get-ADSIRIDsPool -Credential (Get-Credential superAdmin) -Verbose
        Retrieve RID information for the current domain with the specified credential.
    .EXAMPLE
        Get-ADSIRIDsPool -DomainName mytest.local -Credential (Get-Credential superAdmin) -Verbose
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


            if ($PSBoundParameters['Credential'])
            {
                $ContextObjectType = New-ADSIDirectoryContext -Credential $Credential -contextType Domain
                if ($PSBoundParameters['DomainName'])
                {
                    $ContextObjectType = New-ADSIDirectoryContext -Credential $Credential -contextType Domain -DomainName $DomainName
                }
            }
            else
            {
                $ContextObjectType = New-ADSIDirectoryContext -contextType Domain
                if ($PSBoundParameters['DomainName'])
                {
                    $ContextObjectType = New-ADSIDirectoryContext -contextType Domain -DomainName $DomainName
                }
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

            return [pscustomobject]@{
                RIDLastPropagation  = $RidProperties.dscorepropagationdata
                RIDRoleOwner        = $RidProperties.fsmoroleowner
                RIDIssued           = $RIDPoolCount
                RIDRemaining        = $RemaningRID
            }


        }
        catch {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }

}