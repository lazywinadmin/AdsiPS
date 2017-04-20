function Move-ADSIGroup
{
<#
.SYNOPSIS
	Function to Move an Active Directory group in a different Organizational Unit (OU)

.DESCRIPTION
	Function to Move an Active Directory group in a different Organizational Unit (OU)

.PARAMETER Identity
	Specifies the Identity of the group
	
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
	By default it will use the current Domain.

.PARAMETER Destination
	Specifies the Distinguished Name where the object will be moved	

.EXAMPLE
	Move-ADSIGroup -Identity 'FXGROUPTEST01' -Destination 'OU=TEST,DC=FX,DC=lab'

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS

.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.groupprincipal(v=vs.110).aspx
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.AccountManagement.GroupPrincipal')]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Identity,

		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,

		[Alias('Domain', 'Server')]
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain(),
		
		$Destination
	)
	
	BEGIN
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
		# Create Context splatting
		$ContextSplatting = @{ ContextType = "Domain" }
		
		IF ($PSBoundParameters['Credential']) { $ContextSplatting.Credential = $Credential }
		IF ($PSBoundParameters['DomainName']) { $ContextSplatting.DomainName = $DomainName }
		
		$Context = New-ADSIPrincipalContext @ContextSplatting
	}
	PROCESS
	{
		TRY
		{
			$Group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Identity)
			
			# Create DirectoryEntry object
			$NewDirectoryEntry = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList "LDAP://$Destination"
			
			# Move the computer
			$Group.GetUnderlyingObject().psbase.moveto($NewDirectoryEntry)
			$Group.Save()
			
		}
		CATCH
		{
			Write-Error $error[0]
		}
	}
}
