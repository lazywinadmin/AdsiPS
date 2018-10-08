Function Get-ADSIDefaultDomainPasswordPolicy {
    <#
    .SYNOPSIS
        Function to retrieve default Domain Password Policy

    .DESCRIPTION
        Function to retrieve default Domain Password Policy

    .PARAMETER Credential
        Specifies the alternative credential to use.
        By default it will use the current user windows credentials.

    .PARAMETER DomainName
        Specifies the alternative Domain where the user should be created
        By default it will use the current domain.

    .EXAMPLE
        Get-ADSIDefaultDomainPasswordPolicy

    .EXAMPLE
        Get-ADSIDefaultDomainPasswordPolicy -Credential (Get-Credential)

    .EXAMPLE
        Get-ADSIDefaultDomainPasswordPolicy -DomainName "CONTOSO.local"

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

            [String]$DomainName
        )

        BEGIN
        {
            $DirectoryEntryParams = @{}

            IF ($PSBoundParameters['Credential']) { $DirectoryEntryParams.Credential = $Credential }
            IF ($PSBoundParameters['DomainName']) { $DirectoryEntryParams.DomainName = $DomainName }
        }
        PROCESS
        {
            $DirectoryEntry = New-ADSIDirectoryEntry @DirectoryEntryParams

            $Properties = @{
                "minPwdAge" = ($DirectoryEntry.ConvertLargeIntegerToInt64($DirectoryEntry.'minPwdAge'[0]) / -864000000000) -as [int]
                "maxPwdAge" = ($DirectoryEntry.ConvertLargeIntegerToInt64($DirectoryEntry.'maxPwdAge'[0]) / -864000000000) -as [int]
                "minPwdLength" = $DirectoryEntry.minPwdLength.value
                "pwdHistoryLength" = $DirectoryEntry.pwdHistoryLength.value
                "pwdProperties" = Switch ($DirectoryEntry.pwdProperties) {
                                1 {"DOMAIN_PASSWORD_COMPLEX : The server enforces password complexity policy"; break}
                                2 {"DOMAIN_PASSWORD_NO_ANON_CHANGE : Reserved. No effect on password policy"; break}
                                4 {"DOMAIN_PASSWORD_NO_CLEAR_CHANGE : Change-password methods that provide the cleartext password are disabled by the server"; break}
                                8 {"DOMAIN_LOCKOUT_ADMINS : Reserved. No effect on password policy"; break}
                                16 {"DOMAIN_PASSWORD_STORE_CLEARTEXT : The server MUST store the cleartext password, not just the computed hashes."; break}
                                32 {"DOMAIN_REFUSE_PASSWORD_CHANGE : Reserved. No effect on password policy"; break}
                                Default {$DirectoryEntry.pwdProperties}}
            }

            New-Object -TypeName psobject -Property $Properties
        }
    }