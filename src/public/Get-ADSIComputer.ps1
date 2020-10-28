function Get-ADSIComputer
{
<#
.SYNOPSIS
    Function to retrieve a Computer in Active Directory

.DESCRIPTION
    Function to retrieve a Computer in Active Directory

.PARAMETER Identity
    Specifies the Identity of the computer

    You can provide one of the following:
        DistinguishedName
        Guid
        Name
        SamAccountName
        Sid

    System.DirectoryService.AccountManagement.IdentityType
    https://msdn.microsoft.com/en-us/library/bb356425(v=vs.110).aspx

.PARAMETER LDAPFilter
    A custom LDAP Filter string to search for computer objects.
    May not be used together with -Identity.

.PARAMETER LDAPPath
    The directory path to search inside when using an LDAPFilter.

.PARAMETER Credential
    Specifies alternative credential
    By default it will use the current user windows credentials.

.PARAMETER DomainName
    Specifies the alternative Domain.
    By default it will use the current domain.

.EXAMPLE
    Get-ADSIComputer -Identity 'SERVER01'

    This command will retrieve the computer account SERVER01

.EXAMPLE
    Get-ADSIComputer -Identity 'SERVER01' -Credential (Get-Credential)

    This command will retrieve the computer account SERVER01 with the specified credential

.EXAMPLE
    Get-ADSIComputer TESTSERVER01 -credential (Get-Credential) -domain LazyWinAdmin.local

    This command will retrieve the account TESTSERVER01 using the alternative credential specified in the domain lazywinadmin.local

.EXAMPLE
    $Comp = Get-ADSIComputer -Identity 'SERVER01'
    $Comp.GetUnderlyingObject()| Select-Object -Property *

    Help you find all the extra properties

.NOTES
    https://github.com/lazywinadmin/ADSIPS

.LINK
    https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.computerprincipal(v=vs.110).aspx
#>
    [CmdletBinding(DefaultParameterSetName = "All")]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Identity")]
        [string]$Identity,
        
        [Parameter(ParameterSetName = "LDAPFilter")]
        [string]$LDAPFilter,
        [Parameter(ParameterSetName = "LDAPFilter")]
        [string]$LDAPPath,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [String]$DomainName
    )
    begin
    {
        $FunctionName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).Mycommand
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement

        switch ($PsCmdlet.ParameterSetName) {
            'Identity' {
                # Create Context splatting
                $ContextSplatting = @{ ContextType = "Domain" }

                if ($PSBoundParameters['Credential'])
                {
                    Write-Verbose "[$FunctionName] Found Credential Parameter"
                    $ContextSplatting.Credential = $Credential
                }
                if ($PSBoundParameters['DomainName'])
                {
                    Write-Verbose "[$FunctionName] Found DomainName Parameter"
                    $ContextSplatting.DomainName = $DomainName
                }

                $Context = New-ADSIPrincipalContext @ContextSplatting
            }
            
            'LDAPFilter' {
                # Create Context splatting
                $ContextSplatting = @{}

                if ($PSBoundParameters['Credential'])
                {
                    Write-Verbose "[$FunctionName] Found Credential Parameter"
                    $ContextSplatting.Credential = $Credential
                }
                if ($PSBoundParameters['LDAPPath'])
                {
                    Write-Verbose "[$FunctionName] Found LADPPath Parameter"
                    $ContextSplatting.Path = $LDAPPath
                }

                $SearchRoot = New-ADSIDirectoryEntry @ContextSplatting
            }
        }
    }
    process
    {
        try
        {
            switch ($PsCmdlet.ParameterSetName) {
                'Identity' {
                    [System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($Context, $Identity)
                }
                'LDAPFilter' {
                    if ($LDAPFilter) {
                        $LDAPFilter = "(&(objectClass=computer)$LDAPFilter)"
                        $Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ArgumentList $SearchRoot, $LDAPFilter
                    } else {
                        $Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ArgumentList $SearchRoot, 'objectClass=computer'
                    }
                    $Searcher.FindAll() | Select-Object -ExpandProperty Properties
                }
                default {
                    $ComputerPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.ComputerPrincipal -ArgumentList $Context
                    $Searcher = new-object -TypeName System.DirectoryServices.AccountManagement.PrincipalSearcher
                    $Searcher.QueryFilter = $ComputerPrincipal

                    $Searcher.FindAll()
                }
            }
        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}
