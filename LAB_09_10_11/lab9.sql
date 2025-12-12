CREATE TABLE EMPLOYEES (
    employee_id NUMBER PRIMARY KEY,
    employee_name VARCHAR2(100),
    salary NUMBER(10,2),
    department_id NUMBER,
    hire_date DATE
);

CREATE TABLE EMP (
    emp_id NUMBER PRIMARY KEY,
    emp_name VARCHAR2(100),
    department_id NUMBER,
    salary NUMBER(10,2)
);

CREATE TABLE PRODUCTS (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100),
    price NUMBER(10,2),
    category VARCHAR2(50)
);

CREATE TABLE COURSES (
    course_id NUMBER PRIMARY KEY,
    course_name VARCHAR2(100),
    credits NUMBER,
    created_by VARCHAR2(50),
    created_date DATE
);

CREATE TABLE SALES (
    sale_id NUMBER PRIMARY KEY,
    product_id NUMBER,
    quantity NUMBER,
    unit_price NUMBER(10,2),
    sale_date DATE,
    total_amount NUMBER(10,2)
);

CREATE TABLE ORDERS (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    order_date DATE,
    order_status VARCHAR2(20) DEFAULT 'PENDING',
    total_amount NUMBER(10,2),
    CONSTRAINT chk_order_status CHECK (order_status IN ('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED'))
);

-- ============================================
-- TASK 1: Create a BEFORE INSERT trigger on STUDENTS table that automatically 
-- converts student names to uppercase before insertion.
-- ============================================

CREATE TABLE STUDENTS (
    student_id NUMBER PRIMARY KEY,
    student_name VARCHAR2(100),
    email VARCHAR2(100),
    enrollment_date DATE
);

CREATE OR REPLACE TRIGGER trg_students_before_insert
BEFORE INSERT ON STUDENTS
FOR EACH ROW
BEGIN
    :NEW.student_name := UPPER(:NEW.student_name);
END;
/

INSERT INTO STUDENTS (student_id, student_name, email, enrollment_date)
VALUES (1, 'john doe', 'john@example.com', SYSDATE);

SELECT * FROM STUDENTS;

-- ============================================
-- TASK 2: Write a trigger that prevents deletion of rows from the EMPLOYEES 
-- table during weekends.
-- ============================================

CREATE OR REPLACE TRIGGER trg_prevent_delete_weekend
BEFORE DELETE ON EMPLOYEES
BEGIN
    IF TO_CHAR(SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Deletions from EMPLOYEES table are not allowed on weekends.');
    END IF;
END;
/


-- ============================================
-- TASK 3: Create a trigger that logs all UPDATE operations on the SALARY column 
-- of the EMPLOYEES table into a separate LOG_SALARY_AUDIT table.
-- ============================================

CREATE TABLE LOG_SALARY_AUDIT (
    audit_id NUMBER PRIMARY KEY,
    employee_id NUMBER,
    old_salary NUMBER(10,2),
    new_salary NUMBER(10,2),
    updated_by VARCHAR2(50),
    update_date DATE
);

CREATE SEQUENCE seq_audit_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_log_salary_update
AFTER UPDATE OF salary ON EMPLOYEES
FOR EACH ROW
WHEN (OLD.salary <> NEW.salary OR (OLD.salary IS NULL AND NEW.salary IS NOT NULL) 
      OR (OLD.salary IS NOT NULL AND NEW.salary IS NULL))
BEGIN
    INSERT INTO LOG_SALARY_AUDIT (audit_id, employee_id, old_salary, new_salary, updated_by, update_date)
    VALUES (seq_audit_id.NEXTVAL, :OLD.employee_id, :OLD.salary, :NEW.salary, USER, SYSDATE);
END;
/
INSERT INTO EMPLOYEES (employee_id, employee_name, salary, department_id, hire_date)
VALUES (1, 'Alice Smith', 50000, 10, SYSDATE);

UPDATE EMPLOYEES SET salary = 55000 WHERE employee_id = 1;

SELECT * FROM LOG_SALARY_AUDIT;

-- ============================================
-- TASK 4: Design a BEFORE UPDATE trigger that ensures the PRICE of a product 
-- in the PRODUCTS table cannot be set to a negative value.
-- ============================================

CREATE OR REPLACE TRIGGER trg_validate_product_price
BEFORE UPDATE OF price ON PRODUCTS
FOR EACH ROW
BEGIN
    IF :NEW.price < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'Product price cannot be set to a negative value.');
    END IF;
END;
/

INSERT INTO PRODUCTS (product_id, product_name, price, category)
VALUES (1, 'Laptop', 999.99, 'Electronics');


-- ============================================
-- TASK 5: Write a trigger that inserts the username and timestamp whenever a 
-- record is inserted into the COURSES table.
-- ============================================

CREATE OR REPLACE TRIGGER trg_courses_audit_insert
BEFORE INSERT ON COURSES
FOR EACH ROW
BEGIN
    :NEW.created_by := USER;
    :NEW.created_date := SYSDATE;
END;
/

INSERT INTO COURSES (course_id, course_name, credits)
VALUES (1, 'Database Systems', 3);

SELECT * FROM COURSES;

-- ============================================
-- TASK 6: Create a trigger that automatically sets a DEFAULT department_id 
-- value in the EMP table if none is provided during insertion.
-- ============================================

CREATE OR REPLACE TRIGGER trg_emp_default_dept
BEFORE INSERT ON EMP
FOR EACH ROW
BEGIN
    IF :NEW.department_id IS NULL THEN
        :NEW.department_id := 99;
    END IF;
