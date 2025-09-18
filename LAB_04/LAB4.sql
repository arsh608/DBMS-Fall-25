-- 1. Department Table
CREATE TABLE Department (
    dept_id      NUMBER PRIMARY KEY,
    dept_name    VARCHAR2(50) UNIQUE
);

-- 2. Course Table
CREATE TABLE Course (
    course_id    NUMBER PRIMARY KEY,
    course_name  VARCHAR2(50),
    dept_id      NUMBER REFERENCES Department(dept_id)
);

-- 3. Student Table
CREATE TABLE Student (
    student_id   NUMBER PRIMARY KEY,
    student_name VARCHAR2(50),
    dept_id      NUMBER REFERENCES Department(dept_id),
    gpa          NUMBER(3,2),
    fee_paid     NUMBER(10,2)
);

-- 4. Faculty Table
CREATE TABLE Faculty (
    faculty_id   NUMBER PRIMARY KEY,
    faculty_name VARCHAR2(50),
    dept_id      NUMBER REFERENCES Department(dept_id),
    salary       NUMBER(10,2),
    joining_date DATE
);

-- 5. Enrollment Table
CREATE TABLE Enrollment (
    enroll_id    NUMBER PRIMARY KEY,
    student_id   NUMBER REFERENCES Student(student_id),
    course_id    NUMBER REFERENCES Course(course_id)
);

-- =============================
-- 1. POPULATE DEPARTMENT TABLE
-- =============================
INSERT INTO Department VALUES (1, 'Computer Science');
INSERT INTO Department VALUES (2, 'Electrical Engineering');
INSERT INTO Department VALUES (3, 'Business');
INSERT INTO Department VALUES (4, 'Mathematics');

-- =============================
-- 2. POPULATE COURSE TABLE (20 COURSES)
-- =============================
INSERT INTO Course VALUES (101, 'Database Systems', 1);
INSERT INTO Course VALUES (102, 'Data Structures', 1);
INSERT INTO Course VALUES (103, 'Algorithms', 1);
INSERT INTO Course VALUES (104, 'Computer Networks', 1);
INSERT INTO Course VALUES (105, 'Operating Systems', 1);

INSERT INTO Course VALUES (201, 'Circuits', 2);
INSERT INTO Course VALUES (202, 'Digital Systems', 2);
INSERT INTO Course VALUES (203, 'Power Systems', 2);
INSERT INTO Course VALUES (204, 'Electromagnetics', 2);
INSERT INTO Course VALUES (205, 'Microcontrollers', 2);

INSERT INTO Course VALUES (301, 'Marketing', 3);
INSERT INTO Course VALUES (302, 'Finance', 3);
INSERT INTO Course VALUES (303, 'HR Management', 3);
INSERT INTO Course VALUES (304, 'Business Analytics', 3);
INSERT INTO Course VALUES (305, 'Entrepreneurship', 3);

INSERT INTO Course VALUES (401, 'Linear Algebra', 4);
INSERT INTO Course VALUES (402, 'Statistics', 4);
INSERT INTO Course VALUES (403, 'Real Analysis', 4);
INSERT INTO Course VALUES (404, 'Abstract Algebra', 4);
INSERT INTO Course VALUES (405, 'Calculus III', 4);

-- =============================
-- 3. POPULATE STUDENT TABLE (20 STUDENTS)
-- =============================
INSERT INTO Student VALUES (1,  'Ali',      1, 3.80, 50000);
INSERT INTO Student VALUES (2,  'Sara',     1, 3.50, 55000);
INSERT INTO Student VALUES (3,  'Ahmed',    2, 2.90, 40000);
INSERT INTO Student VALUES (4,  'Fatima',   3, 3.20, 65000);
INSERT INTO Student VALUES (5,  'Bilal',    1, 2.50, 30000);
INSERT INTO Student VALUES (6,  'Hina',     4, 3.90, 70000);
INSERT INTO Student VALUES (7,  'Omar',     2, 3.30, 45000);
INSERT INTO Student VALUES (8,  'Usman',    3, 3.10, 62000);
INSERT INTO Student VALUES (9,  'Maya',     4, 2.70, 35000);
INSERT INTO Student VALUES (10, 'Junaid',   1, 3.00, 48000);
INSERT INTO Student VALUES (11, 'Kiran',    3, 3.70, 80000);
INSERT INTO Student VALUES (12, 'Danish',   2, 3.40, 52000);
INSERT INTO Student VALUES (13, 'Anum',     4, 3.60, 68000);
INSERT INTO Student VALUES (14, 'Zara',     3, 3.80, 75000);
INSERT INTO Student VALUES (15, 'Hamza',    1, 2.80, 31000);
INSERT INTO Student VALUES (16, 'Waleed',   1, 3.90, 90000);
INSERT INTO Student VALUES (17, 'Nida',     4, 3.50, 64000);
INSERT INTO Student VALUES (18, 'Imran',    2, 2.60, 28000);
INSERT INTO Student VALUES (19, 'Shahzaib', 3, 3.30, 60000);
INSERT INTO Student VALUES (20, 'Sami',     4, 3.20, 55000);

