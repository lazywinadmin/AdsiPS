function Set-ADSIComputer
{
<#
.SYNOPSIS
    This function modifies an computer identified by its  name, sam account name or distinguished name.

.DESCRIPTION
    This function modifies an computer identified by its  name, sam account name or distinguished name.

.PARAMETER Identity
    Specify the Identity of the Computers to modify.

    The Identity can either be (in order of resolution attempt):
        A SAM account name
        A name
        A distinguished name

.PARAMETER Description
    Specify the description. This parameter sets the description property of a computer.

.PARAMETER DisplayName
    Specify the display name. This parameter sets the DisplayName property of a computer.

.PARAMETER DomainName
    Specify the Domain Distinguished name

.PARAMETER Credential
    Specify alternative Credential

.PARAMETER AccountExpirationDate
    Specifies the Account expiration Date.

.EXAMPLE
    Set-ADSIComputer -identity TestComputer -Description "Computer Description"

    Changes the Country value of the Computer TestComputer

.EXAMPLE
    Set-ADSIComputer -identity TestComputer -AccountExpirationDate '2222-08-12 12:42:00'

    Changes the ComputerExpiration Date of the Computer TestComputer

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Identity,

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [string]$DisplayName,

        [Parameter(Mandatory = $false)]
        [DateTime]$AccountExpirationDate,

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

        $FunctionName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).Mycommand

        # Create Context splatting
        $ContextSplatting = @{ }
        if ($PSBoundParameters['Credential']){
            Write-Verbose "[$FunctionName] Found Credential Parameter"
            $ContextSplatting.Credential = $Credential
        }
        if ($PSBoundParameters['DomainName']){
            Write-Verbose "[$FunctionName] Found DomainName Parameter"
            $ContextSplatting.DomainName = $DomainName
        }

    }
    process
    {
        try
        {
            # Resolve the Object
            $computer = Get-ADSIComputer -Identity $Identity @ContextSplatting

            if ($computer.Count -eq 1)
            {
                Write-Verbose "[$FunctionName] Computer $Identity Found"
                $ComputerName = $computer.Name

                # AccountExpirationDate
                if ($AccountExpirationDate -ne $null)
                {
                    Write-Verbose -Message "[$($ComputerName)] Setting AccountExpiration Date to : $AccountExpirationDate"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set AccountExpirationDate of Computer $ComputerName to $AccountExpirationDate"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting AccountExpirationDate of Computer $ComputerName to $AccountExpirationDate" -Verbose:$true
                        }
                        else
                        {
                            $Computer.AccountExpirationDate = $AccountExpirationDate
                            $Computer.Save()
                        }
                    }
                }

                #Description
                if ($Description -ne '')
                {
                    Write-Verbose -Message "[$($ComputerName)] Setting Description to : $Description"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set Description of Computer $ComputerName to $Description"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting Description of Computer $ComputerName to $Description" -Verbose:$true
                        }
                        else
                        {
                            $Computer.Description = $Description
                            $Computer.Save()
                        }
                    }
                }

                #DisplayName
                if ($DisplayName -ne '')
                {
                    Write-Verbose -Message "[$($ComputerName)] Setting DisplayName to : $Description"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set DisplayName of Computer $ComputerName to $DisplayName"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting DisplayName of Computer $ComputerName to $DisplayName" -Verbose:$true
                        }
                        else
                        {
                            $Computer.DisplayName = $DisplayName
                            $Computer.Save()
                        }
                    }
                }
            }
            elseif ($computer.Count -gt 1)
            {
                Write-Warning -Message "[$FunctionName] Identity $identity is not unique"
            }
            elseif ($computer.Count -eq 0)
            {
                Write-Warning -Message "[$FunctionName] Computer $identity not found"
            }

        }#try
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }#process
    end
    {
        Write-Verbose -Message "[END] Function $FunctionName End."
    }
}
