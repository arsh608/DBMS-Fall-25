/*
PL/SQL MASTER REFERENCE FILE
Combining all concepts from Lab Manual and Practice Files
*/

-- Enable output display in SQL*Plus or SQL Developer
SET SERVEROUTPUT ON;

/*****************************
1. BASIC PL/SQL BLOCK STRUCTURE
*****************************/
DECLARE
    -- Declarations Section: Variables, constants, cursors, exceptions
    v_section_name VARCHAR2(20) := 'Section A';
    v_course_name VARCHAR2(50) := 'Database Systems Lab';
    v_counter NUMBER := 0;
BEGIN
    -- Executable Section: Main logic goes here
    v_counter := v_counter + 1;
    DBMS_OUTPUT.PUT_LINE('This is ' || v_section_name || 
                        ' and the course is ' || v_course_name);
    DBMS_OUTPUT.PUT_LINE('Counter: ' || v_counter);
    
EXCEPTION
    -- Exception Handling Section (Optional)
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/


/*****************************
2. VARIABLES AND DATA TYPES
*****************************/

-- Example 1: Basic variable declaration and assignment
DECLARE
    -- Basic data types
    v_number NUMBER := 100;
    v_float REAL := 70.0/3.0;
    v_text VARCHAR2(50) := 'Hello World';
    v_date DATE := SYSDATE;
    
    -- Using %TYPE to match column type (recommended)
    v_emp_id employees.employee_id%TYPE;
    v_emp_salary employees.salary%TYPE;
    
    -- Using %ROWTYPE for record type
    v_emp_record employees%ROWTYPE;
BEGIN
    v_number := v_number + 50;
    DBMS_OUTPUT.PUT_LINE('Number: ' || v_number);
    DBMS_OUTPUT.PUT_LINE('Float: ' || ROUND(v_float, 2));
    DBMS_OUTPUT.PUT_LINE('Text: ' || v_text);
    DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(v_date, 'DD-MON-YYYY'));
END;
/

-- Example 2: Variable scope (Global vs Local)
DECLARE
    -- Global variables in outer block
    global_num NUMBER := 100;
    global_text VARCHAR2(20) := 'Global';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Outer - Global: ' || global_text || ' = ' || global_num);
    
    DECLARE
        -- Local variables in inner block (shadows outer variables)
        global_num NUMBER := 200;  -- This is different from outer variable
        local_text VARCHAR2(20) := 'Local';
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Inner - Global: ' || global_text || ' = ' || global_num);
        DBMS_OUTPUT.PUT_LINE('Inner - Local: ' || local_text);
    END;
    
    -- Outer block still sees original global variable
    DBMS_OUTPUT.PUT_LINE('Outer - Global after inner block: ' || global_num);
END;
/


/*****************************
3. CONDITIONAL LOGIC
*****************************/

-- IF-THEN Statement
DECLARE
    v_salary employees.salary%TYPE;
    v_emp_id employees.employee_id%TYPE := 100;
BEGIN
    SELECT salary INTO v_salary 
    FROM employees 
    WHERE employee_id = v_emp_id;
    
    IF v_salary >= 5000 THEN
        DBMS_OUTPUT.PUT_LINE('High salary employee');
    END IF;
END;
/

-- IF-THEN-ELSE Statement
DECLARE
    v_count NUMBER;
    v_emp_id employees.employee_id%TYPE := 1100;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM employees 
    WHERE employee_id = v_emp_id;
    
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Record already exists');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Record can be inserted');
        -- INSERT statement would go here
    END IF;
END;
/

-- IF-THEN-ELSIF Statement (Multiple conditions)
DECLARE
    v_salary employees.salary%TYPE;
    v_emp_id employees.employee_id%TYPE := 100;
BEGIN
    SELECT salary INTO v_salary 
    FROM employees 
    WHERE employee_id = v_emp_id;
    
    IF v_salary <= 15000 THEN
        DBMS_OUTPUT.PUT_LINE('Salary band: Low');
    ELSIF v_salary <= 25000 THEN
        DBMS_OUTPUT.PUT_LINE('Salary band: Medium');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Salary band: High');
    END IF;
