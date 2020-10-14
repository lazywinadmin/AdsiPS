# Functions

List of function available:

Name                                     Version
----                                     -------
Add-ADSIGroupMember                      1.0.0.10
Compare-ADSITeamGroups                   1.0.0.10
Copy-ADSIGroupMembership                 1.0.0.10
Disable-ADSIComputer                     1.0.0.10
Disable-ADSIUser                         1.0.0.10
Enable-ADSIComputer                      1.0.0.10
Enable-ADSIDomainControllerGlobalCatalog 1.0.0.10
Enable-ADSIUser                          1.0.0.10
Get-ADSIClass                            1.0.0.10
Get-ADSIComputer                         1.0.0.10
Get-ADSIComputerSite                     1.0.0.10
Get-ADSIDefaultDomainAccountLockout      1.0.0.10
Get-ADSIDefaultDomainPasswordPolicy      1.0.0.10
Get-ADSIDomain                           1.0.0.10
Get-ADSIDomainBackup                     1.0.0.10
Get-ADSIDomainController                 1.0.0.10
Get-ADSIDomainMode                       1.0.0.10
Get-ADSIDomainRoot                       1.0.0.10
Get-ADSIDomainTrustRelationship          1.0.0.10
Get-ADSIFineGrainedPasswordPolicy        1.0.0.10
Get-ADSIForest                           1.0.0.10
Get-ADSIForestDomain                     1.0.0.10
Get-ADSIForestMode                       1.0.0.10
Get-ADSIForestTrustRelationship          1.0.0.10
Get-ADSIFsmo                             1.0.0.10
Get-ADSIGlobalCatalog                    1.0.0.10
Get-ADSIGroup                            1.0.0.10
Get-ADSIGroupManagedBy                   1.0.0.10
Get-ADSIGroupMember                      1.0.0.10
Get-ADSIGroupMembershipTreeView          1.0.0.10
Get-ADSIGroupPolicyObject                1.0.0.10
Get-ADSIObject                           1.0.0.10
Get-ADSIOrganizationalUnit               1.0.0.10
Get-ADSIPrincipalGroupMembership         1.0.0.10
Get-ADSIPrintQueue                       1.0.0.10
Get-ADSIReplicaCurrentTime               1.0.0.10
Get-ADSIReplicaDomainInfo                1.0.0.10
Get-ADSIReplicaForestInfo                1.0.0.10
Get-ADSIReplicaGCInfo                    1.0.0.10
Get-ADSIReplicaInfo                      1.0.0.10
Get-ADSIRIDsPool                         1.0.0.10
Get-ADSIRootDSE                          1.0.0.10
Get-ADSISchema                           1.0.0.10
Get-ADSISite                             1.0.0.10
Get-ADSISiteLink                         1.0.0.10
Get-ADSISiteServer                       1.0.0.10
Get-ADSISiteSubnet                       1.0.0.10
Get-ADSITokenGroup                       1.0.0.10
Get-ADSITombstoneLifetime                1.0.0.10
Get-ADSIUser                             1.0.0.10
Get-ADSIUserPrimaryGroup                 1.0.0.10
Move-ADSIComputer                        1.0.0.10
Move-ADSIDomainControllerRole            1.0.0.10
Move-ADSIDomainControllerToSite          1.0.0.10
Move-ADSIGroup                           1.0.0.10
Move-ADSIUser                            1.0.0.10
New-ADSIComputer                         1.0.0.10
New-ADSIDirectoryContext                 1.0.0.10
New-ADSIDirectoryEntry                   1.0.0.10
New-ADSIGroup                            1.0.0.10
New-ADSIPrincipalContext                 1.0.0.10
New-ADSISite                             1.0.0.10
New-ADSISiteSubnet                       1.0.0.10
New-ADSIUser                             1.0.0.10
Remove-ADSIComputer                      1.0.0.10
Remove-ADSIGroup                         1.0.0.10
Remove-ADSIGroupMember                   1.0.0.10
Remove-ADSISite                          1.0.0.10
Remove-ADSISiteSubnet                    1.0.0.10
Remove-ADSIUser                          1.0.0.10
Reset-ADSIUserPasswordAge                1.0.0.10
Search-ADSIAccount                       1.0.0.10
Set-ADSIComputer                         1.0.0.10
Set-ADSIGroup                            1.0.0.10
Set-ADSIUser                             1.0.0.10
Set-ADSIUserPassword                     1.0.0.10
Start-ADSIReplicationConsistencyCheck    1.0.0.10
Test-ADSICredential                      1.0.0.10
Test-ADSIUserIsGroupMember               1.0.0.10
Test-ADSIUserIsLockedOut                 1.0.0.10
Unlock-ADSIComputer                      1.0.0.10
Unlock-ADSIUser                          1.0.0.10

