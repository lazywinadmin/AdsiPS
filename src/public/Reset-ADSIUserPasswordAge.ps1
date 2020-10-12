function Reset-ADSIUserPasswordAge
{
    <#
.SYNOPSIS
    Function to reset a User's password age to zero

.DESCRIPTION
    Function to reset a User's password age to zero

.PARAMETER Identity
    Specifies the Identity

.PARAMETER Credential
    Specifies alternative credential

.EXAMPLE
    Reset-ADSIUserPasswordAge -Identity 'testaccount'

.EXAMPLE
    Reset-ADSIUserPasswordAge -Identity 'testaccount' -Credential (Get-Credential)

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Identity,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    process
    {
        if ($pscmdlet.ShouldProcess("$Identity", "Change Account Password"))
        {
            (Get-ADSIUser @PSBoundParameters).RefreshExpiredPassword()
        }
    }
}