END;
/

-- CASE Statement (Simple CASE)
DECLARE
    v_department_id employees.department_id%TYPE;
    v_emp_id employees.employee_id%TYPE := 100;
BEGIN
    SELECT department_id INTO v_department_id 
    FROM employees 
    WHERE employee_id = v_emp_id;
    
    CASE v_department_id
        WHEN 80 THEN
            DBMS_OUTPUT.PUT_LINE('Sales Department');
        WHEN 50 THEN
            DBMS_OUTPUT.PUT_LINE('Shipping Department');
        WHEN 40 THEN
            DBMS_OUTPUT.PUT_LINE('Human Resources');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Other Department');
    END CASE;
END;
/

-- Searched CASE Statement
DECLARE
    v_salary employees.salary%TYPE;
    v_emp_id employees.employee_id%TYPE := 100;
BEGIN
    SELECT salary INTO v_salary 
    FROM employees 
    WHERE employee_id = v_emp_id;
    
    CASE
        WHEN v_salary < 5000 THEN
            DBMS_OUTPUT.PUT_LINE('Grade: Junior');
        WHEN v_salary BETWEEN 5000 AND 15000 THEN
            DBMS_OUTPUT.PUT_LINE('Grade: Mid-Level');
        WHEN v_salary > 15000 THEN
            DBMS_OUTPUT.PUT_LINE('Grade: Senior');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Grade: Not specified');
    END CASE;
END;
/

-- Nested IF Statements
DECLARE
    v_salary employees.salary%TYPE;
    v_department_id employees.department_id%TYPE;
    v_emp_id employees.employee_id%TYPE := 100;
BEGIN
    SELECT salary, department_id INTO v_salary, v_department_id
    FROM employees 
    WHERE employee_id = v_emp_id;
    
    IF v_department_id = 90 THEN
        IF v_salary >= 20000 THEN
            DBMS_OUTPUT.PUT_LINE('Executive with high salary');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Executive with moderate salary');
        END IF;
    ELSIF v_department_id = 60 THEN
        DBMS_OUTPUT.PUT_LINE('IT Department employee');
    END IF;
END;
/


/*****************************
4. LOOPS
*****************************/

-- FOR LOOP with implicit cursor (Simplest form)
BEGIN
    -- FOR loop automatically opens, fetches, and closes cursor
    FOR emp_rec IN (
        SELECT first_name, salary, hire_date 
        FROM employees 
        WHERE department_id = 80
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Name: ' || emp_rec.first_name || 
            ', Salary: ' || emp_rec.salary || 
            ', Hire Date: ' || TO_CHAR(emp_rec.hire_date, 'DD-MON-YYYY')
        );
    END LOOP;
END;
/

-- WHILE LOOP
DECLARE
    v_counter NUMBER := 1;
BEGIN
    WHILE v_counter <= 5 LOOP
        DBMS_OUTPUT.PUT_LINE('Counter: ' || v_counter);
        v_counter := v_counter + 1;
    END LOOP;
END;
/

-- BASIC LOOP with EXIT condition
DECLARE
    v_counter NUMBER := 1;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE('Iteration: ' || v_counter);
        v_counter := v_counter + 1;
        EXIT WHEN v_counter > 3;
    END LOOP;
END;
/


/*****************************
5. CURSORS (Explicit)
*****************************/

-- Basic Explicit Cursor
DECLARE
    -- Step 1: DECLARE cursor
    CURSOR emp_cursor IS
        SELECT first_name, salary 
        FROM employees 
        WHERE department_id = 80;
    
    -- Variables to hold fetched data
    v_name employees.first_name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    -- Step 2: OPEN cursor
    OPEN emp_cursor;
    
    LOOP
        -- Step 3: FETCH row
        FETCH emp_cursor INTO v_name, v_salary;
        
        -- Step 4: Check if no more rows
        EXIT WHEN emp_cursor%NOTFOUND;
        
        -- Process data
        DBMS_OUTPUT.PUT_LINE(v_name || ' earns ' || v_salary);
    END LOOP;
    
    -- Step 5: CLOSE cursor
    CLOSE emp_cursor;
