function Get-ADSIObject
{
    <#
.SYNOPSIS
    This function will query any kind of object in Active Directory

.DESCRIPTION
    This function will query any kind of object in Active Directory

.PARAMETER  SamAccountName
    Specify the SamAccountName of the object.
    This parameter also search in Name and DisplayName properties
    Name and Displayname are alias.

.PARAMETER  DistinguishedName
    Specify the DistinguishedName of the object your are looking for

.PARAMETER Credential
    Specify the Credential to use

.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query

.PARAMETER SizeLimit
    Specify the number of item(s) to output

.PARAMETER IncludeDeletedObjects
    Deleted objects are included in the search

.PARAMETER DeletedOnly
    Return only deleted objects

.EXAMPLE
    Get-ADSIObject -SamAccountName Fxcat

    Get informations on objects with a SamAccountName equal to Fxcat

.EXAMPLE
    Get-ADSIObject -SamAccountName Fx*

    Get informations on objects with a SamAccountName starting with Fx*

.EXAMPLE
    Get-ADSIObject -SamAccountName Fx* -IncludeDeletedObjects

    Get informations on objects deleted or not with a SamAccountName starting with Fx*

.EXAMPLE
    Get-ADSIObject -SamAccountName Fx* -IncludeDeletedObjects -DeletedOnly

    Get informations on deleted objects with a SamAccountName starting with Fx*

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>

    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "SamAccountName")]
        [Parameter(ParameterSetName = "Deleted")]
        [Alias("Name", "DisplayName")]
        [String]$SamAccountName,

        [Parameter(ParameterSetName = "DistinguishedName")]
        [Parameter(ParameterSetName = "Deleted")]
        [String]$DistinguishedName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("Domain", "DomainDN", "SearchRoot", "SearchBase")]
        [String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Alias("ResultLimit", "Limit")]
        [int]$SizeLimit = '100',

        [Parameter(ParameterSetName = "Deleted", Mandatory = $true)]
        [switch]$IncludeDeletedObjects,

        [Parameter(ParameterSetName = "Deleted")]
        [switch]$DeletedOnly
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
            $Search.SearchRoot = $DomainDistinguishedName

            if ($PSBoundParameters['SamAccountName'])
            {

                if ($PSBoundParameters['DeletedOnly'])
                {
                    $Search.filter = "(&(isDeleted=True)(|(name=$SamAccountName)(samaccountname=$SamAccountName)(displayname=$samaccountname)))"
                }
                else
                {
                    $Search.filter = "(|(name=$SamAccountName)(samaccountname=$SamAccountName)(displayname=$samaccountname))"
                }

            }

            if ($PSBoundParameters['DistinguishedName'])
            {

                if ($PSBoundParameters['DeletedOnly'])
                {
                    $Search.filter = "(&(isDeleted=True)(distinguishedname=$DistinguishedName))"
                }
                else
                {
                    $Search.filter = "(&(distinguishedname=$DistinguishedName))"
                }

            }

            if ($PSBoundParameters['DomainDistinguishedName'])
            {

                if ($DomainDistinguishedName -notlike "LDAP://*")
                {
                    $DomainDistinguishedName = "LDAP://$DomainDistinguishedName"
                }

                Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
                $Search.SearchRoot = $DomainDistinguishedName

            }

            if ($PSBoundParameters['Credential'])
            {

                $Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
                $Search.SearchRoot = $Cred

            }

            if ($PSBoundParameters['IncludeDeletedObjects'])
            {

                $Search.Tombstone = $true

            }

            foreach ($Object in $($Search.FindAll()))
            {

                # Define the properties
                $Properties = @{
                    "displayname"       = $Object.properties.displayname -as [string]
                    "name"              = $Object.properties.name -as [string]
                    "objectcategory"    = $Object.properties.objectcategory -as [string]
                    "objectclass"       = $Object.properties.objectclass -as [string]
                    "samaccountName"    = $Object.properties.samaccountname -as [string]
                    "description"       = $Object.properties.description -as [string]
                    "distinguishedname" = $Object.properties.distinguishedname -as [string]
                    "adspath"           = $Object.properties.adspath -as [string]
                    "lastlogon"         = $Object.properties.lastlogon -as [string]
                    "whencreated"       = $Object.properties.whencreated -as [string]
                    "whenchanged"       = $Object.properties.whenchanged -as [string]
                    "deleted"           = $Object.properties.isDeleted -as [string]
                    "recycled"          = $Object.properties.isRecycled -as [string]
                }

                # Output the info
                New-Object -TypeName PSObject -Property $Properties

            }
        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
    end
    {
        Write-Verbose -Message "[END] Function Get-ADSIObject End."
    }
}