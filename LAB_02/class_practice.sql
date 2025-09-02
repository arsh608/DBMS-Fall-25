select count(*) as total_employees from employees;
select count(*) as total_employees, manager_id from employees group by(manager_id);
select distinct manager_id from employees;
select manager_id from employees group by(manager_id);
select sum(salary) as Total_salary from employees;
--group by department wise salary
select sum(salary) as Total_salary from employees group by(DEPARTMENT_ID);
select min(salary) as min_salary from employees;
select max(salary) as max_salary from employees;
select avg(salary) as avg_salary from employees;
--concatenation
select first_name || salary as First_name_and_salary from employees;
select ALL salary from employees;
select salary from employees;
select salary from employees order by (salary) asc;
select first_name, hire_date from employees order by (first_name) asc;
select first_name, hire_date,salary from employees order by (first_name) asc;
--searching
---------------- underscore kuch bhi aye and % mei kuch aye na aye
select first_name from employees where first_name like 'A__N%';
select first_name from employees where first_name like '%k%';
--------------------------k in lower and uppercase differ

SELECT * FROM DUAL;
---abs will make negative to positive 
SELECT abs(-90.5) from dual;
select ceil(90.3) from dual; --up greater return
select ceil(-90.3) from dual; --returns 90
select floor(90.3) from dual; --90
select floor(-90.3) from dual; ---91
select trunc(90.1234) from dual; --remove decimal
select trunc(90.1234, 2) from dual; --remove decimal upto n decimal place
select round (90.1234) from dual;--90
select round (90.548) from dual;--91
select greatest (90, 99,91,95) from dual;
select least (90, 99,91,95) from dual;

--string functions
select lower('KINZA') FROM DUAL;
SELECT FIRST_NAME, lower(FIRST_NAME) FROM EMPLOYEES;
SELECT FIRST_NAME, upper(FIRST_NAME) FROM EMPLOYEES;
select INITCAP('the cap') from dual; --uppercase first letter of each letter
select length('kinza') from dual;
select first_name, length(first_name) from employees;
select ltrim('      kinza') from dual; ---trim left space
--rtrim trims right side
--trim does from both sides
select substr('Arsh Al Aman', 6, 7) from dual;
select lpad('good', 7, '*') from dual;
select rpad('good', 7, '*') from dual;
--date functions
select ADD_MONTHS('16-SEP-2000', 2) FROM DUAL;
SELECT MONTHS_BETWEEN('28-AUG-2025', '26-DEC-2004') FROM DUAL;
SELECT NEXT_DAY('28-AUG-2025', 'WEDNESDAY') FROM DUAL;

--CONVERSION FUNCTIONS
SELECT to_char(sysdate, 'DD-MM-YYYY') FROM DUAL;
SELECT to_char(sysdate, 'DAY') FROM DUAL;
SELECT to_char(HIRE_DATE, 'DAY') FROM EMPLOYEES;

select * from employees WHERE TO_CHAR(hire_date ,'DAY') = 'SATURDAY ' ;
SELECT TO_CHAR(hire_date,'DAY') from employees;