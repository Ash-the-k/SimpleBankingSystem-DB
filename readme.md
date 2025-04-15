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
* [Detailed Documentation](detailedReadMe.md)

## Database Schema

The database schema consists of the following tables:

* **CUSTOMER\_REQUEST**: Stores information about customer account requests.
* **CUSTOMER**: Stores customer information.
* **EMPLOYEE**: Stores employee information.
* **ACCOUNT**: Stores account details.
* **TRANSACTIONS**: Stores transaction details.
* **TRANSACTION\_REQUESTS**: Stores requests for transactions that require approval.
* **AccountStatusLog**: Logs changes to account status.

## Stored Procedures

The system includes several stored procedures for various operations:

* **RequestAccount**: For customers to request a new account.
* **ApproveAccount**: For employees to approve customer account requests.
* **DepositWithLog**: For depositing money into an account, with logging and high-value deposit approval workflow.
* **WithdrawWithApproval**: For withdrawing money from an account, with approval workflow and balance checks.
* **TransferWithApproval**: For transferring money between accounts, with approval for high-value transfers and insufficient funds check.
* **ApproveTransactionRequest**: For employees to approve or reject pending transaction requests.
* **GetCustomerDetails**: To retrieve customer information.
* **GetMiniStatement**: To retrieve a mini-statement of recent transactions.

## Views

The system includes several views to simplify data retrieval:

* **Pending\_Requests**: Shows all pending customer account requests.
* **Customer\_Transactions**: Shows all approved customer transactions.
* **High\_Value\_Transactions**: Shows transactions with amounts greater than 50000.
* **Customer\_Profile**: Joins customer and account information.
* **Customer\_Balance**: Shows customer account balances.
* **ActiveCustomerAccounts**: Shows active customer accounts.

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
4.  Optionally, run the scripts `1. SETUP_Test.sql`, `2. TESTING DEPOSIT.sql`, `3. TESTING WITHDRAWAL.sql`, and `4.  TESTING TRANSFER FUNCTIONALITY.sql` to populate the database with test data and test the system functionalities.
5.  The `Triggers Demonstration.sql` script provides specific trigger tests.

## File Descriptions

* **SimpleBankingManagementSystemVF.sql**: Contains the SQL code to create the database schema (tables), stored procedures, views, and triggers. This is the core setup script.
* **1.  SETUP\_Test.sql**: SQL script to insert initial data for testing purposes, including employees and customer accounts.
* **2.  TESTING DEPOSIT.sql**: SQL script to test the deposit functionality, including low-value and high-value deposits.
* **3.  TESTING WITHDRAWAL.sql**: SQL script to test the withdrawal functionality, including low-value withdrawals, insufficient funds scenarios and high-value withdrawals.
* **4.  TESTING TRANSFER FUNCTIONALITY.sql**: SQL script to test the transfer functionality, covering low and high-value transfers and insufficient funds.
* **Triggers Demonstration.sql**: SQL script to demonstrate and test the database triggers.

## Contributing

Contributions to this project are welcome. Please feel free to submit pull requests or open issues for any bugs, feature requests, or improvements.

## Detailed Documentation

For more comprehensive information, please refer to the [Detailed Documentation](detailedReadMe.md).