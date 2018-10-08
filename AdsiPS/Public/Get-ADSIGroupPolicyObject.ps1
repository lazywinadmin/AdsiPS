function Get-ADSIGroupPolicyObject
{
<#
.SYNOPSIS
    This function will query Active Directory Group Policy Objects

.DESCRIPTION
    This function will query Active Directory Group Policy Objects

.PARAMETER Credential
    Specifies alternative Credential to use

.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query.

.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.

.EXAMPLE
    Get-ADSIGroupPolicyObject

    Retrieve all the group policy in the current domain

.NOTES
    github.com/lazywinadmin/AdsiPS

    https://msdn.microsoft.com/en-us/library/cc232507.aspx
#>
    [CmdletBinding()]
    PARAM (
        [Parameter()]
        [Alias("Domain", "DomainDN")]
        [String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Alias("ResultLimit", "Limit")]
        [int]$SizeLimit = '100'
    )
    BEGIN { }
    PROCESS
    {
        TRY
        {
            $ScriptName = (Get-Variable -name MyInvocation -Scope 0 -ValueOnly).MyCommand

            # Building the basic search object with some parameters
            Write-Verbose -message "[$ScriptName] Create DirectorySearcher"
            $Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
            Write-Verbose -message "[$ScriptName] Set SizeLimit of '$SizeLimit'"
            $Search.SizeLimit = $SizeLimit
            Write-Verbose -message "[$ScriptName] Set Filter '(objectCategory=groupPolicyContainer)'"
            $Search.Filter = "(objectCategory=groupPolicyContainer)"

            IF ($PSBoundParameters['DomainDistinguishedName'])
            {
                Write-Verbose -message "[$ScriptName] DomainDistinguishedName specified = '$DomainDistinguishedName'"
                IF ($DomainDistinguishedName -notlike "LDAP://*") {
                    Write-Verbose -message "[$ScriptName] DomainDistinguishedName notlike 'LDAP://*', prepending LDAP://"
                    $DomainDistinguishedName = "LDAP://$DomainDistinguishedName"
                }#IF
                $Search.SearchRoot = $DomainDistinguishedName
            }
            IF ($PSBoundParameters['Credential'])
            {
                Write-Verbose -message "[$ScriptName] Different Credential specified: '$($credential.username)'"
                $Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
                $Search.SearchRoot = $Cred
            }
            If (-not $PSBoundParameters["SizeLimit"])
            {
                Write-Warning -Message "[$ScriptName] Default SizeLimit: 100 Results"
            }

            Write-Verbose -message "[$ScriptName] Looking for objects..."
            foreach ($GPO in $($Search.FindAll()))
            {
                # Define the properties
                #  The properties need to be lowercase!!!!!!!!
                $Properties = @{
                    adspath                 = $gpo.properties.adspath                 -as [system.string]
                    gpcfunctionalityversion = $gpo.properties.gpcfunctionalityversion -as [system.int32]
                    usnchanged              = $gpo.properties.usnchanged              -as [system.string]
                    showinadvancedviewonly  = $gpo.properties.showinadvancedviewonly  -as [system.string]
                    displayname             = $gpo.properties.displayname             -as [system.string]
                    whencreated             = $gpo.properties.whencreated             -as [System.DateTime]
                    gpcmachineextensionnames= $gpo.properties.gpcmachineextensionnames-as [system.string]
                    instancetype            = $gpo.properties.instancetype            -as [system.string]
                    versionnumber           = $gpo.properties.versionnumber           -as [system.int32]
                    gpcfilesyspath          = $gpo.properties.gpcfilesyspath          -as [system.string]
                    usncreated              = $gpo.properties.usncreated              -as [system.string]
                    flags                   = $gpo.properties.flags                   -as [system.int32]
                    whenchanged             = $gpo.properties.whenchanged             -as [System.DateTime]
                    cn                      = $gpo.properties.cn                      -as [system.string]
                    objectguid              = $gpo.properties.objectguid
                    distinguishedname       = $gpo.properties.distinguishedname       -as [system.string]
                    objectcategory          = $gpo.properties.objectcategory          -as [system.string]
                    iscriticalsystemobject  = $gpo.properties.iscriticalsystemobject  -as [system.string]
                    objectclass             = $gpo.properties.objectclass
                    systemflags             = $gpo.properties.systemflags             -as [system.string]
                    dscorepropagationdata   = $gpo.properties.dscorepropagationdata   -as [system.string]
                    name                    = $gpo.properties.name                    -as [system.string]
                    raw                     = $gpo
                }

                # Output the info
                New-Object -TypeName PSObject -Property $Properties

            }
        }#TRY
        CATCH
        {
            Write-Warning -Message "[$ScriptName] Something wrong happened!"
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }#PROCESS
    END
    {
        Write-Verbose -message "[$ScriptName] End."
    }
}