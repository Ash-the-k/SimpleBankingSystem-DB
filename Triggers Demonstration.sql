-- ==========================================
-- DEMONSTRATION SCRIPT FOR BANKING SYSTEM
-- INCLUDING TRIGGER TESTS (FRESH DB ASSUMPTION)
-- ==========================================

USE BankingSystem;

-- ==========================================
-- 1. SETUP (Assuming Fresh Database and Tables/Procedures Created)
-- ==========================================

-- Create Test Employees
INSERT INTO EMPLOYEE (Name, Email, Phone, Role) VALUES
('Alice Brown', 'alice.brown@example.com', '8765432109', 'Manager') ON DUPLICATE KEY UPDATE Name=Name;
INSERT INTO EMPLOYEE (Name, Email, Phone, Role) VALUES
('Bob Green', 'bob.green@example.com', '7654321098', 'Teller') ON DUPLICATE KEY UPDATE Name=Name;

-- Request Accounts for John Doe and Jane Smith
CALL RequestAccount('John Doe', 'john.doe@example.com', '9876543210', '123 Main St');
CALL RequestAccount('Jane Smith', 'jane.smith@example.com', '9988776655', '456 Oak Ave');

-- Approve Account Requests
SELECT @john_doe_req_id := RequestID FROM Pending_Requests WHERE Name = 'John Doe';
CALL ApproveAccount(@john_doe_req_id, 'Savings', (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Alice Brown'));

SELECT @jane_smith_req_id := RequestID FROM Pending_Requests WHERE Name = 'Jane Smith';
CALL ApproveAccount(@jane_smith_req_id, 'Checking', (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Alice Brown'));

-- Retrieve Account Numbers
SELECT @john_doe_acc := AccountNo FROM Customer_Profile WHERE Name = 'John Doe';
SELECT @jane_smith_acc := AccountNo FROM Customer_Profile WHERE Name = 'Jane Smith';

-- Deposit some initial funds
CALL DepositWithLog(@john_doe_acc, 100.00, (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));
CALL DepositWithLog(@jane_smith_acc, 100.00, (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT '--- Initial Balances ---' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

-- ==========================================
-- 2. TESTING TRIGGER: PreventNegativeBalance
-- ==========================================

SELECT '--- Testing Trigger: PreventNegativeBalance ---' AS Report;

SELECT '--- Attempting Withdrawal Exceeding Balance for John Doe ---' AS Report;
-- Attempt to withdraw more than the balance (should be prevented by the trigger)
CALL WithdrawWithApproval(@john_doe_acc, 150.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'John Doe'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT '--- John Doe\'s Balance After Failed Over-Withdrawal (Should Be Unchanged) ---' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT '--- Attempting Valid Withdrawal for John Doe ---' AS Report;
CALL WithdrawWithApproval(@john_doe_acc, 50.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'John Doe'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT '--- John Doe\'s Balance After Valid Withdrawal ---' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

-- ==========================================
-- 3. TESTING TRIGGER: Block_Suspended_Account
-- ==========================================

SELECT '--- Testing Trigger: Block_Suspended_Account ---' AS Report;

SELECT '--- Suspending John Doe\'s Account (If Not Already Suspended) ---' AS Report;
UPDATE ACCOUNT SET Status = 'Suspended' WHERE AccountNo = @john_doe_acc AND Status <> 'Suspended';

SELECT '--- Attempting Deposit to Suspended Account ---' AS Report;
CALL DepositWithLog(@john_doe_acc, 20.00, (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT '--- Attempting Withdrawal from Suspended Account ---' AS Report;
CALL WithdrawWithApproval(@john_doe_acc, 10.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'John Doe'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT '--- Attempting Transfer from Suspended Account ---' AS Report;
CALL TransferWithApproval(@john_doe_acc, @jane_smith_acc, 10.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'John Doe'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT '--- Attempting Transfer to Suspended Account ---' AS Report;
CALL TransferWithApproval(@jane_smith_acc, @john_doe_acc, 10.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'Jane Smith'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT '--- Reactivating John Doe\'s Account (If Not Already Active) ---' AS Report;
UPDATE ACCOUNT SET Status = 'Active' WHERE AccountNo = @john_doe_acc AND Status <> 'Active';

-- ==========================================
-- 4. TESTING TRIGGER: LogAccountStatusChange
-- ==========================================

SELECT '--- Testing Trigger: LogAccountStatusChange ---' AS Report;

SELECT '--- Initial Account Status Log (Should Be Empty or contain previous tests) ---' AS Report;
SELECT * FROM AccountStatusLog;

SELECT '--- Updating Jane Smith\'s Account Status to Suspended (If Not Already Suspended) ---' AS Report;
UPDATE ACCOUNT SET Status = 'Suspended' WHERE AccountNo = @jane_smith_acc AND Status <> 'Suspended';

SELECT '--- Account Status Log After Suspending Jane Smith ---' AS Report;
SELECT * FROM AccountStatusLog;

SELECT '--- Updating Jane Smith\'s Account Status back to Active (If Not Already Active) ---' AS Report;
UPDATE ACCOUNT SET Status = 'Active' WHERE AccountNo = @jane_smith_acc AND Status <> 'Active';

SELECT '--- Account Status Log After Reactivating Jane Smith ---' AS Report;
SELECT * FROM AccountStatusLog;

-- ==========================================
-- (Further tests for other functionalities can be added below)
-- ==========================================