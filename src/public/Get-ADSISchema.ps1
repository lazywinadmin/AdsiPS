function Get-ADSISchema
{
<#
.SYNOPSIS
    The Get-ADSISchema function gather information about the current Active Directory Schema

.DESCRIPTION
    The Get-ADSISchema function gather information about the current Active Directory Schema

.PARAMETER PropertyType
    Specify the type of property to return

.PARAMETER ClassName
    Specify the name of the Class to retrieve

.PARAMETER AllClasses
    This will list all the property present in the domain

.PARAMETER FindClassName
    Specify the exact or partial name of the class to search

.PARAMETER ForestName
    Specifies the Forest name

.PARAMETER Credential
    Specifies alternative credential to use

.EXAMPLE
    Get-ADSISchema -PropertyType Mandatory -ClassName user

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param
    (
        [Parameter(ParameterSetName = 'Default',
            Mandatory = $false)]
        [ValidateSet("mandatory", "optional")]
        [String]$PropertyType,

        [Parameter(ParameterSetName = 'Default',
            Mandatory = $true)]
        [String]$ClassName,

        [Parameter(ParameterSetName = 'AllClasses',
            Mandatory = $true)]
        [Switch]$AllClasses,

        [Parameter(ParameterSetName = 'FindClasses',
            Mandatory = $true)]
        [String]$FindClassName,

        [Alias("RunAs")]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        $ForestName = [System.DirectoryServices.ActiveDirectory.Forest]::Getcurrentforest()
    )

    begin
    {
        try
        {
            $FunctionName = (Get-Variable -Name MyInvocation -ValueOnly -Scope 0).MyCommand
            if ($PSBoundParameters['Credential'] -or $PSBoundParameters['ForestName'])
            {
                Write-Verbose -Message "[$FunctionName] Credential or ForestName specified"
                $Splatting = @{ }
                if ($PSBoundParameters['Credential'])
                {
                    Write-Verbose -Message "[$FunctionName] Set Credential"
                    $Splatting.Credential = $Credential
                }
                if ($PSBoundParameters['ForestName'])
                {
                    Write-Verbose -Message "[$FunctionName] Set ForestName"
                    $Splatting.ForestName = $ForestName
                }

                $SchemaContext = New-ADSIDirectoryContext @splatting -contextType Forest
                Write-Verbose -Message "[$FunctionName] Get Schema for forest '$forestName'"
                $schema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetSchema($SchemaContext)
            }
            else
            {
                Write-Verbose -Message "[$FunctionName] Get Current Schema"
                $schema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
            }
        }
        catch
        {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }

    process
    {
        if ($PSBoundParameters['AllClasses'])
        {
            Write-Verbose -Message "[$FunctionName] Retrieving all classes..."
            $schema.FindAllClasses()
        }elseif ($PSBoundParameters['FindClassName'])
        {
            Write-Verbose -Message "[$FunctionName] Looking up for class pattern '$FindClassName'"
            $schema.FindAllClasses() | Where-Object -FilterScript { $_.name -match $FindClassName }
        }elseif ($PropertyType -and $ClassName)
        {
            switch ($PropertyType)
            {
                "mandatory"
                {
                    Write-Verbose -Message "[$FunctionName] Retrieving MandatoryProperties for class '$ClassName'"
                    ($schema.FindClass("$ClassName")).MandatoryProperties
                }
                "optional"
                {
                    Write-Verbose -Message "[$FunctionName] Retrieving OptionalProperties for class '$ClassName'"
                    ($schema.FindClass("$ClassName")).OptionalProperties
                }
            }#switch
        }elseif (-not $propertyType -and $ClassName){
            Write-Verbose -Message "[$FunctionName] Retrieving class '$ClassName'"
            $schema.FindClass("$ClassName")
        }
    }#process
}