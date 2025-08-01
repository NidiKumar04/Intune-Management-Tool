<#
.SYNOPSIS
    Test cases for missing mandatory AD account fields
    Expected result: Error 2002

.DESCRIPTION
    This script tests AD account validation for missing mandatory fields:
    - samaccountname
    - ad_ou_path
    
    All invalid test cases should return error code 2002.

.EXAMPLE
    .\Test-MissingMandatoryFields.ps1
    Runs all test cases for missing mandatory fields
#>

# Function to validate AD account and return appropriate error
function Test-ADAccountValidation {
    param(
        [hashtable]$AccountData
    )
    
    $mandatoryFields = @('samaccountname', 'ad_ou_path')
    $missingFields = @()
    
    # Check for missing mandatory fields
    foreach ($field in $mandatoryFields) {
        if (-not $AccountData.ContainsKey($field) -or 
            [string]::IsNullOrEmpty($AccountData[$field]) -or 
            $AccountData[$field] -eq $null) {
            $missingFields += $field
        }
    }
    
    if ($missingFields.Count -gt 0) {
        # Return error 2002 for missing mandatory fields
        return @{
            Success = $false
            ErrorCode = 2002
            ErrorMessage = "Missing mandatory fields: $($missingFields -join ', ')"
            MissingFields = $missingFields
        }
    }
    
    return @{
        Success = $true
        ErrorCode = $null
        ErrorMessage = $null
        MissingFields = @()
    }
}

# Function to run and display test case results
function Invoke-MandatoryFieldTest {
    param(
        [string]$TestName,
        [hashtable]$TestData,
        [string]$Description
    )
    
    Write-Host "`n" + "="*70 -ForegroundColor Cyan
    Write-Host "TEST: $TestName" -ForegroundColor Yellow
    Write-Host "="*70 -ForegroundColor Cyan
    Write-Host "Description: $Description" -ForegroundColor White
    Write-Host "Input Data:" -ForegroundColor White
    
    if ($TestData.Count -eq 0) {
        Write-Host "  (Empty hashtable)" -ForegroundColor Gray
    } else {
        $TestData.GetEnumerator() | ForEach-Object {
            $value = if ($_.Value -eq $null) { "[NULL]" } elseif ($_.Value -eq "") { "[EMPTY STRING]" } else { $_.Value }
            Write-Host "  $($_.Key): $value" -ForegroundColor Gray
        }
    }
    
    # Run the validation test
    $result = Test-ADAccountValidation -AccountData $TestData
    
    Write-Host "`nResult:" -ForegroundColor White
    if ($result.Success) {
        Write-Host "  ✗ UNEXPECTED SUCCESS - Validation should have failed!" -ForegroundColor Red
        return $false
    } else {
        Write-Host "  ✓ FAILED AS EXPECTED" -ForegroundColor Green
        Write-Host "  Error Code: $($result.ErrorCode)" -ForegroundColor Green
        Write-Host "  Error Message: $($result.ErrorMessage)" -ForegroundColor Green
        
        if ($result.ErrorCode -eq 2002) {
            Write-Host "  ✓ CORRECT ERROR CODE (2002)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  ✗ WRONG ERROR CODE - Expected 2002, got $($result.ErrorCode)" -ForegroundColor Red
            return $false
        }
    }
}

# Function to test valid case
function Invoke-ValidCaseTest {
    Write-Host "`n" + "="*70 -ForegroundColor Cyan
    Write-Host "TEST: Valid AD Account (Control Test)" -ForegroundColor Yellow
    Write-Host "="*70 -ForegroundColor Cyan
    Write-Host "Description: Valid account with all mandatory fields present" -ForegroundColor White
    
    $validData = @{
        samaccountname = "testuser"
        ad_ou_path = "OU=Users,DC=example,DC=com"
        first_name = "Test"
        last_name = "User"
        email = "testuser@example.com"
    }
    
    Write-Host "Input Data:" -ForegroundColor White
    $validData.GetEnumerator() | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Gray
    }
    
    $result = Test-ADAccountValidation -AccountData $validData
    
    Write-Host "`nResult:" -ForegroundColor White
    if ($result.Success) {
        Write-Host "  ✓ SUCCESS - Validation passed as expected" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ✗ UNEXPECTED FAILURE - Valid data should have passed!" -ForegroundColor Red
        Write-Host "  Error: $($result.ErrorMessage)" -ForegroundColor Red
        return $false
    }
}

