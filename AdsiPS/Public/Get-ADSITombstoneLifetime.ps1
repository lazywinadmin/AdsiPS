function Get-ADSITombstoneLifetime
{
    <#
.SYNOPSIS
    Get-ADSITombstoneLifetime returns the number of days before a deleted object is removed from the directory services.

.DESCRIPTION
    Get-ADSITombstoneLifetime returns the number of days before a deleted object is removed from the directory services.

.PARAMETER Credential
    Defines alternate credentials to use. Use Get-Credential to create proper credentials.

.EXAMPLE
    Get-ADSITombstoneLifetime

    For the current domain, returns the number of days before a deleted object is removed from the directory services.

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding()]
    param (
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        $DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    )

    try
    {

        if ($PSBoundParameters['Credential'] -or $PSBoundParameters['DomainName'])
        {
            Write-Verbose -Message '[PROCESS] Credential or DomainName specified'
            $Splatting = @{ }
            if ($PSBoundParameters['Credential'])
            {
                $Splatting.Credential = $Credential
            }
            if ($PSBoundParameters['DomainName'])
            {
                $Splatting.DomainName = $DomainName
            }

            $configurationNamingContext = (Get-ADSIRootDSE @splatting).configurationNamingContext

        }
        else
        {
            $configurationNamingContext = (Get-ADSIRootDSE).configurationNamingContext
        }

    }
    catch
    {
        $pscmdlet.ThrowTerminatingError($_)
    }

    $nTDSService = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList "LDAP://CN=Directory Service,CN=Windows NT,CN=Services,$configurationNamingContext"

    write-verbose "Domain : $DomainName"
    $nTDSService.tombstoneLifetime
}