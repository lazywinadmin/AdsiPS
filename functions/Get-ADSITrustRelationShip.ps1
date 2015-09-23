Function Get-ADSITrustRelationShip
{
	[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().GetAllTrustRelationships()
}