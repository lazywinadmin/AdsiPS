function Test-ADSIUserIsLockedOut
{
<#
.SYNOPSIS
    Function to test if a User is LockedOut

.DESCRIPTION
    Function to test if a User is LockedOut

.PARAMETER Identity
    Specifies the Identity

.PARAMETER Credential
    Specifies alternative credential

.EXAMPLE
    Test-ADSIUserIsLockedOut -Identity 'testaccount'

.EXAMPLE
    Test-ADSIUserIsLockedOut -Identity 'testaccount' -Credential (Get-Credential)

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>

    [CmdletBinding()]
    [OutputType('System.Boolean')]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Identity,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    process
    {
        (Get-ADSIUser @PSBoundParameters).IsAccountLockedOut()
    }
}
