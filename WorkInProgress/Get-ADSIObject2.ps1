function Get-ADSIObject
{

<#
.NOTES
    Francois-Xavier.Cat
    LazyWinAdmin.com
    @lazywinadm
    github.com/lazywinadmin
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)]
    $Identity,

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
		$ContextSplatting = @{
			Contexttype = "Domain"
		}
		
		IF ($PSBoundParameters['Credential']){$ContextSplatting.Credential = $Credential}
        IF ($PSBoundParameters['DomainName']){$ContextSplatting.DomainName = $DomainName}
        
        $Context = New-ADSIPrincipalContext @ContextSplatting
    }
    PROCESS
    {
        TRY{
            # Resolving member
            # Directory Entry object
			$DirectoryEntryParams = $ContextSplatting.remove('ContextType')
			$DirectoryEntry = New-ADSIDirectoryEntry @DirectoryEntryParams
			
			# Principal Searcher
			$DirectorySearcher = new-object -TypeName System.DirectoryServices.DirectorySearcher
			$DirectorySearcher.SearchRoot = $DirectoryEntry
            
            # Adding an Ambiguous Name Resolution LDAP Filter
			$DirectorySearcher.Filter = "(anr=$identity)"
            
            # Retrieve a single object
            $Account = $DirectorySearcher.FindOne().GetDirectoryEntry()

            if($Account)
            {
                switch ($Account.SchemaClassName)
                {
                'user' {[System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, $Account.distinguishedname)}
                'group' {[System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Account.distinguishedname)}
                'computer' {[System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($Context, $Account.distinguishedname)}
                }
            }
        }
        CATCH{
            Write-Error $Error[0]
        }
    }
}