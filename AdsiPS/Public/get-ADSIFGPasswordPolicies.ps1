function Get-ADSIFGPassWordPolicy
{
<#
.SYNOPSIS
	This function will query and list Fine-Grained Password Policies in Active Directory

.DESCRIPTION
	This function will query and list Fine-Grained Password Policies in Active Directory

.PARAMETER  PolicyName
	Specify the name of the policy to retreive
	
.PARAMETER Credential
    Specify the Credential to use

.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.EXAMPLE
	Get-ADSIFGPassWordPolicy 
    Retreive all the password policy on the current domain

.EXAMPLE
	get-ADSIFGPasswordPolicies -Name Name
    Retreive the password policy nammed 'Name' on the current domain
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
	Olivier Miossec
	@omiossec_med
#>
	


    [CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "Name")]
		[String]$Name,
			
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



	BEGIN { } 

	PROCESS
	{
		TRY
		{
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDistinguishedName
			$Search.filter = "(objectclass=msDS-PasswordSettings)"
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
				Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}

					foreach ($Object in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"Name" = $Object.properties.name -as [string]
					"PasswordHistorylength" = $Object.Properties.Item("msds-passwordhistorylength") -as [string]
					"MinimumPasswordLength" = $Object.Properties.Item("msds-minimumpasswordlength") -as [string]
					"passwordreversibleencryptionenabled" = $Object.Properties.Item("msds-passwordreversibleencryptionenabled") -as [string]
					"minimumpasswordage" = $Object.Properties.Item("msds-minimumpasswordage") -as [string]
					"passwordcomplexityenabled" = $Object.Properties.Item("msds-passwordcomplexityenabled") -as [string]
					"passwordsettingsprecedence" = $Object.Properties.Item("msds-passwordsettingsprecedence") -as [string]
					"lockoutduration" = $Object.Properties.Item("msds-lockoutduration") -as [string]
					"lockoutobservationwindow" = $Object.Properties.Item("msds-lockoutobservationwindow") -as [string]
					"lockoutthreshold" = $Object.Properties.Item("msds-lockoutthreshold") -as [string]
					"psoappliesto" = $Object.Properties.Item("msds-psoappliesto") -as [string]
					"WhenCreated" = $Object.properties.whencreated -as [string]
					"WhenChanged" = $Object.properties.whenchanged -as [string]
				}
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			}

		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIFGPassWordPolicy End."
	}
}