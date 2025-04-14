-- ==========================================
-- 2. TESTING DEPOSIT 
-- ==========================================

-- ==========================================
-- LOW-VALUE DEPOSIT (Immediate)
-- ==========================================

CALL DepositWithLog(@john_doe_acc, 100.00, (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT c.Name, a.AccountNo, a.Balance FROM CUSTOMER c JOIN ACCOUNT a ON c.CustomerID = a.CustomerID WHERE a.AccountNo IN (@john_doe_acc, @jane_smith_acc);

-- ==========================================
-- HIGH-VALUE DEPOSIT (Requires Approval)
-- ==========================================

CALL DepositWithLog(@jane_smith_acc, 150000.00, (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT 'Balances After High-Value Deposit Request (Should Be Unchanged):' AS Report;
SELECT c.Name, a.AccountNo, a.Balance FROM CUSTOMER c JOIN ACCOUNT a ON c.CustomerID = a.CustomerID WHERE a.AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Pending Request for High-Value Deposit:' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE ReceiverAcc = @jane_smith_acc AND Amount = 150000.00 AND Type = 'Deposit' AND Status = 'Pending';

-- Approve High-Value Deposit
SELECT @high_deposit_req_id := RequestID FROM TRANSACTION_REQUESTS
WHERE ReceiverAcc = @jane_smith_acc AND Amount = 150000.00 AND Type = 'Deposit' AND Status = 'Pending';
CALL ApproveTransactionRequest(@high_deposit_req_id, (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Alice Brown'));

SELECT 'Balances After Approval of High-Value Deposit:' AS Report;
SELECT c.Name, a.AccountNo, a.Balance FROM CUSTOMER c JOIN ACCOUNT a ON c.CustomerID = a.CustomerID WHERE a.AccountNo IN (@john_doe_acc, @jane_smith_acc);


SELECT 'Pending Requests After Approval (Should Be None for This Deposit):' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE RequestID = @high_deposit_req_id AND Status = 'Pending';