-- =============================
-- 4. POPULATE FACULTY TABLE (20 FACULTY)
-- =============================
INSERT INTO Faculty VALUES (1,  'Dr. Khan',   1, 120000, DATE '2005-06-01');
INSERT INTO Faculty VALUES (2,  'Dr. Ali',    1,  90000, DATE '2010-03-10');
INSERT INTO Faculty VALUES (3,  'Dr. Sara',   2, 110000, DATE '2000-08-15');
INSERT INTO Faculty VALUES (4,  'Dr. Ahsan',  3,  85000, DATE '2018-07-01');
INSERT INTO Faculty VALUES (5,  'Dr. Nadia',  4, 130000, DATE '1998-01-01');
INSERT INTO Faculty VALUES (6,  'Dr. Kamal',  1, 95000,  DATE '2015-04-04');
INSERT INTO Faculty VALUES (7,  'Dr. Hira',   2, 87000,  DATE '2012-05-06');
INSERT INTO Faculty VALUES (8,  'Dr. Salman', 3, 140000, DATE '2001-02-03');
INSERT INTO Faculty VALUES (9,  'Dr. Asif',   4, 60000,  DATE '2016-07-07');
INSERT INTO Faculty VALUES (10, 'Dr. Qasim',  1, 155000, DATE '1995-09-09');
INSERT INTO Faculty VALUES (11, 'Dr. Arif',   3, 98000,  DATE '2011-06-15');
INSERT INTO Faculty VALUES (12, 'Dr. Farah',  4, 125000, DATE '2003-05-20');
INSERT INTO Faculty VALUES (13, 'Dr. Sohail', 2, 132000, DATE '1999-11-30');
INSERT INTO Faculty VALUES (14, 'Dr. Rehan',  3, 103000, DATE '2008-01-25');
INSERT INTO Faculty VALUES (15, 'Dr. Yasir',  1, 89000,  DATE '2017-08-01');
INSERT INTO Faculty VALUES (16, 'Dr. Adeel',  4, 150000, DATE '1997-12-10');
INSERT INTO Faculty VALUES (17, 'Dr. Seema',  2, 95000,  DATE '2013-03-03');
INSERT INTO Faculty VALUES (18, 'Dr. Rauf',   3, 119000, DATE '2005-05-05');
INSERT INTO Faculty VALUES (19, 'Dr. Umair',  2, 102000, DATE '2002-10-10');
INSERT INTO Faculty VALUES (20, 'Dr. Tariq',  4, 88000,  DATE '2014-04-14');

-- =============================
-- 5. POPULATE ENROLLMENT TABLE (AT LEAST 40 ENTRIES)
-- =============================
INSERT INTO Enrollment VALUES (1,  1, 101);
INSERT INTO Enrollment VALUES (2,  1, 102);
INSERT INTO Enrollment VALUES (3,  2, 101);
INSERT INTO Enrollment VALUES (4,  2, 103);
INSERT INTO Enrollment VALUES (5,  3, 201);
INSERT INTO Enrollment VALUES (6,  3, 202);
INSERT INTO Enrollment VALUES (7,  4, 301);
INSERT INTO Enrollment VALUES (8,  4, 302);
INSERT INTO Enrollment VALUES (9,  5, 104);
INSERT INTO Enrollment VALUES (10, 5, 105);
INSERT INTO Enrollment VALUES (11, 6, 401);
INSERT INTO Enrollment VALUES (12, 6, 402);
INSERT INTO Enrollment VALUES (13, 7, 201);
INSERT INTO Enrollment VALUES (14, 7, 203);
INSERT INTO Enrollment VALUES (15, 8, 304);
INSERT INTO Enrollment VALUES (16, 8, 305);
INSERT INTO Enrollment VALUES (17, 9, 401);
INSERT INTO Enrollment VALUES (18, 9, 404);
INSERT INTO Enrollment VALUES (19, 10, 101);
INSERT INTO Enrollment VALUES (20, 10, 102);
INSERT INTO Enrollment VALUES (21, 11, 301);
INSERT INTO Enrollment VALUES (22, 11, 305);
INSERT INTO Enrollment VALUES (23, 12, 202);
INSERT INTO Enrollment VALUES (24, 12, 205);
INSERT INTO Enrollment VALUES (25, 13, 403);
INSERT INTO Enrollment VALUES (26, 13, 405);
INSERT INTO Enrollment VALUES (27, 14, 301);
INSERT INTO Enrollment VALUES (28, 14, 302);
INSERT INTO Enrollment VALUES (29, 15, 101);
INSERT INTO Enrollment VALUES (30, 15, 104);
INSERT INTO Enrollment VALUES (31, 16, 103);
INSERT INTO Enrollment VALUES (32, 16, 105);
INSERT INTO Enrollment VALUES (33, 17, 401);
INSERT INTO Enrollment VALUES (34, 17, 402);
INSERT INTO Enrollment VALUES (35, 18, 201);
INSERT INTO Enrollment VALUES (36, 18, 204);
INSERT INTO Enrollment VALUES (37, 19, 304);
INSERT INTO Enrollment VALUES (38, 19, 303);
INSERT INTO Enrollment VALUES (39, 20, 402);
INSERT INTO Enrollment VALUES (40, 20, 405);


