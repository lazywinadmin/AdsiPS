Describe "Get-ADSIUser" -Tags 'User' {
	Context "Query One" {

        $result = Get-ADSIUser -Identity Administrator

        It "test1" {
            #(-join $result) | Should Be $true
            $result | Should Be $true
        }
    }

    Context "Query Multiple" {

        $result = Get-ADSIUser

        It "test2" {
            #(-join $result) | Should Be $true
            $result.count | Should BeGreaterThan 1
        }
    }
    Context "Be of Type" {

        $result = Get-ADSIUser -Identity Administrator

        It "test3" {
            #(-join $result) | Should Be $true
            $result | Should BeOfType [System.DirectoryServices.AccountManagement.UserPrincipal]
        }
    }
}