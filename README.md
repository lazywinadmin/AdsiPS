[![Build Status](https://dev.azure.com/lazywinadmin/AdsiPS/_apis/build/status/lazywinadmin.AdsiPS?branchName=master)](https://dev.azure.com/lazywinadmin/AdsiPS/_build/latest?definitionId=17&branchName=master)

# AdsiPS

PowerShell module to interact with Active Directory using ADSI and the System.DirectoryServices namespace (.NET Framework)

The initial motivation for this module was to improve my knowledge on how to interact with Active Directory without the Microsoft Active Directory module or the Quest Active Directory Snapin.
The other elements that I wanted to work on were being able to use alternative Credentials and to specify a different Domain.

Obviously I'm still learning and there is ton of space for improvements... Would love contributors, suggestions, feedback or any other help.

## Table of contents

- [Contributing](#contributing)
- [Installation](#installation)
- [Download from PowerShell Gallery](#Download-from-PowerShell-Gallery)
- [Download from GitHub repository](#Download-from-GitHub-repository)
- [Use Cases](#use-cases)
- [More Information](#more-information)
- [Notes](#notes)

## Contributing

Contributions are welcome via pull requests and issues.
Please see our [contributing guide](https://github.com/lazywinadmin/adsips/blob/master/CONTRIBUTING.md) for more details

## Installation

### Download from PowerShell Gallery (recommended)

Only from PowerShell version 5

``` powershell
Install-Module -name ADSIPS
```

### Download from GitHub repository

1. Download the repository
1. Unblock the zip file
1. Extract the folder to a module path (e.g. $home\Documents\WindowsPowerShell\Modules)
1. Run `build.ps1` (exists in project root).
   - **NOTE:** If you get an error after running `build.ps1` - please use **`build.ps1 -InstallDependencies`**
1. `build.ps1` creates a folder called `~\buildoutput\AdsiPs` in the directory which `AdsiPs` was saved to
1. Inside of `\buildoutput\AdsiPs` there is a file called `AdsiPs.psm1`
1. Run `Import-Module -Path "C:\Path\To\buildoutput\AdsiPs\AdsiPs.psm1"` to import the `AdsiPs` module

## Use Cases

1. Learning Active Directory: We can't see the code behind the Microsoft ActiveDirectory Module and Quest ActiveDirectory Snapin. This module is a great way to explore and learn on how Active Directory is working,
1. Delegation: Active Directory queries need to be performed by a tool (GUI for example) and you don't want it to load AD module. Additionally you don't know who will use the tool and if they have/can/know how to install the module,
1. Performance:  ADSI is way faster,
1. Restricted environment: Sometime ActiveDirectory Module is not available/ or can't install it on a machine.

## More Information

* MSDN is a great resource if you want to find more information on the NET classes to use. See [System.DirectoryServices](https://msdn.microsoft.com/en-us/library/system.directoryservices(v=vs.110).aspx)

## Notes

* Thanks to all the Contributors!! @MickyBalladelli @christophekumor @omiossec ...
* Thanks to PowerShell.com/Tobias Weltner for the great content on ADSI [PowerShell.com ADSI](http://powershell.com/cs/blogs/ebookv2/archive/2012/03/25/chapter-19-user-management.aspx)
* Thanks to @RamblingCookieMonster for your great guidelines and contributions [RamblingCookieMonster's Blog](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/)
