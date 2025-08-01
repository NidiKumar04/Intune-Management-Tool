<#
.SYNOPSIS
    PowerShell module for AD Account validation with missing mandatory fields testing

.DESCRIPTION
    This module provides functions to validate AD account data for mandatory fields
    and test cases that should return error code 2002 when fields are missing.

.NOTES
    Mandatory fields: samaccountname, ad_ou_path
    Error code for missing fields: 2002
#>

# AD Account validation function
function Test-ADAccountMandatoryFields {
    <#
    .SYNOPSIS
        Validates AD account for mandatory fields
    
    .DESCRIPTION
        Checks if AD account data contains required mandatory fields:
        - samaccountname
        - ad_ou_path
        
        Returns error 2002 if any mandatory fields are missing, empty, or null.
    
    .PARAMETER AccountData
        Hashtable containing AD account information
    
    .EXAMPLE
        $account = @{ samaccountname = "jdoe"; ad_ou_path = "OU=Users,DC=domain,DC=com" }
        $result = Test-ADAccountMandatoryFields -AccountData $account
    
    .EXAMPLE
        # This should return error 2002
        $invalidAccount = @{ first_name = "John"; last_name = "Doe" }
        $result = Test-ADAccountMandatoryFields -AccountData $invalidAccount
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$AccountData
    )
    
    $mandatoryFields = @('samaccountname', 'ad_ou_path')
    $missingFields = @()
    
    # Validate each mandatory field
    foreach ($field in $mandatoryFields) {
        if (-not $AccountData.ContainsKey($field) -or 
            [string]::IsNullOrWhiteSpace($AccountData[$field]) -or 
            $AccountData[$field] -eq $null) {
            $missingFields += $field
        }
    }
    
    # Return result object
    if ($missingFields.Count -gt 0) {
        return [PSCustomObject]@{
            IsValid = $false
            ErrorCode = 2002
            ErrorMessage = "Missing mandatory fields: $($missingFields -join ', ')"
            MissingFields = $missingFields
            ValidationDateTime = Get-Date
        }
    } else {
        return [PSCustomObject]@{
            IsValid = $true
            ErrorCode = $null
            ErrorMessage = $null
            MissingFields = @()
            ValidationDateTime = Get-Date
        }
    }
}

# Test case data provider
function Get-ADAccountTestCases {
    <#
    .SYNOPSIS
        Returns predefined test cases for AD account validation
    
    .DESCRIPTION
        Provides a collection of test cases including valid and invalid scenarios
        for testing missing mandatory fields validation.
    
    .EXAMPLE
        $testCases = Get-ADAccountTestCases
        foreach ($case in $testCases) {
            $result = Test-ADAccountMandatoryFields -AccountData $case.Data
        }
    #>
    
    return @(
        @{
            Name = "Valid_Account"
            Description = "Valid AD account with all mandatory fields"
            Data = @{
                samaccountname = "jdoe"
                ad_ou_path = "OU=Users,OU=IT,DC=company,DC=com"
                first_name = "John"
                last_name = "Doe"
                email = "jdoe@company.com"
            }
            ExpectedValid = $true
            ExpectedErrorCode = $null
        },
        @{
            Name = "Missing_SamAccountName"
            Description = "Missing samaccountname field - should return error 2002"
            Data = @{
                ad_ou_path = "OU=Users,DC=company,DC=com"
                first_name = "Jane"
                last_name = "Smith"
                email = "jsmith@company.com"
            }
            ExpectedValid = $false
            ExpectedErrorCode = 2002
        },
        @{
            Name = "Missing_AD_OU_Path"
            Description = "Missing ad_ou_path field - should return error 2002"
            Data = @{
                samaccountname = "bwilson"
                first_name = "Bob"
                last_name = "Wilson"
                email = "bwilson@company.com"
            }
            ExpectedValid = $false
            ExpectedErrorCode = 2002
        },
        @{
            Name = "Missing_Both_Fields"
            Description = "Missing both mandatory fields - should return error 2002"
            Data = @{
                first_name = "Alice"
                last_name = "Johnson"
                email = "ajohnson@company.com"
                department = "HR"
            }
            ExpectedValid = $false
            ExpectedErrorCode = 2002
        },
        @{
            Name = "Empty_SamAccountName"
            Description = "Empty samaccountname - should return error 2002"
            Data = @{
                samaccountname = ""
                ad_ou_path = "OU=Users,DC=company,DC=com"
                first_name = "Chris"
                last_name = "Brown"
            }
            ExpectedValid = $false
            ExpectedErrorCode = 2002
        },
        @{
            Name = "Null_AD_OU_Path"
            Description = "Null ad_ou_path - should return error 2002"
            Data = @{
                samaccountname = "mgreen"
                ad_ou_path = $null
                first_name = "Mary"
                last_name = "Green"
            }
            ExpectedValid = $false
            ExpectedErrorCode = 2002
        },
        @{
            Name = "Empty_Account"
            Description = "Completely empty account - should return error 2002"
            Data = @{}
            ExpectedValid = $false
            ExpectedErrorCode = 2002
        },
        @{
            Name = "Only_Optional_Fields"
            Description = "Only optional fields present - should return error 2002"
            Data = @{
                first_name = "David"
                last_name = "Lee"
                email = "dlee@company.com"
                department = "Finance"
                manager = "manager@company.com"
            }
            ExpectedValid = $false
            ExpectedErrorCode = 2002
        }
    )
}

