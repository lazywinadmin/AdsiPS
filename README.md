# AdsiPS

PowerShell module to interact with Active Directory using ADSI and the System.DirectoryServices namespace (.NET Framework)

The initial motivation for this module was to improve my knowledge on how to interact with Active Directory without the Microsoft Active Directory module or the Quest Active Directory Snapin.
The other elements that I wanted to work on were being able to use alternative Credentials and to specify a different Domain.

Obviously I'm still learning and there is ton of space for improvements... Would love contributors, suggestions, feedback or any other help.
 
## Installation
#### Download from PowerShell Gallery (PowerShell v5+)
``` powershell
Install-Module -name ADSIPS
```

#### Download from GitHub repository
* Download the repository
* Unblock the zip file
* Extract the folder to a module path (e.g. $home\Documents\WindowsPowerShell\Modules)


## Use Cases

* Learning Active Directory: We can't see the code behind the Microsoft ActiveDirectory Module and Quest ActiveDirectory Snapin. This module is a great way to explore and learn on how Active Directory is working,
* Delegation: Active Directory queries need to be performed by a tool (GUI for example) and you don't want it to load AD module. Additionally you don't know who will use the tool and if they have/can/know how to install the module,
* Performance:  ADSI is way faster,
* Restricted environment: Sometime ActiveDirectory Module is not available/ or can't install it on a machine.



## Help !!
Would love contributors, suggestions, feedback, and other help! Feel free to open an Issue ticket

### Guidelines
* Don't use Write-Host
* Use Verb-Noun format, Check Get-Verb for approved verb
* Always use explicit parameter names, don't assume position
* Don't use Aliases
* Should support Credential input
* If you want to show informational information use Write-Verbose
* If you use Verbose, show the name of the function, you can do this:
```powershell
# Define this variable a the beginning
$ScriptName = (Get-Variable -name MyInvocation -Scope 0 -ValueOnly).Mycommand

# Show your verbose message this way
Write-Verbose -Message "[$ScriptName] Querying system X"
```
* You need to have Error Handling (TRY/CATCH)
* Return terminating error using ```$PSCmdlet.ThrowTerminatingError($_)```
* Think about the next guy, document your function, help them understand what you are achieving, give at least one example
* Implement appropriate WhatIf/Confirm support if you function is changing something

## TODO (not in a specific order)
- [ ] Set-ADSIComputer
- [ ] Set-ADSIGroup
- [ ] Set-ADSIObject
- [ ] Set-ADSIOrganizationalUnit
- [ ] Restore-ADSIAccount
- [ ] Unlock-ADSIAccount
- [x] Search-ADSIAccount (retrieve disabled account, expired, expiring,...)
- [ ] ACL functions
- [ ] GPO functions
- [ ] Set-ADSIDomainMode
- [ ] Set-ADSIForestMode
- [ ] Get-ADSIAccountResultantPasswordReplicationPolicy
- [ ] Get-ADSIDomainControllerPasswordReplicationPolicy
- [ ] Add-ADSIDomainControllerPasswordReplicationPolicy
- [ ] Remove-ADSIDomainControllerPasswordReplicationPolicy
- [x] Get-ADSIDefaultDomainPasswordPolicy
- [ ] Set-ADSIDefaultDomainPasswordPolicy
- [ ] Get-ADSIDomainControllerPasswordReplicationPolicyUsage
- [ ] Get-ADSIDomainControllerPasswordReplicationPolicyUsage
- [x] Get-ADSIFineGrainedPasswordPolicy
- [ ] Get-ADSIAccountResultantPasswordReplicationPolicy
- [ ] Set-ADSIAccountPassword
- [ ] Clear-ADSIAccountExpiration
- [ ] Find expensive queries
- [ ] Improve Get TokenSize

## More Information
 * MSDN is a great resource if you want to find more information on the NET classes to use. See [System.DirectoryServices](https://msdn.microsoft.com/en-us/library/system.directoryservices(v=vs.110).aspx)

## Notes
 * Thanks to all the Contributors!! @MickyBalladelli @christophekumor @omiossec ...
 * Thanks to PowerShell.com/Tobias Weltner for the great content on ADSI [PowerShell.com ADSI](http://powershell.com/cs/blogs/ebookv2/archive/2012/03/25/chapter-19-user-management.aspx)
 * Thanks to @RamblingCookieMonster for your great guidelines and contributions [RamblingCookieMonster's Blog](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/)
