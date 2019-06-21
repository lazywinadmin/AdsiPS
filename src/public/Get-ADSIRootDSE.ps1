function Get-ADSIRootDSE
{
    <#
.SYNOPSIS
    Get-ADSIRootDSE Gets the root of a directory server information tree.

.DESCRIPTION
    Get-ADSIRootDSE Gets the root of a directory server information tree.

.PARAMETER Credential
    Defines alternate credentials to use. Use Get-Credential to create proper credentials.

.PARAMETER DomainName
    Specifies the DomainName to query

.EXAMPLE
    Get-ADSIRootDSE

    Retrieve informations for the current domain

.EXAMPLE
    Get-ADSIRootDSE -DomainName lazywinadmin.com

    Retrieve informations for the domain lazywinadmin.com

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [cmdletbinding()]
    param (
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        $DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    )
    process
    {
        try
        {

            $Splatting = @{ }

            if ($PSBoundParameters['Credential'])
            {
                Write-Verbose -Message '[PROCESS] Credential specified'
                $Splatting.ArgumentList += $($Credential.UserName)
                $Splatting.ArgumentList += $($Credential.GetNetworkCredential().password)
            }
            if ($PSBoundParameters['DomainName'])
            {
                Write-Verbose -Message '[PROCESS] DomainName specified'
                $Splatting.ArgumentList += "LDAP://$DomainName/RootDSE"
            }
            else
            {
                $Splatting.ArgumentList += "LDAP://RootDSE"
            }

            $DomainRootDSE = New-Object -TypeName System.DirectoryServices.DirectoryEntry @splatting

        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }

        # Define the properties
        $Properties = @{
            "currentTime"                   = $DomainRootDSE.currentTime
            "subschemaSubentry"             = $DomainRootDSE.subschemaSubentry
            "dsServiceName"                 = $DomainRootDSE.dsServiceName
            "namingContexts"                = $DomainRootDSE.namingContexts
            "defaultNamingContext"          = $DomainRootDSE.defaultNamingContext
            "schemaNamingContext"           = $DomainRootDSE.schemaNamingContext
            "configurationNamingContext"    = $DomainRootDSE.configurationNamingContext
            "rootDomainNamingContext"       = $DomainRootDSE.rootDomainNamingContext
            "supportedControl"              = $DomainRootDSE.supportedControl
            "supportedLDAPVersion"          = $DomainRootDSE.supportedLDAPVersion
            "supportedLDAPPolicies"         = $DomainRootDSE.supportedLDAPPolicies
            "highestCommittedUSN"           = $DomainRootDSE.highestCommittedUSN
            "supportedSASLMechanisms"       = $DomainRootDSE.supportedSASLMechanisms
            "dnsHostName"                   = $DomainRootDSE.dnsHostName
            "ldapServiceName"               = $DomainRootDSE.ldapServiceName
            "serverName"                    = $DomainRootDSE.serverName
            "supportedCapabilities"         = $DomainRootDSE.supportedCapabilities
            "isSynchronized"                = $DomainRootDSE.isSynchronized
            "isGlobalCatalogReady"          = $DomainRootDSE.isGlobalCatalogReady
            "domainFunctionality"           = $DomainRootDSE.domainFunctionality
            "forestFunctionality"           = $DomainRootDSE.forestFunctionality
            "domainControllerFunctionality" = $DomainRootDSE.domainControllerFunctionality
            "distinguishedName"             = $DomainRootDSE.distinguishedName
        }

        # Output the info
        New-Object -TypeName PSObject -Property $Properties
    }
}