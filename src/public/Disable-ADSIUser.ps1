function Disable-ADSIUser
{
<#
.SYNOPSIS
    Function to Disable a User Account

.DESCRIPTION
    Function to Disable a User Account

.PARAMETER Identity
    Specifies the Identity of the User.

    You can provide one of the following properties
        DistinguishedName
        Guid
        Name
        SamAccountName
        Sid
        UserPrincipalName

    Those properties come from the following enumeration:
        System.DirectoryServices.AccountManagement.IdentityType

.PARAMETER Credential
    Specifies the alternative credential to use.
    By default it will use the current user windows credentials.

.PARAMETER DomainName
    Specifies the alternative Domain.
    By default it will use the current domain.

.EXAMPLE
    Disable-ADSIUser fxtest02

    This will disable the fxtest02 account

.EXAMPLE
    Disable-ADSIUser fxtest02 -whatif

    This will emulate disabling the fxtest02 account

.EXAMPLE
    Disable-ADSIUser fxtest02 -credential (Get-Credential)

    This will disable the fxtest02 account using the credential specified

.EXAMPLE
    Disable-ADSIUser fxtest02 -credential (Get-Credential) -DomainName LazyWinAdmin.local

    This will disable the fxtest02 account using the credential specified in the domain LazyWinAdmin.local

.NOTES
    https://github.com/lazywinadmin/ADSIPS
.LINK
    https://msdn.microsoft.com/en-us/library/System.DirectoryServices.AccountManagement.UserPrincipal(v=vs.110).aspx
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
            $ContextSplatting.Credential = $Credential
        }
        if ($PSBoundParameters['DomainName'])
        {
            $ContextSplatting.DomainName = $DomainName
        }

    }
    process
    {
        try
        {
            if ($pscmdlet.ShouldProcess("$Identity", "Disable Account"))
            {
                $Account = Get-ADSIUser -Identity $Identity @ContextSplatting
                Write-Verbose -Message "Found the User account $Account"
                $Account.Enabled = $false
                Write-Verbose -Message "Found the User account $Account"
                $Account.Save()
                Write-Verbose -Message "Done"

            }
        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}
