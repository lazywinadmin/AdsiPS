function Get-ADSIOrganizationalUnit
{
<#
.SYNOPSIS
    This function will query Active Directory for Organization Unit Objects

.DESCRIPTION
    This function will query Active Directory for Organization Unit Objects

.PARAMETER Name
    Specify the Name of the OU

.PARAMETER DistinguishedName
    Specify the DistinguishedName path of the OU

.PARAMETER All
    Will show all the OU in the domain

.PARAMETER GroupPolicyInheritanceBlocked
    Will show only the OU that have Group Policy Inheritance Blocked enabled.

.PARAMETER Credential
    Specify the Credential to use

.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query

.PARAMETER SizeLimit
    Specify the number of item(s) to output

.EXAMPLE
    Get-ADSIOrganizationalUnit

    This returns all the OU in the Domain (Result Size is 100 per default)

.EXAMPLE
    Get-ADSIOrganizationalUnit -name FX

    This returns the OU with the name FX

.EXAMPLE
    Get-ADSIOrganizationalUnit -name FX*

    This returns the OUs where the name starts by FX

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding(DefaultParameterSetName = "All")]
    param (
        [Parameter(ParameterSetName = "Name")]
        [String]$Name,

        [Parameter(ParameterSetName = "DistinguishedName")]
        [String]$DistinguishedName,

        [Parameter(ParameterSetName = "All")]
        [String]$All,

        [Switch]$GroupPolicyInheritanceBlocked,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("Domain", "DomainDN")]
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


            if ($Name)
            {
                $Search.filter = "(&(objectCategory=organizationalunit)(name=$Name))"
                if ($psboundparameters["GroupPolicyInheritanceBlocked"])
                {
                    $Search.filter = "(&(objectCategory=organizationalunit)(name=$Name)(gpoptions=1))"
                }
            }
            if ($DistinguishedName)
            {
                $Search.filter = "(&(objectCategory=organizationalunit)(distinguishedname=$distinguishedname))"
                if ($psboundparameters["GroupPolicyInheritanceBlocked"])
                {
                    $Search.filter = "(&(objectCategory=organizationalunit)(distinguishedname=$distinguishedname)(gpoptions=1))"
                }
            }
            if ($all)
            {
                $Search.filter = "(&(objectCategory=organizationalunit))"
                if ($psboundparameters["GroupPolicyInheritanceBlocked"])
                {
                    $Search.filter = "(&(objectCategory=organizationalunit)(gpoptions=1))"
                }
            }
            if ($DomainDistinguishedName)
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
            if (-not $PSBoundParameters["SizeLimit"])
            {
                Write-Warning -Message "Default SizeLimit: 100 Results"
            }

            foreach ($ou in $($Search.FindAll()))
            {
                # Define the properties
                #  The properties need to be lowercase!!!!!!!!
                $Properties = @{
                    "Name"                  = $ou.properties.name -as [string]
                    "DistinguishedName"     = $ou.properties.distinguishedname -as [string]
                    "ADsPath"               = $ou.properties.adspath -as [string]
                    "ObjectCategory"        = $ou.properties.objectcategory -as [string]
                    "ObjectClass"           = $ou.properties.objectclass -as [string]
                    "ObjectGuid"            = $ou.properties.objectguid
                    "WhenCreated"           = $ou.properties.whencreated -as [string] -as [datetime]
                    "WhenChanged"           = $ou.properties.whenchanged -as [string] -as [datetime]
                    "usncreated"            = $ou.properties.usncreated -as [string]
                    "usnchanged"            = $ou.properties.usnchanged -as [string]
                    "dscorepropagationdata" = $ou.properties.dscorepropagationdata
                    "instancetype"          = $ou.properties.instancetype -as [string]
                }

                # Output the info
                New-Object -TypeName PSObject -Property $Properties
            }
        }#try
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }#process
    end
    {
        Write-Verbose -Message "[END] Function Get-ADSIOrganizationalUnit End."
    }
}