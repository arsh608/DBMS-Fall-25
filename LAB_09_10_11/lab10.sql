-- ============================================
-- Q1: Bank Accounts Transaction with ROLLBACK
-- ============================================

CREATE TABLE bank_accounts (
    account_no NUMBER PRIMARY KEY,
    holder_name VARCHAR2(100),
    balance NUMBER(10,2) DEFAULT 0
);

INSERT INTO bank_accounts (account_no, holder_name, balance) VALUES (101, 'John Smith', 25000);
INSERT INTO bank_accounts (account_no, holder_name, balance) VALUES (102, 'Emma Johnson', 18000);
INSERT INTO bank_accounts (account_no, holder_name, balance) VALUES (103, 'Robert Brown', 32000);

COMMIT;

SELECT 'Initial Balances:' as status FROM dual;
SELECT * FROM bank_accounts ORDER BY account_no;

BEGIN
    
    UPDATE bank_accounts SET balance = balance - 5000 WHERE account_no = 101;
    DBMS_OUTPUT.PUT_LINE('Deducted 5000 from account 101');
    
    UPDATE bank_accounts SET balance = balance + 5000 WHERE account_no = 102;
    DBMS_OUTPUT.PUT_LINE('Credited 5000 to account 102');
    
    UPDATE bank_accounts SET balance = balance - 10000 WHERE account_no = 103;
    DBMS_OUTPUT.PUT_LINE('Mistakenly deducted 10000 from account 103 (This was a mistake!)');
    
    DBMS_OUTPUT.PUT_LINE('Balances after updates (before rollback):');
    FOR rec IN (SELECT * FROM bank_accounts ORDER BY account_no) LOOP
        DBMS_OUTPUT.PUT_LINE('Account ' || rec.account_no || ': ' || rec.balance);
    END LOOP;
    
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('ROLLBACK executed - All changes undone');
    
END;
/

SELECT 'After ROLLBACK - Balances returned to original:' as status FROM dual;
SELECT * FROM bank_accounts ORDER BY account_no;

-- ============================================
-- Q2: Inventory Management with SAVEPOINTS
-- ============================================

CREATE TABLE inventory (
    item_id NUMBER PRIMARY KEY,
    item_name VARCHAR2(100),
    quantity NUMBER DEFAULT 0
);

INSERT INTO inventory (item_id, item_name, quantity) VALUES (1, 'Laptop', 100);
INSERT INTO inventory (item_id, item_name, quantity) VALUES (2, 'Mouse', 200);
INSERT INTO inventory (item_id, item_name, quantity) VALUES (3, 'Keyboard', 150);
INSERT INTO inventory (item_id, item_name, quantity) VALUES (4, 'Monitor', 80);

COMMIT;

SELECT 'Initial Inventory:' as status FROM dual;
SELECT * FROM inventory ORDER BY item_id;

BEGIN
    
    UPDATE inventory SET quantity = quantity - 10 WHERE item_id = 1;
    DBMS_OUTPUT.PUT_LINE('Reduced quantity of Laptop by 10');
    
    SAVEPOINT sp1;
    DBMS_OUTPUT.PUT_LINE('SAVEPOINT sp1 created');
    
    UPDATE inventory SET quantity = quantity - 20 WHERE item_id = 2;
    DBMS_OUTPUT.PUT_LINE('Reduced quantity of Mouse by 20');
    
    SAVEPOINT sp2;
    DBMS_OUTPUT.PUT_LINE('SAVEPOINT sp2 created');
    
    UPDATE inventory SET quantity = quantity - 5 WHERE item_id = 3;
    DBMS_OUTPUT.PUT_LINE('Reduced quantity of Keyboard by 5');
    
    DBMS_OUTPUT.PUT_LINE('Inventory after all reductions:');
    FOR rec IN (SELECT * FROM inventory ORDER BY item_id) LOOP
        DBMS_OUTPUT.PUT_LINE('Item ' || rec.item_id || ' (' || rec.item_name || '): ' || rec.quantity);
    END LOOP;
    
    ROLLBACK TO SAVEPOINT sp1;
    DBMS_OUTPUT.PUT_LINE('ROLLBACK TO SAVEPOINT sp1 executed');
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('COMMIT executed - Changes up to sp1 are saved');
    
END;
/

SELECT 'Final Inventory after Q2 transaction:' as status FROM dual;
SELECT * FROM inventory ORDER BY item_id;

