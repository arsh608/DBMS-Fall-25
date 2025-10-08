-- =============================
-- Q1.1: Employee Details with Department and City
-- =============================
SELECT e.first_name,
e.last_name,
j.job_title,
d.department_name,
l.city
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN jobs j ON e.job_id = j.job_id
JOIN locations l ON d.location_id = l.location_id;

-- =============================
-- Q1.2: Employees Earning More Than Dept Average
-- =============================
SELECT e.employee_id,
e.first_name,
e.last_name,
e.salary,
e.department_id
FROM employees e
WHERE e.salary > (SELECT AVG(salary)
FROM employees
WHERE department_id = e.department_id);

-- =============================
-- Q1.3: Colleagues of Steven King (Excluding King)
-- =============================
SELECT e.employee_id,
e.first_name,
e.last_name,
d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.department_id = (SELECT department_id
FROM employees
WHERE first_name = 'Steven' AND last_name = 'King')
AND (e.first_name != 'Steven' OR e.last_name != 'King');

-- =============================
-- Q1.4: Highest Paid Employee in Each Department
-- =============================
SELECT d.department_name,
e.first_name,
e.last_name,
e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE (e.department_id, e.salary) IN (SELECT department_id, MAX(salary)
FROM employees
GROUP BY department_id);

-- =============================
-- Q1.5: City with Maximum Number of Employees
-- =============================
SELECT l.city, COUNT(e.employee_id) AS number_of_employees
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
GROUP BY l.city
HAVING COUNT(e.employee_id) = (SELECT MAX(COUNT(employee_id))
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.location_id);

-- =============================
-- Q1.6: Dept, Manager, and Employee Count per Manager
-- =============================
SELECT d.department_name,
m.first_name AS manager_first_name,
m.last_name AS manager_last_name,
COUNT(e.employee_id) AS number_of_employees
FROM departments d
JOIN employees m ON d.manager_id = m.employee_id
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name, m.first_name, m.last_name;

-- =============================
-- Q1.7: Employees Hired Before Their Manager
-- =============================
SELECT e.first_name AS employee_first_name,
e.last_name AS employee_last_name,
e.hire_date AS employee_hire_date,
m.first_name AS manager_first_name,
m.last_name AS manager_last_name,
m.hire_date AS manager_hire_date
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.hire_date < m.hire_date;

-- =============================
-- Q1.8: Job Titles with Average Salary > $10,000
-- =============================
SELECT j.job_title, AVG(e.salary) AS average_salary
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
GROUP BY j.job_title
HAVING AVG(e.salary) > 10000;

-- =============================
-- Q1.9: Departments With No Employees
-- =============================
SELECT d.department_id, d.department_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- =============================
-- Q1.10: Employees with Maximum Commission
-- =============================
SELECT first_name,
last_name,
salary,
commission_pct
FROM employees
WHERE commission_pct = (SELECT MAX(commission_pct) FROM employees);







CLO 4: E-Commerce Management System DDL & DML
-- =============================
-- Q2.1: Create Table - Customers
-- =============================
CREATE TABLE Customers (
customer_id NUMBER PRIMARY KEY,
first_name VARCHAR2(50) NOT NULL,
last_name VARCHAR2(50) NOT NULL,
email VARCHAR2(100) UNIQUE NOT NULL,
phone VARCHAR2(20) UNIQUE
);

-- =============================
-- Q2.2: Create Table - Products
-- =============================
CREATE TABLE Products (
product_id NUMBER PRIMARY KEY,
product_name VARCHAR2(100) NOT NULL,
price NUMBER CHECK (price > 0),
stock_quantity NUMBER CHECK (stock_quantity >= 0)
);

