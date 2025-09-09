CREATE TABLE departments (
  dept_id   NUMBER CONSTRAINT pk_departments PRIMARY KEY,
  dept_name VARCHAR2(50) CONSTRAINT unq_dept_name UNIQUE
);

INSERT INTO departments VALUES (10,'HR');
INSERT INTO departments VALUES (20,'IT');
INSERT INTO departments VALUES (30,'Finance');

SELECT * FROM departments;

CREATE TABLE employees (
  emp_id     INT CONSTRAINT pk_employees PRIMARY KEY,
  emp_name   VARCHAR2(50),
  salary     INT CONSTRAINT chk_salary CHECK (salary > 20000),
  dept_id    INT,
  CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

ALTER TABLE employees RENAME COLUMN emp_name TO full_name;

ALTER TABLE employees DROP CONSTRAINT chk_salary;
INSERT INTO employees VALUES (101, 'Ali', 5000, 10);

ALTER TABLE employees ADD bonus NUMBER(6,2) DEFAULT 1000 CONSTRAINT unq_bonus UNIQUE;
ALTER TABLE employees ADD city VARCHAR2(20) DEFAULT 'Karachi';
ALTER TABLE employees ADD age NUMBER CONSTRAINT chk_age CHECK (age > 18);

DELETE FROM employees WHERE emp_id IN (1,3);
ALTER TABLE employees MODIFY full_name VARCHAR2(20);
ALTER TABLE employees MODIFY city VARCHAR2(20);

ALTER TABLE employees ADD email VARCHAR2(50) CONSTRAINT unq_email UNIQUE;
ALTER TABLE employees ADD dob DATE CONSTRAINT chk_dob CHECK (dob <= DATE '2007-01-01');

INSERT INTO employees (emp_id, full_name, salary, dept_id, dob) VALUES (102,'Sara',25000,20,DATE '2010-01-01');
--ORA-02290: check constraint (ARSH.CHK_DOB) violated

ALTER TABLE employees DROP CONSTRAINT fk_emp_dept;
INSERT INTO employees (emp_id, full_name, salary, dept_id, bonus, city, age, email, dob) 
VALUES (103,'John',30000,99,1200,'Karachi',25,'john@example.com',DATE '1995-01-01');
ALTER TABLE employees ADD CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id);

--Error starting at line : 42 in command -
--ORA-02298: cannot validate (ARSH.FK_EMP_DEPT) - parent keys not found
--02298. 00000 - "cannot validate (%s.%s) - parent keys not found"
--*Cause:    an alter table validating constraint failed because the table has
--           child records.
--*Action:   Obvious

ALTER TABLE employees DROP COLUMN age;
ALTER TABLE employees DROP COLUMN city;

SELECT d.dept_id, d.dept_name, e.emp_id, e.full_name 
FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id;

ALTER TABLE employees RENAME COLUMN salary TO monthly_salary;

SELECT * FROM departments d WHERE NOT EXISTS (SELECT 1 FROM employees e WHERE e.dept_id = d.dept_id);

TRUNCATE TABLE students;
--student table not created 

SELECT dept_id, emp_count
FROM (
  SELECT dept_id, COUNT(*) AS emp_count
  FROM employees
  GROUP BY dept_id
  ORDER BY emp_count DESC
)
WHERE ROWNUM = 1;