--in lab
SELECT SUM(salary) AS total_salary FROM employees;
SELECT AVG(salary) AS average_salary FROM employees;
SELECT manager_id, COUNT(*) AS emp_count FROM employees WHERE manager_id IS NOT NULL GROUP BY manager_id;
SELECT * FROM employees WHERE salary = (SELECT MIN(salary) FROM employees);
SELECT * FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'DD-MM-YYYY') AS today FROM dual;
SELECT TO_CHAR(SYSDATE, 'DAY MONTH YYYY') AS full_date FROM dual;
SELECT * FROM employees WHERE TO_CHAR(hire_date, 'DAY') = 'WEDNESDAY';
SELECT MONTHS_BETWEEN(DATE '2025-01-01', DATE '2024-09-01') AS months_diff FROM dual;
SELECT first_name, last_name, MONTHS_BETWEEN(SYSDATE, hire_date) AS months_worked FROM employees;
SELECT SUBSTR(last_name, 1, 5) AS short_last_name FROM employees;

--post lab
SELECT LPAD(first_name, 15, '*') AS padded_name FROM employees;
SELECT LTRIM(' Oracle') AS trimmed_string FROM dual;
SELECT INITCAP(first_name) AS proper_first_name, INITCAP(last_name) AS proper_last_name FROM employees;
SELECT NEXT_DAY(DATE '2022-08-20', 'MONDAY') AS next_monday FROM dual;

