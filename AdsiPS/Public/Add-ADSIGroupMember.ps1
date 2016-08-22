function Add-ADSIGroupMember
{
<#
.SYNOPSIS
    Function to add a group member

.DESCRIPTION
    Function to add a group member

.PARAMETER Identity
    Specifies the Identity of the group

    You can provide one of the following properties
        DistinguishedName
        Guid
        Name
        SamAccountName
        Sid
        UserPrincipalName
    
    Those properties come from the following enumeration:
        System.DirectoryServices.AccountManagement.IdentityType

.PARAMETER Member
    Specifies the member account.
    Performing an Ambiguous Name Resolution LDAP query to find the account.
    http://social.technet.microsoft.com/wiki/contents/articles/22653.active-directory-ambiguous-name-resolution.aspx

.PARAMETER Credential
    Specifies the alternative credential to use.
    By default it will use the current user windows credentials.

.PARAMETER DomainName
    Specifies the alternative Domain where the user should be created
    By default it will use the current domain.

.EXAMPLE 
    Add-ADSIGroupMember -Identity TestADSIGroup -Member 'UserTestAccount1'

    Adding the User account 'UserTestAccount1' to the group 'TestADSIGroup'

.EXAMPLE
    Add-ADSIGroupMember -Identity TestADSIGroup -Member 'GroupTestAccount1'

    Adding the Group account 'GroupTestAccount1' to the group 'TestADSIGroup'

.EXAMPLE
    Add-ADSIGroupMember -Identity TestADSIGroup -Member 'ComputerTestAccount1'

    Adding the Computer account 'ComputerTestAccount1' to the group 'TestADSIGroup'

.NOTES
    Francois-Xavier Cat
    LazyWinAdmin.com
    @lazywinadm
    github.com/lazywinadmin/ADSIPS
#>
[CmdletBinding(SupportsShouldProcess=$true)]
PARAM(
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)]
    $Identity,
    
    [Alias("RunAs")]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty,

    [String]$DomainName,

    $Member
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
			$DirectorySearcher.Filter = "(anr=$member)"
            
            # Retrieve a single object
            $Account = $DirectorySearcher.FindOne().GetDirectoryEntry()

            if($Account)
            {
                switch ($Account.SchemaClassName)
                {
                'user' {$member =[System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, $Account.distinguishedname)}
                'group' {$member = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Account.distinguishedname)}
                'computer' {$member = [System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($Context, $Account.distinguishedname)}
                }
            }
            

            if ($pscmdlet.ShouldProcess("$Identity", "Add Account member $member")){
                $group =(Get-ADSIGroup -Identity $Identity @ContextSplatting)
                $group.members.add($Member)
                $group.Save()
            }
        }
        CATCH{
            Write-Error $Error[0]
        }
    }
}