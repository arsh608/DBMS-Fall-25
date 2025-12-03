/*
QUESTION 1: SQL QUERIES
*/

-- 1. Find departments where total payroll exceeds $100,000
SELECT 
    d.department_name,
    SUM(e.salary) AS total_payroll
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING SUM(e.salary) > 100000
ORDER BY total_payroll DESC;

-- 2. Identify employees hired most recently in each department
SELECT 
    d.department_name,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.hire_date
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE (e.department_id, e.hire_date) IN (
    SELECT department_id, MAX(hire_date)
    FROM employees
    WHERE department_id IS NOT NULL
    GROUP BY department_id
)
ORDER BY d.department_name;

-- 3. Find managers who supervise more than 5 employees
SELECT 
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    mgr.job_id,
    COUNT(emp.employee_id) AS employees_supervised
FROM employees emp
JOIN employees mgr ON emp.manager_id = mgr.employee_id
GROUP BY mgr.employee_id, mgr.first_name, mgr.last_name, mgr.job_id
HAVING COUNT(emp.employee_id) > 5
ORDER BY employees_supervised DESC;

-- 4. List employees whose salary is above department average
SELECT 
    d.department_name,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.salary,
    ROUND(dept_avg.avg_salary, 2) AS department_avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    WHERE department_id IS NOT NULL
    GROUP BY department_id
) dept_avg ON e.department_id = dept_avg.department_id
WHERE e.salary > dept_avg.avg_salary
ORDER BY d.department_name, e.salary DESC;

-- 5. Find job titles where no one is earning the maximum salary for that job
SELECT 
    j.job_title
FROM jobs j
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.job_id = j.job_id
    AND e.salary = j.max_salary
)
ORDER BY j.job_title;

/*
QUESTION 2: TRIGGERS & TRANSACTIONS
*/

-- a. TRIGGER for Patient Health Alert
-- Create tables
CREATE TABLE Patient_Records (
    patient_id NUMBER PRIMARY KEY,
    patient_name VARCHAR2(100),
    age NUMBER,
    blood_pressure VARCHAR2(20),
    heart_rate NUMBER,
    last_update DATE DEFAULT SYSDATE
);

CREATE TABLE Health_Alerts (
    alert_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id NUMBER,
    blood_pressure VARCHAR2(20),
    alert_message VARCHAR2(200),
    alert_date DATE DEFAULT SYSDATE,
    FOREIGN KEY (patient_id) REFERENCES Patient_Records(patient_id)
);

-- Create trigger
CREATE OR REPLACE TRIGGER critical_health_alert
BEFORE UPDATE ON Patient_Records
FOR EACH ROW
BEGIN
    -- Check if blood pressure exceeds 180/120
    IF :NEW.blood_pressure LIKE '18%/%' OR 
       :NEW.blood_pressure LIKE '19%/%' OR
       :NEW.blood_pressure LIKE '2%/%' THEN
        
        INSERT INTO Health_Alerts (patient_id, blood_pressure, alert_message)
        VALUES (
            :NEW.patient_id,
            :NEW.blood_pressure,
            'CRITICAL: Blood pressure ' || :NEW.blood_pressure || ' exceeds safe limits (180/120)'
        );
    END IF;
END;
/

-- b. TRANSACTION for Hotel Booking
-- Create tables
CREATE TABLE guests (
    guest_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(100),
    total_paid_amount NUMBER(10,2) DEFAULT 0
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

-- Transaction example
DECLARE
    v_guest_id NUMBER := 100;
    v_room_id NUMBER := 200;
    v_reservation_id NUMBER;
    v_room_price NUMBER(10,2) := 150.00;
BEGIN
    -- Start transaction
    INSERT INTO guests (guest_id, name, email)
    VALUES (v_guest_id, 'John Doe', 'john@email.com');
    
    INSERT INTO reservations (guest_id, room_id, check_in, check_out)
    VALUES (v_guest_id, v_room_id, SYSDATE, SYSDATE + 3)
    RETURNING reservation_id INTO v_reservation_id;
    
    -- Create savepoint
    SAVEPOINT sp_reservation;
    
    -- Attempt invalid payment (negative amount)
    BEGIN
        INSERT INTO payments (reservation_id, amount)
        VALUES (v_reservation_id, -50);
        
        -- If we reach here, the invalid payment was inserted
        -- This violates business rule, so rollback
        RAISE_APPLICATION_ERROR(-20001, 'Invalid payment amount');
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback to savepoint to undo invalid payment
            ROLLBACK TO sp_reservation;
            DBMS_OUTPUT.PUT_LINE('Invalid payment rolled back: ' || SQLERRM);
    END;
    
    -- Insert valid payment
    INSERT INTO payments (reservation_id, amount)
    VALUES (v_reservation_id, v_room_price * 3); -- 3 days stay
    
    -- Update guest's total paid amount
    UPDATE guests g
    SET total_paid_amount = (
        SELECT SUM(p.amount)
        FROM payments p
        JOIN reservations r ON p.reservation_id = r.reservation_id
        WHERE r.guest_id = g.guest_id
    )
    WHERE guest_id = v_guest_id;
    
    -- Commit all valid changes
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transaction completed successfully');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transaction failed: ' || SQLERRM);
END;
/

