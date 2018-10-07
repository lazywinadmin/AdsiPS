$Context = New-ADSIPrincipalContext -ContextType Domain
$UserPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $Context


#$GroupPrincipal.Name = $Identity
$searcher = new-object System.DirectoryServices.AccountManagement.PrincipalSearcher
$searcher.QueryFilter = $UserPrincipal
$searcher.QueryFilter.Enabled=$false
$searcher.QueryFilter.SamAccountName="fx*"


#Omg... this reveal the query made against AD...
$searcher.GetUnderlyingSearcher().filter
#https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.principalsearcher.getunderlyingsearcher(v=vs.110).aspx


# retrieve other props
$searcher.GetUnderlyingSearcher()

# limit the output
#$searcher.GetUnderlyingSearcher().SizeLimit = 1

# SearchScope https://msdn.microsoft.com/en-us/library/system.directoryservices.searchscope(v=vs.110).aspx
$searcher.GetUnderlyingSearcher().SearchScope = 'subtree' # "Base" "OneLevel"


#include tombstone
#$searcher.GetUnderlyingSearcher().Tombstone

#SearchRoot
#https://msdn.microsoft.com/en-us/library/system.directoryservices.directorysearcher.searchroot(v=vs.110).aspx
$searcher.GetUnderlyingSearcher().SearchRoot =""

#Sort
#https://msdn.microsoft.com/en-us/library/system.directoryservices.sortoption(v=vs.110).aspx
$searcher.GetUnderlyingSearcher().Sort =""

#Get type of Properties to load
$searcher.GetUnderlyingSearcher().propertiestoload.gettype()#StringCollection
$searcher.GetUnderlyingSearcher().propertiestoload.gettype()|fl *

$searcher.FindAll()



#### TEST######
### MY OWN LDAP FILTER    !

$Context = New-ADSIPrincipalContext -ContextType Domain
$UserPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $Context


#$GroupPrincipal.Name = $Identity
$searcher = new-object System.DirectoryServices.AccountManagement.PrincipalSearcher
$searcher.QueryFilter = $UserPrincipal
$searcher.QueryFilter.AdvancedSearchFilter.
#$searcher.GetUnderlyingSearcher().Filter = "(&(objectCategory=user)(objectClass=user)(samaccountname=fxt)(userAccountControl:1.2.840.113556.1.4.803:=2))"
$searcher.GetUnderlyingSearcher().set_Filter("(&(objectCategory=user)(objectClass=user)(samaccountname=fxt)(userAccountControl:1.2.840.113556.1.4.803:=2))")
$searcher

$searcher.FindAll()|select name


$Context = New-ADSIPrincipalContext -ContextType Domain
$UserPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $Context
$searcher2 = new-object system.directoryservices.directorysearcher -ArgumentList $UserPrincipal
$searcher2.q
