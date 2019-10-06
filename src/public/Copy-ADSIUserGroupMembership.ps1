function Copy-ADSIUserGroupMembership{
<#
.SYNOPSIS
	Function to Copy the Group Memberships of a User to another in Active Directory

.DESCRIPTION
	Function to Copy the Group Memberships of a User to another in Active Directory

.PARAMETER SourceIdentity
	Specifies the Identity of the Source User
	You can provide one of the following properties
	DistinguishedName
	Guid
	Name
	SamAccountName
	Sid
	UserPrincipalName
	Those properties come from the following enumeration:
	System.DirectoryServices.AccountManagement.IdentityType

.PARAMETER DestinationIdentity
	Specifies the Identity of the Destination User
	You can provide one of the following properties
	DistinguishedName
	Guid
	Name
	SamAccountName
	Sid
	UserPrincipalName
	Those properties come from the following enumeration:
	System.DirectoryServices.AccountManagement.IdentityType

.PARAMETER DomainName
	Specifies the Domain Name where the function should look

.PARAMETER Credential
	Specifies the alternative credential to use.
	By default it will use the current user windows credentials.

.EXAMPLE
	Copy-ADSIUserGroupMembership -SourceIdentity User1 -DestinationIdentity User2 -DomainName "my.domain"

.NOTES
	https://github.com/lazywinadmin/ADSIPS
.LINK
	https://msdn.microsoft.com/en-us/library/System.DirectoryServices.AccountManagement.UserPrincipal(v=vs.110).aspx
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param(
		[Parameter(Mandatory = $true,
			Position = 0,
			ParameterSetName = "Identity")]
		[System.string]$SourceIdentity,
		
		[Parameter(Mandatory = $true,
			Position = 1,
			ParameterSetName = "Identity")]
		[System.string]$DestinationIdentity,
	
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
	
		[System.String]$DomainName
	)
	
	begin{
		$FunctionName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).Mycommand
	
		# Create Context splatting
		$ContextSplatting = @{ }
		if ($PSBoundParameters['Credential']){
			Write-Verbose "[$FunctionName] Found Credential Parameter"
			$ContextSplatting.Credential = $Credential
		}
		if ($PSBoundParameters['DomainName']){
			Write-Verbose "[$FunctionName] Found DomainName Parameter"
			$ContextSplatting.DomainName = $DomainName
		}
	}

	process{
		#GetSourceUserGroups
		$SourceUserGroups = (Get-ADSIUser -Identity $SourceIdentity @ContextSplatting).GetGroups()

		#GetDestinationUserGroups
		$DestinationUserGroups = (Get-ADSIUser -Identity $DestinationIdentity @ContextSplatting).GetGroups()

		#Get only new Groups
		$MissingGroups = Compare-Object -ReferenceObject $SourceUserGroups.SamAccountName -DifferenceObject $DestinationUserGroups.SamAccountName | Where-Object {$_.SideIndicator -eq "<="}
		if($MissingGroups -eq $null){
			Write-Verbose "[$FunctionName] Nothing to do"
		} else {
			Write-Verbose "[$FunctionName] Missing Groups: $($MissingGroups.InputObject)"
		}

		#Add DestinationUser to Missing Groups
		foreach($Group in $MissingGroups.InputObject){
				If($PSCmdlet.ShouldProcess($Group, "Adding $DestinationIdentity to group")){
					Add-ADSIGroupMember -Identity $Group -Member $DestinationIdentity @ContextSplatting
				}
		}
	}
}