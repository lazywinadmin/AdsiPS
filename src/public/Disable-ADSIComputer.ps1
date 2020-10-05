function Disable-ADSIComputer
{
<#
.SYNOPSIS
    Function to disable a Computer Account

.DESCRIPTION
    Function to disable a Computer Account

.PARAMETER Identity
    Specifies the Identity of the Computer.

    You can provide one of the following properties
        DistinguishedName
        Guid
        Name
        SamAccountName
        Sid

.PARAMETER Credential
    Specifies the alternative credential to use.
    By default it will use the current user windows credentials.

.PARAMETER DomainName
    Specifies the alternative Domain.
    By default it will use the current domain.

.EXAMPLE
    Disable-ADSIComputer TESTSERVER01

    This command will disable the account TESTSERVER01

.EXAMPLE
    Disable-ADSIComputer TESTSERVER01 -whatif

    This command will emulate disabling the account TESTSERVER01

.EXAMPLE
    Disable-ADSIComputer TESTSERVER01 -credential (Get-Credential)

    This command will disable the account TESTSERVER01 using the alternative credential specified

.EXAMPLE
    Disable-ADSIComputer TESTSERVER01 -credential (Get-Credential) -domain LazyWinAdmin.local

    This command will disable the account TESTSERVER01 using the alternative credential specified in the domain lazywinadmin.local

.NOTES
    https://github.com/lazywinadmin/ADSIPS

.LINK
    https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.computerprincipal(v=vs.110).aspx
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        $Identity,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [String]$DomainName)

    begin
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement

        # Create Context splatting
        $ContextSplatting = @{ }
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
        try
        {
            if ($pscmdlet.ShouldProcess("$Identity", "Disable Account"))
            {
                $Account = Get-ADSIComputer -Identity $Identity @ContextSplatting
                $Account.enabled = $false
                $Account.Save()
                Write-Verbose "[$FunctionName] The Account $Identity was disable"

            }
        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}
