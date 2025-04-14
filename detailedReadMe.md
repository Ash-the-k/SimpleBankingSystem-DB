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

* **RequestAccount(IN `cust_name` VARCHAR(100), IN `cust_email` VARCHAR(100), IN `cust_phone` VARCHAR(15), IN `cust_address`)**
    * Description:  Inserts a new customer account request into the `CUSTOMER_REQUEST`
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


## Contributing

Contributions to this project are welcome. Please feel free to submit pull requests or open issues for any bugs, feature requests, or improvements.

---