-- ============================================
-- Q3: Fees Management with Partial Rollback
-- ============================================

CREATE TABLE fees (
    student_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    amount_paid NUMBER(10,2) DEFAULT 0,
    total_fee NUMBER(10,2) DEFAULT 100000
);

INSERT INTO fees (student_id, name, amount_paid, total_fee) VALUES (1, 'Alice Williams', 50000, 100000);
INSERT INTO fees (student_id, name, amount_paid, total_fee) VALUES (2, 'Bob Miller', 75000, 100000);
INSERT INTO fees (student_id, name, amount_paid, total_fee) VALUES (3, 'Carol Davis', 90000, 100000);

COMMIT;
SELECT 'Initial Fees Status:' as status FROM dual;
SELECT * FROM fees ORDER BY student_id;

BEGIN
    
    UPDATE fees SET amount_paid = amount_paid + 20000 WHERE student_id = 1;
    DBMS_OUTPUT.PUT_LINE('Updated amount_paid for Alice Williams (+20000)');
    
    SAVEPOINT halfway;
    DBMS_OUTPUT.PUT_LINE('SAVEPOINT halfway created');
    
    UPDATE fees SET amount_paid = amount_paid + 30000 WHERE student_id = 2;
    DBMS_OUTPUT.PUT_LINE('Updated amount_paid for Bob Miller (+30000) - BUT THIS IS AN ERROR!');
    
    DBMS_OUTPUT.PUT_LINE('Fees after both updates (including error):');
    FOR rec IN (SELECT * FROM fees ORDER BY student_id) LOOP
        DBMS_OUTPUT.PUT_LINE('Student ' || rec.student_id || ': Paid=' || rec.amount_paid || ', Balance=' || (rec.total_fee - rec.amount_paid));
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('ERROR DETECTED: Bob Miller should only pay 10000 more, not 30000!');
    ROLLBACK TO SAVEPOINT halfway;
    DBMS_OUTPUT.PUT_LINE('ROLLBACK TO SAVEPOINT halfway executed');
    
    UPDATE fees SET amount_paid = amount_paid + 10000 WHERE student_id = 2;
    DBMS_OUTPUT.PUT_LINE('Corrected: Updated amount_paid for Bob Miller (+10000)');
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('COMMIT executed - Only correct updates are saved');
    
END;
/

SELECT 'Final Fees Status after Q3 transaction:' as status FROM dual;
SELECT *, (total_fee - amount_paid) as balance_due FROM fees ORDER BY student_id;

-- ============================================
-- Q4: Products and Orders with Transaction Control
-- ============================================

CREATE TABLE products (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100),
    stock NUMBER DEFAULT 0
);

