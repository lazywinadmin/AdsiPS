Function Get-ADSIRootDomain
{
	[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().RootDomain
}