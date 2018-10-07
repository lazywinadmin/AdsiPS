function Set-ADSIUserExpiration
{
<#

#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$true)]
    $Identity,
    [parameter(Mandatory=$true)]
    [datetime]$ExpirationDateTime,
    [Alias("RunAs")]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty,
    [String]$DomainName)

    BEGIN
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement

        # Create Context splatting
        $ContextSplatting=@{}
        IF ($PSBoundParameters['Credential']){$ContextSplatting.Credential = $Credential}
        IF ($PSBoundParameters['DomainName']){$ContextSplatting.DomainName = $DomainName}

        $Context = New-ADSIPrincipalContext @ContextSplatting -contexttype Domain
    }
    PROCESS
    {
        TRY{
            $([System.Nullable[DateTime]]($ExpirationDateTime))

            #(Get-ADSIUser -Identity $Identity @ContextSplatting).AccountExpirationDate = $($ExpirationDateTime.ToLocalTime())
            #(Get-ADSIUser -Identity $Identity @ContextSplatting).invokeset('AccountExpirationDate',$($ExpirationDateTime.ToLocalTime()))
            #(Get-ADSIUser -Identity $Identity @ContextSplatting).set_AccountExpirationDate($($ExpirationDateTime.ToLocalTime().ToShortDateString()))
            #(Get-ADSIUser -Identity $Identity @ContextSplatting).set_AccountExpirationDate($([System.Nullable[DateTime]]($ExpirationDateTime)))
            (Get-ADSIUser -Identity $Identity @ContextSplatting).AccountExpirationDate =$([System.Nullable[DateTime]]($ExpirationDateTime))
            (Get-ADSIUser -Identity $Identity @ContextSplatting).Save($Context)
        }
        CATCH{
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}

Get-ADSIuser fxtest03
(Get-ADSIuser fxtest03).AccountExpirationDate
Set-ADSIUserExpiration -Identity fxtest03 -ExpirationDateTime $((Get-Date).AddDays(2))
(Get-ADSIuser fxtest03).AccountExpirationDate.HasValue

Get-ADSIuser fxtest03 | gm -Force|where{$_.name -eq 'Set_accountExpirationDate'} | fl *


(Get-Date).ToLocalTime().ToShortDateString()

man Set-ADAccountExpiration


[System.Nullable[DateTime]]((Get-date).AddDays(5))