## Syntax

```powershell
Add-ADSIGroupMember [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [[-Member] <Object>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Compare-ADSITeamGroups -TeamUsersIdentity <array> [-Credential <pscredential>] [-DomainName <string>] [<CommonParameters>]

Compare-ADSITeamGroups -BaseGroupIdentity <string> [-Credential <pscredential>] [-DomainName <string>] [<CommonParameters>]
```

```powershell
Copy-ADSIGroupMembership [-SourceIdentity] <string> [-DestinationIdentity] <string> [-Credential <pscredential>] [-DomainName <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Disable-ADSIComputer [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Disable-ADSIUser [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Enable-ADSIComputer [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Enable-ADSIDomainControllerGlobalCatalog [-ComputerName] <string> [[-Credential] <pscredential>] [<CommonParameters>]
```

```powershell
Enable-ADSIUser [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Get-ADSIClass [-Credential <pscredential>] [-ForestName <Object>] [<CommonParameters>]

Get-ADSIClass [-ClassName <string>] [-Credential <pscredential>] [-ForestName <Object>] [<CommonParameters>]

Get-ADSIClass [-AllClasses] [-Credential <pscredential>] [-ForestName <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIComputer [-Credential <pscredential>] [-DomainName <string>] [<CommonParameters>]

Get-ADSIComputer [-Identity] <string> [-Credential <pscredential>] [-DomainName <string>] [<CommonParameters>]
```

```powershell
Get-ADSIComputerSite [[-ComputerName] <string[]>] [<CommonParameters>]
```

```powershell
Get-ADSIDefaultDomainAccountLockout [[-Credential] <pscredential>] [[-DomainName] <string>] [[-DomainDistinguishedName] <string>] [<CommonParameters>]
```

```powershell
Get-ADSIDefaultDomainPasswordPolicy [[-Credential] <pscredential>] [[-DomainName] <string>] [<CommonParameters>]
```

```powershell
Get-ADSIDomain [[-Credential] <pscredential>] [[-DomainName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIDomainBackup [[-Credential] <pscredential>] [[-DomainName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIDomainController [[-Credential] <pscredential>] [[-DomainName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIDomainMode [[-Credential] <pscredential>] [[-DomainName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIDomainRoot [[-Credential] <pscredential>] [[-ForestName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIDomainTrustRelationship [[-Credential] <pscredential>] [[-DomainName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIFineGrainedPasswordPolicy [-Name <string>] [-DomainDistinguishedName <string>] [-Credential <pscredential>] [-SizeLimit <int>] [<CommonParameters>]
```

```powershell
Get-ADSIForest [[-Credential] <pscredential>] [[-ForestName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIForestDomain [[-Credential] <pscredential>] [[-ForestName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIForestMode [[-Credential] <pscredential>] [[-ForestName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIForestTrustRelationship [[-Credential] <pscredential>] [[-ForestName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIFsmo [[-Credential] <pscredential>] [[-ForestName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIGlobalCatalog [[-Credential] <pscredential>] [[-ForestName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIGroup [-Credential <pscredential>] [-DomainName <Object>] [<CommonParameters>]

Get-ADSIGroup [-Identity <string>] [-Credential <pscredential>] [-DomainName <Object>] [<CommonParameters>]

Get-ADSIGroup [-Credential <pscredential>] [-DomainName <Object>] [-GroupScope <GroupScope>] [-IsSecurityGroup <bool>] [-Description <Object>] [-UserPrincipalName <Object>] [-Displayname <Object>] [-Name <Object>] [-SID <Object>] [<CommonParameters>]

Get-ADSIGroup [-Credential <pscredential>] [-DomainName <Object>] [-LDAPFilter <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIGroupManagedBy [-SamAccountName <string>] [-Credential <pscredential>] [-DomainDistinguishedName <string>] [-SizeLimit <int>] [<CommonParameters>]

Get-ADSIGroupManagedBy [-AllManagedGroups] [-Credential <pscredential>] [-DomainDistinguishedName <string>] [-SizeLimit <int>] [<CommonParameters>]

Get-ADSIGroupManagedBy [-NoManager] [-Credential <pscredential>] [-DomainDistinguishedName <string>] [-SizeLimit <int>] [<CommonParameters>]
```

