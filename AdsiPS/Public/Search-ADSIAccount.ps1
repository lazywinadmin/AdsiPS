
#Never loged and must change password -> *Home tested*
$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(pwdLastSet=0)(lastLogon=0)(!lastlogontime‌​stamp=*))))"


#Never loged and password never expire -> *Home tested*
$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=65536)(lastLogon=0)(!lastlogontime‌​stamp=*))))"

#Disabled *tested OK*
$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=2))))"

#Password never expire *tested OK*
$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=65536))))"

#Account expired *tested ok*
$date = (Get-Date).ToFileTime()
$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(accountExpires<=$date)(!(accountExpires=0)))))"

#Account expired in X days *tested ok*
$Now = Get-Date
$start = $Now.ToFileTime()
$end = ($Now.Adddays(30)).ToFileTime() #attention 29 jours en réalité, va cherche jusque lendemain du 30eme jour 00:00

$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(accountExpires>=$start)(accountExpires<=$end))))"

#Account never expire *tested ok*
$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(accountExpires=0))))"

#PASSWORD Expired *tested ok* -> l utilisateur c'est au moins connecté 1 fois, sinon ne ressortira pas.
$DirectorySearcher.Filter = "(&(objectCategory=user)(objectClass=user)(pwdLastSet=0)(!(userAccountControl:1.2.840.113556.1.4.803:=65536))(|(lastLogon>=1)(lastLogonTimestamp>=1)))"

#Lockout
$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=16))))"

#Lockout second method
$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(lockoutTime>=1))))"

#CANT Change password
$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=64))))"
#exemple : LDAP://CN=KNEBT12_H1,OU=Utilisateurs,OU=KNEH1,OU=O-Nantes,OU=C-Com... {codepage, objectcategory, scriptpath, description...}


#PASSWORD_EXPIRED (don't work)
#$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=8388608))))"

#PASSWORD_EXPIRED (don't work)
#$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.1460:=‭8388608‬))))"

#Never loged but password is set without ask must change ->  besoin ????
##$DirectorySearcher.Filter = "(&(objectCategory=user)((&(objectClass=user)(!(pwdLastSet=0))(lastLogon=0))))"

$DirectorySearcher.FindAll()

#Never logged and must change password
#Never logged and password never expire
#Disabled
#Password never expire
#PASSWORD Expired
#Account expired
#Account expire in X days
#Account never expire
