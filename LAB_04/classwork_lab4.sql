create table students(
id int primary key ,
stdName varchar(30),
email varchar(20),
password varchar(20),
age int , 
city varchar(20),
salary int 
);
create table department(
id int primary key ,
name varchar(30)
);
select * from students;
select * from department;
insert into DEPARTMENT values(4,'CY');

ALTER table students add (dept_id int , CONSTRAINT fk_dept_id FOREIGN key(dept_id) REFERENCES department(id) );
insert into STUDENTS  values (6,'huzaifa khan','hhuzaifa@gmail.com',1233 , 24 , 'Lahore',80000, 1);

select count(*) as total_students , dept_id  from students group by(dept_id); 

select (select d.name from DEPARTMENT d where d.id = s.dept_id)  as dept_name , count(*) 
from students s group by(s.dept_id);

select (select name from DEPARTMENT where id = students.dept_id) as dept_name , count(*) as total_students , 
sum(salary) as total_salary from students group by (dept_id);

create table faculty(
id int primary key ,
name varchar(30)
);
insert into FACULTY values(3,'Miss Amna');
select * from faculty;
ALTER table students add (f_id int , CONSTRAINT fk_fac_id FOREIGN key(f_id) REFERENCES faculty(id) );

update STUDENTS set f_id = 1 where id in(4,6);


select f_id , count(*) as total_students from students group by(f_id);


select (select name from faculty where id = students.f_id) as faculty_name ,
count(*) as total_students from students group by(f_id);

select sum(salary) as total_salary , (select name from department where id = students.dept_id) as dept_name 
from students group by(dept_id) HAVING sum(salary) >= 100000;
select dept_id , max(salary) as heighest_salary from students group by(dept_id) having max(salary) >= 80000;

select max(salary) from students ;
select * from students where salary  = (select max(salary) from students);

select * from students where salary < any (select salary from students where dept_id = 2) ; -- [60000 ,66000]
select * from students where salary < ALL (select salary from students where dept_id = 2) ; -- [60000 ,66000]

select * from students where salary > any (select salary from students where dept_id = 2) ; -- [60000 ,66000]
select * from students where salary > ALL (select salary from students where dept_id = 2) ; -- [60000 ,66000]

insert into students (id , stdName , email , password , age ,city , salary, dept_id , f_id)
values
(7,'aisha','aisha@gmail.com' , 202 , 23 , 'Karachi' ,78000, (select id from department where name = 'CY') , 
(select id from FACULTY where name = 'Miss Fareeha') 
);

update STUDENTS set age = age + 1 where dept_id  = (select id from DEPARTMENT where name = 'CY' );

        SELECT * FROM (
       SELECT * FROM STUDENTS 
       ORDER BY salary DESC
        )
       WHERE ROWNUM <= 3;


