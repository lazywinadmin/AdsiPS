Function Remove-ADSISite
{
    <#
.SYNOPSIS
    function to remove a Site

.DESCRIPTION
    function to remove a Site

.PARAMETER SiteName
    Specifies the Site Name

.PARAMETER Credential
    Specifies the alternative credential to use.
    By default it will use the current user windows credentials.

.PARAMETER ForestName
    Specifies the alternative Forest where the user should be created
    By default it will use the current Forest.

.EXAMPLE
    Remove-ADSISite -SiteName WOW01

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [parameter(Mandatory = $true)]
        [String]$SiteName,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [String]$ForestName

    )
    begin
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement

        # Create Context splatting
        $ContextSplatting = @{}

        if ($PSBoundParameters['Credential'])
        {
            $ContextSplatting.Credential = $Credential
        }
        if ($PSBoundParameters['ForestName'])
        {
            $ContextSplatting.ForestName = $ForestName
        }
    }
    process
    {
        try
        {
            if ($PSCmdlet.ShouldProcess($SiteName, "Delete"))
            {
                # Delete Site
                (Get-ADSISite -Name $SiteName @ContextSplatting).Delete()
            }
        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
            break
        }
    }
}