END;
/

-- Cursor with FOR LOOP (Simplified)
DECLARE
    CURSOR dept_cursor IS
        SELECT department_id, department_name
        FROM departments;
BEGIN
    -- FOR loop automatically handles open, fetch, close
    FOR dept_rec IN dept_cursor LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Dept ID: ' || dept_rec.department_id || 
            ', Name: ' || dept_rec.department_name
        );
    END LOOP;
END;
/

-- Cursor with Parameter
DECLARE
    -- Parameterized cursor
    CURSOR emp_dept_cursor(p_dept_id NUMBER) IS
        SELECT employee_id, first_name, salary
        FROM employees
        WHERE department_id = p_dept_id;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Employees in Dept 90 ---');
    FOR emp_rec IN emp_dept_cursor(90) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'ID: ' || emp_rec.employee_id || 
            ', Name: ' || emp_rec.first_name || 
            ', Salary: ' || emp_rec.salary
        );
    END LOOP;
END;
/

-- Cursor Attributes
DECLARE
    CURSOR emp_cursor IS
        SELECT * FROM employees WHERE department_id = 80;
    v_emp_record employees%ROWTYPE;
BEGIN
    OPEN emp_cursor;
    
    -- %ISOPEN: Check if cursor is open
    IF emp_cursor%ISOPEN THEN
        DBMS_OUTPUT.PUT_LINE('Cursor is open');
    END IF;
    
    -- %ROWCOUNT: Number of rows fetched so far
    LOOP
        FETCH emp_cursor INTO v_emp_record;
        EXIT WHEN emp_cursor%NOTFOUND;
        IF emp_cursor%ROWCOUNT = 5 THEN
            DBMS_OUTPUT.PUT_LINE('Fetched 5th record');
        END IF;
    END LOOP;
    
    -- %FOUND and %NOTFOUND
    DBMS_OUTPUT.PUT_LINE('Total records fetched: ' || emp_cursor%ROWCOUNT);
    
    CLOSE emp_cursor;
END;
/


/*****************************
6. FUNCTIONS
*****************************/

-- Scalar Function (returns single value)
CREATE OR REPLACE FUNCTION calculate_salary(dept_id IN NUMBER)
RETURN NUMBER
IS
    total_salary NUMBER := 0;
BEGIN
    SELECT SUM(salary) INTO total_salary 
    FROM employees 
    WHERE department_id = dept_id;
    
    RETURN total_salary;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END calculate_salary;
/

-- Using the function
BEGIN
    DBMS_OUTPUT.PUT_LINE('Total salary in Dept 80: ' || calculate_salary(80));
END;
/

-- Function without parameters
CREATE OR REPLACE FUNCTION get_total_employee_count
RETURN NUMBER
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM employees;
    RETURN v_count;
END get_total_employee_count;
/

-- Table Function (returns collection)
-- First create object type and table type
CREATE OR REPLACE TYPE emp_obj_type AS OBJECT (
    emp_id NUMBER,
    emp_name VARCHAR2(50),
    hire_date DATE
);
/

CREATE OR REPLACE TYPE emp_tbl_type AS TABLE OF emp_obj_type;
/

-- Function returning table of objects
CREATE OR REPLACE FUNCTION get_employee_details(p_dept_id NUMBER)
RETURN emp_tbl_type
IS
    emp_details emp_tbl_type := emp_tbl_type();
BEGIN
    -- Use BULK COLLECT for efficiency
    SELECT emp_obj_type(employee_id, first_name, hire_date)
    BULK COLLECT INTO emp_details
    FROM employees
    WHERE department_id = p_dept_id;
    
    RETURN emp_details;
END get_employee_details;
/

-- Using table function
SELECT * FROM TABLE(get_employee_details(80));
/


