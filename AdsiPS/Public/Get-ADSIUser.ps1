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

.PARAMETER NoResultLimit
    Remove the SizeLimit of 1000

    SizeLimit is useless, it can't go over the server limit which is 1000 by default

.PARAMETER LDAPFilter
	Specifies the LDAP query to apply

.EXAMPLE
	Get-ADSIUser
	
	This example will retrieve all accounts in the current domain using
	the current user credential. There is a limit of 1000 objects returned.

.EXAMPLE
	Get-ADSIUser -NoResultLimit
	
	This example will retrieve all accounts in the current domain using
	the current user credential. Using the parameter -NoResultLimit will remove the Sizelimit on the Result.

.EXAMPLE
	Get-ADSIUser -Identity 'testaccount'
	
	This example will retrieve the account 'testaccount' in the current domain using 
	the current user credential

.EXAMPLE
	Get-ADSIUser -Identity 'testaccount' -Credential (Get-Credential)
	
	This example will retrieve the account 'testaccount' in the current domain using 
	the specified credential
	
.EXAMPLE
	Get-ADSIUSer -LDAPFilter "(&(objectClass=user)(samaccountname=*fx*))" -DomainName 'fx.lab'
	
	This example will retrieve the user account that contains fx inside the samaccountname
	property for the domain fx.lab. There is a limit of 1000 objects returned.

.EXAMPLE
	Get-ADSIUSer -LDAPFilter "(&(objectClass=user)(samaccountname=*fx*))" -DomainName 'fx.lab' -NoResultLimit
	
	This example will retrieve the user account that contains fx inside the samaccountname
	property for the domain fx.lab. There is a limit of 1000 objects returned.
	
.EXAMPLE
	$user = Get-ADSIUser -Identity 'testaccount'
	$user.GetUnderlyingObject()| select-object *

	Help you find all the extra properties and methods available

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS

.LINK
	https://msdn.microsoft.com/en-us/library/System.DirectoryServices.AccountManagement.UserPrincipal(v=vs.110).aspx
#>
	
	[CmdletBinding(DefaultParameterSetName = "All")]
	[OutputType('System.DirectoryServices.AccountManagement.UserPrincipal')]
	param
	(
		[Parameter(Mandatory = $true, ParameterSetName = "Identity")]
		[string]$Identity,

		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,

		[String]$DomainName,

        [Parameter(Mandatory = $true, ParameterSetName = "LDAPFilter")]
		[string]$LDAPFilter,

        [Parameter(ParameterSetName = "LDAPFilter")]
        [Parameter(ParameterSetName = "All")]
        [Switch]$NoResultLimit
		
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
			Write-Verbose "Identity"
			[System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, $Identity)

		}
		ELSEIF ($PSBoundParameters['LDAPFilter'])
		{
			
			# Directory Entry object
			$DirectoryEntryParams = $ContextSplatting.remove('ContextType')
			$DirectoryEntry = New-ADSIDirectoryEntry @DirectoryEntryParams
			
			# Principal Searcher
			$DirectorySearcher = new-object -TypeName System.DirectoryServices.DirectorySearcher
			$DirectorySearcher.SearchRoot = $DirectoryEntry

			$DirectorySearcher.Filter = "(&(objectCategory=user)$LDAPFilter)"
            #$DirectorySearcher.PropertiesToLoad.AddRange("'Enabled','SamAccountName','DistinguishedName','Sid','DistinguishedName'")

            if(-not$PSBoundParameters['NoResultLimit']){Write-warning "Result is limited to 1000 entries, specify a specific number on the parameter SizeLimit or 0 to remove the limit"}
            else{
                # SizeLimit is useless, even if there is a$Searcher.GetUnderlyingSearcher().sizelimit=$SizeLimit
                # the server limit is kept
                $DirectorySearcher.PageSize = 10000
            }
            
            $DirectorySearcher.FindAll() | ForEach-Object {
				[System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, ($_.path -replace 'LDAP://'))
			}# Return UserPrincipale object
		}
		ELSE
		{
			Write-Verbose "Searcher"
			
			$UserPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $Context
			$Searcher = new-object System.DirectoryServices.AccountManagement.PrincipalSearcher
			$Searcher.QueryFilter = $UserPrincipal

            if(-not$PSBoundParameters['NoResultLimit']){Write-warning "Result is limited to 1000 entries, specify a specific number on the parameter SizeLimit or 0 to remove the limit"}
            else {
                # SizeLimit is useless, even if there is a$Searcher.GetUnderlyingSearcher().sizelimit=$SizeLimit
                # the server limit is kept
                $Searcher.GetUnderlyingSearcher().pagesize=10000
                
                }
           #$Searcher.GetUnderlyingSearcher().propertiestoload.AddRange("'Enabled','SamAccountName','DistinguishedName','Sid','DistinguishedName'")
			$Searcher.FindAll() # Return UserPrincipale
		}
	}
}