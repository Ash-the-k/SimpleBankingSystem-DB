# Simple Banking System

This repository contains SQL scripts for setting up and testing a simple banking system database. The system includes functionalities for customer account management, transactions (deposits, withdrawals, transfers), employee management, and transaction logging. 

## Table of Contents

* [Database Schema](#database-schema)
* [Stored Procedures](#stored-procedures)
* [Views](#views)
* [Triggers](#triggers)
* [Testing Scripts](#testing-scripts)
* [Setup Instructions](#setup-instructions)
* [File Descriptions](#file-descriptions)
* [Contributing](#contributing)
* [Short Documentation](readme.md)

## Database Schema

The database schema consists of the following tables:

### Tables

* **CUSTOMER\_REQUEST**

    |   Column Name   |   Data Type   |   Description                                                                  |
    | :------------ | :------------ | :--------------------------------------------------------------------------- |
    |   RequestID   |   INT         |   Primary Key, auto-incrementing                                               |
    |   Name        |   VARCHAR(100)  |   Customer name                                                                |
    |   Email       |   VARCHAR(100)  |   Customer email (unique)                                                      |
    |   Phone       |   VARCHAR(15)   |   Customer phone number (unique)                                               |
    |   Address     |   VARCHAR(255)  |   Customer address                                                             |
    |   RequestedDate   |   DATETIME    |   Date and time of the account request                                         |
    |   Status      |   VARCHAR(20)   |   Status of the request ('Pending', 'Approved', 'Rejected')                     |                                     

* **CUSTOMER**

    |   Column Name   |   Data Type   |   Description                                                                  |
    | :------------ | :------------ | :--------------------------------------------------------------------------- |
    |   CustomerID    |   INT         |   Primary Key, auto-incrementing                                               |
    |   Name        |   VARCHAR(100)  |   Customer name                                                                |
    |   Email       |   VARCHAR(100)  |   Customer email (unique)                                                      |
    |   Phone       |   VARCHAR(15)   |   Customer phone number (unique)                                               |
    |   Address     |   VARCHAR(255)  |   Customer address                                                             |
    |   ApprovedDate    |   DATETIME    |   Date and time of account approval                                            |
    |   Status      |   VARCHAR(20)   |   Customer status ('Active', 'Suspended')                                     |                                           |
* **EMPLOYEE**

    |   Column Name   |   Data Type   |   Description                                        |
    | :------------ | :------------ | :------------------------------------------------- |
    |   EmployeeID    |   INT         |   Primary Key, auto-incrementing                     |
    |   Name        |   VARCHAR(100)  |   Employee name                                      |
    |   Email       |   VARCHAR(100)  |   Employee email (unique)                            |
    |   Phone       |   VARCHAR(15)   |   Employee phone number (unique)                     |
    |   Role        |   VARCHAR(50)   |   Employee role                                      |

* **ACCOUNT**

    |   Column Name   |   Data Type   |   Description                                                  |
    | :------------ | :------------ | :----------------------------------------------------------- |
    |   AccountNo   |   INT         |   Primary Key, auto-incrementing                               |
    |   CustomerID    |   INT         |   Foreign Key referencing CUSTOMER table                       |
    |   AccountType   |   VARCHAR(20)   |   Type of account ('Savings', 'Checking')                      |
    |   Balance     |   DECIMAL(10, 2)  |   Account balance                                              |
    |   Status      |   VARCHAR(20)   |   Account status ('Active', 'Suspended')                       |
    |   CreatedDate   |   DATETIME    |   Date and time of account creation                            |
* **TRANSACTIONS**

    |   Column Name   |   Data Type   |   Description                                                                  |
    | :------------ | :------------ | :--------------------------------------------------------------------------- |
    |   TransactionID   |   INT         |   Primary Key, auto-incrementing                                               |
    |   SenderAcc   |   INT         |   Foreign Key referencing ACCOUNT table (nullable, for withdrawals/transfers)    |
    |   ReceiverAcc |   INT         |   Foreign Key referencing ACCOUNT table (nullable, for deposits/transfers)     |
    |   Amount      |   DECIMAL(10, 2)  |   Transaction amount                                                           |
    |   TransactionDate   |   DATETIME    |   Date and time of the transaction                                             |
    |   Type        |   VARCHAR(20)   |   Transaction type ('Deposit', 'Withdraw', 'Transfer')                         |
    |   Approved    |   BOOLEAN     |   Indicates if the transaction was approved (for high-value transactions)      |
    |   EmployeeID    |   INT         |   Foreign Key referencing EMPLOYEE table                                       |
* **TRANSACTION\_REQUESTS**

    |   Column Name   |   Data Type   |   Description                                                                  |
    | :------------ | :------------ | :--------------------------------------------------------------------------- |
    |   RequestID   |   INT         |   Primary Key, auto-incrementing                                               |
    |   SenderAcc   |   INT         |   Foreign Key referencing ACCOUNT table (nullable)                               |
    |   ReceiverAcc |   INT         |   Foreign Key referencing ACCOUNT table (nullable)                               |
    |   Amount      |   DECIMAL(10, 2)  |   Transaction amount                                                           |
    |   Type        |   VARCHAR(20)   |   Transaction type ('Deposit', 'Withdraw', 'Transfer')                         |
    |   Status      |   VARCHAR(20)   |   Status of the transaction request ('Pending', 'Approved', 'Rejected')        |
    |   RequestDate   |   DATETIME    |   Date and time of the transaction request                                     |
    |   EmployeeID    |   INT         |   Foreign Key referencing EMPLOYEE table                                       |
* **AccountStatusLog**

    |   Column Name   |   Data Type   |   Description                                                                  |
    | :------------ | :------------ | :--------------------------------------------------------------------------- |
    |   LogID       |   INT         |   Primary Key, auto-incrementing                                               |
    |   AccountNo   |   INT         |   Foreign Key referencing ACCOUNT table                                      |
    |   OldStatus   |   VARCHAR(20)   |   Previous account status                                                      |
    |   NewStatus   |   VARCHAR(20)   |   New account status                                                           |
    |   ChangedTimestamp  |   DATETIME    |   Date and time when the account status was changed                           |

## Stored Procedures

The system includes several stored procedures for various operations:

* **RequestAccount(IN `cust_name` VARCHAR(100), IN `cust_email` VARCHAR(100), IN `cust_phone` VARCHAR(15), IN `cust_address` VARCHAR(255), IN `cust_password` VARCHAR(255))**
    * Description:  Inserts a new customer account request into the `CUSTOMER_REQUEST` table.
    * Parameters:
        * `cust_name`:  Customer name.
        * `cust_email`: Customer email.
        * `cust_phone`: Customer phone number.
        * `cust_address`: Customer address.
        * `cust_password`: Customer password.
* **ApproveAccount(IN `req_id` INT, IN `acc_type` VARCHAR(20), IN `emp_id` INT)**
    * Description: Approves a customer account request, creates a new account, and updates customer and request status.
    * Parameters:
        * `req_id`:  The ID of the customer request to approve.
        * `acc_type`: The type of account ('Savings' or 'Checking').
        * `emp_id`: The ID of the employee approving the request.
* **DepositWithLog(IN `acc_num` INT, IN `amount` DECIMAL(10, 2), IN `emp_id` INT)**
    * Description: Deposits money into an account, logs the transaction, and handles high-value deposit approval.
    * Parameters:
        * `acc_num`: The account number to deposit into.
        * `amount`: The amount to deposit.
        * `emp_id`: The ID of the employee processing the deposit.
* **WithdrawWithApproval(IN `acc_num` INT, IN `amount` DECIMAL(10, 2), IN `cust_id` INT, IN `emp_id` INT)**
    * Description: Withdraws money from an account, checks for sufficient funds, and handles high-value withdrawal approval.
    * Parameters:
        * `acc_num`: The account number to withdraw from.
        * `amount`: The amount to withdraw.
        * `cust_id`: The ID of the customer making the withdrawal.
        * `emp_id`: The ID of the employee processing the withdrawal.
* **TransferWithApproval(IN `sender_acc` INT, IN `receiver_acc` INT, IN `amount` DECIMAL(10, 2), IN `cust_id` INT, IN `emp_id` INT)**
    * Description: Transfers money between accounts, checks for sufficient funds, and handles high-value transfer approval.
    * Parameters:
        * `sender_acc`: The account number to transfer from.
        * `receiver_acc`: The account number to transfer to.
        * `amount`: The amount to transfer.
        * `cust_id`:  The ID of the customer making the transfer
        * `emp_id`: The ID of the employee processing the transfer.
* **ApproveTransactionRequest(IN `req_id` INT, IN `emp_id` INT)**
    * Description: Approves or rejects a pending transaction request.
    * Parameters:
        * `req_id`: The ID of the transaction request to approve.
        * `emp_id`: The ID of the employee approving the transaction.
* **GetCustomerDetails(IN `cust_id` INT)**
    * Description: Retrieves customer details
    * Parameters:
        * `cust_id`: The ID of the customer.
* **GetMiniStatement(IN `acc_num` INT)**
     * Description: Retrieves mini statement for an account.
     * Parameters:
        * `acc_num`: The account number.

## Views

The system includes several views to simplify data retrieval:

* **Pending\_Requests**: Shows all pending customer account requests.
    * Columns: `RequestID`, `Name`, `Email`, `Phone`, `Address`, `RequestedDate`, `Status`
* **Customer\_Transactions**: Shows all approved customer transactions.
     * Columns: `TransactionID`, `SenderAcc`, `ReceiverAcc`, `Amount`, `TransactionDate`, `Type`, `Approved`, `EmployeeID`
* **High\_Value\_Transactions**: Shows transactions with amounts greater than 50000.
    * Columns: `TransactionID`, `SenderAcc`, `ReceiverAcc`, `Amount`, `TransactionDate`, `Type`, `Approved`, `EmployeeID`
* **Customer\_Profile**: Joins customer and account information.
    * Columns: `CustomerID`, `Name`, `Email`, `Phone`, `Address`, `ApprovedDate`, `Status`, `AccountNo`, `AccountType`, `Balance`, `CreatedDate`
* **Customer\_Balance**: Shows customer account balances.
    * Columns: `CustomerID`, `Name`, `AccountNo`, `AccountType`, `Balance`
* **ActiveCustomerAccounts**: Shows active customer accounts.
     * Columns: `AccountNo`, `CustomerID`, `AccountType`, `Balance`, `CreatedDate`


## Triggers

The following triggers are implemented:

* **Block\_Suspended\_Account**: Prevents transactions on suspended accounts.
* **PreventNegativeBalance**: Prevents account balances from going negative.
* **LogAccountStatusChange**: Logs changes to account status.

## Testing Scripts

The repository includes SQL scripts to test the functionality of the banking system:

* **1.  SETUP\_Test.sql**: Script to set up test data.
* **2.  TESTING DEPOSIT.sql**: Script to test deposit functionality.
* **3.  TESTING WITHDRAWAL.sql**: Script to test withdrawal functionality.
* **4.  TESTING TRANSFER FUNCTIONALITY.sql**: Script to test transfer functionality.
* **Triggers Demonstration.sql**: Script specifically for demonstrating and testing the database triggers.

## Setup Instructions

1.  Ensure you have a MySQL database server installed and running.
2.  Create a new database named `BankingSystem`.
3.  Execute the SQL script `SimpleBankingManagementSystemVF.sql` to create the tables, stored procedures, views, and triggers.
4.  Optionally, run the scripts `1. SETUP_Test.sql`, `2. TESTING DEPOSIT.sql`, `3. TESTING WITHDRAWAL.sql`, and `4. TESTING TRANSFER FUNCTIONALITY.sql` to populate the database with test data and test the system functionalities.  The `Triggers Demonstration.sql` script provides specific trigger tests.

## File Descriptions

* **SimpleBankingManagementSystemVF.sql**: Contains the SQL code to create the database schema (tables), stored procedures, views, and triggers. This is the core setup script.
* **1.  SETUP\_Test.sql**: SQL script to insert initial data for testing purposes, including employees and customer accounts.
* **2.  TESTING DEPOSIT.sql**: SQL script to test the deposit functionality, including low-value and high-value deposits.
* **3.  TESTING WITHDRAWAL.sql**: SQL script to test the withdrawal functionality, including low-value withdrawals, insufficient funds scenarios and high-value withdrawals.
* **4.  TESTING TRANSFER FUNCTIONALITY.sql**: SQL script to test the transfer functionality, covering low and high-value transfers and insufficient funds.
* **Triggers Demonstration.sql**: SQL script to demonstrate and test the database triggers.

## Contributing

Contributions to this project are welcome. Please feel free to submit pull requests or open issues for any bugs, feature requests, or improvements.
