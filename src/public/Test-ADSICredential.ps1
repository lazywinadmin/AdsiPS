function Test-ADSICredential
{
<#
.SYNOPSIS
    Function to test credential

.DESCRIPTION
    Function to test credential

.PARAMETER AccountName
    Specifies the AccountName to check

.PARAMETER AccountPassword
    Specifies the AccountName's password

.PARAMETER Credential
    Specifies the alternative credential to use.
    By default it will use the current user windows credentials.

.PARAMETER DomainName
    Specifies the alternative Domain where the user should be created
    By default it will use the current domain.

.EXAMPLE
    Test-ADSICredential -AccountName 'Xavier' -Password 'Wine and Cheese!'

.EXAMPLE
    PS C:\> New-ADSIUser -SamAccountName "fxtest04" -Enabled -AccountPassword (read-host -AsSecureString -Prompt "AccountPassword") -Passthru

    # You can test the credential using the following function
    Test-ADSICredential -AccountName "fxtest04" -Password "Password1"

.OUTPUTS
    System.Boolean

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [OutputType('System.Boolean')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [Alias("UserName")]
        [string]$AccountName,

        [Parameter(Mandatory)]
        [System.Security.SecureString]$AccountPassword,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [String]$DomainName)
    begin
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement

        # Create Context splatting
        $ContextSplatting = @{ ContextType = "Domain" }

        if ($PSBoundParameters['Credential'])
        {
            $ContextSplatting.Credential = $Credential
        }
        if ($PSBoundParameters['DomainName'])
        {
            $ContextSplatting.DomainName = $DomainName
        }

        $Context = New-ADSIPrincipalContext @ContextSplatting
    }
    process
    {
        try
        {
            Write-Verbose -Message "[Test-ADSICredential][PROCESS] Validating $AccountName Credential against $($Context.ConnectedServer)"
            $Context.ValidateCredentials($AccountName, (New-Object -TypeName PSCredential -ArgumentList "user", $AccountPassword).GetNetworkCredential().Password)
        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}
