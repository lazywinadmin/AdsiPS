function Add-ADSIGroupMember
{
<#
.SYNOPSIS
	This function will add a AD object inside a AD Group.
	
.PARAMETER GroupSamAccountName
	Specify the Group SamAccountName of the group
	
.PARAMETER GroupName
	Specify the Name of the group
	
.PARAMETER GroupDistinguishedName
	Specify the DistinguishedName path of the group
	
.PARAMETER MemberSamAccountName
    Specify the member SamAccountName to add
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDN
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.EXAMPLE
    Add-ADSIGroupMember -GroupSamAccountName TestGroup -UserSamAccountName fxcat -Credential (Get-Credential -Credential SuperAdmin)
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding(DefaultParameterSetName = "GroupSamAccountName")]
	PARAM (
		[Parameter(Mandatory = $true, ParameterSetName = "Name")]
		[String]$GroupName,
		
		[Parameter(Mandatory = $true, ParameterSetName = "GroupSamAccountName")]
		[String]$GroupSamAccountName,
		
		[Parameter(Mandatory = $true, ParameterSetName = "DistinguishedName")]
		[String]$GroupDistinguishedName,
		
		[Parameter(Mandatory = $true)]
		[string]$MemberSamAccountName,
		
		[Alias("Domain")]
		[String]$DomainDN = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDN
			
			IF ($PSBoundParameters['DomainDN'])
			{
				IF ($DomainDN -notlike "LDAP://*") { $DomainDN = "LDAP://$DomainDN" }#IF
				Write-Verbose -Message "Different Domain specified: $DomainDN"
				$Search.SearchRoot = $DomainDN
			}
			
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $DomainDN
			}
			
			# Resolve the Object
			Write-Verbose -Message "[PROCESS] Looking for Object: $MemberSamAccountName"
			$ObjectSearch = $Search
			$ObjectSearch.filter = "(samaccountname=$MemberSamAccountName)"
			$ObjectSearchADSPath = $ObjectSearch.FindOne().Properties.adspath -as [string]
			$ObjectSearchADSPathADSI = $ObjectSearchADSPath -as [ADSI]
			$objectResult = $ObjectSearch.FindOne()
			
			If ($PSBoundParameters['GroupName'])
			{
				Write-Verbose -Message "[PROCESS] Parameter GROUPNAME: $GroupName"
				$Search.filter = "(&(objectCategory=group)(name=$GroupName))"
			}
			IF ($PSBoundParameters['GroupSamAccountName'])
			{
				Write-Verbose -Message "[PROCESS] Parameter GROUPSAMACCOUNTNAME: $GroupSamAccountName"
				$Search.filter = "(&(objectCategory=group)(samaccountname=$GroupSamAccountName))"
			}
			IF ($PSBoundParameters['GroupDistinguishedName'])
			{
				Write-Verbose -Message "[PROCESS] Parameter GROUP DISTINGUISHEDNAME: $GroupDistinguishedName"
				$Search.filter = "(&(objectCategory=group)(distinguishedname=$GroupDistinguishedName))"
			}
			
			$Group = $Search.FindOne()
			$Member = $objectResult
			
			# Verify Member and Object exist
			IF (($Group.Count -gt 0) -and $Member.count -gt 0)
			{
				
				# Get the SamAccountName and ADSPATH of the Group
				$GroupAccount = $Group.Properties.samaccountname -as [string]
				$GroupAdspath = $($Group.Properties.adspath -as [string]) -as [ADSI]
				
				# Member
				$MemberAdsPath = [ADSI]"$($member.Properties.adspath)"
				
				# Check if the Object is member of the group
				$IsMember = $GroupAdspath.IsMember($MemberAdsPath.AdsPath)
				IF (-not ($IsMember))
				{
					Write-Verbose -Message "[PROCESS] Group: $($Group.properties.name -as [string])"
					Write-Verbose -Message "[PROCESS] Adding: $($Member.properties.name -as [string])"
					# Add the user to the group
					([ADSI]"$($Group.properties.adspath)").add($($Member.Properties.adspath -as [string]))
				}
				ELSE
				{
					Write-Warning -message "$MemberSamAccountName is already member of $($GroupObj.samaccountname)"
				}
			}
			ELSE
			{
				IF ($Search.FindAll().Count -eq 0) { Write-Warning -Message "[PROCESS] No Group Found" }
				IF ($objectResult.Count -eq 0) { Write-Warning -Message "[PROCESS] $MemberSamAccountName not Found" }
			}
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			#if ($ProcessErrorGetADSIUser) { Write-Warning -Message "[PROCESS] Issue while getting information on the user using Get-ADSIUser" }
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Add-ADSIGroupMember End."
	}
}