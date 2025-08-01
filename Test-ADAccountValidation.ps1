#Requires -Version 5.1

<#
.SYNOPSIS
    AD Account Validation Test Suite
    Tests for missing mandatory fields: samaccountname, ad_ou_path
    Expected error code: 2002

.DESCRIPTION
    This PowerShell script validates AD account data for mandatory fields.
    When mandatory fields are missing, it should return error code 2002.

.PARAMETER TestCase
    Specific test case to run (optional). If not specified, runs all tests.

.EXAMPLE
    .\Test-ADAccountValidation.ps1
    Runs all test cases

.EXAMPLE
    .\Test-ADAccountValidation.ps1 -TestCase "MissingSamAccountName"
    Runs specific test case
#>

param(
    [string]$TestCase = $null
)

# Custom exception class for AD account validation errors
class ADAccountValidationError : System.Exception {
    [int]$ErrorCode
    [string]$ErrorMessage
    
    ADAccountValidationError([int]$errorCode, [string]$message) : base("Error $errorCode`: $message") {
        $this.ErrorCode = $errorCode
        $this.ErrorMessage = $message
    }
}

# AD Account Validator class
class ADAccountValidator {
    static [string[]]$MandatoryFields = @('samaccountname', 'ad_ou_path')
    static [int]$ErrorMissingMandatoryFields = 2002
    
    static [bool] ValidateADAccount([hashtable]$AccountData) {
        $missingFields = @()
        
        # Check for missing mandatory fields
        foreach ($field in [ADAccountValidator]::MandatoryFields) {
            if (-not $AccountData.ContainsKey($field) -or 
                [string]::IsNullOrEmpty($AccountData[$field]) -or 
                $AccountData[$field] -eq $null) {
                $missingFields += $field
            }
        }
        
        if ($missingFields.Count -gt 0) {
            $errorMessage = "Missing mandatory fields: $($missingFields -join ', ')"
            throw [ADAccountValidationError]::new([ADAccountValidator]::ErrorMissingMandatoryFields, $errorMessage)
        }
        
        return $true
    }
}

