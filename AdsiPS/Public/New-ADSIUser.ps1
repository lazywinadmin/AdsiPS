Function New-ADSIUser
{
	## add the assembly
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	
	## create a password
	$password = Read-Host "Password" -AsSecureString
	
	## create the context i.e. connect to the domain
	$ctype = [System.DirectoryServices.AccountManagement.ContextType]::Domain
	$context = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $ctype, "manticore.org", "OU=AMTest,DC=Manticore,DC=org"
	
	## create the user object
	$usr = New-Object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $context
	
	## set the properties
	$usr.Name = "AM Test1"
	$usr.DisplayName = "AM Test1"
	$usr.GivenName = "AM"
	$usr.SurName = "Test1"
	$usr.SamAccountName = "AMTest1"
	$usr.UserPrincipalName = "amtest1@manticore.org"
	
	$usr.PasswordNotRequired = $false
	$usr.SetPassword($password)
	$usr.Enabled = $true
	
	## save the user
	$usr.Save()
	
}