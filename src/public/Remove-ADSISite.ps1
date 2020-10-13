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
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $SiteName,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [String]$ForestName

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

        if ($PSBoundParameters['ForestName']){
            Write-Verbose "[$FunctionName] Found ForestName Parameter"
            $ContextSplatting.ForestName = $ForestName
        }
    }
    process
    {
        try
        {
            if($SiteName.GetType().FullName -eq 'System.String') {
                $ADSISite = Get-ADSISite -Name $SiteName @ContextSplatting
                if($ADSISite -eq $null){
                    Write-Error "[$FunctionName] Could not find Site"
                } else {
                    Write-Verbose "[$FunctionName] Found Site"
                }
            } else {
                $ADSISite = $SiteName
            }

            if ($PSCmdlet.ShouldProcess($SiteName, "Delete"))
            {
                # Delete Site
                $ADSISite.Delete()
            }
        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
            break
        }
    }
}

