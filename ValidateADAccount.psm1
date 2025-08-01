function ValidateADAccount {
    <#
    .SYNOPSIS
        Validates AD account data for mandatory fields
    
    .DESCRIPTION
        Validates that required mandatory fields (samaccountname, ad_ou_path) are present
        and not empty. Returns error code 2002 when mandatory fields are missing.
    
    .PARAMETER obj
        Input object containing AD account data in JSON format
    
    .EXAMPLE
        $result = ValidateADAccount -obj $inputJson
        if ($result.returnCode -eq "2002") {
            Write-Host "Missing mandatory fields: $($result.returnText)"
        }
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]$obj
    )
    
    try {
        # Define mandatory fields for AD account validation
        $mandatoryFields = @('samaccountname', 'ad_ou_path')
        $missingFields = @()
        
        # Check if item property exists
        if (-not $obj.PSObject.Properties['item']) {
            return @{
                returnCode = "2002"
                returnText = "Missing mandatory fields: item object not found"
                timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
        
        # Validate each mandatory field
        foreach ($field in $mandatoryFields) {
            $fieldMissing = $false
            
            # Check if field property exists
            if (-not $obj.item.PSObject.Properties[$field]) {
                $fieldMissing = $true
            }
            # Check if field is null
            elseif ($obj.item.$field -eq $null) {
                $fieldMissing = $true
            }
            # Check if field has a value property and it's empty or null
            elseif ($obj.item.$field.PSObject.Properties['value'] -and 
                    ([string]::IsNullOrWhiteSpace($obj.item.$field.value) -or 
                     $obj.item.$field.value -eq $null)) {
                $fieldMissing = $true
            }
            # Check if field is directly a string and is empty
            elseif ($obj.item.$field -is [string] -and [string]::IsNullOrWhiteSpace($obj.item.$field)) {
                $fieldMissing = $true
            }
            
            if ($fieldMissing) {
                $missingFields += $field
            }
        }
        
        # Return error 2002 if any mandatory fields are missing
        if ($missingFields.Count -gt 0) {
            return @{
                returnCode = "2002"
                returnText = "Missing mandatory fields: $($missingFields -join ', ')"
                missingFields = $missingFields
                timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
        
        # Additional validation logic can be added here
        # For now, just validate mandatory fields are present
        
        # If all validations pass, return success
        return @{
            returnCode = "0"
            returnText = "Validation completed successfully"
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            validatedFields = $mandatoryFields
        }
        
    }
    catch {
        # Handle any unexpected errors
        return @{
            returnCode = "9999"
            returnText = "Unexpected error during validation: $($_.Exception.Message)"
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            error = $_.Exception.Message
        }
    }
}

# Helper function to test individual scenarios
function Test-ADAccountValidationScenario {
    <#
    .SYNOPSIS
        Helper function to test specific AD account validation scenarios
    
    .DESCRIPTION
        Creates test scenarios for missing mandatory fields and validates
        that error code 2002 is returned appropriately.
    
    .PARAMETER ScenarioName
        Name of the test scenario to execute
    
    .EXAMPLE
        Test-ADAccountValidationScenario -ScenarioName "MissingSamAccountName"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("MissingSamAccountName", "MissingADOUPath", "MissingBothFields", 
                     "EmptySamAccountName", "EmptyADOUPath", "EmptyItem", "ValidInput")]
        [string]$ScenarioName
    )
    
    # Base test object structure
    $baseObject = @{
        item = @{
            samaccountname = @{ value = "testuser"; type = "string"; mandatory = $true }
            ad_ou_path = @{ value = "OU=Users,DC=example,DC=com"; type = "string"; mandatory = $true }
            first_name = @{ value = "Test"; type = "string"; mandatory = $false }
            last_name = @{ value = "User"; type = "string"; mandatory = $false }
        }
    } | ConvertTo-Json -Depth 10 | ConvertFrom-Json
    
    switch ($ScenarioName) {
        "MissingSamAccountName" {
            $baseObject.item.PSObject.Properties.Remove('samaccountname')
            $expectedCode = "2002"
            $expectedText = "*samaccountname*"
        }
        "MissingADOUPath" {
            $baseObject.item.PSObject.Properties.Remove('ad_ou_path')
            $expectedCode = "2002"
            $expectedText = "*ad_ou_path*"
        }
        "MissingBothFields" {
            $baseObject.item.PSObject.Properties.Remove('samaccountname')
            $baseObject.item.PSObject.Properties.Remove('ad_ou_path')
            $expectedCode = "2002"
            $expectedText = "*samaccountname*ad_ou_path*"
        }
        "EmptySamAccountName" {
            $baseObject.item.samaccountname.value = ""
            $expectedCode = "2002"
            $expectedText = "*samaccountname*"
        }
        "EmptyADOUPath" {
            $baseObject.item.ad_ou_path.value = ""
            $expectedCode = "2002"
            $expectedText = "*ad_ou_path*"
        }
        "EmptyItem" {
            $baseObject.item = [PSCustomObject]@{}
            $expectedCode = "2002"
            $expectedText = "*samaccountname*ad_ou_path*"
        }
        "ValidInput" {
            # Use base object as-is
            $expectedCode = "0"
            $expectedText = "*successfully*"
        }
    }
    
    # Execute the validation
    $result = ValidateADAccount -obj $baseObject
    
    # Verify results
    $testPassed = $true
    if ($result.returnCode -ne $expectedCode) {
        Write-Host "❌ FAILED: Expected return code $expectedCode, got $($result.returnCode)" -ForegroundColor Red
        $testPassed = $false
    }
    
    if ($result.returnText -notlike $expectedText) {
        Write-Host "❌ FAILED: Expected text pattern '$expectedText', got '$($result.returnText)'" -ForegroundColor Red
        $testPassed = $false
    }
    
    if ($testPassed) {
        Write-Host "✅ PASSED: $ScenarioName - Code: $($result.returnCode), Text: $($result.returnText)" -ForegroundColor Green
    }
    
    return @{
        ScenarioName = $ScenarioName
        Passed = $testPassed
        ActualCode = $result.returnCode
        ActualText = $result.returnText
        ExpectedCode = $expectedCode
        ExpectedPattern = $expectedText
    }
}

# Function to run all test scenarios
function Invoke-AllADAccountValidationTests {
    <#
    .SYNOPSIS
        Runs all AD account validation test scenarios
    
    .DESCRIPTION
        Executes all predefined test scenarios to validate that missing
        mandatory fields correctly return error code 2002.
    #>
    
    Write-Host "🧪 Running AD Account Validation Tests - Missing Mandatory Fields (Error 2002)" -ForegroundColor Cyan
    Write-Host "=" * 80 -ForegroundColor Cyan
    
    $scenarios = @(
        "MissingSamAccountName",
        "MissingADOUPath", 
        "MissingBothFields",
        "EmptySamAccountName",
        "EmptyADOUPath",
        "EmptyItem",
        "ValidInput"
    )
    
    $results = @()
    foreach ($scenario in $scenarios) {
        Write-Host "`nTesting: $scenario" -ForegroundColor Yellow
        $result = Test-ADAccountValidationScenario -ScenarioName $scenario
        $results += $result
    }
    
    # Summary
    Write-Host "`n" + "=" * 80 -ForegroundColor Cyan
    Write-Host "📊 Test Summary" -ForegroundColor Cyan
    Write-Host "=" * 80 -ForegroundColor Cyan
    
    $passed = ($results | Where-Object { $_.Passed }).Count
    $total = $results.Count
    
    Write-Host "Tests Passed: $passed/$total" -ForegroundColor White
    
    if ($passed -eq $total) {
        Write-Host "✅ ALL TESTS PASSED - Error 2002 correctly returned for missing mandatory fields" -ForegroundColor Green
    } else {
        Write-Host "❌ SOME TESTS FAILED" -ForegroundColor Red
        $failed = $results | Where-Object { -not $_.Passed }
        foreach ($fail in $failed) {
            Write-Host "   - $($fail.ScenarioName): Expected $($fail.ExpectedCode), got $($fail.ActualCode)" -ForegroundColor Red
        }
    }
    
    return $results
}

# Export functions
Export-ModuleMember -Function ValidateADAccount, Test-ADAccountValidationScenario, Invoke-AllADAccountValidationTests