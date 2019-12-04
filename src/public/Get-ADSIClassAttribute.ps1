function Get-ADSIClassAttribute
{
<#
.SYNOPSIS
    Function to retrieve the Attributes available for a class in
    Active Directory.

.DESCRIPTION
    This function is mostly a wrapper around the Get-ADSISchema Cmdlet.

.PARAMETER PropertyType
    Specify the type of property to return.
    Alias 'AttributeType'

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
    Get-ADSIClassAttribute -PropertyType Mandatory -ClassName user

.NOTES
    https://github.com/lazywinadmin/ADSIPS
#>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param
    (
        [Parameter(ParameterSetName = 'Default',
            Mandatory = $true)]
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
            if ($PSBoundParameters['Credential'] -or $PSBoundParameters['ForestName'])
            {
                Write-Verbose -Message '[PROCESS] Credential or ForestName specified'
                $Splatting = @{ }
                if ($PSBoundParameters['Credential'])
                {
                    $Splatting.Credential = $Credential
                }
                if ($PSBoundParameters['ForestName'])
                {
                    $Splatting.ForestName = $ForestName
                }

                $SchemaContext = New-ADSIDirectoryContext @splatting -contextType Forest
                $schema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetSchema($SchemaContext)
            }
            else
            {
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
            $schema.FindAllClasses().Name
        }
        if ($PSBoundParameters['FindClassName'])
        {
            $schema.FindAllClasses() | Where-Object -FilterScript { $_.name -match $FindClassName } | Select-Object -Property Name
        }

        else
        {

            switch ($PropertyType)
            {
                "mandatory"
                {
                    ($schema.FindClass("$ClassName")).MandatoryProperties
                }
                "optional"
                {
                    ($schema.FindClass("$ClassName")).OptionalProperties
                }
            }#switch
        }#else

    }#process
}