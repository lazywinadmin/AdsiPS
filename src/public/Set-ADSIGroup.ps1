#function Set-ADSIGroup
#{
<#
.SYNOPSIS
    This function modifies an group identified by its  name, sam group name or distinguished name.

.DESCRIPTION
    This function modifies an group identified by its  name, sam group name or distinguished name.

.PARAMETER Identity
    Specify the Identity of the group to modify.

    The Identity can either be (in order of resolution attempt):
        A SAM account name
        A name
        A distinguished name

.PARAMETER Description
    Specify the description. This parameter sets the description property of a group.

.PARAMETER DisplayName
    Specify the display name. This parameter sets the DisplayName property of a group.

.PARAMETER DomainName
    Specify the Domain Distinguished name

.PARAMETER Credential
    Specify alternative Credential

.EXAMPLE
    Set-ADSIGroup -identity Testgroup -Description "group Description"

    Changes the Country value of the group Testgroup

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory = $true)]
        [String]$Identity,

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [string]$DisplayName,

        [Alias("Domain", "DomainDN")]
        [String]$DomainName = $(([adsisearcher]"").Searchroot.path),

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    begin
    {

        Add-Type -AssemblyName System.DirectoryServices.AccountManagement

        # Create Context splatting
        $ContextSplatting = @{}

        if ($PSBoundParameters['Credential'])
        {
            $ContextSplatting.Credential = $Credential
        }
        if ($PSBoundParameters['DomainName'])
        {
            $ContextSplatting.DomainName = $DomainName
        }

    }
    process
    {
        try
        {
            # Resolve the Object
            $group = Get-ADSIgroup -Identity $Identity @ContextSplatting

            if ($group.Count -eq 1)
            {
                $groupName = $group.Name

                #Description
                if ($Description -ne '')
                {
                    Write-Verbose -Message "[$($groupName)] Setting Description to : $Description"

                    if ($PSCmdlet.ShouldProcess($env:groupNAME, "Set Description of group $groupName to $Description"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting Description of group $groupName to $Description" -Verbose:$true
                        }
                        else
                        {
                            $group.Description = $Description
                            $group.Save()
                        }
                    }
                }

                #DisplayName
                if ($DisplayName -ne '')
                {
                    Write-Verbose -Message "[$($groupName)] Setting DisplayName to : $Description"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set DisplayName of group $groupName to $DisplayName"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting DisplayName of group $groupName to $DisplayName" -Verbose:$true
                        }
                        else
                        {
                            $group.DisplayName = $DisplayName
                            $group.Save()
                        }
                    }
                }
            }
            elseif ($group.Count -gt 1)
            {
                Write-Warning -Message "[Set-ADSIgroup] Identity $identity is not unique"
            }
            elseif ($group.Count -eq 0)
            {
                Write-Warning -Message "[Set-ADSIgroup] group $identity not found"
            }

        }#try
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }#process
    end
    {
        Write-Verbose -Message "[END] Function Set-ADSIgroup End."
    }
#}
