function Remove-ADSIGroupMember
{
<#
.SYNOPSIS
    Function to Remove a group member

.DESCRIPTION
    Function to Remove a group member

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
    Remove-ADSIGroupMember -Identity TestADSIGroup -Member 'UserTestAccount1'

    Removing the User account 'UserTestAccount1' to the group 'TestADSIGroup'

.EXAMPLE
    Remove-ADSIGroupMember -Identity TestADSIGroup -Member 'GroupTestAccount1'

    Removing the Group account 'GroupTestAccount1' to the group 'TestADSIGroup'

.EXAMPLE
    Remove-ADSIGroupMember -Identity TestADSIGroup -Member 'ComputerTestAccount1'

    Removing the Computer account 'ComputerTestAccount1' to the group 'TestADSIGroup'

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true)]
        $Identity,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [System.String]$DomainName,

        [System.String]$Member
    )

    begin
    {
        $FunctionName = (Get-Variable -Name MyInvocation -ValueOnly -Scope 0).MyCommand
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement

        Write-Verbose -Message "[$FunctionName] Building context parameters"
        # Create Context splatting
        $ContextSplatting = @{
            Contexttype = "Domain"
        }

        if ($PSBoundParameters['Credential'])
        {
            Write-Verbose -Message "[$FunctionName] Append Credential to context parameters for username '$($credential.UserName)'"
            $ContextSplatting.Credential = $Credential
        }
        if ($PSBoundParameters['DomainName'])
        {
            Write-Verbose -Message "[$FunctionName] Append DomainName to context parameters '$DomainName'"
            $ContextSplatting.DomainName = $DomainName
        }

        Write-Verbose -Message "[$FunctionName] Creating context object"
        $Context = New-ADSIPrincipalContext @ContextSplatting
    }
    process
    {
        try
        {
            # Resolving member
            # Directory Entry object
            Write-Verbose -Message "[$FunctionName] Building DirectoryEntry parameters"
            $DirectoryEntryParams = $ContextSplatting
            $DirectoryEntryParams.remove('ContextType')
            Write-Verbose -Message "[$FunctionName] Creating DirectoryEntry object"
            $DirectoryEntry = New-ADSIDirectoryEntry @DirectoryEntryParams

            # Principal Searcher
            Write-Verbose -Message "[$FunctionName] Creating DirectorySearcher object"
            $DirectorySearcher = new-object -TypeName System.DirectoryServices.DirectorySearcher
            $DirectorySearcher.SearchRoot = $DirectoryEntry

            # Adding an Ambiguous Name Resolution LDAP Filter
            $DirectorySearcher.Filter = "(anr=$member)"

            # Retrieve a single object
            Write-Verbose -Message "[$FunctionName] Querying Directory Entry"
            $Account = $DirectorySearcher.FindOne().GetDirectoryEntry()

            if ($Account)
            {
                switch ($Account.SchemaClassName)
                {
                    'user'
                    {
                        $member = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($Context, $Account.distinguishedname)
                    }
                    'group'
                    {
                        $member = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($Context, $Account.distinguishedname)
                    }
                    'computer'
                    {
                        $member = [System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($Context, $Account.distinguishedname)
                    }
                }
            }


            if ($pscmdlet.ShouldProcess("$Identity", "Remove Account member $member"))
            {
                Write-Verbose -Message "[$FunctionName] Retrieving Group '$Identity'"
                $group = (Get-ADSIGroup -Identity $Identity @ContextSplatting)

                Write-Verbose -Message "[$FunctionName] Removing member '$member'"
                if($group.members.remove($Member) -eq $false){
                    Write-Verbose -Message "[$FunctionName] Account '$Member' is not a member of Group '$Identity'"
                    #False = Not Part of the Group / True = removed GroupMembership
                }else{
                    Write-Verbose -Message "[$FunctionName] Saving changes"
                    $group.Save()
                }
            }
        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}
