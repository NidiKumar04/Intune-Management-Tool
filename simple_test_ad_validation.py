#!/usr/bin/env python3
"""
Simple AD Account Validation Test Suite
Tests for missing mandatory fields (samaccountname, ad_ou_path)
Expected error code: 2002
"""

from typing import Dict, Any

class ADAccountValidationError(Exception):
    """Custom exception for AD account validation errors"""
    def __init__(self, error_code: int, message: str):
        self.error_code = error_code
        self.message = message
        super().__init__(f"Error {error_code}: {message}")

class ADAccountValidator:
    """AD Account validator class"""
    
    MANDATORY_FIELDS = ['samaccountname', 'ad_ou_path']
    ERROR_MISSING_MANDATORY_FIELDS = 2002
    
    @staticmethod
    def validate_ad_account(account_data: Dict[str, Any]) -> bool:
        """
        Validates AD account data for mandatory fields
        
        Args:
            account_data: Dictionary containing AD account information
            
        Returns:
            bool: True if validation passes
            
        Raises:
            ADAccountValidationError: If validation fails with error 2002
        """
        missing_fields = []
        
        # Check for missing mandatory fields
        for field in ADAccountValidator.MANDATORY_FIELDS:
            if field not in account_data or account_data[field] is None or account_data[field] == "":
                missing_fields.append(field)
        
        if missing_fields:
            raise ADAccountValidationError(
                ADAccountValidator.ERROR_MISSING_MANDATORY_FIELDS,
                f"Missing mandatory fields: {', '.join(missing_fields)}"
            )
        
        return True

def run_test_case(test_name: str, account_data: Dict[str, Any], should_pass: bool = False):
    """Helper function to run individual test cases"""
    print(f"\n{'='*60}")
    print(f"TEST CASE: {test_name}")
    print(f"{'='*60}")
    print(f"Input data: {account_data}")
    print(f"Expected: {'PASS' if should_pass else 'FAIL with error 2002'}")
    
    try:
        result = ADAccountValidator.validate_ad_account(account_data)
        if should_pass:
            print(f"✓ RESULT: PASSED - Validation successful")
            return True
        else:
            print(f"✗ RESULT: UNEXPECTED PASS - Should have failed with error 2002")
            return False
    except ADAccountValidationError as e:
        if not should_pass and e.error_code == 2002:
            print(f"✓ RESULT: FAILED AS EXPECTED - Error {e.error_code}: {e.message}")
            return True
        else:
            print(f"✗ RESULT: UNEXPECTED ERROR - Error {e.error_code}: {e.message}")
            return False
    except Exception as e:
        print(f"✗ RESULT: UNEXPECTED EXCEPTION - {type(e).__name__}: {e}")
        return False

def main():
    """Main test runner"""
    print("AD ACCOUNT VALIDATION TEST SUITE")
    print("Testing for missing mandatory fields: samaccountname, ad_ou_path")
    print("Expected error code for failures: 2002")
    
    test_results = []
    
    # Test 1: Valid AD account (should pass)
    test_results.append(run_test_case(
        "Valid AD Account",
        {
            'samaccountname': 'jdoe',
            'ad_ou_path': 'OU=Users,OU=IT,DC=company,DC=com',
            'first_name': 'John',
            'last_name': 'Doe',
            'email': 'jdoe@company.com'
        },
        should_pass=True
    ))
    
    # Test 2: Missing samaccountname (should fail with error 2002)
    test_results.append(run_test_case(
        "Missing samaccountname",
        {
            'ad_ou_path': 'OU=Users,OU=IT,DC=company,DC=com',
            'first_name': 'Jane',
            'last_name': 'Smith',
            'email': 'jsmith@company.com'
        },
        should_pass=False
    ))
    
    # Test 3: Missing ad_ou_path (should fail with error 2002)
    test_results.append(run_test_case(
        "Missing ad_ou_path",
        {
            'samaccountname': 'bwilson',
            'first_name': 'Bob',
            'last_name': 'Wilson',
            'email': 'bwilson@company.com'
        },
        should_pass=False
    ))
    
    # Test 4: Missing both mandatory fields (should fail with error 2002)
    test_results.append(run_test_case(
        "Missing both samaccountname and ad_ou_path",
        {
            'first_name': 'Alice',
            'last_name': 'Johnson',
            'email': 'ajohnson@company.com',
            'department': 'HR'
        },
        should_pass=False
    ))
    
    # Test 5: Empty samaccountname (should fail with error 2002)
    test_results.append(run_test_case(
        "Empty samaccountname",
        {
            'samaccountname': '',
            'ad_ou_path': 'OU=Users,OU=IT,DC=company,DC=com',
            'first_name': 'Chris',
            'last_name': 'Brown'
        },
        should_pass=False
    ))
    
    # Test 6: Null ad_ou_path (should fail with error 2002)
    test_results.append(run_test_case(
        "Null ad_ou_path",
        {
            'samaccountname': 'mgreen',
            'ad_ou_path': None,
            'first_name': 'Mary',
            'last_name': 'Green'
        },
        should_pass=False
    ))
    
    # Test 7: Completely empty account data (should fail with error 2002)
    test_results.append(run_test_case(
        "Empty account data",
        {},
        should_pass=False
    ))
    
    # Test 8: Only optional fields present (should fail with error 2002)
    test_results.append(run_test_case(
        "Only optional fields",
        {
            'first_name': 'David',
            'last_name': 'Lee',
            'email': 'dlee@company.com',
            'department': 'Finance',
            'manager': 'manager@company.com',
            'phone': '555-0123'
        },
        should_pass=False
    ))
    
    # Summary
    print(f"\n{'='*60}")
    print("TEST SUMMARY")
    print(f"{'='*60}")
    passed = sum(test_results)
    total = len(test_results)
    print(f"Tests passed: {passed}/{total}")
    
    if passed == total:
        print("✓ ALL TESTS PASSED")
    else:
        print("✗ SOME TESTS FAILED")
        
    print(f"\nNote: Tests that 'fail with error 2002' are expected failures")
    print(f"and count as successful test cases when they fail as expected.")

if __name__ == "__main__":
    main()