/*****************************
7. PROCEDURES
*****************************/

-- Procedure without parameters
CREATE OR REPLACE PROCEDURE display_all_employees
AS
BEGIN
    FOR emp_rec IN (SELECT * FROM employees) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Employee: ' || emp_rec.first_name || 
            ' ' || emp_rec.last_name || 
            ', Salary: ' || emp_rec.salary
        );
    END LOOP;
END display_all_employees;
/

-- Execute procedure
BEGIN
    display_all_employees();
END;
/

-- Procedure with parameters (IN parameters)
CREATE OR REPLACE PROCEDURE insert_employee_data(
    p_emp_id    IN NUMBER,
    p_emp_name  IN VARCHAR2,
    p_hire_date IN DATE
)
AS
    v_exists NUMBER;
BEGIN
    -- Check if employee already exists
    SELECT COUNT(*) INTO v_exists 
    FROM employees_data 
    WHERE emp_id = p_emp_id;
    
    IF v_exists = 0 THEN
        INSERT INTO employees_data (emp_id, emp_name, hire_date)
        VALUES (p_emp_id, p_emp_name, p_hire_date);
        
        DBMS_OUTPUT.PUT_LINE('Employee inserted successfully');
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error: Employee ID ' || p_emp_id || ' already exists');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END insert_employee_data;
/

-- Execute with named notation
BEGIN
    insert_employee_data(
        p_emp_id => 10,
        p_emp_name => 'John Doe',
        p_hire_date => SYSDATE
    );
END;
/

-- Procedure with OUT parameter
CREATE OR REPLACE PROCEDURE get_employee_info(
    p_emp_id    IN  NUMBER,
    p_emp_name  OUT VARCHAR2,
    p_salary    OUT NUMBER
)
AS
BEGIN
    SELECT first_name, salary INTO p_emp_name, p_salary
    FROM employees
    WHERE employee_id = p_emp_id;
END get_employee_info;
/

-- Calling procedure with OUT parameters
DECLARE
    v_name VARCHAR2(50);
    v_salary NUMBER;
BEGIN
    get_employee_info(100, v_name, v_salary);
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name || ', Salary: ' || v_salary);
END;
/

-- Procedure with IN OUT parameter
CREATE OR REPLACE PROCEDURE increase_salary(
    p_emp_id    IN NUMBER,
    p_increase  IN OUT NUMBER
)
AS
    v_current_salary NUMBER;
BEGIN
    SELECT salary INTO v_current_salary
    FROM employees
    WHERE employee_id = p_emp_id;
    
    -- Increase salary
    p_increase := v_current_salary * (p_increase/100);
    
    UPDATE employees
    SET salary = salary + p_increase
    WHERE employee_id = p_emp_id;
    
    COMMIT;
END increase_salary;
/


/*****************************
8. OBJECT TYPES
*****************************/

-- Create Object Type with Member Function
CREATE OR REPLACE TYPE employee_type AS OBJECT (
    -- Attributes
    emp_id      NUMBER,
    emp_name    VARCHAR2(50),
    hire_date   DATE,
    
    -- Member function declaration
    MEMBER FUNCTION calculate_service_years RETURN NUMBER
);
/

-- Create Object Type Body with implementation
CREATE OR REPLACE TYPE BODY employee_type AS
    -- Implement member function
    MEMBER FUNCTION calculate_service_years RETURN NUMBER IS
    BEGIN
        -- Calculate years of service
        RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date)/12);
    END calculate_service_years;
END;
/

-- Create table to store objects
CREATE TABLE employee_objects OF employee_type (
    PRIMARY KEY (emp_id)
);

-- Insert data into object table
INSERT INTO employee_objects VALUES (
    employee_type(1, 'Alice Johnson', DATE '2020-03-15')
);
INSERT INTO employee_objects VALUES (
    employee_type(2, 'Bob Smith', DATE '2018-07-22')
);
COMMIT;

