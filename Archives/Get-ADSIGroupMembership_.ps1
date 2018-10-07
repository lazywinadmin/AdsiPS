function Get-ADSIGroupMembership
{
<#
.SYNOPSIS
	This function will list all the member of the specified group

.PARAMETER SamAccountName
	Specify the SamAccountName of the Group

.EXAMPLE
	Get-ADSIGroupMembership -SamAccountName TestGroup

.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding()]
	PARAM ($SamAccountName)
	BEGIN
	{
		$search = [adsisearcher]"(&(objectCategory=group)(SamAccountName=$SamAccountName))"
	}
	PROCESS
	{
		TRY
		{
			foreach ($member in $search.FindOne().properties.member)
			{
				#User
				#Get-ADSIUser -DistinguishedName $member
				Get-ADSIObject -DistinguishedName $member

				#Group
				# need to be done here
			}
		}#try
		CATCH
		{
			$pscmdlet.ThrowTerminatingError($_)
		}
	}#process
	END { Write-Verbose -Message "[END] Function Get-ADSIGroupMembership End." }
}