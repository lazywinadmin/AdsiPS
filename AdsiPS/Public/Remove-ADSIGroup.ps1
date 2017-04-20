function Remove-ADSIGroup
{
<#
.SYNOPSIS
	function to remove a group

.DESCRIPTION
	function to remove a group

.PARAMETER Identity
	Specifies the Identity

	You can provide one of the following properties
		DistinguishedName
		Guid
		Name
		SamAccountName
		Sid
		UserPrincipalName
	
	Those properties come from the following enumeration:
		System.DirectoryServices.AccountManagement.IdentityType

.PARAMETER Credential
	Specifies the alternative credential to use.
	By default it will use the current user windows credentials.

.PARAMETER DomainName
	Specifies the alternative Domain where the user should be created
	By default it will use the current domain.

.EXAMPLE
	Remove-ADSIGroup FXTESTGROUP

.EXAMPLE
	Remove-ADSIGroup FXTESTGROUP -whatif

.NOTES
	Francois-Xavier.Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
#>
[CmdletBinding(SupportsShouldProcess=$true)]
PARAM(
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)]
    $Identity,

    [Alias("RunAs")]
	[System.Management.Automation.PSCredential]
	[System.Management.Automation.Credential()]
	$Credential = [System.Management.Automation.PSCredential]::Empty,

    [String]$DomainName)

    BEGIN
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
        # Create Context splatting
		$ContextSplatting = @{
			Contexttype = "Domain"
		}
		
		IF ($PSBoundParameters['Credential']){$ContextSplatting.Credential = $Credential}
        IF ($PSBoundParameters['DomainName']){$ContextSplatting.DomainName = $DomainName}
        
        $Context = New-ADSIPrincipalContext @ContextSplatting
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