function Unlock-ADSIUser
{
<#
.SYNOPSIS
    Function to Unlock a User in Active Directory

.DESCRIPTION
    Function to Unlock a User in Active Directory

.PARAMETER Identity
    Specifies the Identity

.PARAMETER Credential
    Specifies alternative credential

.EXAMPLE
    Unlock-ADSIUser -Identity 'testaccount'

.EXAMPLE
    Unlock-ADSIUser -Identity 'testaccount' -Credential (Get-Credential)

.PARAMETER DomainName
    Specifies the alternative Domain where the user should be created
    By default it will use the current domain.

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding()]
    param ([Parameter(Mandatory, ValueFromPipeline = $true)]
        $Identity,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [String]$DomainName
    )
    begin
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement

        # Create Context splatting
        $ContextSplatting = @{ }
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
        (Get-ADSIUser -Identity $Identity @ContextSplatting).UnlockAccount()
    }
}
