/*
QUESTION 1: SQL QUERIES
*/

-- 1. Write a query to find the following output:
SELECT 
    d.department_name,
    e.first_name || ' ' || e.last_name AS employee_name,
    j.job_title,
    e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN jobs j ON e.job_id = j.job_id
WHERE e.employee_id IN (
    SELECT employee_id 
    FROM (
        SELECT employee_id, 
               ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) as rn
        FROM employees
        WHERE department_id IS NOT NULL
    ) 
    WHERE rn = 1
)
ORDER BY d.department_name;

-- 2. Find departments where salary difference > $4000
SELECT 
    d.department_name,
    MAX(e.salary) AS max_salary,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) - MIN(e.salary) AS salary_difference
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING MAX(e.salary) - MIN(e.salary) > 4000
ORDER BY salary_difference DESC;

-- 3. Find year and department that hired most employees
SELECT 
    d.department_name,
    EXTRACT(YEAR FROM e.hire_date) AS hire_year,
    COUNT(*) AS number_of_hires
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name, EXTRACT(YEAR FROM e.hire_date)
HAVING COUNT(*) = (
    SELECT MAX(hire_count)
    FROM (
        SELECT 
            department_id,
            EXTRACT(YEAR FROM hire_date) AS year,
            COUNT(*) AS hire_count
        FROM employees
        GROUP BY department_id, EXTRACT(YEAR FROM hire_date)
    )
);

-- 4. Employees whose salary hasn't changed since hire
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    e.hire_date,
    e.salary,
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM job_history jh 
    WHERE jh.employee_id = e.employee_id
);

-- 5. Employees who earn more than their manager
SELECT 
    emp.first_name || ' ' || emp.last_name AS employee_name,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    emp.salary AS employee_salary,
    mgr.salary AS manager_salary
FROM employees emp
JOIN employees mgr ON emp.manager_id = mgr.employee_id
WHERE emp.salary > mgr.salary;

/*
QUESTION 2: TRIGGERS & TRANSACTIONS
*/

-- a. Trigger for stock threshold
-- First create Stock_Alert table
CREATE TABLE Stock_Alert (
    alert_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id NUMBER,
    current_stock NUMBER,
    alert_message VARCHAR2(200),
    alert_date DATE DEFAULT SYSDATE
);

-- Create the trigger
CREATE OR REPLACE TRIGGER stock_threshold_check
BEFORE UPDATE ON Products
FOR EACH ROW
WHEN (NEW.stock_quantity < 5)
BEGIN
    INSERT INTO Stock_Alert (product_id, current_stock, alert_message)
    VALUES (
        :NEW.product_id,
        :NEW.stock_quantity,
        'Warning: Stock quantity below threshold of 5 units for product ' || :NEW.product_name
    );
END;
/

-- b. Hotel reservation system transaction
-- Create tables
CREATE TABLE guests (
    guest_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(100)
);

CREATE TABLE rooms (
    room_id NUMBER PRIMARY KEY,
    room_type VARCHAR2(50),
    price NUMBER(10,2)
);

CREATE TABLE reservations (
    reservation_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    guest_id NUMBER,
    room_id NUMBER,
    check_in DATE,
    check_out DATE,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

CREATE TABLE payments (
    payment_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reservation_id NUMBER,
    amount NUMBER(10,2),
    FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id)
);

CREATE TABLE reservation_log (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reservation_id NUMBER,
    action VARCHAR2(200),
    action_date DATE DEFAULT SYSDATE,
    FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id)
);

-- Transaction example
DECLARE
    v_guest_id NUMBER := 101;
    v_room_id NUMBER := 201;
    v_reservation_id NUMBER;
BEGIN
    -- Start transaction
    SAVEPOINT start_transaction;
    
    -- Insert new guest
    INSERT INTO guests (guest_id, name, email) 
    VALUES (v_guest_id, 'John Smith', 'john@email.com');
    
    -- Make reservation
    INSERT INTO reservations (guest_id, room_id, check_in, check_out)
    VALUES (v_guest_id, v_room_id, SYSDATE, SYSDATE + 3)
    RETURNING reservation_id INTO v_reservation_id;
    
    -- Process payment
    INSERT INTO payments (reservation_id, amount)
    VALUES (v_reservation_id, 300);
    
    -- Log the action
    INSERT INTO reservation_log (reservation_id, action)
    VALUES (v_reservation_id, 'Reservation created and payment processed');
    
    -- If all successful, commit
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        -- If any error, rollback
        ROLLBACK TO start_transaction;
        DBMS_OUTPUT.PUT_LINE('Transaction failed: ' || SQLERRM);
END;
/

/*
QUESTION 3: PL/SQL
*/

-- Create tables for question 3
CREATE TABLE Products (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100),
    price NUMBER(10,2),
    stock_quantity NUMBER
);

