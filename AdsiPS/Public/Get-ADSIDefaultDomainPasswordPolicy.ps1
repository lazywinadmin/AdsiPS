Function Get-ADSIDefaultDomainPasswordPolicy {
<#
.SYNOPSIS
	Function to retrieve default Domain Password Policy

.DESCRIPTION
	Function to retrieve default Domain Password Policy

.PARAMETER Credential
	Specifies alternative credential

.PARAMETER DomainName
	Specifies the Domain to use

.PARAMETER DomainDistinguishedName
    Specifies the DistinguishedName of the Domain to query

.EXAMPLE
	Get-ADSIDefaultDomainPasswordPolicy

.EXAMPLE
	Get-ADSIDefaultDomainPasswordPolicy -Credential (Get-Credential)

.EXAMPLE
	Get-ADSIDefaultDomainPasswordPolicy -DomainName "CONTOSO.local"

.EXAMPLE
    Get-ADSIDefaultDomainPasswordPolicy -DomainDistinguishedName 'DC=CONTOSO,DC=local'

.OUTPUTS
	DomainMinimumPasswordAge
        specifies the minimum amount of time that a password can be used
        Unit : days
    
        EXAMPLE
        minPwdAge         : 3 days
    
    DomainMaximumPasswordAge
        specifies the maximum amount of time that a password is valid
        Unit : days

        EXAMPLE
        maxPwdAge         : 180 days

    DomainMinimumPasswordLength
        specifies the minimum number of characters that a password has to contain
    
        EXAMPLE
        minPwdLength      : 8 

    DomainPasswordHistoryLength 
        specifies the number of old passwords to save
    
        EXAMPLE
        pwdHistoryLength  : 5

    PasswordProperties
        Part of Domain Policy. A bitfield to indicate complexity and storage restrictions. 
    
        EXAMPLE
        pwdProperties : 1 DOMAIN_PASSWORD_COMPLEX : The server enforces password complexity policy
                        2 DOMAIN_PASSWORD_NO_ANON_CHANGE : Reserved. No effect on password policy
                        4 DOMAIN_PASSWORD_NO_CLEAR_CHANGE : Change-password methods that provide the cleartext password are disabled by the server
                        8 DOMAIN_LOCKOUT_ADMINS : Reserved. No effect on password policy
                        16 DOMAIN_PASSWORD_STORE_CLEARTEXT : The server MUST store the cleartext password, not just the computed hashes
                        32 DOMAIN_REFUSE_PASSWORD_CHANGE : Reserved. No effect on password policy
    
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
		[ValidateScript({ if ($_ -match "^(?:(?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$") {$true} else {throw "DomainName must be FQDN. Ex: contoso.locale - Hostname like '$_' is not working"} })]
		[String]$DomainName,
		
		[Alias("DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path)
	)

	BEGIN {	}
	PROCESS
	{
			
        	IF ($PSBoundParameters['DomainName'])
			{
				$DomainDistinguishedName = "LDAP://DC=$($DomainName.replace(".", ",DC="))"
             
                Write-Verbose -Message "Current Domain: $DomainDistinguishedName"

			}
			ELSEIF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") 
				{ 
					$DomainDistinguishedName = "LDAP://$DomainDistinguishedName" 
				}
					Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"

			}

			IF ($PSBoundParameters['Credential'])
			{
				$DomainAccount = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
			
			}
            ELSE {

                $DomainAccount = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName
            }

				
				$Properties = @{
                    "minPwdAge" = ($DomainAccount.ConvertLargeIntegerToInt64($DomainAccount.'minPwdAge'[0]) / -864000000000) -as [int]
					"maxPwdAge" = ($DomainAccount.ConvertLargeIntegerToInt64($DomainAccount.'maxPwdAge'[0]) / -864000000000) -as [int]
					"minPwdLength" = $DomainAccount.minPwdLength -as [int]
                    "pwdHistoryLength" = $DomainAccount.pwdHistoryLength -as [int]
                    "pwdProperties" = Switch ($DomainAccount.pwdProperties) {
                                  1 {"DOMAIN_PASSWORD_COMPLEX : The server enforces password complexity policy"; break} 
                                  2 {"DOMAIN_PASSWORD_NO_ANON_CHANGE : Reserved. No effect on password policy"; break} 
                                  4 {"DOMAIN_PASSWORD_NO_CLEAR_CHANGE : Change-password methods that provide the cleartext password are disabled by the server"; break} 
                                  8 {"DOMAIN_LOCKOUT_ADMINS : Reserved. No effect on password policy"; break}
                                  16 {"DOMAIN_PASSWORD_STORE_CLEARTEXT : The server MUST store the cleartext password, not just the computed hashes."; break}
                                  32 {"DOMAIN_REFUSE_PASSWORD_CHANGE : Reserved. No effect on password policy"; break}
                                  Default {$DomainAccount.pwdProperties}}
				}
				New-Object -TypeName psobject -Property $Properties
                    
	}

}