function Test-ADSIUserIsLockedOut
{
<#
.SYNOPSIS
    Function to test if a User is LockedOut

.DESCRIPTION
    Function to test if a User is LockedOut

.PARAMETER Identity
    Specifies the Identity

.PARAMETER DomainName
    Specify the Domain Distinguished name

.PARAMETER Credential
    Specify alternative Credential

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
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
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

    process {

        if($Identity.GetType().FullName -eq 'System.String') {
            $User = Get-ADSIUser -Identity $Identity @ContextSplatting
            if($User -eq $null){
                Write-Error "[$FunctionName] Could not find User"
            } else {
                Write-Verbose "[$FunctionName] Found User"
            }
        } else {
            Write-Verbose "[$FunctionName] Found User"
            $User = $Identity
        }

        $User.IsAccountLockedOut()
    }
}
