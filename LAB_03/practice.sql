create table students(
id int primary key,
std_name varchar(30),
email varchar(20),
age int,
check(age>=18)

);
select * from students;
--add column after creation
alter table students add salary int;
alter table students add (city VARCHAR(20) default 'Karachi', dept_id int);
--adding constraints after creation
alter table students add CONSTRAINT unique_email unique(email);
--modify multiple columns or we can modify single column
alter table students modify(std_name varchar(20) not null, email varchar(20) not null);
--adding multiple constraints
alter table students add CONSTRAINT(
check_age check(age between 18 AND 30),
CONSTRAINT unique_email unique(email)
);

CREATE table departments(
id int primary key,
dept_name varchar(20) not null
);
select * from departments;
insert into departments(id, dept_name) values(4,'AI');

select * from students;
ALTER TABLE students drop column dept_id;

alter table students add (dept_id int, foreign key(dept_id) references departments(id));
insert into students(id, std_name, email, age, city, salary, dept_id)
values
(4,'Huzaifa', 'hkl23@gmail.com', 20, 'Lahore', 30000,4);
alter table students rename column email to std_email;
delete from students where id in (4);
insert into students(id, std_name, std_email, age, city, salary, dept_id)
values
(1,'Huzaifa', 'hkl23@gmail.com', 20, 'Lahore', 30000,4);