-- Query object table with member function
SELECT 
    emp_id,
    emp_name,
    hire_date,
    e.calculate_service_years() AS years_of_service
FROM employee_objects e;

-- Using object type as PL/SQL variable (without table)
DECLARE
    v_employee employee_type;  -- Object type variable
BEGIN
    -- Initialize object
    v_employee := employee_type(
        100, 
        'Charlie Brown', 
        DATE '2015-11-30'
    );
    
    -- Access attributes and methods
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_employee.emp_name);
    DBMS_OUTPUT.PUT_LINE('Years of Service: ' || 
                        v_employee.calculate_service_years());
END;
/


/*****************************
9. VIEWS
*****************************/

-- Simple View (Read-only virtual table)
CREATE OR REPLACE VIEW employee_summary AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.salary,
    d.department_name,
    j.job_title
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN jobs j ON e.job_id = j.job_id;

-- Query the view
SELECT * FROM employee_summary WHERE department_name = 'Sales';

-- Updatable View (Can perform DML operations)
CREATE OR REPLACE VIEW sales_employees AS
SELECT 
    employee_id,
    first_name,
    last_name,
    email,
    salary
FROM employees
WHERE department_id = 80
WITH CHECK OPTION CONSTRAINT sales_employees_check;

-- Materialized View (Stores physical data)
-- First grant privilege if needed
-- GRANT CREATE MATERIALIZED VIEW TO HR;

CREATE MATERIALIZED VIEW department_salary_mv
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    SUM(e.salary) AS total_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name;

-- Query materialized view
SELECT * FROM department_salary_mv ORDER BY avg_salary DESC;

-- Refresh materialized view
BEGIN
    DBMS_MVIEW.REFRESH('department_salary_mv');
END;
/


/*****************************
10. COMPREHENSIVE EXAMPLE
   Combining multiple concepts
*****************************/

CREATE OR REPLACE PACKAGE employee_management AS
    -- Type declarations
    TYPE emp_record IS RECORD (
        id      employees.employee_id%TYPE,
        name    employees.first_name%TYPE,
        salary  employees.salary%TYPE,
        dept    employees.department_id%TYPE
    );
    
    TYPE emp_table IS TABLE OF emp_record INDEX BY PLS_INTEGER;
    
    -- Function declarations
    FUNCTION get_employee(p_id NUMBER) RETURN emp_record;
    FUNCTION get_department_employees(p_dept_id NUMBER) RETURN emp_table;
    
    -- Procedure declarations
    PROCEDURE update_employee_salary(p_id NUMBER, p_percent NUMBER);
    PROCEDURE print_employee_report(p_dept_id NUMBER DEFAULT NULL);
    
END employee_management;
/

