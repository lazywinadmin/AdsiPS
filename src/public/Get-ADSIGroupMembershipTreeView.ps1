#function Get-ADSIGroupMembershipTreeView{
<#
.SYNOPSIS
    Function to get all Group Memberships of a User or Computer including all Groups inherited by another group in a Tree View in Active Directory
.DESCRIPTION
    Function to get all Group Memberships of a User or Computer including all Groups inherited by another group in a Tree View in Active Directory
.PARAMETER Identity
    Specifies the Identity of the Source User or Computer
    You can provide one of the following properties
    DistinguishedName
    Guid
    Name
    SamAccountName
    Sid
    UserPrincipalName
    Those properties come from the following enumeration:
    System.DirectoryServices.AccountManagement.IdentityType
.PARAMETER DomainName
    Specifies the Domain Name where the function should look
.PARAMETER Credential
    Specifies the alternative credential to use.
    By default it will use the current user windows credentials.
.EXAMPLE
    Get-ADSIGroupMembershipTreeView -Identity user1
.EXAMPLE
    Get-ADSIGroupMembershipTreeView -Identity computer1
.NOTES
    https://github.com/lazywinadmin/ADSIPS
.LINK
    https://msdn.microsoft.com/en-us/library/System.DirectoryServices.AccountManagement.UserPrincipal(v=vs.110).aspx
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            ParameterSetName = "Identity")]
        [System.string]$Identity,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [System.String]$DomainName
    )

    begin{
        $FunctionName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).Mycommand

        # Create Context splatting
        $ContextSplatting = @{ }
        if ($PSBoundParameters['Credential']){
            Write-Verbose "[$FunctionName] Found Credential Parameter"
            $ContextSplatting.Credential = $Credential
        }
        if ($PSBoundParameters['DomainName']){
            Write-Verbose "[$FunctionName] Found DomainName Parameter"
            $ContextSplatting.DomainName = $DomainName
        }

        #Get Identity Type
        $Object = Get-ADSIObject -Identity $Identity @ContextSplatting

        switch -Wildcard ($Object.objectclass){
            "*group" {$IdentityType = "Group"}
            "*computer" {$IdentityType = "Computer"}
            "*user" {$IdentityType = "User"}
        }
    }

    process{

        function Get-RecursiveGroups([System.DirectoryServices.AccountManagement.Principal]$Group){
            Write-Output "$("  "*$Spacecount)-$($Group.Name)"
            $MemberOf = $Group.GetGroups()
            If($null -ne $MemberOf){
                if($Group -notin $UsedParentGroups){
                    $UsedParentGroups.Add($Group)
                    foreach($MemberOfGroup in $MemberOf){
                        $Spacecount ++
                        Get-RecursiveGroups -Group $MemberOfGroup
                    }
                } else {
                    Write-Warning "[$FunctionName] Stopped processing because a endless loop was detected"
                }
            }
        }

        #GetGroups
        If($IdentityType -eq "User"){
            $Groups = (Get-ADSIUser -Identity $Identity @ContextSplatting).GetGroups()
            Write-Verbose "[$FunctionName] Type: User"
        } elseif ($IdentityType -eq "Computer") {
            $Groups = (Get-ADSIComputer -Identity $Identity @ContextSplatting).GetGroups()
            Write-Verbose "[$FunctionName] Type: Computer"
        } elseif ($IdentityType -eq "Group") {
            $Groups = (Get-ADSIGroup -Identity $Identity @ContextSplatting).GetGroups()
            Write-Verbose "[$FunctionName] Type: Group"
        }

        if($Groups){
            Write-Verbose "Groups found: $($Groups.Name)"
            Write-Output $(Get-ADSIUser -Identity $Identity).Name
            foreach($Group in $Groups){
                $Spacecount = 1
                $UsedParentGroups = New-Object Collections.Generic.List[System.DirectoryServices.AccountManagement.GroupPrincipal]
                Get-RecursiveGroups -Group $Group
            }
        } else {
            Write-Verbose "No Groups found"
        }
    }
#}