Function Remove-ADSISiteSubnet
{
<#
.EXAMPLE
    Remove-ADSISiteSubnet -SubnetName '192.168.8.0/24'
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$true)]
    [String]$SubnetName,
    [Alias("RunAs")]
	[System.Management.Automation.Credential()]
	$Credential = [System.Management.Automation.PSCredential]::Empty,
    [String]$ForestName

)
    BEGIN{
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
        # Create Context splatting
        $ContextSplatting=@{}

		IF ($PSBoundParameters['Credential']){$ContextSplatting.Credential = $Credential}
        IF ($PSBoundParameters['ForestName']){$ContextSplatting.ForestName = $ForestName}
    }
    PROCESS
    {
        TRY
        {
            (Get-ADSISiteSubnet -SubnetName $SubnetName @ContextSplatting).Delete()
        }
        CATCH{
            Write-Error $Error[0]
            break
        }
    }
    END
    {
    }	
}