CREATE TABLE Sales (
    sale_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id NUMBER,
    sale_date DATE DEFAULT SYSDATE,
    sale_amount NUMBER,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Insert sample data
INSERT INTO Products VALUES (1, 'Laptop', 40000, 10);
INSERT INTO Products VALUES (2, 'Smartphone', 25000, 12);
INSERT INTO Products VALUES (3, 'Headphones', 500, 8);
INSERT INTO Products VALUES (4, 'Tablet', 10000, 15);

-- 1. Stored Procedure RecordSale
CREATE OR REPLACE PROCEDURE RecordSale(
    p_product_id IN NUMBER,
    p_sale_amount IN NUMBER
)
IS
    v_stock_quantity NUMBER;
    v_product_exists NUMBER;
BEGIN
    -- Check if product exists
    SELECT COUNT(*) INTO v_product_exists
    FROM Products
    WHERE product_id = p_product_id;
    
    IF v_product_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Product not found.');
        RETURN;
    END IF;
    
    -- Get current stock
    SELECT stock_quantity INTO v_stock_quantity
    FROM Products
    WHERE product_id = p_product_id;
    
    -- Check stock availability
    IF p_sale_amount > v_stock_quantity THEN
        DBMS_OUTPUT.PUT_LINE('Insufficient stock for the sale.');
        RETURN;
    END IF;
    
    -- Update stock and insert sale record
    UPDATE Products
    SET stock_quantity = stock_quantity - p_sale_amount
    WHERE product_id = p_product_id;
    
    INSERT INTO Sales (product_id, sale_amount)
    VALUES (p_product_id, p_sale_amount);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Sale recorded successfully.');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END RecordSale;
/

-- 2. Stored Function GetTotalSalesAmount
CREATE OR REPLACE FUNCTION GetTotalSalesAmount(
    p_product_id IN NUMBER
) RETURN NUMBER
IS
    v_total_sales NUMBER := 0;
BEGIN
    SELECT SUM(sale_amount) INTO v_total_sales
    FROM Sales
    WHERE product_id = p_product_id;
    
    RETURN NVL(v_total_sales, 0);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END GetTotalSalesAmount;
/

-- Test the function
DECLARE
    v_total NUMBER;
BEGIN
    v_total := GetTotalSalesAmount(1);
    DBMS_OUTPUT.PUT_LINE('Total sales for product 1: ' || v_total);
END;
/

/*
QUESTION 4: MONGODB
*/

-- Use database
use bookstore;

-- Insert documents
db.books.insertMany([
    {"book_id": "B001", "title": "Data Science Fundamentals", "author": "John Smith", "category": "Technology", "price": 29.99, "in_stock": true},
    {"book_id": "B002", "title": "Learning MongoDB", "author": "Jane Doe", "category": "Technology", "price": 35.99, "in_stock": false},
    {"book_id": "B003", "title": "Web Development with JavaScript", "author": "Mark Lee", "category": "Programming", "price": 24.99, "in_stock": true},
    {"book_id": "B004", "title": "Introduction to Python", "author": "Alice Brown", "category": "Programming", "price": 19.99, "in_stock": true},
    {"book_id": "B005", "title": "Advanced SQL Queries", "author": "Michael White", "category": "Database", "price": 45.99, "in_stock": true},
    {"book_id": "B006", "title": "C++ Basics", "author": "John Smith", "category": "Programming", "price": 29.99, "in_stock": true},
    {"book_id": "B007", "title": "Machine Learning with Python", "author": "Sara Green", "category": "Technology", "price": 39.99, "in_stock": true},
    {"book_id": "B008", "title": "Deep Learning Essentials", "author": "David Grey", "category": "Technology", "price": 59.99, "in_stock": false},
    {"book_id": "B009", "title": "Data Structures in Java", "author": "Lucas Blue", "category": "Programming", "price": 49.99, "in_stock": true},
    {"book_id": "B010", "title": "Artificial Intelligence", "author": "Sophia Grey", "category": "Technology", "price": 69.99, "in_stock": true}
]);

-- 1. Update Technology books with price < $40 to in_stock: false
db.books.updateMany(
    { 
        "category": "Technology", 
        "price": { $lt: 40 } 
    },
    { 
        $set: { "in_stock": false } 
    }
);

-- 2. Delete book B008 if out of stock
db.books.deleteOne({
    "book_id": "B008",
    "in_stock": false
});

-- 3. Update John Smith's Technology books
db.books.updateMany(
    { 
        "author": "John Smith", 
        "category": "Technology",
        "price": { $gt: 20 },
        "in_stock": true
    },
    { 
        $set: { "price": 35 } 
    }
);

-- 4. Find Programming books with price > $25, in stock, sorted by price desc
db.books.find({
    "category": "Programming",
    "price": { $gt: 25 },
    "in_stock": true
}).sort({ "price": -1 });

-- 5. Delete books: (Programming AND out of stock) OR price > $50
db.books.deleteMany({
    $or: [
        { 
            "category": "Programming", 
            "in_stock": false 
        },
        { 
            "price": { $gt: 50 } 
        }
    ]
});

-- 6. Update books B005 and B006
db.books.updateMany(
    { 
        "book_id": { $in: ["B005", "B006"] } 
    },
    { 
        $set: { 
            "price": 40,
            "in_stock": true 
        } 
    }
);

-- 7. Find books: (author = Jane Doe OR category = Database) AND price between $30-$60
db.books.find({
    $and: [
        {
            $or: [
                { "author": "Jane Doe" },
                { "category": "Database" }
            ]
        },
        {
            "price": { $gte: 30, $lte: 60 }
        }
    ]
});

-- 8. Update Programming books: price < $50 AND in stock
db.books.updateMany(
    { 
        "category": "Programming",
        "price": { $lt: 50 },
        "in_stock": true
    },
    { 
        $set: { "price": 50 } 
    }
);

-- 9. Delete books: price < $30 AND category = Technology AND out of stock
db.books.deleteMany({
    "price": { $lt: 30 },
    "category": "Technology",
    "in_stock": false
});

-- 10. Update book B010
db.books.updateOne(
    { "book_id": "B010" },
    { 
        $set: { 
            "title": "AI Revolution",
            "price": 69.99 * 0.9  -- 10% reduction
        } 
    }
);
