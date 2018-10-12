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

.EXAMPLE
    Get-ADSIObject -SamAccountName Fxcat

.EXAMPLE
    Get-ADSIObject -Name DC*

.NOTES
    Francois-Xavier Cat
    LazyWinAdmin.com
    @lazywinadm
    github.com/lazywinadmin/AdsiPS
#>

    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "SamAccountName")]
        [Alias("Name", "DisplayName")]
        [String]$SamAccountName,

        [Parameter(ParameterSetName = "DistinguishedName")]
        [String]$DistinguishedName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("Domain", "DomainDN", "SearchRoot", "SearchBase")]
        [String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

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
            $Search.SearchRoot = $DomainDistinguishedName

            if ($PSBoundParameters['SamAccountName'])
            {
                $Search.filter = "(|(name=$SamAccountName)(samaccountname=$SamAccountName)(displayname=$samaccountname))"
            }
            if ($PSBoundParameters['DistinguishedName'])
            {
                $Search.filter = "(&(distinguishedname=$DistinguishedName))"
            }
            if ($PSBoundParameters['DomainDistinguishedName'])
            {
                if ($DomainDistinguishedName -notlike "LDAP://*")
                {
                    $DomainDistinguishedName = "LDAP://$DomainDistinguishedName"
                }#if
                Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
                $Search.SearchRoot = $DomainDistinguishedName
            }
            if ($PSBoundParameters['Credential'])
            {
                $Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
                $Search.SearchRoot = $Cred
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