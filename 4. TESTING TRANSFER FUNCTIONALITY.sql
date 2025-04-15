-- ==========================================
-- 4. TESTING TRANSFER FUNCTIONALITY
-- ==========================================

-- ==========================================
-- LOW-VALUE TRANSFER (Immediate)
-- ==========================================

SELECT 'Initial Balances:' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT '--- Testing Low-Value Transfer (20.00 from John to Jane) ---' AS Report;
CALL TransferWithApproval(@john_doe_acc, @jane_smith_acc, 20.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'John Doe'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT 'Balances After Low-Value Transfer:' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Transaction Log for Low-Value Transfer:' AS Report;
SELECT * FROM Customer_Transactions WHERE SenderAcc = @john_doe_acc AND ReceiverAcc = @jane_smith_acc AND Amount = 20.00 AND Type = 'Transfer';

SELECT 'Pending Requests (Should be None for Low-Value Transfer):' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE SenderAcc = @john_doe_acc AND ReceiverAcc = @jane_smith_acc AND Amount = 20.00 AND Type = 'Transfer' AND Status = 'Pending';

-- ==========================================
-- HIGH-VALUE TRANSFER (Requires Approval)
-- ==========================================

SELECT 'Initial Balances (Before High-Value Transfer):' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT '--- Testing High-Value Transfer (55000.00 from Jane to John) ---' AS Report;
CALL TransferWithApproval(@jane_smith_acc, @john_doe_acc, 55000.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'Jane Smith'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT 'Balances After High-Value Transfer Request (Should Be Unchanged):' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Pending Request for High-Value Transfer:' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE SenderAcc = @jane_smith_acc AND ReceiverAcc = @john_doe_acc AND Amount = 55000.00 AND Type = 'Transfer' AND Status = 'Pending';

-- Approve High-Value Transfer
SELECT @high_transfer_req_id := RequestID FROM TRANSACTION_REQUESTS
WHERE SenderAcc = @jane_smith_acc AND ReceiverAcc = @john_doe_acc AND Amount = 55000.00 AND Type = 'Transfer' AND Status = 'Pending';
CALL ApproveTransactionRequest(@high_transfer_req_id, (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Alice Brown'));

SELECT 'Balances After Approval of High-Value Transfer:' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Transaction Log for High-Value Transfer:' AS Report;
SELECT * FROM Customer_Transactions WHERE SenderAcc = @jane_smith_acc AND ReceiverAcc = @john_doe_acc AND Amount = 55000.00 AND Type = 'Transfer';

SELECT 'Pending Requests After Approval (Should Be None for This Transfer):' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE RequestID = @high_transfer_req_id AND Status = 'Pending';

SELECT 'High Value Transactions (High Value Transfer):' AS Report;
SELECT * FROM High_Value_Transactions WHERE SenderAcc = @jane_smith_acc AND ReceiverAcc = @john_doe_acc AND Amount = 55000.00 AND Type = 'Transfer';

-- ==========================================
-- TESTING TRANSFER WITH INSUFFICIENT FUNDS (Low-Value Attempt)
-- ==========================================

SELECT '--- Testing Low-Value Transfer with Insufficient Funds (Attempt 100000.00 from John) ---' AS Report;
CALL TransferWithApproval(@john_doe_acc, @jane_smith_acc, 100000.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'John Doe'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT 'Balances After Failed Low-Value Transfer (Should Be Unchanged):' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Transaction Log (Should Not Contain Failed Transfer):' AS Report;
SELECT * FROM Customer_Transactions WHERE SenderAcc = @john_doe_acc AND ReceiverAcc = @jane_smith_acc AND Amount = 100000.00 AND Type = 'Transfer';

SELECT 'Pending Requests (Should Not Contain Failed Transfer):' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE SenderAcc = @john_doe_acc AND ReceiverAcc = @jane_smith_acc AND Amount = 100000.00 AND Type = 'Transfer' AND Status = 'Pending';

-- ==========================================
-- TESTING HIGH-VALUE TRANSFER WITH INSUFFICIENT FUNDS (Should Not Queue)
-- ==========================================

SELECT '--- Testing High-Value Transfer with Insufficient Funds (Attempt 60000.00 from John) ---' AS Report;
CALL TransferWithApproval(@john_doe_acc, @jane_smith_acc, 60000.00, (SELECT CustomerID FROM CUSTOMER WHERE Name = 'John Doe'), (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Bob Green'));

SELECT 'Balances After Failed High-Value Transfer (Should Be Unchanged):' AS Report;
SELECT Name, AccountNo, Balance FROM Customer_Profile WHERE AccountNo IN (@john_doe_acc, @jane_smith_acc);

SELECT 'Transaction Log (Should Not Contain Failed Transfer):' AS Report;
SELECT * FROM Customer_Transactions WHERE SenderAcc = @john_doe_acc AND ReceiverAcc = @jane_smith_acc AND Amount = 60000.00 AND Type = 'Transfer';

SELECT 'Pending Requests (Should Not Contain Failed Transfer):' AS Report;
SELECT * FROM TRANSACTION_REQUESTS WHERE SenderAcc = @john_doe_acc AND ReceiverAcc = @jane_smith_acc AND Amount = 60000.00 AND Type = 'Transfer' AND Status = 'Pending';