function Get-ADSIClass
{
<#
.SYNOPSIS
    Find all the object classes available in the current or
    specified Active Directory forest.

.DESCRIPTION
    This function is mostly a wrapper around Get-ADSISchema.

.PARAMETER ClassName
    Specify the name of the Class to retrieve

.PARAMETER AllClasses
    This will list all the property present in the domain.
    This parameter is the default one and is hidden.

.PARAMETER ForestName
    Specifies the Forest name

.PARAMETER Credential
    Specifies alternative credential to use

.EXAMPLE
    Get-ADSIClass

    Retrieve all the Class available in the forest

.EXAMPLE
    Get-ADSIClass -ClassName user

    Retrieve the 'user' class.

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding(DefaultParameterSetName = 'AllClass')]
    param
    (
        [Parameter(ParameterSetName = 'ClassName',
            Mandatory = $false)]
        [String]$ClassName,

        [Parameter(DontShow=$true,ParameterSetName = 'AllClasses',
            Mandatory = $false)]
        [Switch]$AllClasses,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        $ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
    )
    process{
        if($ClassName){
            Get-ADSISchema @PSBoundParameters
        }else{
            Get-ADSISchema @PSBoundParameters -AllClasses
        }
    }
}