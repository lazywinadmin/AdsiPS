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
	}
	
	process{
	    #GetSourceUserGroups
	    if($DomainName){
	        if($Credential -ne [System.Management.Automation.PSCredential]::Empty){
	            $SourceUserGroups = (Get-ADSIUser -Identity $SourceIdentity -DomainName $DomainName -Credential $Credential).GetGroups()
	        } else {
	            $SourceUserGroups = (Get-ADSIUser -Identity $SourceIdentity -DomainName $DomainName).GetGroups()
	        }
	    } elseif ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
	        $SourceUserGroups = (Get-ADSIUser -Identity $SourceIdentity -Credential $Credential).GetGroups()
	    } else {
	        $SourceUserGroups = (Get-ADSIUser -Identity $SourceIdentity).GetGroups()
	    }
	
	    #GetDestinationUserGroups
	    if($DomainName){
	        if($Credential -ne [System.Management.Automation.PSCredential]::Empty){
	            $DestinationUserGroups = (Get-ADSIUser -Identity $DestinationIdentity -DomainName $DomainName -Credential $Credential).GetGroups()
	        } else {
	            $DestinationUserGroups = (Get-ADSIUser -Identity $DestinationIdentity -DomainName $DomainName).GetGroups()
	        }
	    } elseif ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
	        $DestinationUserGroups = (Get-ADSIUser -Identity $DestinationIdentity -Credential $Credential).GetGroups()
	    } else {
	        $DestinationUserGroups = (Get-ADSIUser -Identity $DestinationIdentity).GetGroups()
	    }
	
	    #Get only new Groups
	    $MissingGroups = Compare-Object -ReferenceObject $SourceUserGroups.Sid -DifferenceObject $DestinationUserGroups.Sid | Where-Object {$_.SideIndicator -eq "<="}
	    if($MissingGroups -eq $null){
	        Write-Verbose "[$FunctionName] Nothing to do"
	    } else {
	        Write-Verbose "[$FunctionName] Missing Groups: $($MissingGroups.InputObject.Value)"
	    }
	
	    #Add DestinationUser to Missing Groups
	    foreach($Group in $MissingGroups.InputObject.Value){
	        Write-Verbose -Message "[$FunctionName] Adding $DestinationIdentity to $($Group)"
	        if($DomainName){
	            if($Credential -ne [System.Management.Automation.PSCredential]::Empty){
	                Add-ADSIGroupMember -Identity $Group -Member $DestinationIdentity -DomainName $DomainName -Credential $Credential
	            } else {
	                Add-ADSIGroupMember -Identity $Group -Member $DestinationIdentity -DomainName $DomainName
	            }
	        } elseif ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
	            Add-ADSIGroupMember -Identity $Group -Member $DestinationIdentity -Credential $Credential
	        } else {
	            Add-ADSIGroupMember -Identity $Group -Member $DestinationIdentity
	        }
	    }
	}
}
