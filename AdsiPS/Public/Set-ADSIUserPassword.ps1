function Set-ADSIUserPassword
{
PARAM(
    [parameter(Mandatory=$true)]
    $Identity,

    [parameter(Mandatory=$true)]
    $Password,

    [Alias("RunAs")]
    [System.Management.Automation.PSCredential]
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
    }
    PROCESS
    {
        TRY{
            (Get-ADSIUser -Identity $Identity @ContextSplatting).SetPassword("$Password")
        }
        CATCH{
            Write-Error $Error[0]
        }
    }
}