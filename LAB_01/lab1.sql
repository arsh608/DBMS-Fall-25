-- IN–LAB TASKS
select * from employees where department_id <> 100;
select * from employees where salary IN (10000, 12000, 15000);
select first_name, salary from employees where salary <= 25000;
select * from employees where department_id <> 60;
select * from employees where department_id BETWEEN 60 AND 80;
select * from departments;
select * from employees where first_name = 'Steven';
select * from employees where salary BETWEEN 15000 AND 25000 AND department_id = 80;
select * from employees where salary < ANY ( select salary from employees where department_id = 100 );
select * from employees e where department_id IN ( select department_id from employees GROUP BY department_id HAVING COUNT(*) = 1 );

-- POST–LAB TASKS
select * from employees where hire_date BETWEEN DATE '2005-01-01' AND DATE '2006-12-31';
select * from employees where manager_id IS NULL;
select * from employees where salary < ALL ( select salary from employees where salary > 8000 );
select * from employees where salary > ANY ( select salary from employees where department_id = 90 );
select * from departments d where EXISTS ( select 1 from employees e where e.department_id = d.department_id );
select * from departments d where NOT EXISTS ( select 1 from employees e where e.department_id = d.department_id );
select * from employees where salary NOT BETWEEN 5000 AND 15000;
select * from employees where department_id IN (10, 20, 30) AND department_id <> 40;
select * from employees where salary < ( select MIN(salary) from employees where department_id = 50 );
select * from employees where salary > ( select MAX(salary) from employees where department_id = 90 );
