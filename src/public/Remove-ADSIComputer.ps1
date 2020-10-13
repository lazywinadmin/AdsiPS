function Remove-ADSIComputer
{
    <#
.SYNOPSIS
    Function to Remove a Computer Account

.DESCRIPTION
    Function to Remove a Computer Account

.PARAMETER Identity
    Specifies the Identity of the Computer.

    You can provide one of the following:
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

.PARAMETER Recursive
    Specifies that any child object should be deleted as well
    Typically you would use this parameter if you get the error "The directory service can perform the requested operation only on a leaf object"
    when you try to delete the object without the -recursive param

.EXAMPLE
    Remove-ADSIComputer -identity TESTSERVER01

    This command will Remove the account TESTSERVER01

.EXAMPLE
    Remove-ADSIComputer -identity TESTSERVER01 -recursive

    This command will Remove the account TESTSERVER01 and all the child leaf

.EXAMPLE
    Remove-ADSIComputer -identity TESTSERVER01 -whatif

    This command will emulate removing the account TESTSERVER01

.EXAMPLE
    Remove-ADSIComputer -identity TESTSERVER01 -credential (Get-Credential)

    This command will Remove the account TESTSERVER01 using the alternative credential specified

.EXAMPLE
    Remove-ADSIComputer -identity TESTSERVER01 -credential (Get-Credential) -domain LazyWinAdmin.local

    This command will Remove the account TESTSERVER01 using the alternative credential specified in the domain lazywinadmin.local

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

        [String]$DomainName,

        [Switch]$Recursive
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
            # Not Recursive
            if (-not $PSBoundParameters['Recursive'])
            {
                if ($pscmdlet.ShouldProcess("$Identity", "Remove Account"))
                {
                    $Account = Get-ADSIComputer -Identity $Identity @ContextSplatting
                    $Account.delete()
                }
            }

            # Recursive (if the computer is the parent of one leaf or more)
            if ($PSBoundParameters['Recursive'])
            {
                Write-Verbose "[$FunctionName] Recursive Parameter found"
                if ($pscmdlet.ShouldProcess("$Identity", "Remove Account and any child objects"))
                {
                    $Account = Get-ADSIComputer -Identity $Identity @ContextSplatting
                    $Account.GetUnderlyingObject().deletetree()
                }
            }

        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}
