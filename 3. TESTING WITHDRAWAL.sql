-- ==========================================
-- 3. TESTING WITHDRAWAL
-- ==========================================

-- ==========================================
-- LOW-VALUE WITHDRAWAL (Immediate)
-- ==========================================

SELECT c.Name, a.AccountNo, a.Balance FROM CUSTOMER c JOIN ACCOUNT a ON c.CustomerID = a.CustomerID WHERE a.AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT '--- Testing Low-Value Withdrawal (50.00 from John Doe) ---' AS Report;
CALL WithdrawWithApproval(@john_doe_acc, 50.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'John Doe'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT 'Balances After Low-Value Withdrawal:' AS Report;
SELECT c.Name, a.AccountNo, a.Balance FROM CUSTOMER c JOIN ACCOUNT a ON c.CustomerID = a.CustomerID WHERE a.AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Transaction Log for Low-Value Withdrawal:' AS Report;
SELECT * FROM TRANSACTIONS WHERE SenderAcc = @john_doe_acc AND Amount = 50.00 AND Type = 'Withdraw';

SELECT 'Pending Requests (Should be None for Low-Value Withdrawal):' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE SenderAcc = @john_doe_acc AND Amount = 50.00 AND Type = 'Withdraw' AND Status = 'Pending';


-- ==========================================
-- TESTING INSUFFICIENT FUNDS FOR WITHDRAWAL 
-- ==========================================

SELECT '--- Testing Low-Value Withdrawal with Insufficient Funds (Attempt 100000.00 from John) ---' AS Report;
CALL WithdrawWithApproval(@john_doe_acc, 100000.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'John Doe'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT 'Balances After Failed Low-Value Withdrawal (Should Be Unchanged):' AS Report;
SELECT c.Name, a.AccountNo, a.Balance FROM CUSTOMER c JOIN ACCOUNT a ON c.CustomerID = a.CustomerID WHERE a.AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Transaction Log (Should Not Contain Failed Withdrawal):' AS Report;
SELECT * FROM TRANSACTIONS WHERE SenderAcc = @john_doe_acc AND Amount = 100000.00 AND Type = 'Withdraw';

SELECT 'Pending Requests (Should Not Contain Failed Withdrawal):' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE SenderAcc = @john_doe_acc AND Amount = 100000.00 AND Type = 'Withdraw' AND Status = 'Pending';


-- ==========================================
-- HIGH-VALUE WITHDRAWAL (Requires Approval)
-- ==========================================

SELECT '--- Testing High-Value Withdrawal (50001.00 from Jane Smith) ---' AS Report;
CALL WithdrawWithApproval(@jane_smith_acc, 50001.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'Jane Smith'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT 'Balances After High-Value Withdrawal Request (Should Be Unchanged):' AS Report;
SELECT c.Name, a.AccountNo, a.Balance FROM CUSTOMER c JOIN ACCOUNT a ON c.CustomerID = a.CustomerID WHERE a.AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Pending Request for High-Value Withdrawal:' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE SenderAcc = @jane_smith_acc AND Amount = 50001.00 AND Type = 'Withdraw' AND Status = 'Pending';

-- Approve High-Value Withdrawal
SELECT @high_withdraw_req_id := RequestID FROM TRANSACTION_REQUESTS
WHERE SenderAcc = @jane_smith_acc AND Amount = 50001.00 AND Type = 'Withdraw' AND Status = 'Pending';
CALL ApproveTransactionRequest(@high_withdraw_req_id, (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Alice Brown'));

SELECT 'Balances After Approval of High-Value Withdrawal:' AS Report;
SELECT c.Name, a.AccountNo, a.Balance FROM CUSTOMER c JOIN ACCOUNT a ON c.CustomerID = a.CustomerID WHERE a.AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Transaction Log for High-Value Withdrawal:' AS Report;
SELECT * FROM TRANSACTIONS WHERE SenderAcc = @jane_smith_acc AND Amount = 50001.00 AND Type = 'Withdraw';

SELECT 'Pending Requests After Approval (Should Be None for This Withdrawal):' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE RequestID = @high_withdraw_req_id AND Status = 'Pending';