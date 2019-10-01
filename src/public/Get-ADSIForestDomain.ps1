Function Get-ADSIForestDomain
{
<#
.SYNOPSIS
    Function to retrieve the forest domain(s)

.DESCRIPTION
    Function to retrieve the forest domain(s)

.PARAMETER Credential
    Specifies alternative credential to use

.PARAMETER ForestName
    Specifies the ForestName to query

.EXAMPLE
    Get-ADSIForest

.EXAMPLE
    Get-ADSIForest -ForestName lazywinadmin.com

.EXAMPLE
    Get-ADSIForest -Credential (Get-Credential superAdmin) -Verbose

.EXAMPLE
    Get-ADSIForest -ForestName lazywinadmin.com -Credential (Get-Credential superAdmin) -Verbose

.OUTPUTS
    System.DirectoryServices.ActiveDirectory.Forest

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [cmdletbinding()]
    param (
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        $ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
    )
    process
    {
        try
        {
            if ($PSBoundParameters['Credential'] -or $PSBoundParameters['ForestName'])
            {
                Write-Verbose -Message '[PROCESS] Credential or FirstName specified'
                $Splatting = @{ }
                if ($PSBoundParameters['Credential'])
                {
                    $Splatting.Credential = $Credential
                }
                if ($PSBoundParameters['ForestName'])
                {
                    $Splatting.ForestName = $ForestName
                }

                $Domains = (Get-ADSIForest @splatting).Domains
                Write-Verbose -Message "Found the Domain $Domains"
                return $Domains
            }
            else
            {
                $Domains = (Get-ADSIForest).Domains
                Write-Verbose -Message "Found the Domain $Domains"
                return $Domains
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