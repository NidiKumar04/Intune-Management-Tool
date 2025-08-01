Import-Module "$PSScriptRoot\..\Libraries\CZ_Interface.psm1" -Force
Import-Module "$PSScriptRoot\..\Libraries\Powershell_AD_Functions\ValidateADAccount.psm1" -Force

Describe 'ValidateADAccount - Input Validation' {
    
    Context 'Missing Mandatory Fields - Should Return Error 2002' {
        
        BeforeAll {
            $jsonPath = "$PSScriptRoot\..\TestData\Powershell_AD\ValidateADAccount\ValidateADAccount.json"
            $inputJson = Get-Content $jsonPath -Raw | ConvertFrom-Json
        }
        
        It 'Should return error 2002 when samaccountname is missing' {
            # Modify the loaded JSON to simulate missing samaccountname field
            $testInput = $inputJson.PSObject.Copy()
            $testInput.item.samaccountname = $null
            
            $result = ValidateADAccount -obj $testInput
            $result.returnCode | Should Be "2002"
            $result.returnText | Should Match "Missing mandatory fields.*samaccountname"
        }
        
        It 'Should return error 2002 when ad_ou_path is missing' {
            # Modify the loaded JSON to simulate missing ad_ou_path field
            $testInput = $inputJson.PSObject.Copy()
            $testInput.item.ad_ou_path = $null
            
            $result = ValidateADAccount -obj $testInput
            $result.returnCode | Should Be "2002"
            $result.returnText | Should Match "Missing mandatory fields.*ad_ou_path"
        }
        
        It 'Should return error 2002 when both mandatory fields are missing' {
            # Modify the loaded JSON to simulate missing both mandatory fields
            $testInput = $inputJson.PSObject.Copy()
            $testInput.item.samaccountname = $null
            $testInput.item.ad_ou_path = $null
            
            $result = ValidateADAccount -obj $testInput
            $result.returnCode | Should Be "2002"
            $result.returnText | Should Match "Missing mandatory fields.*samaccountname.*ad_ou_path"
        }
        
        It 'Should return error 2002 when samaccountname is empty string' {
            # Modify the loaded JSON to simulate empty samaccountname
            $testInput = $inputJson.PSObject.Copy()
            $testInput.item.samaccountname.value = ""
            
            $result = ValidateADAccount -obj $testInput
            $result.returnCode | Should Be "2002"
            $result.returnText | Should Match "Missing mandatory fields.*samaccountname"
        }
        
        It 'Should return error 2002 when ad_ou_path is empty string' {
            # Modify the loaded JSON to simulate empty ad_ou_path
            $testInput = $inputJson.PSObject.Copy()
            $testInput.item.ad_ou_path.value = ""
            
            $result = ValidateADAccount -obj $testInput
            $result.returnCode | Should Be "2002"
            $result.returnText | Should Match "Missing mandatory fields.*ad_ou_path"
        }
        
        It 'Should return error 2002 when samaccountname property does not exist' {
            # Modify the loaded JSON to remove samaccountname property entirely
            $testInput = $inputJson.PSObject.Copy()
            $testInput.item.PSObject.Properties.Remove('samaccountname')
            
            $result = ValidateADAccount -obj $testInput
            $result.returnCode | Should Be "2002"
            $result.returnText | Should Match "Missing mandatory fields.*samaccountname"
        }
        
        It 'Should return error 2002 when ad_ou_path property does not exist' {
            # Modify the loaded JSON to remove ad_ou_path property entirely
            $testInput = $inputJson.PSObject.Copy()
            $testInput.item.PSObject.Properties.Remove('ad_ou_path')
            
            $result = ValidateADAccount -obj $testInput
            $result.returnCode | Should Be "2002"
            $result.returnText | Should Match "Missing mandatory fields.*ad_ou_path"
        }
        
        It 'Should return error 2002 when item object is completely empty' {
            # Modify the loaded JSON to simulate empty item object
            $testInput = $inputJson.PSObject.Copy()
            $testInput.item = [PSCustomObject]@{}
            
            $result = ValidateADAccount -obj $testInput
            $result.returnCode | Should Be "2002"
            $result.returnText | Should Match "Missing mandatory fields.*samaccountname.*ad_ou_path"
        }
    }
    
    Context 'Valid Input - Should Pass Validation' {
        
        It 'Should complete successfully with all mandatory fields present' {
            $jsonPath = "$PSScriptRoot\..\TestData\Powershell_AD\ValidateADAccount\ValidateADAccount.json"
            $inputJson = Get-Content $jsonPath -Raw | ConvertFrom-Json
            
            # Ensure all mandatory fields are present and valid
            $inputJson.item.samaccountname.value = "testuser123"
            $inputJson.item.ad_ou_path.value = "OU=Users,OU=IT,DC=company,DC=com"
            
            $result = ValidateADAccount -obj $inputJson
            $result.returnCode | Should Be "0"
            $result.returnText | Should Match "Validation completed successfully"
        }
    }
}