```powershell
Get-ADSIGroupMember -Identity <string> [-Credential <pscredential>] [-DomainName <string>] [-Recurse] [<CommonParameters>]

Get-ADSIGroupMember -Identity <string> [-Credential <pscredential>] [-DomainName <string>] [-GroupsOnly] [<CommonParameters>]
```

```powershell
Get-ADSIGroupMembershipTreeView [-Identity] <string> [-Credential <pscredential>] [-DomainName <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Get-ADSIGroupPolicyObject [[-DomainDistinguishedName] <string>] [[-Credential] <pscredential>] [[-SizeLimit] <int>] [<CommonParameters>]
```

```powershell
Get-ADSIObject -IncludeDeletedObjects [-Identity <string>] [-DomainDistinguishedName <string>] [-Credential <pscredential>] [-SizeLimit <int>] [-DeletedOnly] [<CommonParameters>]

Get-ADSIObject -Identity <string> [-DomainDistinguishedName <string>] [-Credential <pscredential>] [-SizeLimit <int>] [<CommonParameters>]
```

```powershell
Get-ADSIOrganizationalUnit [-All <string>] [-GroupPolicyInheritanceBlocked] [-DomainDistinguishedName <string>] [-Credential <pscredential>] [-SizeLimit <int>] [<CommonParameters>]

Get-ADSIOrganizationalUnit [-Name <string>] [-GroupPolicyInheritanceBlocked] [-DomainDistinguishedName <string>] [-Credential <pscredential>] [-SizeLimit <int>] [<CommonParameters>]

Get-ADSIOrganizationalUnit [-DistinguishedName <string>] [-GroupPolicyInheritanceBlocked] [-DomainDistinguishedName <string>] [-Credential <pscredential>] [-SizeLimit <int>] [<CommonParameters>]
```

```powershell
Get-ADSIPrincipalGroupMembership -Identity <string> [-Credential <pscredential>] [-DomainName <string>] [<CommonParameters>]

Get-ADSIPrincipalGroupMembership -UserInfos <AuthenticablePrincipal> [-Credential <pscredential>] [<CommonParameters>]

Get-ADSIPrincipalGroupMembership -GroupInfos <Principal> [-Credential <pscredential>] [<CommonParameters>]
```

```powershell
Get-ADSIPrintQueue [[-PrinterQueueName] <string>] [[-ServerName] <string>] [[-DomainName] <string>] [[-DomainDistinguishedName] <string>] [[-Credential] <pscredential>] [[-SizeLimit] <int>] [-NoResultLimit] [<CommonParameters>]
```

```powershell
Get-ADSIReplicaCurrentTime [-ComputerName] <string> [[-Credential] <pscredential>] [<CommonParameters>]
```

```powershell
Get-ADSIReplicaDomainInfo [-ComputerName] <string> [[-Credential] <pscredential>] [-Recurse] [<CommonParameters>]
```

```powershell
Get-ADSIReplicaForestInfo [-ComputerName] <string> [[-Credential] <pscredential>] [<CommonParameters>]
```

```powershell
Get-ADSIReplicaGCInfo [-ComputerName] <string> [[-Credential] <pscredential>] [<CommonParameters>]
```

```powershell
Get-ADSIReplicaInfo [[-ComputerName] <string>] [[-Domain] <string>] [[-Credential] <pscredential>] [[-NamingContext] <string>] [-Neighbors] [-Latency] [-Cursors] [-Errors] [-DisplayDC] [-FormatTable] [<CommonParameters>]
```

```powershell
Get-ADSIRIDsPool [[-Credential] <pscredential>] [[-DomainName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIRootDSE [[-Credential] <pscredential>] [[-DomainName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSISchema -ClassName <string> [-PropertyType <string>] [-Credential <pscredential>] [-ForestName <Object>] [<CommonParameters>]

Get-ADSISchema -AllClasses [-Credential <pscredential>] [-ForestName <Object>] [<CommonParameters>]

Get-ADSISchema -FindClassName <string> [-Credential <pscredential>] [-ForestName <Object>] [<CommonParameters>]
```

