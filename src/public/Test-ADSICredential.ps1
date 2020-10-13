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
    PS C:\> $Password = read-host -AsSecureString -Prompt "AccountPassword"
    PS C:\> Test-ADSICredential -AccountName 'Xavier' -AccountPassword $Password

.EXAMPLE
    PS C:\> $Password = read-host -AsSecureString -Prompt "AccountPassword"
    PS C:\> New-ADSIUser -SamAccountName "fxtest04" -Enabled -AccountPassword $Password -Passthru

    # You can test the credential using the following function
    PS C:\> Test-ADSICredential -AccountName "fxtest04" -AccountPassword $Password

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
