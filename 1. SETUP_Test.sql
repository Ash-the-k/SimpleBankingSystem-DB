-- ==========================================
-- 1. SETUP (Assuming Fresh Database and Tables/Procedures Created)
-- ==========================================

-- Create Test Employees
INSERT INTO EMPLOYEE (Name, Email, Phone, Role) VALUES
('Alice Brown', 'alice.brown@example.com', '8765432109', 'Manager') ON DUPLICATE KEY UPDATE Name=Name;
INSERT INTO EMPLOYEE (Name, Email, Phone, Role) VALUES
('Bob Green', 'bob.green@example.com', '7654321098', 'Teller') ON DUPLICATE KEY UPDATE Name=Name;
INSERT INTO EMPLOYEE (Name, Email, Phone, Role) VALUES
('Charlie Black', 'charlie.black@example.com', '2233445566', 'Senior Teller') ON DUPLICATE KEY UPDATE Name=Name;

SELECT * FROM EMPLOYEE;

-- Request Accounts for John Doe and Jane Smith
CALL RequestAccount('John Doe', 'john.doe@example.com', '9876543210', '123 Main St');
CALL RequestAccount('Jane Smith', 'jane.smith@example.com', '9988776655', '456 Oak Ave');

-- Approve Account Requests
SELECT @john_doe_req_id := RequestID FROM CUSTOMER_REQUEST WHERE Name = 'John Doe' AND Status = 'Pending';
CALL ApproveAccount(@john_doe_req_id, 'Savings', (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Alice Brown'));

SELECT * FROM ACCOUNT;
SELECT * FROM CUSTOMER;

SELECT @jane_smith_req_id := RequestID FROM CUSTOMER_REQUEST WHERE Name = 'Jane Smith' AND Status = 'Pending';
CALL ApproveAccount(@jane_smith_req_id, 'Checking', (SELECT EmployeeID FROM EMPLOYEE WHERE Name = 'Alice Brown'));
SELECT * FROM ACCOUNT;
SELECT * FROM CUSTOMER;

-- Retrieve Account Numbers
SELECT @john_doe_acc := AccountNo FROM ACCOUNT WHERE CustomerID = (SELECT CustomerID FROM CUSTOMER WHERE Name = 'John Doe');
SELECT @jane_smith_acc := AccountNo FROM ACCOUNT WHERE CustomerID = (SELECT CustomerID FROM CUSTOMER WHERE Name = 'Jane Smith');


SELECT c.Name, a.AccountNo, a.Balance FROM CUSTOMER c JOIN ACCOUNT a ON c.CustomerID = a.CustomerID WHERE a.AccountNo IN (@john_doe_acc, @jane_smith_acc);
