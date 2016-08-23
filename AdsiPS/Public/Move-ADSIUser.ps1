function Move-ADSIUser
{
<#
.SYNOPSIS
	Function to move a User in Active Directory

.DESCRIPTION
	Function to move a User in Active Directory

.PARAMETER Identity
	Specifies the Identity of the User

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

.PARAMETER Destination
	Specifies the Distinguished Name where the object will be moved	

.EXAMPLE
	Move-ADSIUser -Identity 'fxtest01' -Destination "OU=Test,DC=FX,DC=lab"

.EXAMPLE
	Move-ADSIUser -Identity 'fxtest01' -Destination "OU=Test,DC=FX,DC=lab" -Credential (Get-Credential)

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS

.LINK
	https://msdn.microsoft.com/en-us/library/System.DirectoryServices.AccountManagement.UserPrincipal(v=vs.110).aspx
#>
	
	[CmdletBinding()]
	[OutputType('System.DirectoryServices.AccountManagement.UserPrincipal')]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Identity,
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[String]$DomainName,
		
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
		IF ($Identity)
		{
			$user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, $Identity)
			
			# Retrieve DirectoryEntry
			#$User.GetUnderlyingObject()
			
			# Create DirectoryEntry object
			$NewDirectoryEntry = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList "LDAP://$Destination"
			
			# Move the computer
			$User.GetUnderlyingObject().psbase.moveto($NewDirectoryEntry)
			$User.Save()
		}
	}
}
