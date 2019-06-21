function New-ADSIComputer
{
<#
.SYNOPSIS
    function to create a new computer

.DESCRIPTION
    function to create a new computer

.PARAMETER Name
    Specifies the property Name

.PARAMETER DisplayName
    Specifies the property DisplayName

.PARAMETER Description
    Specifies the property Description

.PARAMETER Enable
    Specifies you want the account enabled after creation.
    By Default the account is disable

.PARAMETER Passthru
    Specifies if you want to see the object created after running the command.

.PARAMETER Credential
    Specifies if you want to specifies alternative credentials

.PARAMETER DomainName
    Specifies if you want to specifies alternative DomainName

.EXAMPLE
    New-ADSIComputer FXTEST01 -Description 'Dev system'

    Create a new computer account FXTEST01 and add the description 'Dev System'

.EXAMPLE
    New-ADSIComputer FXTEST01 -enable

    Create a new computer account FXTEST01 inside the default Computers Organizational Unit and Enable the account

.EXAMPLE
    New-ADSIComputer FXTEST01 -Description 'Dev system'

    Create a new computer account FXTEST01 and add the description 'Dev System'

.EXAMPLE
    New-ADSIComputer FXTEST01 -Passthru

    Create a new computer account FXTEST01 and return the object created and its properties.

.NOTES
    https://github.com/lazywinadmin/ADSIPS

.LINK
    https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.computerprincipal(v=vs.110).aspx
#>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        $Name,

        [String]$DisplayName,

        [String]$Description,

        [switch]$Passthru,

        [Switch]$Enable,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [String]$DomainName
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

            if ($PSCmdlet.ShouldProcess($Name, "Create Computer"))
            {
                $newObject = New-Object -TypeName System.DirectoryServices.AccountManagement.ComputerPrincipal -ArgumentList $Context
                $newObject.SamAccountName = $Name

                if ($PSBoundParameters['Enable'])
                {
                    $newObject.Enabled = $true
                }

                if ($PSBoundParameters['Description'])
                {
                    $newObject.Description = $Description
                }

                if ($PSBoundParameters['DisplayName'])
                {
                    $newObject.DisplayName
                }

                # Push to ActiveDirectory
                $newObject.Save($Context)

                if ($PSBoundParameters['Passthru'])
                {
                    $ContextSplatting.Remove('ContextType')
                    Get-ADSIComputer -Identity $Name @ContextSplatting
                }
            }
        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }

    }
    end
    {

    }
}
