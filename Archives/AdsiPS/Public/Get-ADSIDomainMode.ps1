Function Get-ADSIDomainMode
{
<#
.SYNOPSIS
    Function to retrieve Domain mode

.DESCRIPTION
    Function to retrieve Domain mode

.PARAMETER Credential
    Specifies alternative credential

.PARAMETER DomainName
    Specifies the Domain Name where the function should look

.EXAMPLE
    Get-ADSIDomainMode

.EXAMPLE
    Get-ADSIDomainMode -Credential (Get-Credential)

.EXAMPLE
    Get-ADSIDomainMode -DomainName "FXTEST.local"

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [cmdletbinding()]
    param (
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        $DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain()
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
                    $Splatting.Credential = $Credential
                }
                if ($PSBoundParameters['DomainName'])
                {
                    $Splatting.DomainName = $DomainName
                }

                (Get-ADSIDomain @splatting).DomainMode

            }
            else
            {
                (Get-ADSIDomain).DomainMode
            }

        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}