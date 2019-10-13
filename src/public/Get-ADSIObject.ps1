function Get-ADSIObject
{
    <#
.SYNOPSIS
    This function will query any kind of object in Active Directory

.DESCRIPTION
    This function will query any kind of object in Active Directory

.PARAMETER Identity
	Specifies the Identity of the Object
	You can provide one of the following properties
	DistinguishedName
	Name
	SamAccountName
    UserPrincipalName
    Guid
    Sid

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
    Get-ADSIObject -Identity Fxcat

    Get informations on objects with a Identity equal to Fxcat

.EXAMPLE
    Get-ADSIObject -Identity Fx*

    Get informations on objects with a Identity starting with Fx*

.EXAMPLE
    Get-ADSIObject -Identity Fx* -IncludeDeletedObjects

    Get informations on objects deleted or not with a Identity starting with Fx*

.EXAMPLE
    Get-ADSIObject -Identity Fx* -IncludeDeletedObjects -DeletedOnly

    Get informations on deleted objects with a Identity starting with Fx*

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>

    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Identity", Mandatory = $true)]
        [Parameter(ParameterSetName = "Deleted")]
        [Alias("SamAccountName", "DistinguishedName")]
        [System.String]$Identity,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("Domain", "DomainDN", "SearchRoot", "SearchBase")]
        [System.String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),

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

            #Convert Identity Input String to HEX
            $IdentityGUID = ""
            Try{
                ([System.Guid]$Identity).ToByteArray() | %{ $IdentityGUID += $("\{0:x2}" -f $_) }
            } Catch {
                $IdentityGUID="null"
            }

            if ($PSBoundParameters['Identity'])
            {
                if ($PSBoundParameters['DeletedOnly'])
                {
                    $Search.filter = "(&(isDeleted=True)(|(DistinguishedName=$Identity)(Name=$Identity)(SamAccountName=$Identity)(UserPrincipalName=$Identity)(objectGUID=$IdentityGUID)(objectSid=$Identity)))"
                }
                else
                {
                    $Search.filter = "(|(DistinguishedName=$Identity)(Name=$Identity)(SamAccountName=$Identity)(UserPrincipalName=$Identity)(objectGUID=$IdentityGUID)(objectSid=$Identity))"
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
                    "userPrincipalName" = $Object.properties.userprincipalname -as [string]
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