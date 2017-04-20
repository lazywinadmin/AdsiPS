function Get-ADSIGroupMember
{
<#
.SYNOPSIS
	Function to retrieve the members from a specific group in Active Directory

.DESCRIPTION
	Function to retrieve the members from a specific group in Active Directory

.PARAMETER Identity
	Specifies the Identity of the Group
	
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
	Specifies alternative credential

.PARAMETER Recurse
	Retrieves all the recursive members (Members of group(s)'s members)
	
.PARAMETER DomainName
	Specifies the alternative Domain where the user should be created
	By default it will use the current domain.
	
.PARAMETER GroupsOnly
	Specifies that you only want to retrieve the members of type Group only.

.EXAMPLE
	Get-ADSIGroupMember -Identity 'Finance'
	
	Retrieve the direct members of the group 'Finance'

.EXAMPLE
	Get-ADSIGroupMember -Identity 'Finance' -Recursive
	
	Retrieve the direct and nested members of the group 'Finance'

.EXAMPLE
	Get-ADSIGroupMember -Identity 'Finance' -GroupsOnly
	
	Retrieve the direct groups members of the group 'Finance'
	
.EXAMPLE
	Get-ADSIGroupMember -Identity 'Finance' -Credential (Get-Credential)
	
	Retrieve the direct members of the group 'Finance' using alternative Credential

.EXAMPLE
	Get-ADSIGroupMember -Identity 'Finance' -Credential (Get-Credential) -DomainName FX.LAB
	
	Retrieve the direct members of the group 'Finance' using alternative Credential in the domain FX.LAB
	
.EXAMPLE
	$Comp = Get-ADSIGroupMember -Identity 'SERVER01'
	$Comp.GetUnderlyingObject()| select-object *

	Help you find all the extra properties

.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.groupprincipal%28v=vs.110%29.aspx?f=255&MSPPError=-2147217396
	
.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
#>
	[CmdletBinding(DefaultParameterSetName='All')]
	param ([Parameter(Mandatory=$true)]
		[System.String]$Identity,
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[System.String]$DomainName,
		
		[Parameter(ParameterSetName='All')]
		[Switch]$Recurse,
		
		[Parameter(ParameterSetName = 'Groups')]
		[Switch]$GroupsOnly
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
			
			IF ($PSBoundParameters['GroupsOnly'])
			{
				Write-Verbose -Message "GROUP: $($Identity.toUpper()) - Retrieving Groups only"
				$Account = ([System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Identity))
				$Account.GetGroups()
			}
			ELSE
			{
				Write-Verbose -Message "GROUP: $($Identity.toUpper()) - Retrieving All members"
				IF ($PSBoundParameters['Recursive']) { Write-Verbose -Message "GROUP: $($Identity.toUpper()) - Recursive parameter Specified" }
				# Returns a collection of the principal objects that is contained in the group.
				# When the $recurse flag is set to true, this method searches the current group recursively and returns all nested group members.
				([System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Identity)).GetMembers($Recurse)
			}
		}
		CATCH
		{
			$Error[0]
		}
	}
}
