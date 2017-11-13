function Set-ADSIUser
{
<#
.SYNOPSIS
	This function modifies an account identified by its display name, sam account name or distinguished name.

.DESCRIPTION
	This function modifies an account identified by its display name, sam account name or distinguished name.

.PARAMETER Identity
	Specify the Identity of the accounts to modify.

    The Identity can either be (in order of resolution attempt):
        A SAM account name
        An object SID
        A distinguished name

.PARAMETER Country
	Specify the country name. This parameter sets the co property of a user.

.PARAMETER Description
	Specify the description. This parameter sets the description property of a user.

.PARAMETER DisplayName
	Specify the display name. This parameter sets the DisplayName property of a user.

.PARAMETER Location
	Specify the location name. This parameter sets the l property of a user.

.PARAMETER Mail
	Specify the mail address. This parameter sets the mail property of a user.

.PARAMETER Manager
	Specify the manager. This parameter sets the manager property of a user.
    The manager must be specified as a SAM account name.

.PARAMETER PostalCode
	Specify the postal code name. This parameter sets the postalCode property of a user.

.PARAMETER SamAccountName
	Specify the Sam account name. This parameter sets the sAMAccountName property of a user.

.PARAMETER UserPrincipalName
	Specify the UserPrincipalName. This parameter sets the UserPrincipalName property of a user.
.PARAMETER TelephoneNumber
    Specify the Telephone number
.PARAMETER DomainDN
    Specify the Domain Distinguished name
.PARAMETER Credential
    Specify alternative Credential
.EXAMPLE
    Set-ADSIUSer -Identity micky -UserPrincipalName micky@contoso.com -confirm:$false -SamAccountName mickyballadelli

    Changes the UPN and SAM account name of an account without confirmation popup

.EXAMPLE
    Set-ADSIUSer -identity micky -Country France

    Changes the Country value of the account micky


.NOTES
	Micky Balladelli
	github.com/lazywinadmin/AdsiPS
#>
	[CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
	PARAM (
		[Parameter(Mandatory = $true)]
		[String]$Identity,

		[Parameter(Mandatory = $false)]
		[string]$Country,

		[Parameter(Mandatory = $false)]
		[string]$Description,

		[Parameter(Mandatory = $false)]
		[string]$DisplayName,

		[Parameter(Mandatory = $false)]
		[string]$Location,

		[Parameter(Mandatory = $false)]
		[string]$Mail,

		[Parameter(Mandatory = $false)]
		[string]$Manager,

		[Parameter(Mandatory = $false)]
		[string]$PostalCode,

		[Parameter(Mandatory = $false)]
		[String]$SamAccountName,

		[Parameter(Mandatory = $false)]
		[String]$TelephoneNumber,

		[Parameter(Mandatory = $false)]
		[string]$UserPrincipalName,

        [Alias("Domain", "DomainDN")]
		[String]$DomainName = $(([adsisearcher]"").Searchroot.path),

		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
    BEGIN
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement

        # Create Context splatting
        $ContextSplatting = @{ ContextType = "Domain" }

        IF ($PSBoundParameters['Credential']) { $ContextSplatting.Credential = $Credential }
        IF ($PSBoundParameters['DomainName']) { $ContextSplatting.DomainName = $DomainName }

        $Context = New-ADSIPrincipalContext @ContextSplatting
    }
	PROCESS
	{
		TRY
		{
            $DirectoryEntryParams = $ContextSplatting
            $DirectoryEntryParams.remove('ContextType')
            $DirectoryEntry = New-ADSIDirectoryEntry @DirectoryEntryParams

            # Principal Searcher
            $Search = new-object -TypeName System.DirectoryServices.DirectorySearcher
            $Search.SizeLimit = 2
            $Search.SearchRoot = $DirectoryEntry

			# Resolve the Object
		    $Search.filter = "(&(objectCategory=person)(objectClass=User)(samaccountname=$Identity))"
			$user = $Search.FindAll()
			IF ($user.Count -eq 0)
			{
    		    $Search.filter = "(&(objectCategory=person)(objectClass=User)(objectsid=$Identity))"
	    		$user = $Search.FindAll()
            }
			IF ($user.Count -eq 0)
			{
    		    $Search.filter = "(&(objectCategory=person)(objectClass=User)(distinguishedname=$Identity))"
    			$user = $Search.FindAll()
            }
            IF ($user.Count -eq 0)
			{
                $Search.filter = "(&(objectCategory=person)(objectClass=User)(UserPrincipalName=$Identity))"
    			$user = $Search.FindAll()
            }

			IF ($user.Count -eq 1)
			{
				$Account = $user.Properties.samaccountname -as [string]
				$adspath = $($user.Properties.adspath -as [string]) -as [ADSI]

                # Country
                if ($Country -ne '')
                {
                    Write-Verbose -Message "[$($Account)] Setting Country value to : $Country"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set Country of account $account to $Country"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting Country of account $account to $Country" -Verbose:$true
                        }
                        else
                        {
                            $Adspath.Put("co", $Country)
                            $Adspath.SetInfo()
                        }
                    }
                }

                # Description
                if ($Description -ne '')
                {
                    Write-Verbose -Message "[$($Account)] Setting Description value to : $Description"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set Description of account $account to $Description"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting Description of account $account to $Description" -Verbose:$true
                        }
                        else
                        {
                            $Adspath.Put("description", $Description)
                            $Adspath.SetInfo()
                        }
                    }
                }

                # DisplayName
                if ($DisplayName -ne '')
                {
                    Write-Verbose -Message "[$($Account)] Setting Country value to : $DisplayName"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set DisplayName of account $account to $DisplayName"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting DisplayName of account $account to $DisplayName" -Verbose:$true
                        }
                        else
                        {
                            $Adspath.Put("displayName", $DisplayName)
                            $Adspath.SetInfo()
                        }
                    }
                }

                # Location
                if ($Location -ne '')
                {
                    Write-Verbose -Message "[$($Account)] Setting Location value to : $Location"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set Location of account $account to $Location"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting Location of account $account to $Location" -Verbose:$true
                        }
                        else
                        {
                            $Adspath.Put("l", $Location)
                            $Adspath.SetInfo()
                        }
                    }
                }

                # Mail
                if ($Mail -ne '')
                {
                    Write-Verbose -Message "[$($Account)] Setting Mail value to : $Mail"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set Mail of account $account to $Mail"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting Mail of account $account to $Mail" -Verbose:$true
                        }
                        else
                        {
                            $Adspath.Put("mail", $Mail)
                            $Adspath.SetInfo()
                        }
                    }
                }

                # Manager
                if ($Manager -ne '')
                {
                    Write-Verbose -Message "[$($Account)] Setting Manager value to : $Manager"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set Manager of account $account to $Manager"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting Manager of account $account to $Manager" -Verbose:$true
                        }
                        else
                        {
                            $Search.filter = "(&(objectCategory=person)(objectClass=User)(samaccountname=$Manager))"
			                $user = $Search.FindOne()

                            $Adspath.Put("manager", ($user.properties.distinguishedname -as [string]))
                            $Adspath.SetInfo()
                        }
                    }
                }

                # PostalCode
                if ($PostalCode -ne '')
                {
                    Write-Verbose -Message "[$($Account)] Setting Location value to : $PostalCode"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set PostalCode of account $account to $PostalCode"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting Location of account $account to $PostalCode" -Verbose:$true
                        }
                        else
                        {
                            $Adspath.Put("postalCode", $PostalCode)
                            $Adspath.SetInfo()
                        }
                    }
                }

                # TelephoneNumber
                if ($TelephoneNumber -ne '')
                {
                    Write-Verbose -Message "[$($Account)] Setting SamAccountName value to : $TelephoneNumber"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set TelephoneNumber of account $account to $TelephoneNumber"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting TelephoneNumber of account $account to $TelephoneNumber" -Verbose:$true
                        }
                        else
                        {
                            $Adspath.Put("telephoneNumber", $TelephoneNumber)
                            $Adspath.SetInfo()
                        }
                    }
                }
                # SAM Account Name
                if ($SamAccountName -ne '')
                {
                    Write-Verbose -Message "[$($Account)] Setting SamAccountName value to : $SamAccountName"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set SamAccountName of account $account to $SamAccountName"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting SamAccountName of account $account to $SamAccountName" -Verbose:$true
                        }
                        else
                        {
                            $Adspath.Put("sAMAccountName", $SamAccountName)
                            $Adspath.SetInfo()
                        }
                    }
                }

                # UserPrincipalName
                if ($UserPrincipalName -ne '')
                {
                    Write-Verbose -Message "[$($Account)] Setting UPN value to : $UserPrincipalName"

                    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Set UPN of account $account to $UserPrincipalName"))
                    {
                        if ($PSBoundParameters.ContainsKey('WhatIf'))
                        {
                            Write-Verbose -Message "WhatIf: Setting UPN of account $account to $UserPrincipalName" -Verbose:$true
                        }
                        else
                        {
                            $Adspath.Put("UserPrincipalName", $UserPrincipalName)
                            $Adspath.SetInfo()
                        }
                    }
                }

			}
			ELSEIF ($user.Count -gt 1)
			{
                Write-Warning -Message "[Set-ADSIUser] Identity $identity is not unique"
            }
            ELSEIF ($Search.FindAll().Count -eq 0)
            {
                Write-Warning -Message "[Set-ADSIUser] Account $identity not found"
            }

		}#TRY
		CATCH
		{
			$pscmdlet.ThrowTerminatingError($_)
		}
	}#PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Set-ADSIUser End."
	}
}
