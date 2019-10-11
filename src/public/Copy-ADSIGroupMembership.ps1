function Copy-ADSIGroupMembership{
<#
.SYNOPSIS
	Function to Copy the Group Memberships of a User or Computer to another in Active Directory

.DESCRIPTION
	Function to Copy the Group Memberships of a User or Computer to another in Active Directory

.PARAMETER SourceIdentity
	Specifies the Identity of the Source User or Computer
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
	Specifies the Identity of the Destination User or Computer
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
	Copy-ADSIGroupMembership -SourceIdentity User1 -DestinationIdentity User2 -DomainName "my.domain"

.EXAMPLE
	Copy-ADSIGroupMembership -SourceIdentity User1 -DestinationIdentity Computer2 -DomainName "my.domain"

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
		#Get SourceIdentity Type
		If(Get-ADSIComputer -Identity $SourceIdentity){$SourceType = "Computer"}
		If(Get-ADSIUser -Identity $SourceIdentity){$SourceType = "User"}
		If($null -eq $SourceType){Write-Error "SourceIdentity not found"; Exit}

		#Get DestinationIdentity Type
		If(Get-ADSIComputer -Identity $DestinationIdentity){$DestinationType = "Computer"}
		If(Get-ADSIUser -Identity $DestinationIdentity){$DestinationType = "User"}
		If($null -eq $DestinationType){Write-Error "DestinationIdentity not found"; Exit}

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
		#GetSourceGroups
		If($SourceType -eq "User"){
			$SourceGroups = (Get-ADSIUser -Identity $SourceIdentity @ContextSplatting).GetGroups()
			Write-Verbose "[$FunctionName] SourceType: User"
		} elseif ($SourceType -eq "Computer") {
			$SourceGroups = (Get-ADSIComputer -Identity $SourceIdentity @ContextSplatting).GetGroups()
			Write-Verbose "[$FunctionName] SourceType: Computer"
		}
		#GetDestinationGroups
		If($DestinationType -eq "User"){
			$DestinationGroups = (Get-ADSIUser -Identity $DestinationIdentity @ContextSplatting).GetGroups()
			Write-Verbose "[$FunctionName] DestinationType: User"
		} elseif ($DestinationType -eq "Computer") {
			$DestinationGroups = (Get-ADSIComputer -Identity $DestinationIdentity @ContextSplatting).GetGroups()
			Write-Verbose "[$FunctionName] DestinationType: Computer"
		}

		#Get only new Groups
		$MissingGroups = Compare-Object -ReferenceObject $SourceGroups.SamAccountName -DifferenceObject $DestinationGroups.SamAccountName | Where-Object {$_.SideIndicator -eq "<="}
		if($MissingGroups -eq $null){
			Write-Verbose "[$FunctionName] Nothing to do"
		} else {
			Write-Verbose "[$FunctionName] Missing Groups: $($MissingGroups.InputObject)"
		}

		#Add Destination to Missing Groups
		foreach($Group in $MissingGroups.InputObject){
				If($PSCmdlet.ShouldProcess($Group, "Adding $DestinationIdentity to group")){
					Add-ADSIGroupMember -Identity $Group -Member $DestinationIdentity @ContextSplatting
				}
		}
	}
}