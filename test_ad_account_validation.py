import pytest
import json
from typing import Dict, Any, Optional

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
            ADAccountValidationError: If validation fails
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

class TestADAccountValidation:
    """Test cases for AD Account validation"""
    
    def test_valid_ad_account(self):
        """Test case: Valid AD account with all mandatory fields"""
        valid_account = {
            'samaccountname': 'testuser',
            'ad_ou_path': 'OU=Users,DC=example,DC=com',
            'first_name': 'Test',
            'last_name': 'User',
            'email': 'testuser@example.com'
        }
        
        result = ADAccountValidator.validate_ad_account(valid_account)
        assert result is True
    
    def test_missing_samaccountname(self):
        """Test case: Missing samaccountname field - should return error 2002"""
        invalid_account = {
            'ad_ou_path': 'OU=Users,DC=example,DC=com',
            'first_name': 'Test',
            'last_name': 'User',
            'email': 'testuser@example.com'
        }
        
        with pytest.raises(ADAccountValidationError) as exc_info:
            ADAccountValidator.validate_ad_account(invalid_account)
        
        assert exc_info.value.error_code == 2002
        assert 'samaccountname' in exc_info.value.message
        assert 'Missing mandatory fields' in exc_info.value.message
    
    def test_missing_ad_ou_path(self):
        """Test case: Missing ad_ou_path field - should return error 2002"""
        invalid_account = {
            'samaccountname': 'testuser',
            'first_name': 'Test',
            'last_name': 'User',
            'email': 'testuser@example.com'
        }
        
        with pytest.raises(ADAccountValidationError) as exc_info:
            ADAccountValidator.validate_ad_account(invalid_account)
        
        assert exc_info.value.error_code == 2002
        assert 'ad_ou_path' in exc_info.value.message
        assert 'Missing mandatory fields' in exc_info.value.message
    
    def test_missing_multiple_mandatory_fields(self):
        """Test case: Missing both samaccountname and ad_ou_path - should return error 2002"""
        invalid_account = {
            'first_name': 'Test',
            'last_name': 'User',
            'email': 'testuser@example.com'
        }
        
        with pytest.raises(ADAccountValidationError) as exc_info:
            ADAccountValidator.validate_ad_account(invalid_account)
        
        assert exc_info.value.error_code == 2002
        assert 'samaccountname' in exc_info.value.message
        assert 'ad_ou_path' in exc_info.value.message
        assert 'Missing mandatory fields' in exc_info.value.message
    
    def test_empty_samaccountname(self):
        """Test case: Empty samaccountname field - should return error 2002"""
        invalid_account = {
            'samaccountname': '',
            'ad_ou_path': 'OU=Users,DC=example,DC=com',
            'first_name': 'Test',
            'last_name': 'User'
        }
        
        with pytest.raises(ADAccountValidationError) as exc_info:
            ADAccountValidator.validate_ad_account(invalid_account)
        
        assert exc_info.value.error_code == 2002
        assert 'samaccountname' in exc_info.value.message
    
    def test_null_ad_ou_path(self):
        """Test case: Null ad_ou_path field - should return error 2002"""
        invalid_account = {
            'samaccountname': 'testuser',
            'ad_ou_path': None,
            'first_name': 'Test',
            'last_name': 'User'
        }
        
        with pytest.raises(ADAccountValidationError) as exc_info:
            ADAccountValidator.validate_ad_account(invalid_account)
        
        assert exc_info.value.error_code == 2002
        assert 'ad_ou_path' in exc_info.value.message
    
    def test_empty_account_data(self):
        """Test case: Completely empty account data - should return error 2002"""
        empty_account = {}
        
        with pytest.raises(ADAccountValidationError) as exc_info:
            ADAccountValidator.validate_ad_account(empty_account)
        
        assert exc_info.value.error_code == 2002
        assert 'samaccountname' in exc_info.value.message
        assert 'ad_ou_path' in exc_info.value.message
    
    def test_account_with_only_optional_fields(self):
        """Test case: Account with only optional fields - should return error 2002"""
        invalid_account = {
            'first_name': 'Test',
            'last_name': 'User',
            'email': 'testuser@example.com',
            'department': 'IT',
            'manager': 'manager@example.com'
        }
        
        with pytest.raises(ADAccountValidationError) as exc_info:
            ADAccountValidator.validate_ad_account(invalid_account)
        
        assert exc_info.value.error_code == 2002
        assert 'samaccountname' in exc_info.value.message
        assert 'ad_ou_path' in exc_info.value.message

if __name__ == "__main__":
    # Example usage and manual testing
    validator = ADAccountValidator()
    
    print("=== AD Account Validation Test Examples ===\n")
    
    # Test 1: Valid account
    print("Test 1: Valid AD Account")
    valid_account = {
        'samaccountname': 'jdoe',
        'ad_ou_path': 'OU=Users,OU=IT,DC=company,DC=com',
        'first_name': 'John',
        'last_name': 'Doe'
    }
    try:
        result = validator.validate_ad_account(valid_account)
        print(f"✓ Validation passed: {result}")
    except ADAccountValidationError as e:
        print(f"✗ Validation failed: {e}")
    
    # Test 2: Missing samaccountname
    print("\nTest 2: Missing samaccountname")
    invalid_account1 = {
        'ad_ou_path': 'OU=Users,OU=IT,DC=company,DC=com',
        'first_name': 'Jane',
        'last_name': 'Smith'
    }
    try:
        result = validator.validate_ad_account(invalid_account1)
        print(f"✓ Validation passed: {result}")
    except ADAccountValidationError as e:
        print(f"✗ Expected validation failure: Error {e.error_code} - {e.message}")
    
    # Test 3: Missing ad_ou_path
    print("\nTest 3: Missing ad_ou_path")
    invalid_account2 = {
        'samaccountname': 'bwilson',
        'first_name': 'Bob',
        'last_name': 'Wilson'
    }
    try:
        result = validator.validate_ad_account(invalid_account2)
        print(f"✓ Validation passed: {result}")
    except ADAccountValidationError as e:
        print(f"✗ Expected validation failure: Error {e.error_code} - {e.message}")
    
    # Test 4: Missing both mandatory fields
    print("\nTest 4: Missing both mandatory fields")
    invalid_account3 = {
        'first_name': 'Alice',
        'last_name': 'Johnson',
        'email': 'alice.johnson@company.com'
    }
    try:
        result = validator.validate_ad_account(invalid_account3)
        print(f"✓ Validation passed: {result}")
    except ADAccountValidationError as e:
        print(f"✗ Expected validation failure: Error {e.error_code} - {e.message}")