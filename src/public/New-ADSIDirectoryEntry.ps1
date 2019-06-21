function New-ADSIDirectoryEntry
{
<#
.SYNOPSIS
    Function to create a DirectoryEntry instance

.DESCRIPTION
    Function to create a DirectoryEntry instance

    This function is typically a helper function used by some of the other functions
    in the module ADSIPS

.PARAMETER Path
    The path of this DirectoryEntry.
    Default is $(([adsisearcher]"").Searchroot.path)

    https://msdn.microsoft.com/en-us/library/system.directoryservices.directoryentry.path.aspx

.PARAMETER Credential
    Specifies alternative credential to use

.PARAMETER AuthenticationType
    Specifies the optional AuthenticationType secure flag(s) to use

    The Secure flag can be used in combination with other flags such as ReadonlyServer, FastBind.

    See the full detailed list here:
    https://msdn.microsoft.com/en-us/library/system.directoryservices.authenticationtypes(v=vs.110).aspx

.EXAMPLE
    New-ADSIDirectoryEntry

    Create a new DirectoryEntry object for the current domain

.EXAMPLE
    New-ADSIDirectoryEntry -Path "LDAP://DC=FX,DC=lab"

    Create a new DirectoryEntry object for the domain FX.Lab

.EXAMPLE
    New-ADSIDirectoryEntry -Path "LDAP://DC=FX,DC=lab" -Credential (Get-Credential)

    Create a new DirectoryEntry object for the domain FX.Lab  with the specified credential

.LINK
    https://msdn.microsoft.com/en-us/library/system.directoryservices.directoryentry.aspx

.LINK
    http://www.lazywinadmin.com/2013/10/powershell-using-adsi-with-alternate.html

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Alias('DomainName')]
        $Path = $(([adsisearcher]"").Searchroot.path),

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [System.DirectoryServices.AuthenticationTypes[]]$AuthenticationType
    )
    try
    {
        #If path isn't prefixed with LDAP://, add it
        if ($PSBoundParameters['Path'])
        {
            if ($Path -notlike "LDAP://*")
            {
                $Path = "LDAP://$Path"
            }
        }

        #Building Argument
        if ($PSBoundParameters['Credential'])
        {
            $ArgumentList = $Path, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
        }
        else
        {
            $ArgumentList = $Path
        }

        if ($PSBoundParameters['AuthenticationType'])
        {
            $ArgumentList += $AuthenticationType
        }

        if ($PSCmdlet.ShouldProcess($Path, "Create Directory Entry"))
        {
            # Create object
            New-Object -TypeName DirectoryServices.DirectoryEntry -ArgumentList $ArgumentList
        }
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)

    }
}