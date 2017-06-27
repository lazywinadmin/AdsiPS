Function Get-ADSIDefaultDomainAccountLockout
{
    <#
.SYNOPSIS
	Function to retrieve default Domain Account Lockout Policy

.DESCRIPTION
	Function to retrieve default Domain Account Lockout Policy

.PARAMETER Credential
	Specifies alternative credential

.PARAMETER DomainName
	Specifies the Domain Name where the function should look

.PARAMETER DomainDistinguishedName
    Specifies the DistinguishedName of the Domain to query    

.EXAMPLE
	Get-ADSIDefaultDomainAccountLockout

.EXAMPLE
	Get-ADSIDefaultDomainAccountLockout -Credential (Get-Credential)

.EXAMPLE
	Get-ADSIDefaultDomainAccountLockout -DomainName "CONTOSO.local"

.EXAMPLE
    Get-ADSIDefaultDomainAccountLockout -DomainDistinguishedName 'DC=CONTOSO,DC=local'

.OUTPUTS
    LockoutDuration
        This attribute specifies the lockout duration for locked-out user accounts
        Unit : minutes

        EXAMPLE
        lockoutDuration          : 10 minutes

    LockoutObservationWindow
        This attribute specifies the observation window for lockout of user accounts.
        Unit : minutes

        EXAMPLE
        lockoutObservationWindow : 10 minutes

    LockoutThreshold
        This attribute specifies the lockout threshold for lockout of user accounts.

        EXAMPLE
        lockoutThreshold         : 7

.NOTES
	Christophe Kumor
	https://christophekumor.github.io

	github.com/lazywinadmin/ADSIPS
#>
	
    [CmdletBinding()]
    param
    (
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Alias("Domain")]
        [ValidateScript( { if ($_ -match "^(?:(?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$") {$true} else {throw "DomainName must be FQDN. Ex: contoso.locale - Hostname like '$_' is not working"} })]
        [String]$DomainName,
		
        [Alias("DomainDN")]
        [String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path)
    )

    BEGIN
    {	
        $FunctionName = (Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).Mycommand
    }
    PROCESS
    {
			
        IF ($PSBoundParameters['DomainName'])
        {
            $DomainDistinguishedName = "LDAP://DC=$($DomainName.replace(".", ",DC="))"
             
            Write-Verbose -Message "[$FunctionName] Current Domain: $DomainDistinguishedName"

        }
        ELSEIF ($PSBoundParameters['DomainDistinguishedName'])
        {
            IF ($DomainDistinguishedName -notlike "LDAP://*") 
            { 
                $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" 
            }
            Write-Verbose -Message "[$FunctionName] Different Domain specified: $DomainDistinguishedName"

        }

        IF ($PSBoundParameters['Credential'])
        {
            $DomainAccount = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
			
        }
        ELSE
        {

            $DomainAccount = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName
        }

				
        $Properties = @{
            "lockoutDuration"          = ($DomainAccount.ConvertLargeIntegerToInt64($DomainAccount.'lockoutDuration'[0]) / -600000000) -as [int]
            "lockoutObservationWindow" = ($DomainAccount.ConvertLargeIntegerToInt64($DomainAccount.'lockoutObservationWindow'[0]) / -600000000) -as [int]
            "lockoutThreshold"         = $DomainAccount.lockoutThreshold -as [int]
        }
        New-Object -TypeName psobject -Property $Properties
    }

}