# Test case runner function
function Invoke-TestCase {
    param(
        [string]$TestName,
        [hashtable]$AccountData,
        [bool]$ShouldPass = $false
    )
    
    Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
    Write-Host "TEST CASE: $TestName" -ForegroundColor Cyan
    Write-Host "$('=' * 60)" -ForegroundColor Cyan
    Write-Host "Input data: $($AccountData | ConvertTo-Json -Compress)" -ForegroundColor White
    Write-Host "Expected: $(if ($ShouldPass) { 'PASS' } else { 'FAIL with error 2002' })" -ForegroundColor White
    
    try {
        $result = [ADAccountValidator]::ValidateADAccount($AccountData)
        if ($ShouldPass) {
            Write-Host "✓ RESULT: PASSED - Validation successful" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ RESULT: UNEXPECTED PASS - Should have failed with error 2002" -ForegroundColor Red
            return $false
        }
    }
    catch [ADAccountValidationError] {
        if (-not $ShouldPass -and $_.Exception.ErrorCode -eq 2002) {
            Write-Host "✓ RESULT: FAILED AS EXPECTED - Error $($_.Exception.ErrorCode): $($_.Exception.ErrorMessage)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ RESULT: UNEXPECTED ERROR - Error $($_.Exception.ErrorCode): $($_.Exception.ErrorMessage)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ RESULT: UNEXPECTED EXCEPTION - $($_.Exception.GetType().Name): $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main test function
function Start-ADValidationTests {
    param([string]$SpecificTest = $null)
    
    Write-Host "AD ACCOUNT VALIDATION TEST SUITE" -ForegroundColor Yellow
    Write-Host "Testing for missing mandatory fields: samaccountname, ad_ou_path" -ForegroundColor Yellow
    Write-Host "Expected error code for failures: 2002" -ForegroundColor Yellow
    
    $testResults = @()
    $testCases = @{}
    
    # Define all test cases
    $testCases["ValidADAccount"] = @{
        Name = "Valid AD Account"
        Data = @{
            samaccountname = "jdoe"
            ad_ou_path = "OU=Users,OU=IT,DC=company,DC=com"
            first_name = "John"
            last_name = "Doe"
            email = "jdoe@company.com"
        }
        ShouldPass = $true
    }
    
    $testCases["MissingSamAccountName"] = @{
        Name = "Missing samaccountname"
        Data = @{
            ad_ou_path = "OU=Users,OU=IT,DC=company,DC=com"
            first_name = "Jane"
            last_name = "Smith"
            email = "jsmith@company.com"
        }
        ShouldPass = $false
    }
    
    $testCases["MissingADOUPath"] = @{
        Name = "Missing ad_ou_path"
        Data = @{
            samaccountname = "bwilson"
            first_name = "Bob"
            last_name = "Wilson"
            email = "bwilson@company.com"
        }
        ShouldPass = $false
    }
    
    $testCases["MissingBothMandatoryFields"] = @{
        Name = "Missing both samaccountname and ad_ou_path"
        Data = @{
            first_name = "Alice"
            last_name = "Johnson"
            email = "ajohnson@company.com"
            department = "HR"
        }
        ShouldPass = $false
    }
    
    $testCases["EmptySamAccountName"] = @{
        Name = "Empty samaccountname"
        Data = @{
            samaccountname = ""
            ad_ou_path = "OU=Users,OU=IT,DC=company,DC=com"
            first_name = "Chris"
            last_name = "Brown"
        }
        ShouldPass = $false
    }
    
    $testCases["NullADOUPath"] = @{
        Name = "Null ad_ou_path"
        Data = @{
            samaccountname = "mgreen"
            ad_ou_path = $null
            first_name = "Mary"
            last_name = "Green"
        }
        ShouldPass = $false
    }
    
    $testCases["EmptyAccountData"] = @{
        Name = "Empty account data"
        Data = @{}
        ShouldPass = $false
    }
    
    $testCases["OnlyOptionalFields"] = @{
        Name = "Only optional fields"
        Data = @{
            first_name = "David"
            last_name = "Lee"
            email = "dlee@company.com"
            department = "Finance"
            manager = "manager@company.com"
            phone = "555-0123"
        }
        ShouldPass = $false
    }
    
    # Run specific test case or all test cases
    if ($SpecificTest) {
        if ($testCases.ContainsKey($SpecificTest)) {
            $case = $testCases[$SpecificTest]
            $testResults += Invoke-TestCase -TestName $case.Name -AccountData $case.Data -ShouldPass $case.ShouldPass
        } else {
            Write-Host "Test case '$SpecificTest' not found. Available test cases:" -ForegroundColor Red
            $testCases.Keys | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
            return
        }
    } else {
        # Run all test cases
        foreach ($key in $testCases.Keys) {
            $case = $testCases[$key]
            $testResults += Invoke-TestCase -TestName $case.Name -AccountData $case.Data -ShouldPass $case.ShouldPass
        }
    }
    
    # Test summary
    Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
    Write-Host "TEST SUMMARY" -ForegroundColor Cyan
    Write-Host "$('=' * 60)" -ForegroundColor Cyan
    
    $passed = ($testResults | Where-Object { $_ -eq $true }).Count
    $total = $testResults.Count
    
    Write-Host "Tests passed: $passed/$total" -ForegroundColor White
    
    if ($passed -eq $total) {
        Write-Host "✓ ALL TESTS PASSED" -ForegroundColor Green
    } else {
        Write-Host "✗ SOME TESTS FAILED" -ForegroundColor Red
    }
    
    Write-Host "`nNote: Tests that 'fail with error 2002' are expected failures" -ForegroundColor Yellow
    Write-Host "and count as successful test cases when they fail as expected." -ForegroundColor Yellow
}

# Export functions for module usage
Export-ModuleMember -Function Start-ADValidationTests, Invoke-TestCase
Export-ModuleMember -Class ADAccountValidator, ADAccountValidationError

# Main execution
if ($MyInvocation.InvocationName -ne '.') {
    Start-ADValidationTests -SpecificTest $TestCase
}