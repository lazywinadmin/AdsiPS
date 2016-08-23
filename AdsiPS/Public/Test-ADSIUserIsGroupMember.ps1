function Test-ADSIUserIsGroupMember
{
<#
.SYNOPSIS
    This function will check if a domain user is member of a domain group

.DESCRIPTION
    This function will check if a domain user is member of a domain group

.PARAMETER GroupSamAccountName
	Specifies the Group to query

.PARAMETER UserSamAccountName
	Specifies the user account 

.EXAMPLE
    Test-ADSIUserIsGroupMember -GroupSamAccountName TestGroup -UserSamAccountName Fxcat

    This will return $true or $false depending if the user Fxcat is member of TestGroup
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS 
#>
	PARAM (
		$GroupSamAccountName,
		
		$UserSamAccountName
	)
	
	$UserInfo = [ADSI]"$((Get-ADSIUser -SamAccountName $UserSamAccountName).AdsPath)"
	$GroupInfo = [ADSI]"$((Get-ADSIGroup -SamAccountName $GroupSamAccountName).AdsPath)"
	
	#([ADSI]$GroupInfo.ADsPath).IsMember([ADSI]($UserInfo.AdsPath))
	$GroupInfo.IsMember($UserInfo.ADsPath)
	
}