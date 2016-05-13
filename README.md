# AdsiPS

PowerShell module to interact with Active Directory using ADSI and DirectoryServices (.NET)

#### Goals
 * No ActiveDirectory module/No Quest AD Snapin required
 * Being able to specify different credentials
 * Being able to specify different domain
 
## Installation
#### Download from PowerShell Gallery
Coming soon...
#### Download from GitHub repository

* Download the repository
* Unblock the zip file
* Extract the folder to a module path (e.g. $home\Documents\WindowsPowerShell\Modules)

 
## Use Cases

* Learning Active Directory: We can't see the code behind the Microsoft ActiveDirectory Module and Quest ActiveDirectory Snapin. This module is a great way to explore and learn on how Active Directory is working,
* Delegation: Active Directory queries need to be performed by a tool (GUI for example) and you don't want it to load AD module. Additionally you don't know who will use the tool and if they have/can/know how to install the module,
* Performance:  ADSI is way faster,
* Restricted environment: Sometime ActiveDirectory Module is not available/ or can't install it on a machine.


# Cmdlets
 * Add-ADSIGroupMember
 * Enable-ADSIDomainControllerGlobalCatalog
 * Get-ADSIComputer
 * Get-ADSIComputerSite
 * Get-ADSIDomain
 * Get-ADSIDomainController
 * Get-ADSIDomainMode
 * Get-ADSIDomainRoot
 * Get-ADSIDomainTrustRelationship
 * Get-ADSIForest
 * Get-ADSIForestDomain
 * Get-ADSIForestMode
 * Get-ADSIForestTrustRelationship
 * Get-ADSIFsmo
 * Get-ADSIGroup
 * Get-ADSIGroupManagedBy
 * Get-ADSIGroupMember
 * Get-ADSIGroupPolicyObject
 * Get-ADSIObject
 * Get-ADSIOrganizationalUnit
 * Get-ADSIReplicaCurrentTime
 * Get-ADSIReplicaDomainInfo
 * Get-ADSIReplicaForestInfo
 * Get-ADSIReplicaGCInfo
 * Get-ADSIReplicaInfo
 * Get-ADSISchema
 * Get-ADSISite
 * Get-ADSISiteLink
 * Get-ADSISiteServer
 * Get-ADSISiteSubnet
 * Get-ADSITokenGroup
 * Get-ADSIUser
 * Move-ADSIDomainControllerRole
 * Move-ADSIDomainControllerToSite
 * New-ADSIDirectoryContext
 * New-ADSIGroup
 * New-ADSIPrincipalContext
 * New-ADSISite
 * New-ADSIUser
 * Remove-ADSIGroup
 * Remove-ADSIGroupMember
 * Remove-ADSISite
 * Remove-ADSISiteSubnet
 * Remove-ADSIUser
 * Reset-ADSIUserPasswordAge
 * Set-ADSIUserPassword
 * Start-ADSIReplicationConsistencyCheck
 * Test-ADSICredential
 * Test-ADSIUserIsGroupMember
 * Test-ADSIUserIsLockedOut
 * Unlock-ADSIUser