/*
QUESTION 3: PL/SQL
*/

-- Create tables for university system
CREATE TABLE Students (
    student_id NUMBER PRIMARY KEY,
    student_name VARCHAR2(100),
    email VARCHAR2(100),
    enrollment_date DATE DEFAULT SYSDATE
);

CREATE TABLE Enrollments (
    enrollment_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id NUMBER,
    course_id NUMBER,
    enrollment_date DATE DEFAULT SYSDATE,
    grade VARCHAR2(2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- Insert sample data
INSERT INTO Students VALUES (1, 'Ali Khan', 'ali@university.edu', SYSDATE);
INSERT INTO Students VALUES (2, 'Sara Ahmed', 'sara@university.edu', SYSDATE);
INSERT INTO Enrollments (student_id, course_id, grade) VALUES (1, 101, 'A');
INSERT INTO Enrollments (student_id, course_id, grade) VALUES (1, 102, 'B+');
INSERT INTO Enrollments (student_id, course_id, grade) VALUES (2, 101, NULL);

-- a. Stored Procedure RecordGrade
CREATE OR REPLACE PROCEDURE RecordGrade(
    p_student_id IN NUMBER,
    p_course_id IN NUMBER,
    p_grade IN VARCHAR2
)
IS
    v_enrollment_count NUMBER;
BEGIN
    -- Check if student is enrolled in the course
    SELECT COUNT(*) INTO v_enrollment_count
    FROM Enrollments
    WHERE student_id = p_student_id
    AND course_id = p_course_id;
    
    IF v_enrollment_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Student is not enrolled in the course.');
        RETURN;
    END IF;
    
    -- Update the grade
    UPDATE Enrollments
    SET grade = p_grade
    WHERE student_id = p_student_id
    AND course_id = p_course_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Grade recorded successfully for student_id ' || 
                        p_student_id || ' in course_id ' || p_course_id);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END RecordGrade;
/

-- b. Stored Function GetStudentAverageGrade
CREATE OR REPLACE FUNCTION GetStudentAverageGrade(
    p_student_id IN NUMBER
) RETURN NUMBER
IS
    v_avg_grade NUMBER;
    v_grade_count NUMBER;
BEGIN
    -- Convert letter grades to numeric values
    SELECT 
        AVG(CASE grade
            WHEN 'A' THEN 4.0
            WHEN 'A-' THEN 3.7
            WHEN 'B+' THEN 3.3
            WHEN 'B' THEN 3.0
            WHEN 'B-' THEN 2.7
            WHEN 'C+' THEN 2.3
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
            ELSE NULL
        END),
        COUNT(grade)
    INTO v_avg_grade, v_grade_count
    FROM Enrollments
    WHERE student_id = p_student_id;
    
    IF v_grade_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No grades available for this student.');
        RETURN NULL;
    END IF;
    
    RETURN ROUND(v_avg_grade, 2);
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END GetStudentAverageGrade;
/

-- Test the function
DECLARE
    v_avg NUMBER;
BEGIN
    v_avg := GetStudentAverageGrade(1);
    IF v_avg IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Average grade for student 1: ' || v_avg);
    END IF;
    
    v_avg := GetStudentAverageGrade(2);
    IF v_avg IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Student 2 has no grades recorded.');
    END IF;
END;
/

/*
QUESTION 4: MONGODB
*/

-- Use database
use hospital;

-- Insert documents into Patients collection
db.Patients.insertMany([
    {
        "patient_id": 301,
        "first_name": "Hamza",
        "last_name": "Ali",
        "age": 32,
        "city": "Islamabad",
        "contact": "0333-1234567"
    },
    {
        "patient_id": 302,
        "first_name": "Ayesha",
        "last_name": "Khan",
        "age": 28,
        "city": "Karachi",
        "contact": "0333-7654321"
    },
    {
        "patient_id": 303,
        "first_name": "Omar",
        "last_name": "Ahmed",
        "age": 45,
        "city": "Quetta",
        "contact": "0333-9876543"
    }
]);

-- Insert documents into Appointments collection
db.Appointments.insertMany([
    {
        "appointment_id": 7001,
        "patient_id": 301,
        "doctor_name": "Dr. Ayesha Siddiqui",
        "services": [
            {"service_name": "Consultation", "fee": 1500},
            {"service_name": "Blood Test", "fee": 800}
        ],
        "appointment_date": ISODate("2025-11-25T09:30:00Z"),
        "status": "Pending"
    },
    {
        "appointment_id": 7002,
        "patient_id": 302,
        "doctor_name": "Dr. Ahmed Khan",
        "services": [
            {"service_name": "Consultation", "fee": 1500},
            {"service_name": "X-Ray", "fee": 1200},
            {"service_name": "Medicine", "fee": 500}
        ],
        "appointment_date": ISODate("2025-11-28T14:00:00Z"),
        "status": "Completed"
    },
    {
        "appointment_id": 7003,
        "patient_id": 301,
        "doctor_name": "Dr. Sara Ahmed",
        "services": [
            {"service_name": "Follow-up", "fee": 1000},
            {"service_name": "Lab Test", "fee": 900}
        ],
        "appointment_date": ISODate("2025-12-01T11:00:00Z"),
        "status": "Pending"
    }
]);

-- 1. Find all appointments where total services are more than 2
db.Appointments.find({
    $expr: { $gt: [{ $size: "$services" }, 2] }
});

-- 2. Calculate total bill amount for each appointment
db.Appointments.aggregate([
    {
        $project: {
            appointment_id: 1,
            patient_id: 1,
            doctor_name: 1,
            total_bill: {
                $sum: "$services.fee"
            }
        }
    }
]);

-- 3. Find the patient who has spent the highest total amount on appointments
db.Appointments.aggregate([
    {
        $unwind: "$services"
    },
    {
        $group: {
            _id: "$patient_id",
            total_spent: { $sum: "$services.fee" }
        }
    },
    {
        $sort: { total_spent: -1 }
    },
    {
        $limit: 1
    }
]);

-- 4. List all services provided along with their total count across all appointments
db.Appointments.aggregate([
    {
        $unwind: "$services"
    },
    {
        $group: {
            _id: "$services.service_name",
            total_count: { $sum: 1 }
        }
    },
    {
        $sort: { total_count: -1 }
    }
]);

-- 5. Retrieve all appointments scheduled in November 2025
db.Appointments.find({
    "appointment_date": {
        $gte: ISODate("2025-11-01T00:00:00Z"),
        $lt: ISODate("2025-12-01T00:00:00Z")
    }
});

-- 6. Update the status of all Pending appointments to Completed
db.Appointments.updateMany(
    { "status": "Pending" },
    { $set: { "status": "Completed" } }
);

-- 7. Find the top 3 patients by number of appointments booked
db.Appointments.aggregate([
    {
        $group: {
            _id: "$patient_id",
            appointment_count: { $sum: 1 }
        }
    },
    {
        $sort: { appointment_count: -1 }
    },
    {
        $limit: 3
    }
]);

-- 8. Count the total number of appointments for each patient
db.Appointments.aggregate([
    {
        $group: {
            _id: "$patient_id",
            total_appointments: { $sum: 1 }
        }
    }
]);

-- 9. Find all patients living in Islamabad, sorted by last_name
db.Patients.find(
    { "city": "Islamabad" }
).sort({ "last_name": 1 });

-- 10. Delete all patients whose city is Quetta
db.Patients.deleteMany(
    { "city": "Quetta" }
);
