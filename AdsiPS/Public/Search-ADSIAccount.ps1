Function Search-ADSIAccount
{
    <#
.SYNOPSIS
    Function to retrieve AD accounts from differents filters

.DESCRIPTION
    Function to retrieve AD accounts from differents filters

.PARAMETER Credential
    Specifies alternative credential

.PARAMETER DomainName
    Specifies the Domain Name where the function should look

.PARAMETER DomainDistinguishedName
    Specifies the DistinguishedName of the Domain to query   

.PARAMETER SizeLimit
    Specify the number of item(s) to output (1 to 1000)
    Use NoResultLimit for more than 1000 objects

.PARAMETER NoResultLimit
    Remove the SizeLimit of 1000
    Warning : can take time! it depends on the number of objects in your domain
    NoResultLimit parameter override SizeLimit parameter 

.EXAMPLE
    Search-ADSIAccount -Users -AccountNeverLogged

    Get all not disabled user accounts that have never logged

.EXAMPLE
    Search-ADSIAccount -Users -AccountNeverLogged -PasswordNeverExpire

    Get all not disabled user accounts that have never logged in and whose password never expires

.EXAMPLE
    Search-ADSIAccount -Users -AccountNeverLogged -ChangePassword

    Get all not disabled user accounts that have never logged in and need to change their password

.EXAMPLE
    Search-ADSIAccount -Users -AccountDisabled

    Get all disabled user accounts

.EXAMPLE
    Search-ADSIAccount -Users -PasswordNeverExpires

    Get all not disabled user accounts whose password never expire

.EXAMPLE
    Search-ADSIAccount -Users -AccountExpired

    Get all not disabled user accounts that have expired

.EXAMPLE
    Search-ADSIAccount -Users -AccountExpiring -Days 10

    Get all not disabled user accounts that will expire within the next 10 days.

    Valide Range : 1 to 365
    Default expiration : 30 Days

.EXAMPLE
    Search-ADSIAccount -Users -PasswordExpired

    Get all not disabled user accounts whose password has expired and are not disabled

.EXAMPLE
    Search-ADSIAccount -Users -AccountNeverExpire

    Get all not disabled user accounts that never expire
    

.EXAMPLE
    Search-ADSIAccount -Users -AccountDisabled -SizeLimit 10
    
    Get only 10 user accounts disabled
    
    Default AD limit :1000

.EXAMPLE
    Search-ADSIAccount -Users -AccountDisabled -NoResultLimit
    
    Remove the default AD limit of 1000 objects returned, in example the search is about disabled user accounts
    
.EXAMPLE
    Search-ADSIAccount -Users -AccountDisabled -Credential (Get-Credential)
    
    Use a different credential to perform the search, in example the search is about disabled user accounts
    
.EXAMPLE
    Search-ADSIAccount -Users -AccountDisabled -DomainName "CONTOSO.local"

    Use a different domain name to perform the search, in example the search is about disabled user accounts

.EXAMPLE
    Search-ADSIAccount -Users -AccountDisabled -DomainDistinguishedName 'DC=CONTOSO,DC=local'

    Use a different domain distinguished name to perform the search, in example the search is about disabled user accounts

.NOTES
    Christophe Kumor
    https://christophekumor.github.io 

    github.com/lazywinadmin/ADSIPS
#>
    
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'uAccountInactive', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountNeverExpire', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uPasswordExpired', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountExpiring', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountExpired', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uPasswordNeverExpires', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountDisabled', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountNeverLoggedChangePassword', Mandatory = $true)] 
        [Parameter(ParameterSetName = 'uAccountNeverLoggedPasswordNeverExpire', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountNeverLogged', Mandatory = $true)]
        [switch]$Users,
        
        [Parameter(ParameterSetName = 'cAccountInactive', Mandatory = $true)]
        [Parameter(ParameterSetName = 'cAccountNeverExpire', Mandatory = $true)]
        [Parameter(ParameterSetName = 'cPasswordExpired', Mandatory = $true)]
        [Parameter(ParameterSetName = 'cAccountExpiring', Mandatory = $true)]
        [Parameter(ParameterSetName = 'cAccountExpired', Mandatory = $true)]
        [Parameter(ParameterSetName = 'cPasswordNeverExpires', Mandatory = $true)]
        [Parameter(ParameterSetName = 'cAccountDisabled', Mandatory = $true)]
        [Parameter(ParameterSetName = 'cAccountNeverLogged', Mandatory = $true)]
        [switch]$Computers,
        
        [Parameter(ParameterSetName = 'cAccountNeverLogged', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountNeverLoggedChangePassword', Mandatory = $true)] 
        [Parameter(ParameterSetName = 'uAccountNeverLoggedPasswordNeverExpire', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountNeverLogged', Mandatory = $true)]
        [switch]$AccountNeverLogged,

        [Parameter(ParameterSetName = 'uAccountNeverLoggedChangePassword', Mandatory = $true)] 
        [switch]$ChangePassword,

        [Parameter(ParameterSetName = 'uAccountNeverLoggedPasswordNeverExpire', Mandatory = $true)]
        [switch]$PasswordNeverExpire,

        [Parameter(ParameterSetName = 'cAccountDisabled', Mandatory = $true)]        
        [Parameter(ParameterSetName = 'uAccountDisabled', Mandatory = $true)]
        [switch]$AccountDisabled,

        [Parameter(ParameterSetName = 'cPasswordNeverExpires', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uPasswordNeverExpires', Mandatory = $true)]
        [switch]$PasswordNeverExpires,

        [Parameter(ParameterSetName = 'cAccountExpired', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountExpired', Mandatory = $true)]
        [switch]$AccountExpired,

        [Parameter(ParameterSetName = 'cAccountExpiring', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountExpiring', Mandatory = $true)]
        [switch]$AccountExpiring,

        [Parameter(ParameterSetName = 'cAccountInactive', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountInactive', Mandatory = $true)]
        [switch]$AccountInactive,

        [Parameter(ParameterSetName = 'cAccountInactive')]
        [Parameter(ParameterSetName = 'uAccountInactive')]
        [Parameter(ParameterSetName = 'cAccountExpiring')]
        [Parameter(ParameterSetName = 'uAccountExpiring')]
        [ValidateRange(1, 365)]
        [int]$Days = 30,

        [Parameter(ParameterSetName = 'cPasswordExpired', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uPasswordExpired', Mandatory = $true)]
        [switch]$PasswordExpired,

        [Parameter(ParameterSetName = 'cAccountNeverExpire', Mandatory = $true)]
        [Parameter(ParameterSetName = 'uAccountNeverExpire', Mandatory = $true)]
        [switch]$AccountNeverExpire,

        [Alias('ResultLimit', 'Limit')]
        [ValidateRange(1, 1000)]
        [int]$SizeLimit = 100,
        
        [Alias('RunAs')]
        [pscredential]
        [System.Management.Automation.Credential()]
        $Credential = [pscredential]::Empty,

        [Alias('Domain')]
        [ValidateScript( { if ($_ -match '^(?:(?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$') {$true} else {throw "DomainName must be FQDN. Ex: contoso.locale - Hostname like '$_' is not working"} })]
        [String]$DomainName,
        
        [Alias('DomainDN', 'SearchRoot', 'SearchBase')]
        [String]$DomainDistinguishedName = $(([adsisearcher]'').Searchroot.path),
        
        [Switch]$NoResultLimit

        
    )
    BEGIN
    {
        $FunctionName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).Mycommand
    }
    PROCESS
    { 
        $Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
   

        IF ($PSBoundParameters['DomainName'])
        {
            $DomainDistinguishedName = "LDAP://DC=$($DomainName.replace('.', ',DC='))"
             
            Write-Verbose -Message "[$FunctionName] Current Domain: $DomainDistinguishedName"

        }
        ELSEIF ($PSBoundParameters['DomainDistinguishedName'])
        {
            IF ($DomainDistinguishedName -notlike 'LDAP://*') 
            { 
                $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" 
            }
            Write-Verbose -Message "[$FunctionName] Different Domain specified: $DomainDistinguishedName"

        }

        $Search.SearchRoot = $DomainDistinguishedName

        IF ($PSBoundParameters['Credential'])
        {
            $Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
            $Search.SearchRoot = $Cred
        }


        Write-Verbose -Message ('ParameterSetName : {0}' -f $PSCmdlet.ParameterSetName)
     
        IF ($PSBoundParameters['Computers']) 
        {
            $type = 'computer'
        }
        ELSE
        {
            $type = 'user'
        }
                 
        SWITCH -wildcard ($PSCmdlet.ParameterSetName) 
        {
    
            '?AccountNeverLogged' 
            {
                #Never logged and must change password and not disabled
                $Search.Filter = "(&(objectCategory=$type)(objectClass=$type)(lastLogon=0)(!lastLogonTimestamp=*)(!userAccountControl:1.2.840.113556.1.4.803:=2))"
                break

            }

            '?AccountNeverLoggedChangePassword' 
            {
                #Never logged and must change password and not disabled
                $Search.Filter = "(&(objectCategory=$type)(objectClass=$type)(pwdLastSet=0)(lastLogon=0)(!lastlogontime‌​stamp=*)(!userAccountControl:1.2.840.113556.1.4.803:=2))"
                break

            }

            '?AccountNeverLoggedPasswordNeverExpire' 
            {

                #Never loged and password never expire and not disabled
                $Search.Filter = "(&(objectCategory=$type)(objectClass=$type)(userAccountControl:1.2.840.113556.1.4.803:=65536)(lastLogon=0)(!lastlogontime‌​stamp=*)(!userAccountControl:1.2.840.113556.1.4.803:=2))"
                break

            }
        
            '?AccountDisabled' 
            {
                #Disabled
                $Search.Filter = "(&(objectCategory=$type)(objectClass=$type)(userAccountControl:1.2.840.113556.1.4.803:=2))"
                break

            }
        
            '?PasswordNeverExpires' 
            {
                #Password never expire and not disabled
                $Search.Filter = "(&(objectCategory=$type)(objectClass=$type)(userAccountControl:1.2.840.113556.1.4.803:=65536)(!userAccountControl:1.2.840.113556.1.4.803:=2))"
                break

            }
        
            '?AccountExpired' 
            {
                #Account expired and not disabled
                $date = (Get-Date).ToFileTime()
                $Search.Filter = "(&(objectCategory=$type)(objectClass=$type)(accountExpires<=$date)(!accountExpires=0)(!userAccountControl:1.2.840.113556.1.4.803:=2))"
                break

            }
        
            '?AccountExpiring' 
            {
                #Account expiring in x days and not disabled
                #Attention : Account set to expire on 22/05/2017, attribute is set to 23/05/2017 00:00 or 22:00 

                Write-Verbose -Message "[$FunctionName] Show accounts expiring between now and $Days day(s)"

                $Now = Get-Date
                $start = $Now.ToFileTime()
                $end = ($Now.Adddays($Days)).ToFileTime() 

                $Search.Filter = "(&(objectCategory=$type)(objectClass=$type)(accountExpires>=$start)(accountExpires<=$end)(!userAccountControl:1.2.840.113556.1.4.803:=2))"
                break

            }
        
            '?AccountInactive' 
            {
                #Account Inactive and not disabled
                #Returns all accounts that have been inactive for more than X days.

                Write-Verbose -Message "[$FunctionName] Show inactive accounts for more than $Days day(s)"

                $Now = Get-Date
                $start = ($Now.Adddays( - $Days)).ToFileTime() 

                $Search.Filter = "(&(objectCategory=$type)(objectClass=$type)(lastLogonTimestamp<=$start)(!userAccountControl:1.2.840.113556.1.4.803:=2))"
                break

            }
        
            '?PasswordExpired' 
            {
                #PASSWORD Expired and account not disabled 
                #Rule : User must be connected at least one time to be in the result

                $Search.Filter = "(&(objectCategory=$type)(objectClass=$type)(pwdLastSet=0)(!(userAccountControl:1.2.840.113556.1.4.803:=65536)(!userAccountControl:1.2.840.113556.1.4.803:=2))(|(lastLogon>=1)(lastLogonTimestamp>=1)))"
                break

            }
        
            '?AccountNeverExpire' 
            {
                #Account never expire and account not disabled
                $Search.Filter = "(&(objectCategory=$type)(objectClass=$type)(accountExpires=0)(!userAccountControl:1.2.840.113556.1.4.803:=2))"
                break

            }
        
            Default 
            {
                Write-Verbose -Message "[$FunctionName] unknown ParameterSetName"
                return

            }
        }


        IF (-not$PSBoundParameters['NoResultLimit']) 
        {
            Write-warning -Message "Result is limited to $SizeLimit entries, specify a specific number (1-1000) on the parameter SizeLimit or use -NoResultLimit switch to remove the limit"
        
            $Search.SizeLimit = $SizeLimit
        }
        ELSE 
        {
            Write-Verbose -Message "[$FunctionName] Use NoResultLimit switch, all objects will be returned. no limit"
        
            $Search.PageSize = 10000
        }
 
        $Search.FindAll()
    }
    END {}
}