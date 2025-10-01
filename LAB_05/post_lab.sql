-- Q11. Students and teachers where student city = teacher city
SELECT s.student_name, t.teacher_name, s.city
FROM Student s JOIN Teacher t
ON s.city = t.city;

-- Q12. Employees and their manager names, include employees without managers
SELECT e.emp_name AS Employee, m.emp_name AS Manager
FROM Employee e LEFT JOIN Employee m
ON e.manager_id = m.emp_id;

-- Q13. Employees without any department
SELECT e.emp_name
FROM Employee e LEFT JOIN Department d
ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- Q14. Average salary of employees in each department (avg > 50000)
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM Department d JOIN Employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING AVG(e.salary) > 50000;

-- Q15. Employees earning more than avg salary of their department
SELECT e.emp_name, e.salary, d.dept_name
FROM Employee e JOIN Department d
ON e.dept_id = d.dept_id
WHERE e.salary > (
    SELECT AVG(salary) FROM Employee
    WHERE dept_id = e.dept_id
);

-- Q16. Departments where no employee earns less than 30000
SELECT d.dept_name
FROM Department d JOIN Employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING MIN(e.salary) >= 30000;

-- Q17. Students and their courses where city = 'Lahore'
SELECT s.student_name, c.course_name
FROM Student s JOIN Course c
ON s.course_id = c.course_id
WHERE s.city = 'Lahore';

-- Q18. Employees with manager and department where hire date between given range
SELECT e.emp_name, m.emp_name AS Manager, d.dept_name
FROM Employee e
LEFT JOIN Employee m ON e.manager_id = m.emp_id
JOIN Department d ON e.dept_id = d.dept_id
WHERE e.hire_date BETWEEN DATE '2020-01-01' AND DATE '2023-01-01';

-- Q19. Students enrolled in courses taught by 'Sir Ali'
SELECT s.student_name, c.course_name
FROM Student s
JOIN Course c ON s.course_id = c.course_id
JOIN Teacher t ON c.teacher_id = t.teacher_id
WHERE t.teacher_name = 'Sir Ali';

-- Q20. Employees whose manager is from the same department
SELECT e.emp_name, m.emp_name AS Manager, d.dept_name
FROM Employee e
JOIN Employee m ON e.manager_id = m.emp_id
JOIN Department d ON e.dept_id = d.dept_id AND m.dept_id = d.dept_id;
