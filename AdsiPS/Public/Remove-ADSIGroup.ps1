function Remove-ADSIGroup
{
<#
.EXAMPLE
    Remove-ADSIGroup FXTESTGROUP
.EXAMPLE
    Remove-ADSIGroup FXTESTGROUP -whatif
#>
[CmdletBinding(SupportsShouldProcess=$true)]
PARAM(
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName="SamAccountName", ValueFromPipeline=$true)]
    $Identity,
    [Alias("RunAs")]
	[System.Management.Automation.Credential()]
	$Credential = [System.Management.Automation.PSCredential]::Empty,
    [String]$DomainName)

    BEGIN
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
        # Create Context splatting
        $ContextSplatting=@{}
		IF ($PSBoundParameters['Credential']){$ContextSplatting.Credential = $Credential}
        IF ($PSBoundParameters['DomainName']){$ContextSplatting.DomainName = $DomainName}
        
        $Context = New-ADSIPrincipalContext @ContextSplatting -contexttype Domain
    }
    PROCESS
    {
        TRY{
            if ($pscmdlet.ShouldProcess("$Identity", "Delete Account")){
                (Get-ADSIGroup -Identity $Identity @ContextSplatting).delete()
            }
        }
        CATCH{
            Write-Error $Error[0]
        }
    }
}