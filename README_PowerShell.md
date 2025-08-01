# PowerShell AD Account Validation Test Suite

This repository contains PowerShell scripts for testing AD (Active Directory) account validation, specifically for missing mandatory fields that should return **error code 2002**.

## 📁 Files Included

### PowerShell Scripts
- **`Test-ADAccountValidation.ps1`** - Full-featured test suite with classes and advanced PowerShell features
- **`Test-MissingMandatoryFields.ps1`** - Simplified, focused test script for missing mandatory fields
- **`ADAccountValidation.psm1`** - PowerShell module with reusable functions

### Supporting Files
- **`test_cases.json`** - JSON test data for integration with other systems
- **`README_PowerShell.md`** - This documentation file

## 🎯 Test Scenarios

### Mandatory Fields
The scripts test validation for these mandatory AD account fields:
- **`samaccountname`** - User account name in Active Directory
- **`ad_ou_path`** - Organizational Unit path in Active Directory

### Test Cases for Missing Mandatory Fields (Error 2002)

1. **Missing samaccountname** - Account missing the samaccountname field
2. **Missing ad_ou_path** - Account missing the ad_ou_path field  
3. **Missing both fields** - Account missing both mandatory fields
4. **Empty samaccountname** - Account with empty string samaccountname
5. **Null ad_ou_path** - Account with null ad_ou_path value
6. **Empty account data** - Completely empty account data
7. **Only optional fields** - Account with only non-mandatory fields

### Valid Test Case
- **Valid AD Account** - Account with all mandatory fields present (should pass)

## 🚀 How to Run the Tests

### Prerequisites
- Windows PowerShell 5.1+ or PowerShell Core 6.0+
- No additional modules required

### Option 1: Simple Test Script
```powershell
# Run the focused test script
.\Test-MissingMandatoryFields.ps1
```

### Option 2: Full Test Suite
```powershell
# Run all tests
.\Test-ADAccountValidation.ps1

# Run specific test case
.\Test-ADAccountValidation.ps1 -TestCase "MissingSamAccountName"
```

### Option 3: Using the PowerShell Module
```powershell
# Import the module
Import-Module .\ADAccountValidation.psm1

# Run all tests
Invoke-ADAccountValidationTests

# Run with detailed output
Invoke-ADAccountValidationTests -ShowDetails

# Test individual account
$account = @{ first_name = "John"; last_name = "Doe" }
$result = Test-ADAccountMandatoryFields -AccountData $account
Write-Host "Error Code: $($result.ErrorCode)"  # Should be 2002
```

## 📋 Expected Output Example

When running the test scripts, you should see output similar to:

```
AD ACCOUNT VALIDATION - MISSING MANDATORY FIELDS TEST SUITE
Testing for missing mandatory fields: samaccountname, ad_ou_path
Expected result for invalid cases: Error 2002

======================================================================
TEST: Valid AD Account (Control Test)
======================================================================
Description: Valid account with all mandatory fields present
Input Data:
  samaccountname: testuser
  ad_ou_path: OU=Users,DC=example,DC=com
  first_name: Test
  last_name: User
  email: testuser@example.com

Result:
  ✓ SUCCESS - Validation passed as expected

======================================================================
TEST: Missing samaccountname
======================================================================
Description: Test with missing samaccountname field
Input Data:
  ad_ou_path: OU=Users,DC=example,DC=com
  first_name: Jane
  last_name: Doe
  email: jane.doe@example.com

Result:
  ✓ FAILED AS EXPECTED
  Error Code: 2002
  Error Message: Missing mandatory fields: samaccountname
  ✓ CORRECT ERROR CODE (2002)

[... additional test cases ...]

======================================================================
TEST SUMMARY
======================================================================
Tests Passed: 8/8
✓ ALL TESTS PASSED SUCCESSFULLY
All missing mandatory field scenarios correctly return error 2002
```

## 💡 Usage Examples

### Testing Individual Accounts

