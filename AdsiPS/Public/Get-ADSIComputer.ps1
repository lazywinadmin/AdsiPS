function Get-ADSIComputer
{
<#
	.SYNOPSIS
		Function to retrieve a Computer in Active Directory
	
	.DESCRIPTION
		Function to retrieve a Computer in Active Directory
	
	.PARAMETER Identity
		Specifies the Identity
	
	.PARAMETER Credential
		Specifies alternative credential
	
	.EXAMPLE
		Get-ADSIComputer -Identity 'SERVER01'
	
	.EXAMPLE
		Get-ADSIComputer -Identity 'SERVER01' -Credential (Get-Credential)
	
	.EXAMPLE
		$Comp = Get-ADSIComputer -Identity 'SERVER01'
		$Comp.GetUnderlyingObject()| select-object *
	
		Help you find all the extra properties
	
	.NOTES
		Francois-Xavier Cat
		lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	[CmdletBinding(DefaultParameterSetName="All")]
	param ([Parameter(Mandatory=$true,ParameterSetName="Identity")]
		[string]$Identity,
		
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
        $DomainName
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
