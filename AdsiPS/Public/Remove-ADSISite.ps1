Function Remove-ADSISite
{
<#
.SYNOPSIS
    function to remove a Site

.DESCRIPTION
    function to remove a Site

.PARAMETER SiteName
    Specifies the Site Name

.PARAMETER Credential
    Specifies the alternative credential to use.
    By default it will use the current user windows credentials.

.PARAMETER ForestName
    Specifies the alternative Forest where the user should be created
    By default it will use the current Forest.

.EXAMPLE
    Remove-ADSISite -SiteName WOW01

.NOTES
    Francois-Xavier.Cat
    LazyWinAdmin.com
    @lazywinadm
    github.com/lazywinadmin/AdsiPS
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$true)]
    [String]$SiteName,

    [Alias("RunAs")]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty,

    [String]$ForestName

)
    BEGIN{
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
        # Create Context splatting
        $ContextSplatting=@{}

		IF ($PSBoundParameters['Credential']){$ContextSplatting.Credential = $Credential}
        IF ($PSBoundParameters['ForestName']){$ContextSplatting.ForestName = $ForestName}
    }
    PROCESS
    {
        TRY
        {
            (Get-ADSISite -Name $SiteName @ContextSplatting).Delete()
        }
        CATCH{
            Write-Error $Error[0]
            break
        }
    }
    END
    {
    }	
}