END;
/

INSERT INTO EMP (emp_id, emp_name, salary) 
VALUES (1, 'Bob Johnson', 45000);

SELECT * FROM EMP;

-- ============================================
-- TASK 7: Develop a compound trigger for the SALES table that calculates 
-- total sales amount before and after bulk inserts.
-- ============================================

CREATE OR REPLACE TRIGGER trg_sales_compound
FOR INSERT ON SALES
COMPOUND TRIGGER

    total_rows NUMBER := 0;
    total_amount_sum NUMBER := 0;

    BEFORE STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Starting bulk insert operation at: ' || TO_CHAR(SYSDATE, 'HH24:MI:SS'));
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN

        :NEW.total_amount := :NEW.quantity * :NEW.unit_price;
        total_rows := total_rows + 1;
        total_amount_sum := total_amount_sum + :NEW.total_amount;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        NULL;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Bulk insert completed. Total rows inserted: ' || total_rows);
        DBMS_OUTPUT.PUT_LINE('Total sales amount: ' || total_amount_sum);
        DBMS_OUTPUT.PUT_LINE('End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SS'));
    END AFTER STATEMENT;
    
END trg_sales_compound;
/

SET SERVEROUTPUT ON;

INSERT INTO SALES (sale_id, product_id, quantity, unit_price, sale_date)
VALUES (1, 101, 2, 50.00, SYSDATE);

INSERT INTO SALES (sale_id, product_id, quantity, unit_price, sale_date)
VALUES (2, 102, 3, 75.00, SYSDATE);

SELECT * FROM SALES;

-- ============================================
-- TASK 8: Create a DDL trigger that audits every CREATE or DROP statement 
-- executed in your schema and stores details in SCHEMA_DDL_LOG.
-- ============================================

CREATE TABLE SCHEMA_DDL_LOG (
    log_id NUMBER PRIMARY KEY,
    username VARCHAR2(50),
    event_type VARCHAR2(50),
    object_type VARCHAR2(50),
    object_name VARCHAR2(100),
    sql_text CLOB,
    log_date DATE
);

CREATE SEQUENCE seq_ddl_log_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_audit_ddl
AFTER CREATE OR DROP ON SCHEMA
DECLARE
    v_sql_text ORA_NAME_LIST_T;
    v_sql_stmt CLOB := '';
    v_list_length NUMBER;
BEGIN

    v_list_length := ORA_SQL_TXT(v_sql_text);
    
    FOR i IN 1..v_list_length LOOP
        v_sql_stmt := v_sql_stmt || v_sql_text(i);
    END LOOP;

    INSERT INTO SCHEMA_DDL_LOG (log_id, username, event_type, object_type, 
                               object_name, sql_text, log_date)
    VALUES (seq_ddl_log_id.NEXTVAL, USER, ORA_SYSEVENT, ORA_DICT_OBJ_TYPE,
           ORA_DICT_OBJ_NAME, v_sql_stmt, SYSDATE);
END;
/

CREATE TABLE TEST_DDL_AUDIT (
    id NUMBER,
    name VARCHAR2(50)
);

DROP TABLE TEST_DDL_AUDIT;

SELECT * FROM SCHEMA_DDL_LOG;

-- ============================================
-- TASK 9: Write a trigger that prevents updates on an ORDER table if the 
-- order_status is marked as 'SHIPPED'.
-- ============================================

CREATE OR REPLACE TRIGGER trg_prevent_update_shipped
BEFORE UPDATE ON ORDERS
FOR EACH ROW
BEGIN
    IF :OLD.order_status = 'SHIPPED' THEN
        RAISE_APPLICATION_ERROR(-20003, 
            'Cannot update orders with SHIPPED status.');
    END IF;
END;
/

INSERT INTO ORDERS (order_id, customer_id, order_date, order_status, total_amount)
VALUES (1, 1001, SYSDATE, 'SHIPPED', 150.00);

INSERT INTO ORDERS (order_id, customer_id, order_date, order_status, total_amount)
VALUES (2, 1002, SYSDATE, 'PENDING', 75.00);

UPDATE ORDERS SET total_amount = 80 WHERE order_id = 2;

-- ============================================
-- TASK 10: Create a schema-level LOGON trigger that records each user's login 
-- time and username into a LOGIN_AUDIT table.
-- ============================================

CREATE TABLE LOGIN_AUDIT (
    login_id NUMBER PRIMARY KEY,
    username VARCHAR2(50),
    login_time TIMESTAMP,
    session_id NUMBER,
    host VARCHAR2(100),
    ip_address VARCHAR2(50)
);

CREATE SEQUENCE seq_login_id START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_logon_audit
AFTER LOGON ON DATABASE
DECLARE
    v_host VARCHAR2(100);
    v_ip VARCHAR2(50);
BEGIN
    BEGIN
        v_host := SYS_CONTEXT('USERENV', 'HOST');
    EXCEPTION
        WHEN OTHERS THEN v_host := 'UNKNOWN';
    END;
    
    BEGIN
        v_ip := SYS_CONTEXT('USERENV', 'IP_ADDRESS');
    EXCEPTION
        WHEN OTHERS THEN v_ip := 'UNKNOWN';
    END;

    INSERT INTO LOGIN_AUDIT (login_id, username, login_time, session_id, host, ip_address)
    VALUES (seq_login_id.NEXTVAL, USER, SYSTIMESTAMP, USERENV('SESSIONID'), v_host, v_ip);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
