function Test-ADSIUserIsGroupMember
{
<#
.SYNOPSIS
    This function will check if a domain user is member of a domain group

.DESCRIPTION
    This function will check if a domain user is member of a domain group

.PARAMETER GroupSamAccountName
    Specifies the Group to query

.PARAMETER UserSamAccountName
    Specifies the user account

.PARAMETER DomainName
    Specify the Domain Distinguished name

.PARAMETER Credential
    Specify alternative Credential

.EXAMPLE
    Test-ADSIUserIsGroupMember -GroupSamAccountName TestGroup -UserSamAccountName Fxcat

    This will return $true or $false depending if the user Fxcat is member of TestGroup

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>

    [CmdletBinding()]
    [OutputType('System.Boolean')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeLine = $true)]
        $UserSamAccountName,
        [Parameter(Mandatory = $true)]
        [System.String]$GroupSamAccountName,

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

        if($UserSamAccountName.GetType().FullName -eq 'System.String') {
            $UserInfo = Get-ADSIUser -Identity $UserSamAccountName @ContextSplatting
            if($UserInfo -eq $null){
                Write-Error "[$FunctionName] Could not find User"
            } else {
                Write-Verbose "[$FunctionName] Found User"
            }
        } else {
            Write-Verbose "[$FunctionName] Found User"
            $UserInfo = $UserSamAccountName
        }

        $GroupInfo = Get-ADSIGroup -Identity $GroupSamAccountName @ContextSplatting
        if($GroupInfo -eq $null){
            Write-Error "[$FunctionName] Could not find Group"
        } else {
            Write-Verbose "[$FunctionName] Found Group"
        }
        $UserInfo.isMemberOf($GroupInfo)
    }
}