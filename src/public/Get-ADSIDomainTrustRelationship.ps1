function Get-ADSIDomainTrustRelationship
{
<#
.SYNOPSIS
    Function to retrieve the Trust relationship of a domain. Current one by default.

.DESCRIPTION
    Function to retrieve the Trust relationship of a domain. Current one by default.

.PARAMETER Credential
    Specifies the alternative credential to use. Default is the current user.

.PARAMETER DomainName
    Specifies the alternative domain name to use. Default is the current one.

.EXAMPLE
    Get-ADSIDomainTrustRelationship

    Retrieve the Trust relationship(s) of a current domain

.EXAMPLE
    Get-ADSIDomainTrustRelationship -DomainName FX.lab

    Retrieve the Trust relationship(s) of domain fx.lab

.EXAMPLE
    Get-ADSIDomainTrustRelationship -DomainName FX.lab -Credential (Get-Credential)

    Retrieve the Trust relationship(s) of domain fx.lab with the credential specified

.NOTES
    https://github.com/lazywinadmin/ADSIPS

.OUTPUTS
    System.DirectoryServices.ActiveDirectory.TrustRelationshipInformation

.LINK
    https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectory.trustrelationshipinformation(v=vs.110).aspx
#>

    [CmdletBinding()]
    [OutputType('System.DirectoryServices.ActiveDirectory.TrustRelationshipInformation')]
    param
    (
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        $DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetcurrentDomain()
    )

    process
    {
        try
        {
            if ($PSBoundParameters['Credential'] -or $PSBoundParameters['DomainName'])
            {
                Write-Verbose -Message '[PROCESS] Credential or FirstName specified'
                $Splatting = @{ }
                if ($PSBoundParameters['Credential'])
                {
                    $Splatting.Credential = $Credential
                }
                if ($PSBoundParameters['DomainName'])
                {
                    $Splatting.DomainName = $DomainName
                }

                $AllTrustRelation= (Get-ADSIDomain @splatting).GetAllTrustRelationships()

                Write-Verbose -Message "The Root domain is $(Get-ADSIDomain @splatting).GetAllTrustRelationships()"

                return = $AllTrustRelation

            }
            else
            {
                $AllTrustRelation = (Get-ADSIDomain).GetAllTrustRelationships()

                Write-Verbose -Message "The Root domain is $(Get-ADSIDomain @splatting).GetAllTrustRelationships()"

                return = $AllTrustRelation
            }

        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
    end
    {
        Write-Verbose -Message "[$FunctionName] Done"
    }
}