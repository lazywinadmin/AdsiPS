﻿function Get-ADSIGroupManagedBy
{
<#
.SYNOPSIS
    This function retrieve the group that the current user manage in the ActiveDirectory.

.DESCRIPTION
    This function retrieve the group that the current user manage in the ActiveDirectory.
    Typically the function will search for group(s) and look at the 'ManagedBy' property where it matches the current user.

.PARAMETER SamAccountName
    Specify the SamAccountName of the Manager of the group
    You can also use the alias: ManagerSamAccountName.

.PARAMETER AllManagedGroups
    Specify to search for groups with a Manager (managedby property)

.PARAMETER NoManager
    Specify to search for groups without Manager (managedby property)

.PARAMETER Credential
    Specify the Credential to use for the query

.PARAMETER SizeLimit
    Specify the number of item maximum to retrieve

.PARAMETER DomainDistinguishedName
    Specify the Domain or Domain DN path to use

.EXAMPLE
    Get-ADSIGroupManagedBy -SamAccountName fxcat

    This will list all the group(s) where fxcat is designated as Manager.

.EXAMPLE
    Get-ADSIGroupManagedBy

    This will list all the group(s) where the current user is designated as Manager.

.EXAMPLE
    Get-ADSIGroupManagedBy -NoManager

    This will list all the group(s) without Manager

.EXAMPLE
    Get-ADSIGroupManagedBy -AllManagedGroup

    This will list all the group(s) without Manager

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding(DefaultParameterSetName = "One")]
    param (
        [Parameter(ParameterSetName = "One")]
        [Alias("ManagerSamAccountName")]
        [String]$SamAccountName = $env:USERNAME,

        [Parameter(ParameterSetName = "All")]
        [Switch]$AllManagedGroups,

        [Parameter(ParameterSetName = "No")]
        [Switch]$NoManager,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Alias("DomainDN", "Domain", "SearchBase", "SearchRoot")]
        [String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),

        [Alias("ResultLimit", "Limit")]
        [int]$SizeLimit = '100'
    )

    begin
    {
    }
    process
    {
        try
        {
            # Building the basic search object with some parameters
            $Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
            $Search.SizeLimit = $SizeLimit
            $Search.SearchRoot = $DomainDN

            if ($PSBoundParameters['DomainDistinguishedName'])
            {
                # Fixing the path if needed
                if ($DomainDistinguishedName -notlike "LDAP://*")
                {
                    $DomainDistinguishedName = "LDAP://$DomainDistinguishedName"
                }#if

                Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
                $Search.SearchRoot = $DomainDistinguishedName
            }

            if ($PSBoundParameters['Credential'])
            {
                Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
                $Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
                $Search.SearchRoot = $Cred
            }

            if ($PSBoundParameters['SamAccountName'])
            {
                Write-Verbose -Message "SamAccountName"
                #Look for User DN
                $UserSearch = $search
                $UserSearch.Filter = "(&(SamAccountName=$SamAccountName))"
                $UserDN = $UserSearch.FindOne().Properties.distinguishedname -as [string]

                # Define the query to find the Groups managed by this user
                $Search.Filter = "(&(objectCategory=group)(ManagedBy=$UserDN))"
            }

            if ($PSBoundParameters['AllManagedGroups'])
            {
                Write-Verbose -Message "All Managed Groups Param"
                $Search.Filter = "(&(objectCategory=group)(managedBy=*))"
            }

            if ($PSBoundParameters['NoManager'])
            {
                Write-Verbose -Message "No Manager param"
                $Search.Filter = "(&(objectCategory=group)(!(!managedBy=*)))"
            }

            if (-not ($PSBoundParameters['SamAccountName']) -and -not ($PSBoundParameters['AllManagedGroups']) -and -not ($PSBoundParameters['NoManager']))
            {
                Write-Verbose -Message "No parameters used"
                #Look for User DN
                $UserSearch = $search
                $UserSearch.Filter = "(&(SamAccountName=$SamAccountName))"
                $UserDN = $UserSearch.FindOne().Properties.distinguishedname -as [string]

                # Define the query to find the Groups managed by this user
                $Search.Filter = "(&(objectCategory=group)(ManagedBy=$UserDN))"
            }

            foreach ($group in $Search.FindAll())
            {
                $Properties = @{
                    "SamAccountName"    = $group.properties.samaccountname -as [string]
                    "DistinguishedName" = $group.properties.distinguishedname -as [string]
                    "GroupType"         = $group.properties.grouptype -as [string]
                    "Mail"              = $group.properties.mail -as [string]
                }
                New-Object -TypeName psobject -Property $Properties
            }
        }#try
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }#Process
    end
    {
        Write-Verbose -Message "[END] Function Get-ADSIGroupManagedBy End."
    }
}