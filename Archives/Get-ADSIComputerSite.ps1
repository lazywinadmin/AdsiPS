function Get-ADSICurrentComputerSite
{
	[System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()
}