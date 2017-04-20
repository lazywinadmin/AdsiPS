function Get-ADSIComputer
{
<#
.SYNOPSIS
	Function to retrieve a Computer in Active Directory

.DESCRIPTION
	Function to retrieve a Computer in Active Directory

.PARAMETER Identity
	Specifies the Identity of the computer
		
	You can provide one of the following:
		DistinguishedName
		Guid
		Name
		SamAccountName
		Sid

	System.DirectoryService.AccountManagement.IdentityType
	https://msdn.microsoft.com/en-us/library/bb356425(v=vs.110).aspx

.PARAMETER Credential
	Specifies alternative credential
	By default it will use the current user windows credentials.

.PARAMETER DomainName
	Specifies the alternative Domain.
	By default it will use the current domain.

.EXAMPLE
	Get-ADSIComputer -Identity 'SERVER01'

	This command will retrieve the computer account SERVER01

.EXAMPLE
	Get-ADSIComputer -Identity 'SERVER01' -Credential (Get-Credential)

	This command will retrieve the computer account SERVER01 with the specified credential

.EXAMPLE
	Get-ADSIComputer TESTSERVER01 -credential (Get-Credential) -domain LazyWinAdmin.local

	This command will retrieve the account TESTSERVER01 using the alternative credential specified in the domain lazywinadmin.local

.EXAMPLE
	$Comp = Get-ADSIComputer -Identity 'SERVER01'
	$Comp.GetUnderlyingObject()| select-object *

	Help you find all the extra properties

.NOTES
	Francois-Xavier Cat
	lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/ADSIPS

.LINK
	https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.computerprincipal(v=vs.110).aspx
#>
	[CmdletBinding(DefaultParameterSetName="All")]
	param ([Parameter(Mandatory=$true,ParameterSetName="Identity")]
		[string]$Identity,
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,

		[String]$DomainName
	)
	BEGIN
	{
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
        # Create Context splatting
        $ContextSplatting = @{ ContextType = "Domain" }
		
        IF ($PSBoundParameters['Credential']) { $ContextSplatting.Credential = $Credential }
        IF ($PSBoundParameters['DomainName']) { $ContextSplatting.DomainName = $DomainName }
		
        $Context = New-ADSIPrincipalContext @ContextSplatting

	}
	PROCESS
	{
        TRY{
            IF($Identity)
            {
                [System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($Context, $Identity)
            }
            ELSE{
                $ComputerPrincipal = New-object -TypeName System.DirectoryServices.AccountManagement.ComputerPrincipal -ArgumentList $Context
			    $Searcher = new-object System.DirectoryServices.AccountManagement.PrincipalSearcher
			    $Searcher.QueryFilter = $ComputerPrincipal

                $Searcher.FindAll()
            }
        }
        CATCH
        {
        $Error[0]
        }
	}
}