```powershell
Get-ADSISite [[-Credential] <pscredential>] [[-ForestName] <Object>] [[-SiteName] <string>] [<CommonParameters>]
```

```powershell
Get-ADSISiteLink [[-Credential] <pscredential>] [[-ForestName] <Object>] [[-Name] <string>] [<CommonParameters>]
```

```powershell
Get-ADSISiteServer [[-Credential] <pscredential>] [[-ForestName] <Object>] [[-Name] <string>] [<CommonParameters>]
```

```powershell
Get-ADSISiteSubnet [[-Credential] <pscredential>] [[-ForestName] <Object>] [[-SubnetName] <string>] [<CommonParameters>]
```

```powershell
Get-ADSITokenGroup [[-SamAccountName] <string>] [[-Credential] <pscredential>] [[-DomainDistinguishedName] <string>] [[-SizeLimit] <int>] [<CommonParameters>]
```

```powershell
Get-ADSITombstoneLifetime [[-Credential] <pscredential>] [[-DomainName] <Object>] [<CommonParameters>]
```

```powershell
Get-ADSIUser [-Credential <pscredential>] [-DomainName <string>] [-NoResultLimit] [<CommonParameters>]

Get-ADSIUser [-Identity] <string> [-Credential <pscredential>] [-DomainName <string>] [<CommonParameters>]

Get-ADSIUser -LDAPFilter <string> [-Credential <pscredential>] [-DomainName <string>] [-NoResultLimit] [<CommonParameters>]
```

```powershell
Get-ADSIUserPrimaryGroup [-Identity] <AuthenticablePrincipal> [-ReturnNameAndDescriptionOnly] [<CommonParameters>]
```

```powershell
Move-ADSIComputer [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <Object>] [[-Destination] <Object>] [<CommonParameters>]
```

```powershell
Move-ADSIDomainControllerRole [-ComputerName] <string> [[-Credential] <pscredential>] [-Role] <ActiveDirectoryRole[]> [-Force] [<CommonParameters>]
```

```powershell
Move-ADSIDomainControllerToSite [-ComputerName] <string> [[-Credential] <pscredential>] [-Site] <string> [<CommonParameters>]
```

```powershell
Move-ADSIGroup [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <Object>] [[-Destination] <Object>] [<CommonParameters>]
```

```powershell
Move-ADSIUser [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [[-Destination] <Object>] [<CommonParameters>]
```