CREATE OR REPLACE PACKAGE BODY employee_management AS
    
    FUNCTION get_employee(p_id NUMBER) RETURN emp_record IS
        v_emp emp_record;
    BEGIN
        SELECT employee_id, first_name, salary, department_id
        INTO v_emp.id, v_emp.name, v_emp.salary, v_emp.dept
        FROM employees
        WHERE employee_id = p_id;
        
        RETURN v_emp;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Employee not found');
    END get_employee;
    
    FUNCTION get_department_employees(p_dept_id NUMBER) RETURN emp_table IS
        v_employees emp_table;
    BEGIN
        IF p_dept_id IS NOT NULL THEN
            SELECT employee_id, first_name, salary, department_id
            BULK COLLECT INTO v_employees
            FROM employees
            WHERE department_id = p_dept_id
            ORDER BY salary DESC;
        ELSE
            SELECT employee_id, first_name, salary, department_id
            BULK COLLECT INTO v_employees
            FROM employees
            ORDER BY salary DESC;
        END IF;
        
        RETURN v_employees;
    END get_department_employees;
    
    PROCEDURE update_employee_salary(p_id NUMBER, p_percent NUMBER) IS
        v_current_salary NUMBER;
        v_new_salary NUMBER;
    BEGIN
        -- Get current salary
        SELECT salary INTO v_current_salary
        FROM employees
        WHERE employee_id = p_id;
        
        -- Calculate new salary
        v_new_salary := v_current_salary * (1 + p_percent/100);
        
        -- Update with validation
        IF v_new_salary > v_current_salary * 2 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Salary increase too high');
        END IF;
        
        UPDATE employees
        SET salary = v_new_salary
        WHERE employee_id = p_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Updated salary for employee ' || p_id || 
                            ' from ' || v_current_salary || 
                            ' to ' || v_new_salary);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Employee ' || p_id || ' not found');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ROLLBACK;
    END update_employee_salary;
    
    PROCEDURE print_employee_report(p_dept_id NUMBER DEFAULT NULL) IS
        v_employees emp_table;
        v_total_salary NUMBER := 0;
        v_count NUMBER := 0;
    BEGIN
        -- Get employees using function
        v_employees := get_department_employees(p_dept_id);
        
        DBMS_OUTPUT.PUT_LINE('=' || RPAD('=', 60, '='));
        DBMS_OUTPUT.PUT_LINE('EMPLOYEE REPORT');
        DBMS_OUTPUT.PUT_LINE('=' || RPAD('=', 60, '='));
        
        -- Loop through employees
        FOR i IN 1..v_employees.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_employees(i).id, 8) ||
                RPAD(v_employees(i).name, 20) ||
                RPAD(v_employees(i).dept, 10) ||
                TO_CHAR(v_employees(i).salary, '999,999.99')
            );
            
            v_total_salary := v_total_salary + v_employees(i).salary;
            v_count := v_count + 1;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('-'.RPAD('-', 60, '-'));
        DBMS_OUTPUT.PUT_LINE(
            'Total Employees: ' || v_count ||
            ', Total Salary: ' || TO_CHAR(v_total_salary, '999,999,999.99') ||
            ', Average: ' || TO_CHAR(v_total_salary/NULLIF(v_count,0), '999,999.99')
        );
        
    END print_employee_report;
    
END employee_management;
/

-- Test the comprehensive package
BEGIN
    -- Test individual functions/procedures
    employee_management.print_employee_report(80);
    DBMS_OUTPUT.PUT_LINE(CHR(10));  -- New line
    
    -- Get specific employee
    DECLARE
        v_emp employee_management.emp_record;
    BEGIN
        v_emp := employee_management.get_employee(100);
        DBMS_OUTPUT.PUT_LINE('Employee 100: ' || v_emp.name || 
                            ', Salary: ' || v_emp.salary);
    END;
    
END;
/


/*****************************
11. EXCEPTION HANDLING
*****************************/

DECLARE
    v_emp_id NUMBER := 99999;  -- Non-existent ID
    v_name VARCHAR2(50);
    v_salary NUMBER;
BEGIN
    -- This will raise NO_DATA_FOUND exception
    SELECT first_name, salary INTO v_name, v_salary
    FROM employees
    WHERE employee_id = v_emp_id;
    
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Employee ID ' || v_emp_id || ' not found');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Error: Multiple employees found with same ID');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLCODE || ' - ' || SQLERRM);
END;
/

-- User-defined exception
DECLARE
    v_salary employees.salary%TYPE;
    v_emp_id employees.employee_id%TYPE := 100;
    
    -- Declare user-defined exception
    salary_too_low EXCEPTION;
    PRAGMA EXCEPTION_INIT(salary_too_low, -20001);
BEGIN
    SELECT salary INTO v_salary
    FROM employees
    WHERE employee_id = v_emp_id;
    
    -- Raise exception conditionally
    IF v_salary < 5000 THEN
        RAISE salary_too_low;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Salary is acceptable: ' || v_salary);
    
EXCEPTION
    WHEN salary_too_low THEN
        DBMS_OUTPUT.PUT_LINE('Error: Salary is too low for employee ' || v_emp_id);
        DBMS_OUTPUT.PUT_LINE('Current salary: ' || v_salary);
END;
/


/*****************************
12. DYNAMIC SQL
*****************************/

