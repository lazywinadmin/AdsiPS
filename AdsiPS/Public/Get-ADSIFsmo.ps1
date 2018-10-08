function Get-ADSIFsmo
{
<#
.SYNOPSIS
    Function to retrieve the Flexible single master operation (FSMO) roles owner(s)

.DESCRIPTION
    Function to retrieve the Flexible single master operation (FSMO) roles owner(s)

.PARAMETER Credential
    Specifies the Alternative credential to use

.PARAMETER ForestName
    Specifies the alternative forest name

.EXAMPLE
    Get-ADSIFsmo

    Retrieve the Flexible single master operation (FSMO) roles owner(s) of the current domain/forest

.EXAMPLE
    Get-ADSIFsmo -ForestName 'lazywinadmin.com'

    Retrieve the Flexible single master operation (FSMO) roles owner(s) of the root domain/forest lazywinadmin.com

.EXAMPLE
    Get-ADSIFsmo -ForestName 'lazywinadmin.com' -credential (Get-Credential)

    Retrieve the Flexible single master operation (FSMO) roles owner(s) of the root domain/forest lazywinadmin.com using
    the specified credential.

.NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadm
    github.com/lazywinadmin/AdsiPS

.OUTPUTS
    System.Management.Automation.PSCustomObject
#>

    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param
    (
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        $ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
    )

    PROCESS
    {
        TRY
        {
            $FunctionName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).Mycommand

            IF ($PSBoundParameters['Credential'] -or $PSBoundParameters['ForestName'])
            {
                $Splatting = @{ }
                IF ($PSBoundParameters['Credential'])
                {
                    Write-Verbose -message "[$FunctionName] Add Credential to splatting"
                    $Splatting.Credential = $Credential
                }
                IF ($PSBoundParameters['ForestName'])
                {
                    Write-Verbose -message "[$FunctionName] Add ForestName to splatting"
                    $Splatting.ForestName = $ForestName
                }

                # Forest Query
                Write-Verbose -message "[$FunctionName] Retrieve Forest information '$ForestName'"
                $Forest = (Get-ADSIForest @splatting)

                # Domain Splatting cleanup
                $Splatting.Remove("ForestName")
                $Splatting.DomainName = $Forest.RootDomain.name

                # Domain Query
                Write-Verbose -message "[$FunctionName] Retrieve Domain information '$($Forest.RootDomain.name)'"
                $Domain = (Get-ADSIDomain @Splatting)

            }
            ELSE
            {
                Write-Verbose -message "[$FunctionName] Retrieve Forest information '$ForestName'"
                $Forest = Get-ADSIForest
                Write-Verbose -message "[$FunctionName] Retrieve Domain information"
                $Domain = Get-ADSIDomain
            }

            Write-Verbose -message "[$FunctionName] Prepare Output"
            $Properties = @{
                SchemaRoleOwner = $Forest.SchemaRoleOwner
                NamingRoleOwner = $Forest.NamingRoleOwner
                InfrastructureRoleOwner = $Domain.InfrastructureRoleOwner
                RidRoleOwner = $Domain.RidRoleOwner
                PdcRoleOwner = $Domain.PdcRoleOwner
            }

            New-Object -TypeName PSObject -property $Properties

        }
        CATCH
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
    END{
        Write-Verbose -message "[$FunctionName] Done."
    }
}