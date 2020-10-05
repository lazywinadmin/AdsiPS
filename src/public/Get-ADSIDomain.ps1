Function Get-ADSIDomain
{
    <#
.SYNOPSIS
    Function to retrieve the current or specified domain

.DESCRIPTION
    Function to retrieve the current or specified domain

.PARAMETER Credential
    Specifies alternative credential to use

.PARAMETER DomainName
    Specifies the DomainName to query

.EXAMPLE
    Get-ADSIDomain

    Retrieve the current domain

.EXAMPLE
    Get-ADSIDomain -DomainName lazywinadmin.com

    Retrieve the domain lazywinadmin.com

.EXAMPLE
    Get-ADSIDomain -Credential (Get-Credential superAdmin) -Verbose

    Retrieve the current domain with the specified credential.

.EXAMPLE
    Get-ADSIDomain -DomainName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose

    Retrieve the domain lazywinadmin.com with the specified credential.

.NOTES
    https://github.com/lazywinadmin/ADSIPS

.OUTPUTS
    'System.DirectoryServices.ActiveDirectory.Domain'

.LINK
    https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.domain(v=vs.110).aspx
#>
    [cmdletbinding()]
    [OutputType('System.DirectoryServices.ActiveDirectory.Domain')]
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
            if ($PSBoundParameters['Credential'] -or $PSBoundParameters['DomainName'])
            {
                Write-Verbose -Message '[PROCESS] Credential or DomainName specified'
                $Splatting = @{ }
                if ($PSBoundParameters['Credential'])
                {
                    Write-Verbose "[$FunctionName] Found Credential Parameter"
                    $Splatting.Credential = $Credential
                }
                if ($PSBoundParameters['DomainName'])
                {
                    Write-Verbose "[$FunctionName] Found Credential Parameter"
                    $Splatting.DomainName = $DomainName
                }

                $DomainContext = New-ADSIDirectoryContext @splatting -contextType Domain
                [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($DomainContext)
            }
            else
            {
                [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
            }

        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}