/*
TRANSACTION CONTROL LANGUAGE (TCL) REFERENCE
Based on DB Lab 10 Manual and TCL.txt
Only essential concepts, no extras
*/

/*****************************
1. BASIC TRANSACTION CONTROL
*****************************/

-- Check current data
SELECT * FROM BOOKS;

-- INSERT with manual COMMIT
INSERT INTO books VALUES(1, 'TOC');
COMMIT;  -- Makes the INSERT permanent

-- Create SAVEPOINT
SAVEPOINT First;
INSERT INTO books VALUES(2, 'Algo');
INSERT INTO books VALUES(3, 'DAA');

-- Create another SAVEPOINT
SAVEPOINT Second;
INSERT INTO books VALUES(4, 'Algo');
INSERT INTO books VALUES(5, 'DAA');

-- Rollback to specific SAVEPOINT
ROLLBACK TO First;  -- Undoes inserts after First savepoint

-- Final COMMIT to save remaining changes
COMMIT;

/*****************************
2. TRANSACTION FLOW EXAMPLES
*****************************/

-- Example 1: Named transaction with savepoints
SET TRANSACTION NAME 'sal_update';

UPDATE employees SET salary = 7000 WHERE last_name = 'Banda';
SAVEPOINT after_banda_sal;

UPDATE employees SET salary = 12000 WHERE last_name = 'Greene';
SAVEPOINT after_greene_sal;

-- Partial rollback
ROLLBACK TO SAVEPOINT after_banda_sal;  -- Undoes Greene's update

UPDATE employees SET salary = 11000 WHERE last_name = 'Greene';

-- Complete rollback
ROLLBACK;  -- Undoes all changes in this transaction

-- Start new transaction
SET TRANSACTION NAME 'sal_update2';
UPDATE employees SET salary = 7050 WHERE last_name = 'Banda';
UPDATE employees SET salary = 10950 WHERE last_name = 'Greene';

-- Final commit
COMMIT;  -- Makes both updates permanent

/*****************************
3. AUTOCOMMIT CONTROL
*****************************/

-- Enable AUTOCOMMIT (each DML auto-commits)
SET AUTOCOMMIT ON;

INSERT INTO worker (worker_id, worker_name, salary) VALUES (3, 'FAST-NU', 5000);
-- Automatically committed

-- Disable AUTOCOMMIT (requires manual commit)
SET AUTOCOMMIT OFF;

INSERT INTO worker (worker_id, worker_name, salary) VALUES (4, 'Test', 6000);
-- Not committed yet, need COMMIT

COMMIT;  -- Now it's permanent

/*****************************
4. PRACTICAL SCENARIO: CUSTOMER ORDER
*****************************/

-- Create tables
CREATE TABLE customer (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(50),
    balance NUMBER
);

CREATE TABLE orders (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    order_amount NUMBER,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Transaction: Customer places order
SET TRANSACTION NAME 'customer_order_transaction';

-- Step 1: Insert new customer
INSERT INTO customer (customer_id, customer_name, balance) 
VALUES (101, 'John Doe', 1000);
SAVEPOINT customer_added;

-- Step 2: Insert order and update balance
INSERT INTO orders (order_id, customer_id, order_amount)
VALUES (501, 101, 200);

UPDATE customer 
SET balance = balance - 200 
WHERE customer_id = 101;

SAVEPOINT order_added;

-- Check if balance is sufficient
-- If balance < 0, rollback to customer_added
-- If all OK, commit

COMMIT;  -- OR ROLLBACK TO customer_added if error

/*****************************
5. WORKER TABLE EXAMPLE
*****************************/

-- Create worker table
CREATE TABLE worker (
    worker_id NUMBER PRIMARY KEY,
    worker_name VARCHAR2(50),
    salary NUMBER
);

-- Session 1: First transaction
INSERT INTO worker (worker_id, worker_name, salary) VALUES (1, 'Sohail', 5000);
UPDATE worker SET salary = 6000 WHERE worker_id = 1;
-- Not committed yet

-- Session 2: Try to update same row (will wait/block)
-- UPDATE worker SET salary = 7000 WHERE worker_id = 1;

-- Session 1: Commit to release lock
COMMIT;

-- Now Session 2 can proceed

-- Using savepoints in worker table
SET TRANSACTION NAME 'test_transaction';
INSERT INTO worker (worker_id, worker_name, salary) VALUES (2, 'Erum', 5500);
SAVEPOINT sp1;

UPDATE worker SET salary = 6000 WHERE worker_name = 'Erum';
SAVEPOINT sp2;

-- Partial rollback
ROLLBACK TO SAVEPOINT sp1;  -- Salary goes back to 5500

-- Final commit
COMMIT;


SELECT * FROM worker;
SELECT * FROM customer;
SELECT * FROM orders;
SELECT * FROM books;
