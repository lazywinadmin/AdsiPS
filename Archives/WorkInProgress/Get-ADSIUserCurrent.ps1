function Get-ADSIUserCurrent
{
$Context = New-ADSIPrincipalContext -ContextType 'Domain'
$UserPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $Context

$UserPrincipal.current
}