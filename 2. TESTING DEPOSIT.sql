-- ==========================================
-- 2. TESTING DEPOSIT
-- ==========================================

-- ==========================================
-- LOW-VALUE DEPOSIT (Immediate)
-- ==========================================

CALL DepositWithLog(@john_doe_acc, 100.00, (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT 'Balances After Low-Value Deposit:' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Customer Transactions (Low-Value Deposit):' AS Report;
SELECT * FROM Customer_Transactions WHERE ReceiverAcc = @john_doe_acc;

-- ==========================================
-- HIGH-VALUE DEPOSIT (Requires Approval)
-- ==========================================

CALL DepositWithLog(@jane_smith_acc, 150000.00, (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT 'Balances After High-Value Deposit Request (Should Be Unchanged):' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Pending Request for High-Value Deposit:' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE ReceiverAcc = @jane_smith_acc AND Amount = 150000.00 AND Type = 'Deposit' AND Status = 'Pending';

SELECT 'Customer Transactions (Before Approval):' AS Report;
SELECT * FROM Customer_Transactions; -- Transaction doesn't appear cause it is not Approved yet

-- Approve High-Value Deposit
SELECT @high_deposit_req_id := RequestID FROM TRANSACTION_REQUESTS
WHERE ReceiverAcc = @jane_smith_acc AND Amount = 150000.00 AND Type = 'Deposit' AND Status = 'Pending';
CALL ApproveTransactionRequest(@high_deposit_req_id, (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Alice Brown'));

SELECT 'Balances After Approval of High-Value Deposit:' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Customer Transactions (High-Value Deposit):' AS Report;
SELECT * FROM Customer_Transactions WHERE ReceiverAcc = @jane_smith_acc;

SELECT 'Customer Transactions (After Approval):' AS Report;
SELECT * FROM Customer_Transactions; -- Transaction appears cause it is Approved

SELECT 'High-Value Transactions (High-Value Deposit):' AS Report;
SELECT * FROM High_Value_Transactions WHERE ReceiverAcc = @jane_smith_acc;