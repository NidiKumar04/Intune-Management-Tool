# AD Account Validation Test Cases

This repository contains test cases for validating AD (Active Directory) account data, specifically testing for missing mandatory fields.

## Test Cases Included

The test suite includes validation for the following scenarios:

### Missing Mandatory Fields (Error 2002)
- **samaccountname**: User account name in Active Directory
- **ad_ou_path**: Organizational Unit path in Active Directory

### Test Scenarios

1. **Valid AD Account**: Tests successful validation with all mandatory fields
2. **Missing samaccountname**: Tests error 2002 when samaccountname is missing
3. **Missing ad_ou_path**: Tests error 2002 when ad_ou_path is missing
4. **Missing both fields**: Tests error 2002 when both mandatory fields are missing
5. **Empty samaccountname**: Tests error 2002 when samaccountname is empty string
6. **Null ad_ou_path**: Tests error 2002 when ad_ou_path is null
7. **Empty account data**: Tests error 2002 with completely empty input
8. **Only optional fields**: Tests error 2002 when only non-mandatory fields are present

## Running the Tests

### Prerequisites
Install the required dependencies:
```bash
pip install -r requirements.txt
```

### Run All Tests
```bash
pytest test_ad_account_validation.py -v
```

### Run with Coverage
```bash
pytest test_ad_account_validation.py --cov=. --cov-report=html
```

### Run Manual Examples
```bash
python test_ad_account_validation.py
```

## Expected Results

All invalid test cases should raise `ADAccountValidationError` with error code **2002** and appropriate error messages indicating which mandatory fields are missing.

## Example Usage

```python
from test_ad_account_validation import ADAccountValidator, ADAccountValidationError

# Valid account
valid_account = {
    'samaccountname': 'jdoe',
    'ad_ou_path': 'OU=Users,DC=example,DC=com'
}

# This will pass validation
result = ADAccountValidator.validate_ad_account(valid_account)

# Invalid account (missing samaccountname)
invalid_account = {
    'ad_ou_path': 'OU=Users,DC=example,DC=com'
}

# This will raise ADAccountValidationError with error code 2002
try:
    ADAccountValidator.validate_ad_account(invalid_account)
except ADAccountValidationError as e:
    print(f"Error {e.error_code}: {e.message}")
```