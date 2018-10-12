function New-ADSIPrincipalContext
{
    <#
.SYNOPSIS
    Function to create an Active Directory PrincipalContext object

.DESCRIPTION
    Function to create an Active Directory PrincipalContext object

.PARAMETER Credential
    Specifies the alternative credentials to use.
    It will use the current credential if not specified.

.PARAMETER ContextType
    Specifies which type of Context to use. Domain, Machine or ApplicationDirectory.

.PARAMETER DomainName
    Specifies the domain to query. Default is the current domain.
    Should only be used with the Domain ContextType.

.PARAMETER Container
    Specifies the scope. Example: "OU=MyOU"

.PARAMETER ContextOptions
    Specifies the ContextOptions.
    Negotiate
    Sealing
    SecureSocketLayer
    ServerBind
    Signing
    SimpleBind

.EXAMPLE
    New-ADSIPrincipalContext -ContextType 'Domain'

.EXAMPLE
    New-ADSIPrincipalContext -ContextType 'Domain' -DomainName "Contoso.com" -Cred (Get-Credential)

.NOTES
    Francois-Xavier.Cat
    LazyWinAdmin.com
    @lazywinadm
    github.com/lazywinadmin/AdsiPS

    https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.principalcontext(v=vs.110).aspx
#>

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType('System.DirectoryServices.AccountManagement.PrincipalContext')]
    param
    (
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $true)]
        [System.DirectoryServices.AccountManagement.ContextType]$ContextType,

        $DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain(),

        $Container,

        [System.DirectoryServices.AccountManagement.ContextOptions[]]$ContextOptions
    )

    begin
    {
        $ScriptName = (Get-Variable -name MyInvocation -Scope 0 -ValueOnly).MyCommand
        Write-Verbose -Message "[$ScriptName] Add Type System.DirectoryServices.AccountManagement"
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    }
    process
    {
        try
        {
            switch ($ContextType)
            {
                "Domain"
                {
                    $ArgumentList = $ContextType, $DomainName
                }
                "Machine"
                {
                    $ArgumentList = $ContextType, $ComputerName
                }
                "ApplicationDirectory"
                {
                    $ArgumentList = $ContextType
                }
            }

            if ($PSBoundParameters['Container'])
            {
                $ArgumentList += $Container
            }

            if ($PSBoundParameters['ContextOptions'])
            {
                $ArgumentList += $($ContextOptions)
            }

            if ($PSBoundParameters['Credential'])
            {
                # Query the specified domain or current if not entered, with the specified credentials
                $ArgumentList += $($Credential.UserName), $($Credential.GetNetworkCredential().password)
            }

            if ($PSCmdlet.ShouldProcess($DomainName, "Create Principal Context"))
            {
                # Query
                New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $ArgumentList
            }
        } #try
        catch
        {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    } #process
}
