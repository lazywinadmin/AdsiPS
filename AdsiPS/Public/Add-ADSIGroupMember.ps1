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
        $FunctionName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).Mycommand

        Write-Verbose -Message "[$FunctionName] Loading assembly System.DirectoryServices.AccountManagement"
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement -ErrorAction Stop

        # Create Context splatting
        Write-Verbose -Message "[$FunctionName] Create context splatting"
		$ContextSplatting = @{
			Contexttype = "Domain"
		}

		IF ($PSBoundParameters['Credential']){
            Write-Verbose -Message "[$FunctionName] Context splatting - Add Credential"
            $ContextSplatting.Credential = $Credential
        }
        IF ($PSBoundParameters['DomainName']){
            Write-Verbose -Message "[$FunctionName] Context splatting - Add DomainName"
            $ContextSplatting.DomainName = $DomainName
        }

        Write-Verbose -Message "[$FunctionName] Create New Principal Context using Context Splatting"
        $Context = New-ADSIPrincipalContext @ContextSplatting -ErrorAction Stop
    }
    PROCESS
    {
        TRY{
            # Resolving member
            # Directory Entry object
            Write-Verbose -Message "[$FunctionName] Copy Context splatting and remove ContextType property"
            $DirectoryEntryParams = $ContextSplatting
			$DirectoryEntryParams.remove('ContextType')
            Write-Verbose -Message "[$FunctionName] Create New Directory Entry using using the copied context"
			$DirectoryEntry = New-ADSIDirectoryEntry @DirectoryEntryParams

			# Principal Searcher
            Write-Verbose -Message "[$FunctionName] Create a System.DirectoryServices.DirectorySearcher"
			$DirectorySearcher = new-object -TypeName System.DirectoryServices.DirectorySearcher
            Write-Verbose -Message "[$FunctionName] Append DirectoryEntry to in the property SearchRoot of DirectorySearcher"
			$DirectorySearcher.SearchRoot = $DirectoryEntry

            # Adding an Ambiguous Name Resolution (ANR) LDAP Filter
            Write-Verbose -Message "[$FunctionName] Append LDAP Filter '(anr=$member)' to the property Filter of DirectorySearcher"
			$DirectorySearcher.Filter = "(anr=$member)"

            # Retrieve a single object
            Write-Verbose -Message "[$FunctionName] Retrieve the account"
            $Account = $DirectorySearcher.FindOne().GetDirectoryEntry()

            if($Account)
            {
                Write-Verbose -Message "[$FunctionName] Account Retrieved"
                switch ($Account.SchemaClassName)
                {
                    'user' {$member =[System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, $Account.distinguishedname)}
                    'group' {$member = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Account.distinguishedname)}
                    'computer' {$member = [System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($Context, $Account.distinguishedname)}
                }
            }
            else{
                Write-Error -Message "[$FunctionName] Can't retrieve the identity '$identity'"
            }


            if ($pscmdlet.ShouldProcess("$Identity", "Add Account member $member")){
                Write-Verbose -Message "[$FunctionName] Retrieve group with the identity '$identity' using Get-ADSIGroup using the Context Splatting"
                $group =(Get-ADSIGroup -Identity $Identity @ContextSplatting -ErrorAction Stop)
                $group.members.add($Member)
                $group.Save()
            }
        }
        CATCH{
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
    END{
        Write-Verbose -Message "[$FunctionName] Done."
    }
}