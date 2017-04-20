function Search-ADSIUserLogonTime
{
$Context = New-ADSIPrincipalContext -ContextType 'Domain'
$UserPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $Context

$UserPrincipal.findbylogontime($Context,$((Get-Date).AddDays(-1)),[System.DirectoryServices.AccountManagement.MatchType]::GreaterThan)
}