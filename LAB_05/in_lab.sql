-- Q1. Display all possible pairs of employees and departments
SELECT e.emp_name, d.dept_name
FROM Employee e CROSS JOIN Department d;

-- Q2. Show all departments and employees, even if no employees are assigned
SELECT d.dept_name, e.emp_name
FROM Department d LEFT OUTER JOIN Employee e
ON d.dept_id = e.dept_id;

-- Q3. Employee names with their manager names
SELECT e.emp_name AS Employee, m.emp_name AS Manager
FROM Employee e LEFT JOIN Employee m
ON e.manager_id = m.emp_id;

-- Q4. Employees not assigned to any project
SELECT e.emp_name
FROM Employee e LEFT JOIN Project p
ON e.emp_id = p.emp_id
WHERE p.proj_id IS NULL;

-- Q5. Student names with enrolled course names
SELECT s.student_name, c.course_name
FROM Student s INNER JOIN Course c
ON s.course_id = c.course_id;

-- Q6. All customers with their orders, even if no order placed
SELECT c.cust_name, o.order_id
FROM Customer c LEFT OUTER JOIN Orders o
ON c.cust_id = o.cust_id;

-- Q7. Show all departments and employees, even if a department has no employee.
SELECT d.dept_name, e.emp_name
FROM Department d LEFT OUTER JOIN Employee e
ON d.dept_id = e.dept_id;

-- Q8. All pairs of teachers and subjects (whether taught or not)
SELECT t.teacher_name, s.subject_name
FROM Teacher t FULL OUTER JOIN Subject s
ON t.subject_id = s.subject_id;

-- Q9. Departments with total employees
SELECT d.dept_name, COUNT(e.emp_id) AS total_employees
FROM Department d LEFT JOIN Employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

-- Q10. Each student, their course, and their teacher
SELECT s.student_name, c.course_name, t.teacher_name
FROM Student s
JOIN Course c ON s.course_id = c.course_id
JOIN Teacher t ON c.teacher_id = t.teacher_id;
