Function New-ADSISite
{
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
        $ContextSplatting=@{ ContextType = "Forest" }

		IF ($PSBoundParameters['Credential']){$ContextSplatting.Credential = $Credential}
        IF ($PSBoundParameters['ForestName']){$ContextSplatting.ForestName = $ForestName}
        
        $Context = New-ADSIDirectoryContext @ContextSplatting
    }
    PROCESS
    {
        TRY
        {
            $Site = New-Object -TypeName System.DirectoryServices.ActiveDirectory.ActiveDirectorySite -ArgumentList $Context,$SiteName
            $Site.Location = $Location
            $Site.Save()

            #$site.GetDirectoryEntry()
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