SELECT d.dept_name, COUNT(s.student_id) AS student_count
FROM Department d, Student s
WHERE d.dept_id = s.dept_id
GROUP BY d.dept_name;

SELECT d.dept_name, AVG(s.gpa) AS avg_gpa
FROM Department d, Student s
WHERE d.dept_id = s.dept_id
GROUP BY d.dept_name
HAVING AVG(s.gpa) > 3.0;

SELECT c.course_name, AVG(s.fee_paid) AS avg_fee
FROM Course c, Student s, Enrollment e
WHERE c.course_id = e.course_id
AND s.student_id = e.student_id
GROUP BY c.course_name;

SELECT d.dept_name, COUNT(f.faculty_id) AS faculty_count
FROM Department d, Faculty f
WHERE d.dept_id = f.dept_id
GROUP BY d.dept_name;

SELECT f.faculty_name, f.salary
FROM Faculty f
WHERE f.salary > (SELECT AVG(salary) FROM Faculty);

SELECT s.student_name, s.gpa
FROM Student s
WHERE s.gpa > (SELECT MIN(gpa) FROM Student WHERE dept_id = 1); --cs department

SELECT student_name, gpa
FROM (
    SELECT student_name, gpa
    FROM Student
    ORDER BY gpa DESC
)
WHERE ROWNUM <= 3;

SELECT s.student_name
FROM Student s
WHERE NOT EXISTS (
    SELECT course_id
    FROM Enrollment e
    WHERE e.student_id = (SELECT student_id FROM Student WHERE student_name='Ali')
    MINUS
    SELECT e2.course_id
    FROM Enrollment e2
    WHERE e2.student_id = s.student_id
);

SELECT d.dept_name, SUM(s.fee_paid) AS total_fees
FROM Department d, Student s
WHERE d.dept_id = s.dept_id
GROUP BY d.dept_name;

SELECT DISTINCT c.course_name
FROM Course c, Student s, Enrollment e
WHERE s.student_id = e.student_id
AND c.course_id = e.course_id
AND s.gpa > 3.5;

SELECT d.dept_name, SUM(s.fee_paid) AS total_fees
FROM Department d, Student s
WHERE d.dept_id = s.dept_id
GROUP BY d.dept_name
HAVING SUM(s.fee_paid) > 1000000;

SELECT d.dept_name, COUNT(f.faculty_id) AS high_salary_count
FROM Department d, Faculty f
WHERE d.dept_id = f.dept_id
AND f.salary > 100000
GROUP BY d.dept_name
HAVING COUNT(f.faculty_id) > 5;

DELETE FROM Student
WHERE gpa < (SELECT AVG(gpa) FROM Student);

DELETE FROM Course
WHERE course_id NOT IN (SELECT DISTINCT course_id FROM Enrollment);

CREATE TABLE HighFee_Students AS
SELECT *
FROM Student
WHERE fee_paid > (SELECT AVG(fee_paid) FROM Student);

CREATE TABLE Retired_Faculty AS SELECT * FROM Faculty WHERE 1=0;

INSERT INTO Retired_Faculty
SELECT *
FROM Faculty
WHERE joining_date < (SELECT MIN(joining_date) FROM Faculty);

SELECT dept_name
FROM (
    SELECT d.dept_name, SUM(s.fee_paid) AS total_fees
    FROM Department d, Student s
    WHERE d.dept_id = s.dept_id
    GROUP BY d.dept_name
    ORDER BY SUM(s.fee_paid) DESC
)
WHERE ROWNUM = 1;

SELECT course_name, enroll_count
FROM (
    SELECT c.course_name, COUNT(e.student_id) AS enroll_count
    FROM Course c, Enrollment e
    WHERE c.course_id = e.course_id
    GROUP BY c.course_name
    ORDER BY COUNT(e.student_id) DESC
)
WHERE ROWNUM <= 3;

SELECT s.student_name, COUNT(e.course_id) AS total_courses
FROM Student s, Enrollment e
WHERE s.student_id = e.student_id
GROUP BY s.student_name, s.gpa
HAVING COUNT(e.course_id) > 3
AND s.gpa > (SELECT AVG(gpa) FROM Student);

CREATE TABLE Unassigned_Faculty AS SELECT * FROM Faculty WHERE 1=0;

INSERT INTO Unassigned_Faculty
SELECT *
FROM Faculty f
WHERE f.dept_id NOT IN (SELECT DISTINCT dept_id FROM Course);