```powershell
# Import the module
Import-Module .\ADAccountValidation.psm1

# Example 1: Valid account (should pass)
$validAccount = @{
    samaccountname = "jdoe"
    ad_ou_path = "OU=Users,DC=company,DC=com"
    first_name = "John"
    last_name = "Doe"
}
$result = Test-ADAccountMandatoryFields -AccountData $validAccount
Write-Host "Valid: $($result.IsValid)"  # Should be True

# Example 2: Missing samaccountname (should return error 2002)
$invalidAccount = @{
    ad_ou_path = "OU=Users,DC=company,DC=com"
    first_name = "Jane"
    last_name = "Smith"
}
$result = Test-ADAccountMandatoryFields -AccountData $invalidAccount
Write-Host "Valid: $($result.IsValid)"        # Should be False
Write-Host "Error Code: $($result.ErrorCode)" # Should be 2002
Write-Host "Missing: $($result.MissingFields -join ', ')" # Should be "samaccountname"

# Example 3: Missing ad_ou_path (should return error 2002)
$invalidAccount2 = @{
    samaccountname = "bwilson"
    first_name = "Bob"
    last_name = "Wilson"
}
$result = Test-ADAccountMandatoryFields -AccountData $invalidAccount2
Write-Host "Error Code: $($result.ErrorCode)" # Should be 2002
Write-Host "Missing: $($result.MissingFields -join ', ')" # Should be "ad_ou_path"

# Example 4: Missing both fields (should return error 2002)
$invalidAccount3 = @{
    first_name = "Alice"
    last_name = "Johnson"
    email = "ajohnson@company.com"
}
$result = Test-ADAccountMandatoryFields -AccountData $invalidAccount3
Write-Host "Error Code: $($result.ErrorCode)" # Should be 2002
Write-Host "Missing: $($result.MissingFields -join ', ')" # Should be "samaccountname, ad_ou_path"
```

### Integration with Other Systems

```powershell
# Example: Processing multiple accounts from JSON
$jsonData = Get-Content "test_cases.json" | ConvertFrom-Json
foreach ($testCase in $jsonData.test_cases) {
    $result = Test-ADAccountMandatoryFields -AccountData $testCase.input
    
    if (-not $result.IsValid -and $result.ErrorCode -eq 2002) {
        Write-Host "✓ Test '$($testCase.name)' failed as expected with error 2002"
    } elseif ($result.IsValid -and $testCase.expected_result -eq "pass") {
        Write-Host "✓ Test '$($testCase.name)' passed as expected"
    } else {
        Write-Host "✗ Test '$($testCase.name)' had unexpected result"
    }
}
```

## 🔧 Customization

### Adding Additional Mandatory Fields

To test additional mandatory fields, modify the `$mandatoryFields` array in any script:

```powershell
# In Test-ADAccountMandatoryFields function
$mandatoryFields = @('samaccountname', 'ad_ou_path', 'email', 'department')
```

### Changing Error Codes

To use a different error code, modify the error code value:

```powershell
# Change from 2002 to your desired error code
ErrorCode = 2003  # or whatever code you need
```

## 📊 Return Values

The validation functions return PowerShell objects with these properties:

```powershell
[PSCustomObject]@{
    IsValid = $true/$false              # Whether validation passed
    ErrorCode = $null/2002              # Error code (2002 for missing fields)
    ErrorMessage = "..."                # Human-readable error message
    MissingFields = @("field1", "field2") # Array of missing field names
    ValidationDateTime = Get-Date       # When validation was performed
}
```

## 🎯 Key Validation Rules

1. **Field Presence**: Field must exist in the hashtable
2. **Non-Null**: Field value cannot be `$null`
3. **Non-Empty**: Field value cannot be empty string `""`
4. **Non-Whitespace**: Field value cannot be only whitespace

## 🔍 Troubleshooting

### Common Issues

1. **Script execution policy**: If you get execution policy errors:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Module import issues**: Ensure you're in the correct directory:
   ```powershell
   Get-Location  # Check current directory
   Import-Module .\ADAccountValidation.psm1 -Force
   ```

3. **Path issues**: Use full paths if needed:
   ```powershell
   & "C:\path\to\Test-MissingMandatoryFields.ps1"
   ```

## 📝 Notes

- All test cases expecting **error 2002** should fail validation when mandatory fields are missing
- The scripts are compatible with both Windows PowerShell and PowerShell Core
- Test data uses realistic AD organizational unit paths and account names
- Functions include comprehensive help documentation accessible via `Get-Help`