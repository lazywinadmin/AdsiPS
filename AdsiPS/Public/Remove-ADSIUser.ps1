function Remove-ADSIUser
{
<#
	.SYNOPSIS
		Function to delete a User Account
	
	.DESCRIPTION
		Function to delete a User Account
	
	.PARAMETER Identity
		Specifies the Identity of the User.
	
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
		Remove-ADSIUser fxtest02
	
	.EXAMPLE
		Remove-ADSIUser fxtest02 -whatif
	
	.NOTES
		Francois-Xavier.Cat
		LazyWinAdmin.com
		@lazywinadm
		github.com/lazywinadmin
	.LINK
		https://msdn.microsoft.com/en-us/library/System.DirectoryServices.AccountManagement.UserPrincipal(v=vs.110).aspx
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
                (Get-ADSIUser -Identity $Identity @ContextSplatting).Delete()
            }
        }
        CATCH{
            Write-Error $Error[0]
        }
    }
}