# Main test execution
Write-Host "AD ACCOUNT VALIDATION - MISSING MANDATORY FIELDS TEST SUITE" -ForegroundColor Magenta
Write-Host "Testing for missing mandatory fields: samaccountname, ad_ou_path" -ForegroundColor Magenta
Write-Host "Expected result for invalid cases: Error 2002" -ForegroundColor Magenta

$testResults = @()

# Test 1: Valid case (control test)
$testResults += Invoke-ValidCaseTest

# Test 2: Missing samaccountname
$testResults += Invoke-MandatoryFieldTest -TestName "Missing samaccountname" -Description "Test with missing samaccountname field" -TestData @{
    ad_ou_path = "OU=Users,DC=example,DC=com"
    first_name = "Jane"
    last_name = "Doe"
    email = "jane.doe@example.com"
}

# Test 3: Missing ad_ou_path
$testResults += Invoke-MandatoryFieldTest -TestName "Missing ad_ou_path" -Description "Test with missing ad_ou_path field" -TestData @{
    samaccountname = "johndoe"
    first_name = "John"
    last_name = "Doe"
    email = "john.doe@example.com"
}

# Test 4: Missing both mandatory fields
$testResults += Invoke-MandatoryFieldTest -TestName "Missing both mandatory fields" -Description "Test with both samaccountname and ad_ou_path missing" -TestData @{
    first_name = "Bob"
    last_name = "Smith"
    email = "bob.smith@example.com"
    department = "IT"
}

# Test 5: Empty samaccountname
$testResults += Invoke-MandatoryFieldTest -TestName "Empty samaccountname" -Description "Test with empty string samaccountname" -TestData @{
    samaccountname = ""
    ad_ou_path = "OU=Users,DC=example,DC=com"
    first_name = "Alice"
    last_name = "Johnson"
}

# Test 6: Null ad_ou_path
$testResults += Invoke-MandatoryFieldTest -TestName "Null ad_ou_path" -Description "Test with null ad_ou_path field" -TestData @{
    samaccountname = "charlie"
    ad_ou_path = $null
    first_name = "Charlie"
    last_name = "Brown"
}

# Test 7: Completely empty account data
$testResults += Invoke-MandatoryFieldTest -TestName "Empty account data" -Description "Test with completely empty account data" -TestData @{}

# Test 8: Only optional fields
$testResults += Invoke-MandatoryFieldTest -TestName "Only optional fields" -Description "Test with only optional fields present" -TestData @{
    first_name = "David"
    last_name = "Wilson"
    email = "david.wilson@example.com"
    department = "Finance"
    manager = "manager@example.com"
    phone = "555-1234"
}

# Summary
Write-Host "`n" + "="*70 -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Magenta
Write-Host "="*70 -ForegroundColor Cyan

$passedTests = ($testResults | Where-Object { $_ -eq $true }).Count
$totalTests = $testResults.Count

Write-Host "Tests Passed: $passedTests/$totalTests" -ForegroundColor White

if ($passedTests -eq $totalTests) {
    Write-Host "✓ ALL TESTS PASSED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "All missing mandatory field scenarios correctly return error 2002" -ForegroundColor Green
} else {
    Write-Host "✗ SOME TESTS FAILED" -ForegroundColor Red
    $failedTests = $totalTests - $passedTests
    Write-Host "$failedTests test(s) did not behave as expected" -ForegroundColor Red
}

Write-Host "`nExpected Behavior:" -ForegroundColor Yellow
Write-Host "- Valid accounts with all mandatory fields should pass validation" -ForegroundColor Yellow
Write-Host "- Accounts missing 'samaccountname' should fail with error 2002" -ForegroundColor Yellow
Write-Host "- Accounts missing 'ad_ou_path' should fail with error 2002" -ForegroundColor Yellow
Write-Host "- Accounts with empty/null mandatory fields should fail with error 2002" -ForegroundColor Yellow