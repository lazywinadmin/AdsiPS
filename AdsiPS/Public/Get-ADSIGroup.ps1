function Get-ADSIGroup
{
<#
	.SYNOPSIS
		Function to retrieve a group in Active Directory
	
	.DESCRIPTION
		Function to retrieve a group in Active Directory
	
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
	
	.PARAMETER GroupScope
		Specifies the Group Scope (Global, Local or Universal)
	
	.PARAMETER IsSecurityGroup
		Specifies if you look for security group, default is $true.
	
	.PARAMETER Description
		Specifies the description of the group
	
	.PARAMETER UserPrincipalName
		Specifies the UPN
	
	.PARAMETER Displayname
		Specifies the DisplayName
	
	.PARAMETER Name
		Specifies the Name
	
	.PARAMETER SID
		Specifies the SID
	
	.EXAMPLE
		Get-ADSIGroup -Identity 'SERVER01'
	
	.EXAMPLE
		Get-ADSIGroup -Identity 'SERVER01' -Credential (Get-Credential)
	
	.EXAMPLE
		Get-ADSIGroup -Name "*ADSIPS*"
	
	.EXAMPLE
		Get-ADSIGroup -ISSecurityGroup:$true -Description "*"
	
	.EXAMPLE
		$Comp = Get-ADSIGroup -Identity 'SERVER01'
		$Comp.GetUnderlyingObject()| select-object *
		
		Help you find all the extra properties
	
	.EXAMPLE
		Get-ADSIGroup -GroupScope Universal -IsSecurityGroup
	
	.EXAMPLE
		Get-ADSIGroup -GroupScope Universal -IsSecurityGroup:$false
	
	.NOTES
		Francois-Xavier Cat
		lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
	
	.LINK
		https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.groupprincipal(v=vs.110).aspx
#>
	
	[CmdletBinding(DefaultParameterSetName = 'All')]
	[OutputType('System.DirectoryServices.AccountManagement.GroupPrincipal')]
	param
	(
		[Parameter(ParameterSetName = 'Identity')]
		[string]$Identity,
		[System.Management.Automation.Credential()]
		[Alias('RunAs')]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		[Alias('Domain', 'Server')]
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain(),
		[Parameter(ParameterSetName = 'Filter')]
		[system.directoryservices.accountmanagement.groupscope]$GroupScope,
		[Parameter(ParameterSetName = 'Filter')]
		[switch]$IsSecurityGroup = $true,
		[Parameter(ParameterSetName = 'Filter')]
		$Description,
		[Parameter(ParameterSetName = 'Filter')]
		$UserPrincipalName,
		[Parameter(ParameterSetName = 'Filter')]
		$Displayname,
		[Parameter(ParameterSetName = 'Filter')]
		$Name,
		[Parameter(ParameterSetName = 'Filter')]
		$SID
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
			IF ($Identity)
			{
				[System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Identity)
			}
			ELSE
			{
				$GroupPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.GroupPrincipal -ArgumentList $Context
				#$GroupPrincipal.Name = $Identity
				$searcher = new-object System.DirectoryServices.AccountManagement.PrincipalSearcher
				$searcher.QueryFilter = $GroupPrincipal
				$searcher.QueryFilter.IsSecurityGroup = $IsSecurityGroup
				if ($PSBoundParameters['GroupScope']) { $searcher.QueryFilter.GroupScope = $GroupScope }
				if ($PSBoundParameters['UserPrincipalName']) { $searcher.QueryFilter.UserPrincipalName = $UserPrincipalName }
				if ($PSBoundParameters['Description']) { $searcher.QueryFilter.Description = $Description }
				if ($PSBoundParameters['DisplayName']) { $searcher.QueryFilter.DisplayName = $DisplayName }
				#if($PSBoundParameters['DistinguishedName']){$searcher.QueryFilter.DistinguishedName = $DistinguishedName}
				if ($PSBoundParameters['Sid']) { $searcher.QueryFilter.Sid.Value = $SID }
				if ($PSBoundParameters['Name']) { $searcher.QueryFilter.Name = $Name }
				
				$searcher.FindAll()
			}
		}
		CATCH
		{
			Write-Error $error[0]
		}
	}
}