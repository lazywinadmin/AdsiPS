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

.PARAMETER LDAPFilter
	Specifies the LDAP query to perform

.EXAMPLE
	Get-ADSIGroup -Identity 'SERVER01'

	Retrieve the group TestGroup in the current domain.

.EXAMPLE
	Get-ADSIGroup -Identity 'TestGroup' -Credential (Get-Credential)

	Retrieve the group TestGroup in the current domain using alternative credential

.EXAMPLE
	Get-ADSIGroup -Name "*ADSIPS*"

	Retrieve all the group(s) that contains 'ADSIPS' in their name

.EXAMPLE
	Get-ADSIGroup -ISSecurityGroup $true -Description "*"

	Retrieve all the security group(s) that have a description

.EXAMPLE
	$Comp = Get-ADSIGroup -Identity 'Finance'
	$Comp.GetUnderlyingObject()| select-object *
	
	Help you find all the extra properties of the Finance group object

.EXAMPLE
	Get-ADSIGroup -GroupScope Universal -IsSecurityGroup:$false

	This will retrieve the Universal groups object with the SamAccountName TestGroup01 in the current domain.

.EXAMPLE
	Get-ADSIGroup -LDAPFilter "(SamAccountName=TestGroup01)"

	This will retrieve the group object with the SamAccountName TestGroup01 in the current domain.

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS

.OUTPUTS
	System.DirectoryServices.AccountManagement.GroupPrincipal

.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.groupprincipal(v=vs.110).aspx
#>
	
	[CmdletBinding(DefaultParameterSetName = 'All')]
	[OutputType('System.DirectoryServices.AccountManagement.GroupPrincipal')]
	param
	(
		[Parameter(ParameterSetName = 'Identity')]
		[string]$Identity,

		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,

		[Alias('Domain', 'Server')]
		$DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain(),

		[Parameter(ParameterSetName = 'Filter')]
		[system.directoryservices.accountmanagement.groupscope]$GroupScope,

		[Parameter(ParameterSetName = 'Filter')]
		[bool]$IsSecurityGroup,

		[Parameter(ParameterSetName = 'Filter')]
		$Description,

		[Parameter(ParameterSetName = 'Filter')]
		$UserPrincipalName,

		[Parameter(ParameterSetName = 'Filter')]
		$Displayname,

		[Parameter(ParameterSetName = 'Filter')]
		$Name,

		[Parameter(ParameterSetName = 'Filter')]
		$SID,
		
        [Parameter(ParameterSetName = 'LDAPFilter')]
        $LDAPFilter
        
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
                Write-Verbose "Identity"
				[System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Identity)
			}
            ELSEIF ($PSBoundParameters['LDAPFilter'])
            {
                Write-Verbose "LDAPFilter"
			
	            # Directory Entry object
	            $DirectoryEntryParams = $ContextSplatting.remove('ContextType')
	            $DirectoryEntry = New-ADSIDirectoryEntry @DirectoryEntryParams
			
	            # Principal Searcher
	            $DirectorySearcher = new-object -TypeName System.DirectoryServices.DirectorySearcher
	            $DirectorySearcher.SearchRoot = $DirectoryEntry
	            $DirectorySearcher.Filter = "(&(objectCategory=group)$LDAPFilter)"

            
                $DirectorySearcher.FindAll() | ForEach-Object {
		            [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, ($_.path -replace 'LDAP://'))
	            }
            }
			ELSE
			{
                Write-Verbose "Other Filters"

				$GroupPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.GroupPrincipal -ArgumentList $Context
				#$GroupPrincipal.Name = $Identity
				$searcher = new-object System.DirectoryServices.AccountManagement.PrincipalSearcher
				$searcher.QueryFilter = $GroupPrincipal
				if ($PSBoundParameters['IsSecurityGroup']) { $searcher.QueryFilter.IsSecurityGroup = $IsSecurityGroup}
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