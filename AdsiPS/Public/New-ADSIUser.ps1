Function New-ADSIUser
{
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$true)]
    [String]$SamAccountName,
    [String]$Password,
    [switch]$Enabled = $false,
    [String]$GivenName,
    [String]$SurName,
    [String]$UserPrincipalName,
    [String]$DisplayName,
    [String]$Name,
    [Switch]$PasswordNeverExpires=$false,
    [Switch]$UserCannotChangePassword=$false,
    [Switch]$PasswordNotRequired=$false,
    [Alias("RunAs")]
	[System.Management.Automation.Credential()]
	$Credential = [System.Management.Automation.PSCredential]::Empty,
    [String]$DomainName,
    [Switch]$Passthru

)
    BEGIN{
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
        # Create Context splatting
        $ContextSplatting=@{ ContextType = "Domain" }

		IF ($PSBoundParameters['Credential']){$ContextSplatting.Credential = $Credential}
        IF ($PSBoundParameters['DomainName']){$ContextSplatting.DomainName = $DomainName}
        
        $Context = New-ADSIPrincipalContext @ContextSplatting

        #GeneratePassword
    }
    PROCESS
    {
        TRY
        {
	        ## create the user object
	        $User = New-Object -TypeName System.DirectoryServices.AccountManagement.UserPrincipal -ArgumentList $context
	
	        ## set the properties
            $User.SamAccountName = $SamAccountName
            $User.Enabled = $Enabled
            $user.PasswordNeverExpires = $PasswordNeverExpires
            $user.UserCannotChangePassword = $UserCannotChangePassword
            $User.PasswordNotRequired = $PasswordNotRequired

	        IF($PSBoundParameters['Name']){$User.Name = $Name}
	        IF($PSBoundParameters['DisplayName']){$User.DisplayName = $DisplayName}
	        IF($PSBoundParameters['GivenName']){$User.GivenName =$GivenName}
	        IF($PSBoundParameters['SurName']){$User.SurName = $SurName}
	        IF($PSBoundParameters['UserPrincipalName']){$User.UserPrincipalName = $UserPrincipalName}
	        #IF($PSBoundParameters['Name']){$User.PasswordNotRequired = $false}
            IF($PSBoundParameters['Description']){$user.Description = $Description}
            IF($PSBoundParameters['EmployeeId']){$user.EmployeeId = $EmployeeId}
            IF($PSBoundParameters['HomeDirectory']){$user.HomeDirectory = $HomeDirectory}
            IF($PSBoundParameters['HomeDrive']){$user.HomeDrive = $HomeDrive}
            IF($PSBoundParameters['MiddleName']){$user.MiddleName = $MiddleName}
            IF($PSBoundParameters['VoiceTelephoneNumber']){$user.VoiceTelephoneNumber}
	        
            
            #$user.AccountExpirationDate
            #$user.ExpirePasswordNow(
            #$user.IsAccountLockedOut()
            #$user.RefreshExpiredPassword()

	        ## Create the User
            $User.SetPassword($Password)
	        $User.Save($Context)
           
        }
        CATCH{
            Write-Error $Error[0]
            break
        }
    }
    END
    {
        IF($PSBoundParameters['Passthru'])
        {
            $ContextSplatting.Remove("ContextType")
            Get-ADSIUser -Identity $SamAccountName @ContextSplatting
        }
    }	
}

New-ADSIUser -SamAccountName "fxtest04" -Enabled -Password "Password1" -Passthru

#convertto-securestring -String "P@ssW0rD!" -asplaintext -force

Test-ADSICredential -AccountName "fxtest04" -Password "Password1"