CREATE TABLE orders (
    order_id NUMBER PRIMARY KEY,
    product_id NUMBER,
    quantity NUMBER,
    order_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE seq_order_id START WITH 1001 INCREMENT BY 1;

INSERT INTO products (product_id, product_name, stock) VALUES (1, 'Smartphone', 50);
INSERT INTO products (product_id, product_name, stock) VALUES (2, 'Tablet', 30);
INSERT INTO products (product_id, product_name, stock) VALUES (3, 'Headphones', 100);

COMMIT;

SELECT 'Initial Products:' as status FROM dual;
SELECT * FROM products ORDER BY product_id;
SELECT 'Initial Orders:' as status FROM dual;
SELECT * FROM orders ORDER BY order_id;

BEGIN
    
    UPDATE products SET stock = stock - 5 WHERE product_id = 1;
    DBMS_OUTPUT.PUT_LINE('Reduced stock of Smartphone by 5');
    
    INSERT INTO orders (order_id, product_id, quantity, order_date)
    VALUES (seq_order_id.NEXTVAL, 1, 5, SYSDATE);
    DBMS_OUTPUT.PUT_LINE('Inserted order for 5 Smartphones');
    
    DELETE FROM products WHERE product_id = 2;
    DBMS_OUTPUT.PUT_LINE('DELETED product_id 2 (Tablet) - THIS WAS A MISTAKE!');
    
    DBMS_OUTPUT.PUT_LINE('State before rollback:');
    DBMS_OUTPUT.PUT_LINE('Products:');
    FOR rec IN (SELECT * FROM products ORDER BY product_id) LOOP
        DBMS_OUTPUT.PUT_LINE('  Product ' || rec.product_id || ': ' || rec.product_name || ' - Stock: ' || rec.stock);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Orders:');
    FOR rec IN (SELECT * FROM orders ORDER BY order_id) LOOP
        DBMS_OUTPUT.PUT_LINE('  Order ' || rec.order_id || ': Product ' || rec.product_id || ' - Qty: ' || rec.quantity);
    END LOOP;
    
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('ROLLBACK executed - All changes undone (including the mistaken delete)');
    
END;
/

SELECT 'After Rollback - Products restored:' as status FROM dual;
SELECT * FROM products ORDER BY product_id;
SELECT 'After Rollback - Orders empty:' as status FROM dual;
SELECT * FROM orders ORDER BY order_id;

BEGIN
    
    UPDATE products SET stock = stock - 3 WHERE product_id = 1;
    DBMS_OUTPUT.PUT_LINE('Reduced stock of Smartphone by 3');

    INSERT INTO orders (order_id, product_id, quantity, order_date)
    VALUES (seq_order_id.NEXTVAL, 1, 3, SYSDATE);
    DBMS_OUTPUT.PUT_LINE('Inserted order for 3 Smartphones');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('COMMIT executed - Transaction completed successfully');
    
END;
/

SELECT 'Final Products after Q4:' as status FROM dual;
SELECT * FROM products ORDER BY product_id;
SELECT 'Final Orders after Q4:' as status FROM dual;
SELECT * FROM orders ORDER BY order_id;

-- ============================================
-- Q5: Employee Salary Updates with Multiple SAVEPOINTS
-- ============================================

CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    emp_name VARCHAR2(100),
    salary NUMBER(10,2)
);

INSERT INTO employees (emp_id, emp_name, salary) VALUES (1, 'David Wilson', 50000);
INSERT INTO employees (emp_id, emp_name, salary) VALUES (2, 'Sarah Taylor', 60000);
INSERT INTO employees (emp_id, emp_name, salary) VALUES (3, 'Michael Lee', 55000);
INSERT INTO employees (emp_id, emp_name, salary) VALUES (4, 'Jessica Martin', 65000);
INSERT INTO employees (emp_id, emp_name, salary) VALUES (5, 'Kevin Anderson', 70000);

COMMIT;

SELECT 'Initial Employee Salaries:' as status FROM dual;
SELECT * FROM employees ORDER BY emp_id;

BEGIN

    UPDATE employees SET salary = salary * 1.10 WHERE emp_id = 1;
    DBMS_OUTPUT.PUT_LINE('Increased salary of David Wilson by 10%');

    SAVEPOINT A;
    DBMS_OUTPUT.PUT_LINE('SAVEPOINT A created');

    UPDATE employees SET salary = salary * 1.15 WHERE emp_id = 2;
    DBMS_OUTPUT.PUT_LINE('Increased salary of Sarah Taylor by 15%');

    SAVEPOINT B;
    DBMS_OUTPUT.PUT_LINE('SAVEPOINT B created');

    UPDATE employees SET salary = salary * 1.20 WHERE emp_id = 3;
    DBMS_OUTPUT.PUT_LINE('Increased salary of Michael Lee by 20%');

    DBMS_OUTPUT.PUT_LINE('Salaries after all increases:');
    FOR rec IN (SELECT * FROM employees WHERE emp_id IN (1,2,3) ORDER BY emp_id) LOOP
        DBMS_OUTPUT.PUT_LINE('  Emp ' || rec.emp_id || ': ' || rec.emp_name || ' - Salary: ' || rec.salary);
    END LOOP;

    ROLLBACK TO SAVEPOINT A;
    DBMS_OUTPUT.PUT_LINE('ROLLBACK TO SAVEPOINT A executed');

    DBMS_OUTPUT.PUT_LINE('Salaries after rollback to SAVEPOINT A:');
    FOR rec IN (SELECT * FROM employees WHERE emp_id IN (1,2,3) ORDER BY emp_id) LOOP
        DBMS_OUTPUT.PUT_LINE('  Emp ' || rec.emp_id || ': ' || rec.emp_name || ' - Salary: ' || rec.salary);
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('COMMIT executed - Only David Wilson''s salary increase is saved');
    
END;
/

SELECT 'Final Employee Salaries after Q5 transaction:' as status FROM dual;
SELECT * FROM employees ORDER BY emp_id;

