<#
.Synopsis
    Pester test to verify the content of the manifest and the documentation of each functions.
.Description
    Pester test to verify the content of the manifest and the documentation of each functions.
#>
[CmdletBinding()]
PARAM(
$ModuleName = "ADSIPS",
$GithubRepository = "github.com/lazywinadmin/"
)

# Make sure one or multiple versions of the module are note loaded
Get-Module -Name $ModuleName | remove-module

# Find the Manifest file
$ManifestFile = "$(Split-path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))\$ModuleName\$ModuleName.psd1"

# Import the module and store the information about the module
$ModuleInformation = Import-module -Name $ManifestFile -PassThru

# Get the functions present in the Manifest
$ExportedFunctions = $ModuleInformation.ExportedFunctions.Values.name

# Get the functions present in the Public folder
$PS1Functions = Get-ChildItem -path "$(Split-path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))\$ModuleName\public\*.ps1"



Describe "$ModuleName Module - Testing Manifest File (.psd1)"{

    Context 'Module Version'{'Loaded Version vs Get-Command return for the module'}
    Context 'Manifest'{
        It 'Should contains RootModule'{$ModuleInformation.RootModule|Should not BeNullOrEmpty}
        It 'Should contains Author'{$ModuleInformation.Author|Should not BeNullOrEmpty}
        It 'Should contains Company Name'{$ModuleInformation.CompanyName|Should not BeNullOrEmpty}
        It 'Should contains Description'{$ModuleInformation.Description|Should not BeNullOrEmpty}
        It 'Should contains Copyright'{$ModuleInformation.Copyright|Should not BeNullOrEmpty}
        It 'Should contains License'{$ModuleInformation.LicenseURI|Should not BeNullOrEmpty}
        It 'Should contains a Project Link'{$ModuleInformation.ProjectURI|Should not BeNullOrEmpty}
        It 'Should contains a Tags (For the PSGallery)'{$ModuleInformation.Tags.count|Should not BeNullOrEmpty}

        It 'Should have equal number of Function Exported and the PS1 files found'{
            $ExportedFunctions.count -eq $PS1Functions.count |Should BeGreaterthan 0}
        It "Compare the missing function"{
            if (-not($ExportedFunctions.count -eq $PS1Functions.count)){
                $Compare = Compare-Object -ReferenceObject $ExportedFunctions -DifferenceObject $PS1Functions.basename
                $Compare.inputobject -join ',' |
                Should BeNullOrEmpty
            }
        }
    }
}


# Testing the Module
Describe "$ModuleName Module - HELP" -Tags "Module" {
    #$Commands = (get-command -Module ADSIPS).Name

    FOREACH ($c in $ExportedFunctions)
    {
        $Help = Get-Help -Name $c -Full
        $Notes = ($Help.alertSet.alert.text -split '\n')
        $FunctionContent = Get-Content function:$c
        $AST = [System.Management.Automation.Language.Parser]::ParseInput($FunctionContent, [ref]$null, [ref]$null)

        Context "$c - Help"{

                It "Synopsis"{$help.Synopsis| Should not BeNullOrEmpty}
                It "Description"{$help.Description| Should not BeNullOrEmpty}
                #It "Notes - Author" {$Notes[0].trim()| Should Be "Francois-Xavier Cat"}
                #It "Notes - Site" {$Notes[1].trim()| Should Be "Lazywinadmin.com"}
                #It "Notes - Twitter" {$Notes[2].trim()| Should Be "@lazywinadm"}
                #It "Notes - Github" {$Notes[3].trim() | Should Be "github.com/lazywinadmin"}
                It "Notes - Github Project" {$Notes -contains "$GithubRepository$ModuleName" | Should Be $true}

                # Get the parameters declared in the Comment Based Help
                #  minus the RiskMitigationParameters
                $RiskMitigationParameters = 'Whatif', 'Confirm'
                $HelpParameters = $help.parameters.parameter | Where-Object name -NotIn $RiskMitigationParameters

                # Parameter Count VS AST Parameter
                $ASTParameters = $ast.ParamBlock.Parameters.Name.variablepath.userpath
                It "Parameter - Compare Count Help/AST" {
                    $HelpParameters.name.count -eq $ASTParameters.count | Should Be $true}

                # Parameters Description
                $HelpParameters| ForEach-Object {
                    It "Parameter $($_.Name) - Should contains description"{
                        $_.description | Should not BeNullOrEmpty
                    }
                }

                # Parameters separated by a space
                $ParamText=$ast.ParamBlock.extent.text -split '\r\n' # split on return
                $ParamText=$ParamText.trim()
                $ParamTextSeparator=$ParamText |select-string ',$' #line that finish by a ','

                if($ParamTextSeparator)
                {
                    Foreach ($ParamLine in $ParamTextSeparator.linenumber)
                    {
                        it "Parameter - Separated by space (Line $ParamLine)"{
                            #$ParamText[$ParamLine] -match '\s+' | Should Be $true
                            $ParamText[$ParamLine] -match '^$|\s+' | Should Be $true
                        }
                    }
                }


                # Examples
                it "Example - Count should be greater than 0"{
                    $Help.examples.example.code.count | Should BeGreaterthan 0
                    $Help.examples | Should not BeNullOrEmpty
                }

                # Validate Help start at the beginning of the line
                #(((get-content .\public\Get-ADSIForestDomain.ps1)) |select-string '.Synopsis') -match "^$($_.pattern)"
                #it "Help - Starts at the beginning of the line"{
                #    $Pattern = "\.Synopsis"
                #    ($FunctionContent -split '\r\n'|select-string $Pattern).line -match "^$Pattern" | Should Be $true
                #}



            <#
                # Testing the Examples
                $help.examples.example[0].code
                $help.examples.example[0].introduction
                $help.examples.example[0].remarks
                $help.examples.example[0].title

                $help.examples.example[0].code
                $help.examples.example[0].introduction
                $help.examples.example[0].remarks
                $help.examples.example[0].title


                $help.parameters.parameter[0].defaultValue
                $help.parameters.parameter[0].description
                $help.Name
                $help.ModuleName

                $help.description
                $help.syntax
                $help.'xmlns:command'

                # AST
                # Parameters
                $ast = [System.Management.Automation.Language.Parser]::ParseInput((Get-Content function:Get-ADSIUser), [ref]$null, [ref]$null)
                $ast.ParamBlock.Parameters.Name.variablepath.userpath #without the S
                $ast.ParamBlock.Parameters.Name.Extent.Text # with the $


                # CmdletBinding
                $ast.ParamBlock.attributes.typename.fullname


                # check each help keyword for indent
                # check space between help keyword
                # check no text pass the 80 characters
                # check PARAM is upper case
                # Check help keywords are upper.
                # check you have outputs
                # check you have [outputType()]
                # check for error handling
                # check for some verbose
                # check does not use accelerator in PARAM()
                # parameters in AST and Help are matching (same name)
                # PARAM() no type defined on a property
            #>
        }
    }
}
