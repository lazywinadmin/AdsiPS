function Search-ADSIUser
{
$Context = New-ADSIPrincipalContext -ContextType 'Domain'
$UserPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $Context
$UserPrincipal.Surname = "E*"

# it will generate the filter for you

$Searcher = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalSearcher
$Searcher.QueryFilter = $UserPrincipal


$Searcher.FindAll()
}
