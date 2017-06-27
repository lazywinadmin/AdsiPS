﻿function Get-ADSIGlobalCatalog
{
    <#
.SYNOPSIS
	Function to retrieve the Global Catalog in the Forest

.DESCRIPTION
	Function to retrieve the Global Catalog in the Forest

.PARAMETER Credential
	Specifies the alternative credential to use. Default is the current user.

.PARAMETER ForestName
	Specifies the alternative Forest name to query. Default is the current one.

.EXAMPLE
	Get-ADSIGlobalCatalog
	
	Retrieve the Global Catalog in the current Forest

.EXAMPLE
	Get-ADSIGlobalCatalog -forestname 'lazywinadmin.com'
	
	Retrieve the Global Catalog in the forest 'lazywinadmin.com'

.NOTES
	Francois-Xavier Cat
	www.lazywinadmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
#>
	
    [CmdletBinding()]
    [OutputType('System.DirectoryServices.ActiveDirectory.GlobalCatalog')]
    param
    (
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,
		
        $ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
    )
    BEGIN
    {
        $FunctionName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).Mycommand
    }
    PROCESS
    {
        TRY
        {
            Write-Verbose -Message "[$FunctionName][PROCESS] Credential or FirstName specified"
            (Get-ADSIForest @PSBoundParameters).GlobalCatalogs
        }
        CATCH
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}