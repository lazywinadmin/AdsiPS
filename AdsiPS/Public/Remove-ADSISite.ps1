Function Remove-ADSISite
{
<#
.EXAMPLE
    Remove-ADSISite -SiteName WOW01
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$true)]
    [String]$SiteName,
    [String]$Location,
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
            (Get-ADSISite -Name $SiteName @ContextSplatting).Delete()
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

