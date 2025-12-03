/*
QUESTION 1: SQL QUERIES
*/

-- 1. Find departments where average salary exceeds $6,000
SELECT 
    d.department_name,
    ROUND(AVG(e.salary), 2) AS average_salary,
    COUNT(e.employee_id) AS employee_count
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.department_id IS NOT NULL
GROUP BY d.department_id, d.department_name
HAVING AVG(e.salary) > 6000
ORDER BY average_salary DESC;

-- 2. Identify employees hired in same year as their manager
SELECT 
    emp.first_name || ' ' || emp.last_name AS employee_name,
    TO_CHAR(emp.hire_date, 'YYYY') AS employee_hire_year,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    TO_CHAR(mgr.hire_date, 'YYYY') AS manager_hire_year
FROM employees emp
JOIN employees mgr ON emp.manager_id = mgr.employee_id
WHERE EXTRACT(YEAR FROM emp.hire_date) = EXTRACT(YEAR FROM mgr.hire_date)
ORDER BY emp.hire_date;

-- 3. Find job title with widest salary range
SELECT 
    j.job_title,
    j.min_salary,
    j.max_salary,
    (j.max_salary - j.min_salary) AS salary_range,
    COUNT(e.employee_id) AS current_employees
FROM jobs j
LEFT JOIN employees e ON j.job_id = e.job_id
GROUP BY j.job_id, j.job_title, j.min_salary, j.max_salary
ORDER BY salary_range DESC
FETCH FIRST 1 ROWS ONLY;

-- 4. List employees who worked in more than one department
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    COUNT(DISTINCT jh.department_id) AS departments_worked_in
FROM employees e
JOIN job_history jh ON e.employee_id = jh.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING COUNT(DISTINCT jh.department_id) > 1
ORDER BY departments_worked_in DESC;

-- 5. Departments with no salary increases in last 2 years
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE d.department_id NOT IN (
    SELECT DISTINCT e2.department_id
    FROM employees e2
    WHERE EXISTS (
        SELECT 1
        FROM job_history jh
        WHERE jh.employee_id = e2.employee_id
        AND jh.start_date >= ADD_MONTHS(SYSDATE, -24)
    )
    AND e2.department_id IS NOT NULL
)
AND d.department_id IS NOT NULL
GROUP BY d.department_id, d.department_name
ORDER BY d.department_name;

/*
QUESTION 2: TRIGGERS & TRANSACTIONS
*/

-- a. TRIGGER for Late Login Monitoring
-- Create tables
CREATE TABLE Employees (
    employee_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    department VARCHAR2(50),
    status VARCHAR2(20) DEFAULT 'Active'
);

