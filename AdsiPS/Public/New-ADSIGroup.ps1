function New-ADSIGroup
{
<#

New-ADSIGroup -Name "TestfromADSIPS3" -Description "some description" -GroupScope Local -IsSecurityGroup
#>
PARAM(
    [parameter(Mandatory=$true)]
    $Name="TestFromADSIPS",
    [String]$DisplayName,
    [String]$UserPrincipalName,
    [String]$Description,
    [parameter(Mandatory=$true)]
    [system.directoryservices.accountmanagement.groupscope]$GroupScope,
    [switch]$IsSecurityGroup=$false,
    [switch]$Passthru,
    [Alias("RunAs")]
	[System.Management.Automation.Credential()]
	$Credential = [System.Management.Automation.PSCredential]::Empty,
    [String]$DomainName
)
    BEGIN{
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
        # Create Context splatting
        $ContextSplatting=@{ ContextType = "Domain" }

		IF ($PSBoundParameters['Credential']){$ContextSplatting.Credential = $Credential}
        IF ($PSBoundParameters['DomainName']){$ContextSplatting.DomainName = $DomainName}
        
        $Context = New-ADSIPrincipalContext @ContextSplatting
    }
    PROCESS
    {
        TRY
        {
            $newGroup = [System.DirectoryServices.AccountManagement.GroupPrincipal]::new($Context,$Name)
            $newGroup.Description = $Description
            $newGroup.GroupScope = $GroupScope
            $newGroup.IsSecurityGroup = $IsSecurityGroup
            $newGroup.DisplayName
            #$newGroup.DistinguishedName = 
            #$newGroup.Members
            $newGroup.SamAccountName = $Name
    
            IF($PSBoundParameters['UserPrincipalName']){$newGroup.UserPrincipalName = $UserPrincipalName}
        
            # Push to ActiveDirectory
            $newGroup.Save($Context)

            IF($PSBoundParameters['Passthru'])
            {
                $ContextSplatting.Remove('ContextType')
                Get-ADSIGroup -Identity $Name @ContextSplatting
            }
        }
        CATCH
        {
        Write-Error $Error[0]
        }

    }
    END
    {
        
    }
}
New-ADSIGroup -Name "TestfromADSIPS5" -Description "some description" -GroupScope Local -IsSecurityGroup -Passthru -domain "FX.LAB"