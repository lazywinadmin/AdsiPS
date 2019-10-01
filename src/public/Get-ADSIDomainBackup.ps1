function Get-ADSIDomainBackup {
<#
.SYNOPSIS
    Function to retrieve last backup for each partitions of a given domain

.DESCRIPTION
    Function to retrieve last backup for each partitions of a given domain.
    It look at the dsaSignature for each naming context.
    dsaSignature attribute change after a succesfull backup

.PARAMETER Credential
    Specifies alternative credential to use

.PARAMETER DomainName
    Specifies the DomainName to query

.EXAMPLE
    get-ADSIDomainBackup

    Retrieve Backup information for the current domain

.EXAMPLE
    get-ADSIDomainBackup -DomainName mytest.local

    Retrieve Backup information for the domain mytest.local

.EXAMPLE
    get-ADSIDomainBackup -Credential (Get-Credential superAdmin) -Verbose

    Retrieve Backup information for the current domain with the specified credential.

.EXAMPLE
    get-ADSIDomainBackup -DomainName mytest.local -Credential (Get-Credential superAdmin) -Verbose

    Retrieve Backup information for the domain mytest.local with the specified credential.

.NOTES
    https://github.com/lazywinadmin/ADSIPS

.OUTPUTS
    'Ps'


#>
    [cmdletbinding()]
    [OutputType('pscustomobject[]')]
    param (
        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        $DomainName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().name
    )



    process {
        try {



            if ($PSBoundParameters['Credential']){
                $ContextObject = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext($ContextObjectType, $DomainName, $Credential.UserName, $Credential.GetNetworkCredential().password)
            } else {
                $ContextObjectType = [System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain
            }



            $DomainControlerObject = [System.DirectoryServices.ActiveDirectory.DomainController]::findOne($ContextObject)

            $ActiveDirectoryPartitions = $DomainControlerObject.Partitions
            Write-Verbose -Message "Found Active Directory Partitions $ActiveDirectoryPartitions"
            $ArrayListBackupInfo = [System.Collections.ArrayList]::new()

            foreach ($partition in $ActiveDirectoryPartitions) {

                Write-Verbose -Message "[PROCESS] for the Partition $partition"
                $ActiveDirectoryPartitionMetaData = $domainController.GetReplicationMetadata($partition)
                $DsaSignatureAtribute = $ActiveDirectoryPartitionMetaData.item("dsaSignature")
                $LastBackupDate = $DsaSignatureAtribute.LastOriginatingChangeTime.DateTime

                $PartitionBackupInfo =   [pscustomobject]@{
                    PartitionName=$partition
                    BackupDateTime=$LastBackupDate
                }

                [void]$ArrayListBackupInfo.Add($PartitionBackupInfo)
            }

            return $ArrayListBackupInfo

        }
        catch {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
    end
    {
        Write-Verbose -Message "[$FunctionName] Done"
    }

}