# Test runner function
function Invoke-ADAccountValidationTests {
    <#
    .SYNOPSIS
        Runs all AD account validation test cases
    
    .DESCRIPTION
        Executes predefined test cases and reports results. Tests validation
        of mandatory fields and verifies error code 2002 is returned for
        missing mandatory fields.
    
    .PARAMETER ShowDetails
        If specified, shows detailed output for each test case
    
    .EXAMPLE
        Invoke-ADAccountValidationTests
    
    .EXAMPLE
        Invoke-ADAccountValidationTests -ShowDetails
    #>
    
    [CmdletBinding()]
    param(
        [switch]$ShowDetails
    )
    
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host "AD ACCOUNT VALIDATION TEST SUITE" -ForegroundColor Yellow
    Write-Host "Testing mandatory fields: samaccountname, ad_ou_path" -ForegroundColor Yellow
    Write-Host "Expected error code for missing fields: 2002" -ForegroundColor Yellow
    Write-Host "=" * 80 -ForegroundColor Cyan
    
    $testCases = Get-ADAccountTestCases
    $passedTests = 0
    $totalTests = $testCases.Count
    
    foreach ($testCase in $testCases) {
        if ($ShowDetails) {
            Write-Host "`nTEST: $($testCase.Name)" -ForegroundColor Magenta
            Write-Host "Description: $($testCase.Description)" -ForegroundColor White
            Write-Host "Input Data: $($testCase.Data | ConvertTo-Json -Compress)" -ForegroundColor Gray
        }
        
        $result = Test-ADAccountMandatoryFields -AccountData $testCase.Data
        
        # Validate test result
        $testPassed = $false
        if ($testCase.ExpectedValid -and $result.IsValid) {
            $testPassed = $true
        } elseif (-not $testCase.ExpectedValid -and -not $result.IsValid -and $result.ErrorCode -eq $testCase.ExpectedErrorCode) {
            $testPassed = $true
        }
        
        if ($testPassed) {
            $passedTests++
            if ($ShowDetails) {
                Write-Host "✓ PASSED" -ForegroundColor Green
            } else {
                Write-Host "✓" -ForegroundColor Green -NoNewline
            }
        } else {
            if ($ShowDetails) {
                Write-Host "✗ FAILED" -ForegroundColor Red
                Write-Host "  Expected Valid: $($testCase.ExpectedValid)" -ForegroundColor Red
                Write-Host "  Actual Valid: $($result.IsValid)" -ForegroundColor Red
                Write-Host "  Expected Error: $($testCase.ExpectedErrorCode)" -ForegroundColor Red
                Write-Host "  Actual Error: $($result.ErrorCode)" -ForegroundColor Red
            } else {
                Write-Host "✗" -ForegroundColor Red -NoNewline
            }
        }
    }
    
    if (-not $ShowDetails) {
        Write-Host ""
    }
    
    # Summary
    Write-Host "`n" + "=" * 80 -ForegroundColor Cyan
    Write-Host "TEST SUMMARY" -ForegroundColor Yellow
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host "Passed: $passedTests/$totalTests" -ForegroundColor White
    
    if ($passedTests -eq $totalTests) {
        Write-Host "✓ ALL TESTS PASSED" -ForegroundColor Green
        Write-Host "All missing mandatory field scenarios correctly return error 2002" -ForegroundColor Green
    } else {
        Write-Host "✗ $($totalTests - $passedTests) TEST(S) FAILED" -ForegroundColor Red
    }
    
    return @{
        TotalTests = $totalTests
        PassedTests = $passedTests
        FailedTests = ($totalTests - $passedTests)
        AllPassed = ($passedTests -eq $totalTests)
    }
}

# Export module members
Export-ModuleMember -Function Test-ADAccountMandatoryFields, Get-ADAccountTestCases, Invoke-ADAccountValidationTests