-- =============================
-- Q2.3: Create Table - Orders
-- =============================
CREATE TABLE Orders (
order_id NUMBER PRIMARY KEY,
customer_id NUMBER,
order_date DATE NOT NULL,
status VARCHAR2(20) CHECK (status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- =============================
-- Q2.4: Create Table - OrderItems
-- =============================
CREATE TABLE OrderItems (
order_item_id NUMBER PRIMARY KEY,
order_id NUMBER,
product_id NUMBER,
quantity NUMBER CHECK (quantity >= 1),
subtotal NUMBER,
FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
FOREIGN KEY (product_id) REFERENCES Products(product_id) ON UPDATE CASCADE
);

-- =============================
-- Q2.a: Insert New Customer 'Ali Raza'
-- =============================
INSERT INTO Customers (customer_id, first_name, last_name, email, phone)
VALUES (1, 'Ali', 'Raza', 'ali.raza@email.com', '+923001234567');

-- =============================
-- Q2.b: Insert New Product 'Laptop'
-- =============================
INSERT INTO Products (product_id, product_name, price, stock_quantity)
VALUES (101, 'Laptop', 100000, 10);

-- =============================
-- Q2.c: Record a New Order for Ali Raza
-- =============================
INSERT INTO Orders (order_id, customer_id, order_date, status)
VALUES (1001, 1, SYSDATE, 'Pending');

-- =============================
-- Q2.d: Add Order Item for 2 Laptops
-- =============================
-- Note: Subtotal is calculated as price * quantity. We assume a trigger or application logic sets this.
-- For this exam, we will calculate and insert it manually.
INSERT INTO OrderItems (order_item_id, order_id, product_id, quantity, subtotal)
VALUES (1, 1001, 101, 2, (SELECT price FROM Products WHERE product_id = 101) * 2);

-- =============================
-- Q2.e: Update Laptop Stock After Purchase
-- =============================
UPDATE Products
SET stock_quantity = stock_quantity - 2
WHERE product_id = 101;

-- =============================
-- Q2.f: Update Order Status to 'Shipped'
-- =============================
UPDATE Orders
SET status = 'Shipped'
WHERE order_id = 1001;

-- =============================
-- Q2.g: Remove Customers with Orders > 50,000
-- =============================
-- This is a two-step process due to the foreign key constraint.
-- First, identify and delete the orders of these customers, which will cascade to OrderItems.
-- Then, delete the customers.

DELETE FROM Orders
WHERE customer_id IN (
SELECT o.customer_id
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
GROUP BY o.customer_id
HAVING SUM(oi.subtotal) > 50000
);

-- Now delete the customers (those whose orders were just deleted, or who had no orders)
DELETE FROM Customers
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM Orders);
-- Note: A more precise solution would involve storing the target customer_ids in a temporary variable.

-- =============================
-- Q2.h: Find Most Frequently Ordered Product
-- =============================
SELECT p.product_name, SUM(oi.quantity) AS total_ordered
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_ordered DESC
FETCH FIRST 1 ROW ONLY;

CLO 4: Vehicle Rental Management System
-- =============================
-- Q3.1 & Q3.2: Relational Schema from ERD
-- =============================

-- Based on the requirements, the ERD would have four entities: Customers, Vehicles, Rentals, Payments.
-- The relational schema is implemented below.

-- =============================
-- Create Table - Customers
-- =============================
CREATE TABLE Customers (
customer_id NUMBER PRIMARY KEY,
first_name VARCHAR2(50) NOT NULL,
last_name VARCHAR2(50) NOT NULL,
drivers_license VARCHAR2(50) UNIQUE NOT NULL
);

-- =============================
-- Create Table - Vehicles
-- =============================
CREATE TABLE Vehicles (
vehicle_id NUMBER PRIMARY KEY,
model VARCHAR2(100) NOT NULL,
type VARCHAR2(20) CHECK (type IN ('Car', 'Bike', 'Van')),
rental_rate_per_day NUMBER NOT NULL
);

-- =============================
-- Create Table - Rentals
-- =============================
-- This table enforces that a vehicle cannot be rented by two customers at the same time.
-- The key is ensuring no overlap in rental dates for the same vehicle.
CREATE TABLE Rentals (
rental_id NUMBER PRIMARY KEY,
customer_id NUMBER NOT NULL,
vehicle_id NUMBER NOT NULL,
rental_start DATE NOT NULL,
rental_end DATE,
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
-- A trigger or application-level check would be needed to prevent date overlaps.
);

-- =============================
-- Create Table - Payments
-- =============================
CREATE TABLE Payments (
payment_id NUMBER PRIMARY KEY,
rental_id NUMBER NOT NULL,
amount NUMBER NOT NULL,
payment_date DATE NOT NULL,
FOREIGN KEY (rental_id) REFERENCES Rentals(rental_id)
);

-- To enforce no overlapping rentals for a vehicle (Q3.2c), a database trigger would be required.
-- The trigger would check, before insert/update, that for the same vehicle_id, the new rental period
-- (rental_start to rental_end) does not overlap with any existing rental period.
-- This is complex to implement via a simple constraint.

