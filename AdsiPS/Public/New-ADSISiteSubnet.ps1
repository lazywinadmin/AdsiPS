Function New-ADSISubnet
{
<#
New-ADSISubnet -SubnetName "5.5.5.0/24" -SiteName "FX3" -Location "test"
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$true)]
    [String]$SubnetName,
    [parameter(Mandatory=$true)]
    [String]$SiteName,
    [String]$Location,
    [String]$Description,
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
        
        $Context = New-ADSIDirectoryContext -ContextType Forest
        #New-ADSIDirectoryContext @ContextSplatting -ContextType Forest
    }
    PROCESS
    {
        TRY
        {
            $Subnet = New-Object -TypeName System.DirectoryServices.ActiveDirectory.ActiveDirectorysubnet -ArgumentList $Context,$SubnetName,$SiteName
            $Subnet.Location = $Location
            $Subnet.Save()

            #$SubnetEntry = $Subnet.GetDirectoryEntry()
            #$SubnetEntry.Description = $subnetdescription 
            #$SubnetEntry.CommitChanges()
            #$SubnetEntry
        }
        CATCH{
            $Error[0]
            break
        }
    }
    END
    {
    }	
}


$t = New-ADSISubnet -SubnetName "5.5.5.5/24" -SiteName "FX3" -Location "test"