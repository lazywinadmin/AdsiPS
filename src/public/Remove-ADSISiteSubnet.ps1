function Remove-ADSISiteSubnet
{
    <#
.SYNOPSIS
    function to remove a Subnet

.DESCRIPTION
    function to remove a Subnet

.PARAMETER SubnetName
    Specifies the Subnet Name

.PARAMETER Credential
    Specifies the alternative credential to use.
    By default it will use the current user windows credentials.

.PARAMETER ForestName
    Specifies the alternative Forest where the user should be created
    By default it will use the current Forest.

.EXAMPLE
    Remove-ADSISiteSubnet -SubnetName '192.168.8.0/24'

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $SubnetName,

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
    }
    process
    {
        try
        {
            if($SubnetName.GetType().FullName -eq 'System.String') {
                $ADSISiteSubnet = Get-ADSISiteSubnet -SubnetName $SubnetName @ContextSplatting
                if($ADSISiteSubnet -eq $null){
                    Write-Error "[$FunctionName] Could not find Site"
                } else {
                    Write-Verbose "[$FunctionName] Found Site"
                }
            } else {
                $ADSISiteSubnet = $SubnetName
            }
            if ($PSCmdlet.ShouldProcess($SubnetName, "Remove Subnet"))
            {
                $ADSISiteSubnet.Delete()
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
    }
}