CREATE TABLE attendance_log (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id NUMBER,
    login_time TIMESTAMP,
    logout_time TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE attendance_alerts (
    alert_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id NUMBER,
    alert_message VARCHAR2(200),
    alert_date DATE DEFAULT SYSDATE,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- Create trigger for late login monitoring
CREATE OR REPLACE TRIGGER late_login_monitor
AFTER INSERT ON attendance_log
FOR EACH ROW
BEGIN
    -- Check if login time is after 09:15 AM
    IF TO_CHAR(:NEW.login_time, 'HH24:MI') > '09:15' THEN
        INSERT INTO attendance_alerts (employee_id, alert_message)
        VALUES (
            :NEW.employee_id,
            'LATE LOGIN: Employee ' || :NEW.employee_id || 
            ' logged in at ' || TO_CHAR(:NEW.login_time, 'HH24:MI:SS') || 
            ' which is after 09:15 AM'
        );
    END IF;
END;
/

-- b. TRANSACTION for Hotel Booking (from previous question, modified for completeness)
-- Create tables if not exists
CREATE TABLE guests (
    guest_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(100),
    total_paid NUMBER(10,2) DEFAULT 0
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

-- Sample room data
INSERT INTO rooms (room_id, room_type, price) VALUES (101, 'Deluxe', 200);
INSERT INTO rooms (room_id, room_type, price) VALUES (102, 'Suite', 350);

-- Transaction for hotel booking payment process
DECLARE
    v_guest_id NUMBER := 1001;
    v_room_id NUMBER := 101;
    v_reservation_id NUMBER;
    v_room_price NUMBER;
BEGIN
    -- Get room price
    SELECT price INTO v_room_price FROM rooms WHERE room_id = v_room_id;
    
    -- 1. Insert new guest
    INSERT INTO guests (guest_id, name, email)
    VALUES (v_guest_id, 'Ahmed Ali', 'ahmed@email.com');
    
    -- 2. Insert reservation
    INSERT INTO reservations (guest_id, room_id, check_in, check_out)
    VALUES (v_guest_id, v_room_id, SYSDATE, SYSDATE + 3)
    RETURNING reservation_id INTO v_reservation_id;
    
    -- 3. Create SAVEPOINT
    SAVEPOINT sp_reservation;
    
    -- 4. Attempt invalid payment (negative amount)
    BEGIN
        INSERT INTO payments (reservation_id, amount)
        VALUES (v_reservation_id, -100); -- Negative amount violates business rule
    EXCEPTION
        WHEN OTHERS THEN
            NULL; -- Continue to rollback
    END;
    
    -- 5. ROLLBACK to SAVEPOINT to undo invalid payment
    ROLLBACK TO sp_reservation;
    
    -- 6. Update guest's total paid amount (calculate valid payments)
    UPDATE guests g
    SET total_paid = (
        SELECT COALESCE(SUM(p.amount), 0)
        FROM payments p
        JOIN reservations r ON p.reservation_id = r.reservation_id
        WHERE r.guest_id = g.guest_id
        AND p.amount > 0 -- Only valid positive payments
    )
    WHERE guest_id = v_guest_id;
    
    -- 7. COMMIT all valid changes
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Transaction completed successfully');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transaction failed: ' || SQLERRM);
END;
/

/*
QUESTION 3: PL/SQL - Logistics Company
*/

-- Create tables for logistics system
CREATE TABLE Shipments (
    shipment_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    origin VARCHAR2(100),
    destination VARCHAR2(100),
    shipment_date DATE DEFAULT SYSDATE,
    status VARCHAR2(20) DEFAULT 'Pending'
);

CREATE TABLE Delivery (
    delivery_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipment_id NUMBER,
    delivery_date DATE DEFAULT SYSDATE,
    delivered_by VARCHAR2(100),
    delivery_status VARCHAR2(20),
    FOREIGN KEY (shipment_id) REFERENCES Shipments(shipment_id)
);

-- Insert sample data
INSERT INTO Shipments VALUES (1001, 501, 'Karachi', 'Lahore', SYSDATE, 'Pending');
INSERT INTO Shipments VALUES (1002, 501, 'Islamabad', 'Karachi', SYSDATE, 'Delivered');
INSERT INTO Shipments VALUES (1003, 502, 'Lahore', 'Islamabad', SYSDATE, 'In Transit');

-- a. Stored Procedure RecordDelivery
CREATE OR REPLACE PROCEDURE RecordDelivery(
    p_shipment_id IN NUMBER,
    p_delivered_by IN VARCHAR2,
    p_delivery_status IN VARCHAR2
)
IS
    v_shipment_exists NUMBER;
    v_current_status VARCHAR2(20);
BEGIN
    -- Check if shipment exists
    SELECT COUNT(*), MAX(status)
    INTO v_shipment_exists, v_current_status
    FROM Shipments
    WHERE shipment_id = p_shipment_id;
    
    IF v_shipment_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Shipment not found.');
        RETURN;
    END IF;
    
    -- Check if already delivered
    IF v_current_status = 'Delivered' THEN
        DBMS_OUTPUT.PUT_LINE('Shipment already delivered.');
        RETURN;
    END IF;
    
    -- Insert delivery record
    INSERT INTO Delivery (shipment_id, delivered_by, delivery_status)
    VALUES (p_shipment_id, p_delivered_by, p_delivery_status);
    
    -- Update shipment status
    UPDATE Shipments
    SET status = 'Delivered'
    WHERE shipment_id = p_shipment_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Delivery recorded successfully for shipment ' || p_shipment_id);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END RecordDelivery;
/

-- b. Stored Function GetPendingShipments
CREATE OR REPLACE FUNCTION GetPendingShipments(
    p_customer_id IN NUMBER
) RETURN NUMBER
IS
    v_pending_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_pending_count
    FROM Shipments
    WHERE customer_id = p_customer_id
    AND status = 'Pending';
    
    RETURN v_pending_count;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN -1; -- Error indicator
END GetPendingShipments;
/

-- Test the procedure and function
BEGIN
    -- Test procedure
    RecordDelivery(1001, 'Driver Ali', 'Delivered');
    
    -- Test function
    DECLARE
        v_pending NUMBER;
    BEGIN
        v_pending := GetPendingShipments(501);
        DBMS_OUTPUT.PUT_LINE('Pending shipments for customer 501: ' || v_pending);
    END;
END;
/

/*
QUESTION 4: MONGODB
*/

-- Use database
use streaming_service;

-- Insert documents into Users collection
db.Users.insertMany([
    {
        "user_id": 501,
        "first_name": "Sara",
        "last_name": "Khan",
        "email": "sara@example.com",
        "city": "Lahore",
        "membership_type": "Premium"
    },
    {
        "user_id": 502,
        "first_name": "Ali",
        "last_name": "Ahmed",
        "email": "ali@example.com",
        "city": "Karachi",
        "membership_type": "Basic"
    },
    {
        "user_id": 503,
        "first_name": "Fatima",
        "last_name": "Zahra",
        "email": "fatima@example.com",
        "city": "Lahore",
        "membership_type": "Standard"
    },
    {
        "user_id": 504,
        "first_name": "Omar",
        "last_name": "Khan",
        "email": "omar@example.com",
        "city": "Islamabad",
        "membership_type": "Expired"
    }
]);

-- Insert documents into WatchHistory collection
db.WatchHistory.insertMany([
    {
        "user_id": 501,
        "movies": [
            {"title": "Inception", "duration": 148, "genre": "Sci-Fi"},
            {"title": "Tenet", "duration": 150, "genre": "Action"},
            {"title": "Interstellar", "duration": 169, "genre": "Sci-Fi"},
            {"title": "The Dark Knight", "duration": 152, "genre": "Action"}
        ],
        "watch_date": ISODate("2025-11-20T18:00:00Z")
    },
    {
        "user_id": 502,
        "movies": [
            {"title": "Avengers", "duration": 143, "genre": "Action"},
            {"title": "Inception", "duration": 148, "genre": "Sci-Fi"}
        ],
        "watch_date": ISODate("2025-11-22T20:00:00Z")
    },
    {
        "user_id": 501,
        "movies": [
            {"title": "Inception", "duration": 148, "genre": "Sci-Fi"},
            {"title": "The Matrix", "duration": 136, "genre": "Sci-Fi"},
            {"title": "Tenet", "duration": 150, "genre": "Action"}
        ],
        "watch_date": ISODate("2025-11-25T15:00:00Z")
    },
    {
        "user_id": 503,
        "movies": [
            {"title": "Interstellar", "duration": 169, "genre": "Sci-Fi"}
        ],
        "watch_date": ISODate("2025-10-15T19:00:00Z")
    }
]);

-- 1. Find all users who watched more than 3 movies in a single watch history record
db.WatchHistory.find({
    $expr: { $gt: [{ $size: "$movies" }, 3] }
});

-- 2. Calculate total watch duration for each history entry
db.WatchHistory.aggregate([
    {
        $project: {
            user_id: 1,
            watch_date: 1,
            total_duration: {
                $sum: "$movies.duration"
            },
            movie_count: { $size: "$movies" }
        }
    }
]);

-- 3. Find the user who spent the most time watching movies overall
db.WatchHistory.aggregate([
    {
        $unwind: "$movies"
    },
    {
        $group: {
            _id: "$user_id",
            total_watch_time: { $sum: "$movies.duration" }
        }
    },
    {
        $sort: { total_watch_time: -1 }
    },
    {
        $limit: 1
    }
]);

-- 4. List all movie titles along with their total number of times watched
db.WatchHistory.aggregate([
    {
        $unwind: "$movies"
    },
    {
        $group: {
            _id: "$movies.title",
            times_watched: { $sum: 1 },
            total_duration_watched: { $sum: "$movies.duration" }
        }
    },
    {
        $sort: { times_watched: -1 }
    }
]);

-- 5. Find all movies watched in November 2025
db.WatchHistory.find({
    "watch_date": {
        $gte: ISODate("2025-11-01T00:00:00Z"),
        $lt: ISODate("2025-12-01T00:00:00Z")
    }
});

-- 6. Update all users with Basic membership to Standard membership
db.Users.updateMany(
    { "membership_type": "Basic" },
    { $set: { "membership_type": "Standard" } }
);

-- 7. Find the top 5 most active users by total watch entries
db.WatchHistory.aggregate([
    {
        $group: {
            _id: "$user_id",
            total_entries: { $sum: 1 }
        }
    },
    {
        $sort: { total_entries: -1 }
    },
    {
        $limit: 5
    }
]);

-- 8. Count the number of watch history entries per user
db.WatchHistory.aggregate([
    {
        $group: {
            _id: "$user_id",
            watch_history_count: { $sum: 1 }
        }
    }
]);

-- 9. Find all Lahore users and sort them by first name
db.Users.find(
    { "city": "Lahore" }
).sort({ "first_name": 1 });

-- 10. Delete all users with membership type = "Expired"
db.Users.deleteMany(
    { "membership_type": "Expired" }
);