-- Execute Immediate for DDL and DML
DECLARE
    v_table_name VARCHAR2(50) := 'temp_employees';
    v_sql VARCHAR2(1000);
BEGIN
    -- Create table dynamically
    v_sql := 'CREATE TABLE ' || v_table_name || ' AS 
              SELECT * FROM employees WHERE 1=0';
    
    EXECUTE IMMEDIATE v_sql;
    DBMS_OUTPUT.PUT_LINE('Table ' || v_table_name || ' created');
    
    -- Insert data dynamically
    v_sql := 'INSERT INTO ' || v_table_name || ' 
              SELECT * FROM employees WHERE department_id = :dept';
    
    EXECUTE IMMEDIATE v_sql USING 80;
    DBMS_OUTPUT.PUT_LINE('Data inserted');
    
    -- Drop table
    EXECUTE IMMEDIATE 'DROP TABLE ' || v_table_name;
    DBMS_OUTPUT.PUT_LINE('Table dropped');
END;
/

-- Dynamic SQL with returning clause
DECLARE
    v_emp_id NUMBER := 999;
    v_emp_name VARCHAR2(50) := 'Test Employee';
    v_new_id NUMBER;
    v_sql VARCHAR2(1000);
BEGIN
    v_sql := 'INSERT INTO employees_data (emp_id, emp_name, hire_date)
              VALUES (:1, :2, SYSDATE)
              RETURNING emp_id INTO :3';
    
    EXECUTE IMMEDIATE v_sql 
    USING v_emp_id, v_emp_name, OUT v_new_id;
    
    DBMS_OUTPUT.PUT_LINE('Inserted with ID: ' || v_new_id);
    COMMIT;
END;
/


/*****************************
CLEANUP (Optional - for testing)
*****************************/
/*
-- Uncomment to cleanup
DROP PACKAGE employee_management;
DROP FUNCTION calculate_salary;
DROP FUNCTION get_total_employee_count;
DROP FUNCTION get_employee_details;
DROP PROCEDURE display_all_employees;
DROP PROCEDURE insert_employee_data;
DROP PROCEDURE get_employee_info;
DROP PROCEDURE increase_salary;
DROP VIEW employee_summary;
DROP VIEW sales_employees;
DROP MATERIALIZED VIEW department_salary_mv;
DROP TABLE employee_objects;
DROP TYPE emp_tbl_type;
DROP TYPE emp_obj_type;
DROP TYPE employee_type;
*/

-- Display final message
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '='.RPAD('=', 70, '='));
    DBMS_OUTPUT.PUT_LINE('PL/SQL MASTER REFERENCE FILE EXECUTED SUCCESSFULLY');
    DBMS_OUTPUT.PUT_LINE('='.RPAD('=', 70, '='));
    DBMS_OUTPUT.PUT_LINE('This file contains examples of:');
    DBMS_OUTPUT.PUT_LINE('1. Basic PL/SQL Blocks');
    DBMS_OUTPUT.PUT_LINE('2. Variables and Data Types');
    DBMS_OUTPUT.PUT_LINE('3. Conditional Logic (IF, CASE)');
    DBMS_OUTPUT.PUT_LINE('4. Loops (FOR, WHILE, BASIC)');
    DBMS_OUTPUT.PUT_LINE('5. Cursors (Explicit, Parameterized)');
    DBMS_OUTPUT.PUT_LINE('6. Functions (Scalar, Table)');
    DBMS_OUTPUT.PUT_LINE('7. Procedures (IN, OUT, IN OUT parameters)');
    DBMS_OUTPUT.PUT_LINE('8. Object Types with Member Functions');
    DBMS_OUTPUT.PUT_LINE('9. Views (Simple, Materialized)');
    DBMS_OUTPUT.PUT_LINE('10. Packages (Comprehensive Example)');
    DBMS_OUTPUT.PUT_LINE('11. Exception Handling');
    DBMS_OUTPUT.PUT_LINE('12. Dynamic SQL');
END;
/
