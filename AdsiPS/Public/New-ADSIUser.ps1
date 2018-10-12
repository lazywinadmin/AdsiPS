function New-ADSIUser
{

    <#
.SYNOPSIS
    Function to create a new User

.DESCRIPTION
    Function to create a new User

.PARAMETER SamAccountName
    Specifies the SamAccountName parameter

.PARAMETER AccountPassword
    Specifies the password parameter

.PARAMETER Enabled
    Specifies if the user need to be enabled on creation.
    Default is $False.

.PARAMETER GivenName
    Specifies the GivenName parameter

.PARAMETER SurName
    Specifies the Surname parameter

.PARAMETER UserPrincipalName
    Specifies the UserPrincipalName parameter.

.PARAMETER DisplayName
    Specifies the DisplayName parameter.

.PARAMETER Name
    Specifies the Name parameter.

.PARAMETER PasswordNeverExpires
    Specifies if the Password Never Expires

.PARAMETER UserCannotChangePassword
    Specifies if the User Cannot Change Password

.PARAMETER PasswordNotRequired
    Specifies if the Password is Not Required

.PARAMETER Credential
    Specifies the alternative credential to use.
    By default it will use the current user windows credentials.

.PARAMETER DomainName
    Specifies the alternative Domain where the user should be created
    By default it will use the current domain.

.PARAMETER Passthru
    Specifies if you want to see the object created after running the command.

.EXAMPLE
    PS C:\> New-ADSIUser -SamAccountName "fxtest04" -Enabled -AccountPassword (Read-Host -AsSecureString "AccountPassword") -Passthru

.EXAMPLE
    PS C:\> New-ADSIUser -SamAccountName "fxtest04" -Enabled -AccountPassword (Read-Host -AsSecureString "AccountPassword") -Passthru

    # You can test the credential using the following function
    Test-ADSICredential -AccountName "fxtest04" -AccountPassword (Read-Host -AsSecureString "AccountPassword")

.NOTES
    Francois-Xavier.Cat
    LazyWinAdmin.com
    @lazywinadm
    github.com/lazywinadmin/AdsiPS

.LINK
        https://msdn.microsoft.com/en-us/library/System.DirectoryServices.AccountManagement.UserPrincipal(v=vs.110).aspx
#>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]$SamAccountName,

        [System.Security.SecureString]$AccountPassword,

        [switch]$Enabled = $false,

        [String]$GivenName,

        [String]$SurName,

        [String]$UserPrincipalName,

        [String]$DisplayName,

        [String]$Name,

        [Switch]$PasswordNeverExpires = $false,

        [Switch]$UserCannotChangePassword = $false,

        [Switch]$PasswordNotRequired = $false,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [String]$DomainName,

        [Switch]$Passthru
    )

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
            if ($PSCmdlet.ShouldProcess($SamAccountName, "Create User Account"))
            {
                Write-Verbose -message "Build the user object"
                $User = New-Object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $context

                Write-Verbose -message "set the properties"
                $User.SamAccountName = $SamAccountName
                $User.Enabled = $Enabled
                $user.PasswordNeverExpires = $PasswordNeverExpires
                $user.UserCannotChangePassword = $UserCannotChangePassword
                $User.PasswordNotRequired = $PasswordNotRequired

                if ($PSBoundParameters['Name'])
                {
                    $User.Name = $Name
                }
                if ($PSBoundParameters['DisplayName'])
                {
                    $User.DisplayName = $DisplayName
                }
                if ($PSBoundParameters['GivenName'])
                {
                    $User.GivenName = $GivenName
                }
                if ($PSBoundParameters['SurName'])
                {
                    $User.SurName = $SurName
                }
                if ($PSBoundParameters['UserPrincipalName'])
                {
                    $User.UserPrincipalName = $UserPrincipalName
                }
                if ($PSBoundParameters['Description'])
                {
                    $user.Description = $Description
                }
                if ($PSBoundParameters['EmployeeId'])
                {
                    $user.EmployeeId = $EmployeeId
                }
                if ($PSBoundParameters['HomeDirectory'])
                {
                    $user.HomeDirectory = $HomeDirectory
                }
                if ($PSBoundParameters['HomeDrive'])
                {
                    $user.HomeDrive = $HomeDrive
                }
                if ($PSBoundParameters['MiddleName'])
                {
                    $user.MiddleName = $MiddleName
                }
                if ($PSBoundParameters['VoiceTelephoneNumber'])
                {
                    $user.VoiceTelephoneNumber
                }
                if ($PSBoundParameters['AccountPassword'])
                {
                    $User.SetPassword((New-Object -TypeName PSCredential -ArgumentList "user", $AccountPassword).GetNetworkCredential().Password)
                }

                Write-Verbose -message "Create the Account in Active Directory"
                $User.Save($Context)
            }
        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
            break
        }
    }
    end
    {
        if ($PSBoundParameters['Passthru'])
        {
            $ContextSplatting.Remove("ContextType")
            Get-ADSIUser -Identity $SamAccountName @ContextSplatting
        }
    }
}