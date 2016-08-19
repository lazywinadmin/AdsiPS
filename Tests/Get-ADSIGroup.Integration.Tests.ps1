Describe "Get-ADSIGroup" -Tags 'Group' {
    Context "Query One" {

        $result = Get-ADSIGroup -Identity 'Domain Admins'

        It "test1" {
            #(-join $result) | Should Be $true
            $result | Should Be $true
        }
    }
    Context "Query Multiple" {

        $result = Get-ADSIGroup

        It "test2" {
            #(-join $result) | Should Be $true
            $result.count | Should BeGreaterThan 1
        }
    }
    Context "Be of Type" {

        $result = Get-ADSIGroup -Identity "Domain Admins"

        It "test3" {
            #(-join $result) | Should Be $true
            $result | Should BeOfType [System.DirectoryServices.AccountManagement.GroupPrincipal]
        }
    }
}
