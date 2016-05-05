function Get-ADSIGroup
{
<#
	.SYNOPSIS
		Function to retrieve a group in Active Directory
	
	.DESCRIPTION
		Function to retrieve a group in Active Directory
	
	.PARAMETER Identity
		Specifies the Identity of the group
	
	.PARAMETER Credential
		Specifies alternative credential
	
	.EXAMPLE
		Get-ADSIGroup -Identity 'SERVER01'
	
	.EXAMPLE
		Get-ADSIGroup -Identity 'SERVER01' -Credential (Get-Credential)

    .EXAMPLE
        Get-ADSIGroup -Name "*ADSIPS*"
    .EXAMPLE
        Get-ADSIGroup -ISSecurityGroup:$true -Description "*"
	
	.EXAMPLE
		$Comp = Get-ADSIGroup -Identity 'SERVER01'
		$Comp.GetUnderlyingObject()| select-object *
	
		Help you find all the extra properties

    .EXAMPLE
        Get-ADSIGroup -GroupScope Universal -IsSecurityGroup

    .EXAMPLE
        Get-ADSIGroup -GroupScope Universal -IsSecurityGroup:$false
	
	.NOTES
		Francois-Xavier Cat
		lazywinadmin.com
		@lazywinadm
		github.com/lazywinadmin
#>
	[CmdletBinding(DefaultParameterSetName='All')]
	param (
        [Parameter(ParameterSetName='Identity')]
		[string]$Identity,
		
		[Alias('RunAs')]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
	
		#$SearchBase,

        [Alias("Domain","Server")]
        $DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::Getcurrentdomain(),

        [Parameter(ParameterSetName='Filter')]
        [system.directoryservices.accountmanagement.groupscope]$GroupScope,

        [Parameter(ParameterSetName='Filter')]
        [switch]$IsSecurityGroup=$true,

        [Parameter(ParameterSetName='Filter')]
        $Description,

        [Parameter(ParameterSetName='Filter')]
        $UserPrincipalName,

        [Parameter(ParameterSetName='Filter')]
        $Displayname ,
        #[Parameter(ParameterSetName='Filter')]
        #$DistinguishedName,
        [Parameter(ParameterSetName='Filter')]
        $Name,
        [Parameter(ParameterSetName='Filter')]
        $SID

	)
	BEGIN
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
        <#
		IF ($PSBoundParameters['Credential'])
		{
			$Context = New-ADSIPrincipalContext -contexttype Domain -Credential $Credential
			IF ($PSBoundParameters['SearchBase'])
			{
				$Context = New-ADSIPrincipalContext -contexttype Domain -Credential $Credential -Container $SearchBase
			}
		}
		ELSE
		{
			$Context = New-ADSIPrincipalContext -contexttype Domain
			
			IF ($PSBoundParameters['SearchBase'])
			{
				$Context = New-ADSIPrincipalContext -contexttype Domain -Container $SearchBase
			}
		}
        #>
        $Splatting = $PSBoundParameters.Remove("Identity")
       #$Splatting = $Splatting.Remove("SearchBase")
        $Context = New-ADSIPrincipalContext -contexttype Domain # $SearchBase
	}
	PROCESS
	{
        TRY
        {
            IF($Identity)
            {
		        [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Identity)
            }
            ELSE{
                $GroupPrincipal =New-object -TypeName System.DirectoryServices.AccountManagement.GroupPrincipal -argu $Context
                #$GroupPrincipal.Name = $Identity
                $searcher = new-object System.DirectoryServices.AccountManagement.PrincipalSearcher
                $searcher.QueryFilter = $GroupPrincipal
                $searcher.QueryFilter.IsSecurityGroup = $IsSecurityGroup
                if($PSBoundParameters['GroupScope']){$searcher.QueryFilter.GroupScope = $GroupScope}
                if($PSBoundParameters['UserPrincipalName']){$searcher.QueryFilter.UserPrincipalName = $UserPrincipalName}
                if($PSBoundParameters['Description']){$searcher.QueryFilter.Description = $Description}
                if($PSBoundParameters['DisplayName']){$searcher.QueryFilter.DisplayName = $DisplayName}
                #if($PSBoundParameters['DistinguishedName']){$searcher.QueryFilter.DistinguishedName = $DistinguishedName}
                if($PSBoundParameters['Sid']){$searcher.QueryFilter.Sid.Value = $SID}
                if($PSBoundParameters['Name']){$searcher.QueryFilter.Name = $Name}

                $searcher.FindAll()
            }
        }
        CATCH
        {
            Write-Error $error[0]
        }
	}
}