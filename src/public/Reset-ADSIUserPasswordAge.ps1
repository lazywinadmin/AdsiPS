function Reset-ADSIUserPasswordAge
{
    <#
.SYNOPSIS
    Function to reset a User's password age to zero

.DESCRIPTION
    Function to reset a User's password age to zero

.PARAMETER Identity
    Specifies the Identity

.PARAMETER DomainName
    Specify the Domain Distinguished name

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
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        $Identity,

        [Alias("Domain", "DomainDN")]
        [String]$DomainName = $(([adsisearcher]"").Searchroot.path),

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        $FunctionName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).Mycommand

        # Create Context splatting
        $ContextSplatting = @{}

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
    }

    process
    {
        if($Identity.GetType().FullName -eq 'System.String') {
            if ($pscmdlet.ShouldProcess("$Identity", "Change Account Password"))
            {
                (Get-ADSIUser -Identity $Identity @ContextSplatting).RefreshExpiredPassword()
            }
        } else {
            if ($pscmdlet.ShouldProcess("$($Identity.SamAccountName)", "Change Account Password"))
            {
                $Identity.RefreshExpiredPassword()
            }
        }
    }
}