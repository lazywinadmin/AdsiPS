PARAM(
$ModuleName = "ADSIPS"
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

    Context "Module Version"{
        "Loaded Version vs Get-Command return for the module"

    }

    Context "Manifest"{
        It "Should contains RootModule"{
            $ModuleInformation.RootModule|Should not BeNullOrEmpty
        }

        It "Should contains Author"{$ModuleInformation.Author|Should not BeNullOrEmpty}
        It "Should contains Company Name"{$ModuleInformation.CompanyName|Should not BeNullOrEmpty
        }
        It "Should contains Description"{
            $ModuleInformation.Description|Should not BeNullOrEmpty
        }
        It "Should contains Copyright"{
            $ModuleInformation.Copyright|Should not BeNullOrEmpty
        }
        It "Should contains License"{
            $ModuleInformation.LicenseURI|Should not BeNullOrEmpty
        }
        It "Should contains a Project Link"{
            $ModuleInformation.ProjectURI|Should not BeNullOrEmpty
        }
        It "Should contains a Tags (For the PSGallery)"{
            $ModuleInformation.Tags.count|Should not BeNullOrEmpty
        }

        It "Compare the count of Function Exported and the PS1 files found"{
            $ExportedFunctions.count -eq $PS1Functions.count |
            Should BeGreaterthan 0
        }
        It "Compare the missing function"{
            if (-not($ExportedFunctions.count -eq $PS1Functions.count)){
                $Compare = Compare-Object -ReferenceObject $ExportedFunctions -DifferenceObject $PS1Functions.basename
                $Compare.inputobject -join ',' |
                Should BeNullOrEmpty
            }
        }
    }
}

Describe "$ModuleName Module - HELP" -Tags "Module" {
    $Commands = (get-command -Module ADSIPS).Name

    FOREACH ($c in $Commands)
    {
        $Help = Get-Help -Name $c -Full
        $Notes = ($Help.alertSet.alert.text -split '\n')
        $AST = [System.Management.Automation.Language.Parser]::ParseInput((Get-Content function:$c), [ref]$null, [ref]$null)

	    Context "$c - Help"{
			
                It "Synopsis"{$help.Synopsis| Should not BeNullOrEmpty}
                It "Description"{$help.Description| Should not BeNullOrEmpty}
                It "Notes - Author" {$Notes[0].trim()| Should Be "Francois-Xavier Cat"}
                It "Notes - Site" {$Notes[1].trim()| Should Be "Lazywinadmin.com"}
                It "Notes - Twitter" {$Notes[2].trim()| Should Be "@lazywinadm"}
                It "Notes - Github" {$Notes[3].trim() | Should Be "github.com/lazywinadmin"}

                #$help.note| Should not BeNullOrEmpty
                

                $HelpParameters = $help.parameters.parameter
                $ASTParameters = $ast.ParamBlock.Parameters.Name.variablepath.userpath
                It "Parameter - Compare Count Help/AST" {
                    $HelpParameters.count -eq $ASTParameters.count | Should Be $true}

                $help.parameters.parameter| ForEach-Object {
                    It "Parameter $($_.Name) - Should contains description"{
                        $_.description | Should not BeNullOrEmpty
                    }
                }

                it "Example - Count should be greater than 0"{
                    $Help.examples.example.code.count | Should BeGreaterthan 0
                }



			    $Help.examples | Should not BeNullOrEmpty
			    $Help.Details | Should not BeNullOrEmpty
			    $Help.Description | Should not BeNullOrEmpty
            
                $help.parameters.parameter| ForEach-Object {
                    $_.description | Should not BeNullOrEmpty
                
                }

            
			    #$Help.
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
		
		    #>
	    }
    }
}