```powershell
New-ADSIComputer [-Name] <Object> [[-DisplayName] <string>] [[-Description] <string>] [[-Credential] <pscredential>] [[-DomainName] <string>] [-Passthru] [-Enable] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
New-ADSIDirectoryContext -ContextType <DirectoryContextType> [-Credential <pscredential>] [-Server <ValidateNotNullOrEmpty>] [-WhatIf] [-Confirm] [<CommonParameters>]

New-ADSIDirectoryContext -ContextType <DirectoryContextType> [-Credential <pscredential>] [-DomainName <Object>] [-WhatIf] [-Confirm] [<CommonParameters>]

New-ADSIDirectoryContext -ContextType <DirectoryContextType> [-Credential <pscredential>] [-ForestName <Object>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
New-ADSIDirectoryEntry [[-Path] <Object>] [[-Credential] <pscredential>] [[-AuthenticationType] <AuthenticationTypes[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
New-ADSIGroup [-Name] <Object> [[-DisplayName] <string>] [[-UserPrincipalName] <string>] [[-Description] <string>] [-GroupScope] <GroupScope> [[-Credential] <pscredential>] [[-DomainName] <string>] [-IsSecurityGroup] [-Passthru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
New-ADSIPrincipalContext [[-Credential] <pscredential>] [-ContextType] <ContextType> [[-DomainName] <Object>] [[-Container] <Object>] [[-ContextOptions] <ContextOptions[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
New-ADSISite [-SiteName] <string> [[-Location] <string>] [[-Credential] <pscredential>] [[-ForestName] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
New-ADSISiteSubnet [-SubnetName] <string> [-SiteName] <string> [[-Location] <string>] [[-Credential] <pscredential>] [[-ForestName] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
New-ADSIUser [-SamAccountName] <string> [[-AccountPassword] <securestring>] [[-GivenName] <string>] [[-SurName] <string>] [[-UserPrincipalName] <string>] [[-DisplayName] <string>] [[-Name] <string>] [[-AccountExpirationDate] <datetime>] [[-Credential] <pscredential>] [[-DomainName] <string>] [-Enabled] [-PasswordNeverExpires] [-UserCannotChangePassword] [-PasswordNotRequired] [-Passthru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Remove-ADSIComputer [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [-Recursive] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Remove-ADSIGroup [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Remove-ADSIGroupMember [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [[-Member] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Remove-ADSISite [-SiteName] <Object> [[-Credential] <pscredential>] [[-ForestName] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Remove-ADSISiteSubnet [-SubnetName] <Object> [[-Credential] <pscredential>] [[-ForestName] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Remove-ADSIUser [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [-Recursive] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Reset-ADSIUserPasswordAge [-Identity] <Object> [[-DomainName] <string>] [[-Credential] <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Search-ADSIAccount -Users -AccountNeverLogged [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Users -AccountNeverLogged -PasswordNeverExpire [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Users -AccountNeverLogged -ChangePassword [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Users -AccountDisabled [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Users -PasswordNeverExpires [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Users -AccountExpired [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Users -AccountExpiring [-Days <int>] [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Users -PasswordExpired [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Users -AccountNeverExpire [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Users -AccountInactive [-Days <int>] [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Computers -AccountNeverLogged [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Computers -AccountDisabled [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Computers -PasswordNeverExpires [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Computers -AccountExpired [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Computers -AccountExpiring [-Days <int>] [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Computers -PasswordExpired [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Computers -AccountNeverExpire [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]

Search-ADSIAccount -Computers -AccountInactive [-Days <int>] [-SizeLimit <int>] [-Credential <pscredential>] [-DomainName <string>] [-DomainDistinguishedName <string>] [-NoResultLimit] [<CommonParameters>]
```

```powershell
Set-ADSIComputer [-Identity] <Object> [[-Description] <string>] [[-DisplayName] <string>] [[-AccountExpirationDate] <datetime>] [[-DomainName] <string>] [[-Credential] <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Set-ADSIGroup [-Identity] <Object> [[-Description] <string>] [[-DisplayName] <string>] [[-DomainName] <string>] [[-Credential] <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Set-ADSIUser -Identity <Object> [-Country <string>] [-Description <string>] [-DisplayName <string>] [-Location <string>] [-Mail <string>] [-Manager <string>] [-PostalCode <string>] [-SamAccountName <string>] [-TelephoneNumber <string>] [-UserPrincipalName <string>] [-AccountExpirationDate <datetime>] [-HomeDrive <string>] [-HomeDirectory <string>] [-DomainName <string>] [-Credential <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]

Set-ADSIUser -Identity <Object> -HomeDrive <string> -HomeDirectory <string> [-Country <string>] [-Description <string>] [-DisplayName <string>] [-Location <string>] [-Mail <string>] [-Manager <string>] [-PostalCode <string>] [-SamAccountName <string>] [-TelephoneNumber <string>] [-UserPrincipalName <string>] [-AccountExpirationDate <datetime>] [-DomainName <string>] [-Credential <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Set-ADSIUserPassword [-Identity] <Object> [-AccountPassword] <securestring> [[-Credential] <pscredential>] [[-DomainName] <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Start-ADSIReplicationConsistencyCheck [-ComputerName] <string> [[-Credential] <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Test-ADSICredential [-AccountName] <string> [-AccountPassword] <securestring> [[-Credential] <pscredential>] [[-DomainName] <string>] [<CommonParameters>]
```

```powershell
Test-ADSIUserIsGroupMember [-UserSamAccountName] <Object> [-GroupSamAccountName] <string> [[-DomainName] <string>] [[-Credential] <pscredential>] [<CommonParameters>]
```

```powershell
Test-ADSIUserIsLockedOut [-Identity] <Object> [[-DomainName] <string>] [[-Credential] <pscredential>] [<CommonParameters>]
```

```powershell
Unlock-ADSIComputer [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [<CommonParameters>]
```

```powershell
Unlock-ADSIUser [-Identity] <Object> [[-Credential] <pscredential>] [[-DomainName] <string>] [<CommonParameters>]
```