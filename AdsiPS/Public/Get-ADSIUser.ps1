function Get-ADSIUser
{
<#
	.SYNOPSIS
		Function to retrieve a User in Active Directory
	
	.DESCRIPTION
		Function to retrieve a User in Active Directory
	
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
	
	.EXAMPLE
		Get-ADSIUser -Identity 'testaccount'
	
	.EXAMPLE
		Get-ADSIUser -Identity 'testaccount' -Credential (Get-Credential)
	
	.EXAMPLE
		$user = Get-ADSIUser -Identity 'testaccount'
		$user.GetUnderlyingObject()| select-object *
		
		Help you find all the extra properties
	
	.NOTES
		Francois-Xavier Cat
		lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
	
	.LINK
		https://msdn.microsoft.com/en-us/library/System.DirectoryServices.AccountManagement.UserPrincipal(v=vs.110).aspx
#>
	
	[CmdletBinding()]
	#[OutputType([System.DirectoryServices.AccountManagement.UserPrincipal])]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Identity,
		
		[System.Management.Automation.Credential()]
		[Alias('RunAs')]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
	
		[String]$DomainName
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
			[System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, $Identity)
		}
		ELSE
		{
			$UserPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $Context
			$Searcher = new-object System.DirectoryServices.AccountManagement.PrincipalSearcher
			$Searcher.QueryFilter = $UserPrincipal
			
			<#
			#$searcher.QueryFilter.AccountExpirationDate
			#$searcher.QueryFilter.AdvancedSearchFilter
			#$searcher.QueryFilter.AdvancedSearchFilter.AccountExpirationDate(
			#$searcher.QueryFilter.AdvancedSearchFilter.LastBadPasswordAttempt(
			#$searcher.QueryFilter.AdvancedSearchFilter.LastLogonTime(
			#$searcher.QueryFilter.AdvancedSearchFilter.LastPasswordSetTime(
			$searcher.QueryFilter.Description
			$searcher.QueryFilter.DisplayName
			$searcher.QueryFilter.DistinguishedName
			$searcher.QueryFilter.EmailAddress
			$searcher.QueryFilter.EmployeeId
			$searcher.QueryFilter.Enabled
			$searcher.QueryFilter.GivenName
			$searcher.QueryFilter.Guid
			$searcher.QueryFilter.HomeDirectory
			$searcher.QueryFilter.HomeDrive
			$searcher.QueryFilter.MiddleName
			$searcher.QueryFilter.Name

			PasswordNeverExpires
			PasswordNotRequired 
			PermittedLogonTimes
			PermittedWorkstations
			SamAccountName
			ScriptPath
			Sid
			Surname
			UserCannotChangePassword
			UserPrincipalName
			VoiceTelephoneNumber
			$searcher.QueryFilter |gm
			$searcher.FindAll()
			#>
			
			
			$Searcher.FindAll()
		}
	}
}
