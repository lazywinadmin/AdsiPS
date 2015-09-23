function Get-ADSISiteConnection
{
	[CmdletBinding()]
	param (
		[parameter(mandatory = $true, position = 0, ValueFromPipeline = $true)]
		$Domain,
		
		[parameter(mandatory = $true)]
		$Site
	)
	$DomainName = $Domain.Name
	$ADEntry = [system.directoryservices.directoryentry]([ADSI]"LDAP://$DomainName")
	$source = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchRoot = "LDAP://CN=$Site,CN=Sites,CN=Configuration,$DomainName"
	$source.SearchScope = 'Subtree'
	$source.PageSize = 100000
	$source.filter = "(objectclass=nTDSConnection)"
	try
	{
		$SiteConnections = $source.findall()
		if ($SiteConnections -ne $null)
		{
			foreach ($SiteConnection in $SiteConnections)
			{
				$Object = New-Object -TypeName 'PSObject'
				$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
				$Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value $Site
				$Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value $($SiteConnection.Properties.Item("Name"))
				$Object | Add-Member -MemberType 'NoteProperty' -Name 'FromServer' -Value $($SiteConnection.Properties.Item("fromserver") -split ',' -replace 'CN=', '')[3]
				$Object
			}
		}
		else
		{
			$Object = New-Object -TypeName 'PSObject'
			$Object | Add-Member -MemberType 'NoteProperty' -Name 'Domain' -Value $Domain.FQDN
			$Object | Add-Member -MemberType 'NoteProperty' -Name 'Site' -Value $Site
			$Object | Add-Member -MemberType 'NoteProperty' -Name 'Name' -Value ''
			$Object | Add-Member -MemberType 'NoteProperty' -Name 'FromServer' -Value ''
			$Object
		}
	}
	catch
	{
	}
}