#ADSI

PowerShell module for ADSI

#### Goals
 * No ActiveDirectory module/No Quest AD Snapin required
 * Being able to specify different credentials
 * Being able to specify different domain


#### Use Cases

 * Sometime ActiveDirectory Module is not available/ or can't install it on a machine
 * AD queries need to be performed by a tool (GUI for example) and don't want it to load AD module. Additionally you don't know who will use the tool and if they have/can/know how to install the module.
 * Performance, ADSI is way faster...

#### ToDo

##### Brainstorm
- [ ] Find a smarter way to return all the properties (keys/values) after a findall()
- [ ] Create custom views for each Cmdlets

##### Cmdlets
- [x] Add-ADSIGroupMember
- [ ] Disable-ADSIAccount
- [ ] Enable-ADSIAccount
- [x] Get-ADSIComputer
 - [ ] Param: OperatingSystem
 - [ ] Param: Disabled
- [x] Get-ADSIContact
- [ ] Get-ADSIDomain
- [x] Get-ADSIDomainController
- [x] Get-ADSIFsmo
 -  [ ] [Switch]$Domain
 -  [ ] [Switch]$Forest
- [x] Get-ADSIGroup
 -  [ ] Param: GroupScope (Domain Local, Global, Universal)
 -  [ ] Param: GroupType (Distribution/Security)
 -  [ ] Modify queries to use Anr (Ambiguous Name Resolution)
- [x] Get-ADSIGroupManagedBy
- [x] Get-ADSIGroupMembership
 - [ ] Indirect Members (Check in Chain)
- [x] Get-ADSIObject
- [x] Get-ADSIOrganizationalUnit
- [ ] Get-ADSIRootDSE
- [ ] Get-ADSIServiceAccount
- [x] Get-ADSISite
- [x] Get-ADSISiteConnection
- [x] Get-ADSISiteServer
- [ ] Get-ADSITrust
- [x] Get-ADSIUser
 - [ ] Modify queries to use Anr (Ambiguous Name Resolution)
 - [ ] Param: Disabled Account 
 - [ ] Param: Change Password next logon enabled
 - [ ] Param: LockedOut
 - [ ] Param: Disabled
- [ ] New-ADSISite
- [ ] New-ADSIComputer
- [ ] New-ADSIUser
- [ ] New-ADSIGroup
- [ ] New-ADSIOrganizationalUnit
- [x] Remove-ADSIGroupMember
- [ ] Remove-ADSIUser
- [ ] Remove-ADSIComputer
- [ ] Remove-ADSIContact
- [ ] Remove-ADSIOrganizationUnit
- [ ] Set-ADSIUser
- [ ] Set-ADSIComputer
- [ ] Set-ADSIContact
- [ ] Set-ADSIGroup
- [ ] Set-ADSIDeletionProtection
- [x] Test-ADSIUserIsGroupMember
- [ ] Unlock-ADSIAccount

