BEGIN;

-- Job titles
INSERT INTO job_title(job_title) VALUES
('Ass. Professor'),
('Lecturer'),
('PhD Student'),
('TA');

-- Departments (manager_id sätts efter att employees finns)
INSERT INTO department(department_name, manager_id) VALUES
('Computer Science', NULL),
('Mathematics', NULL);

-- Persons
INSERT INTO person(personal_number, first_name, last_name, phone_number, address) VALUES
('19800101-0001','Paris','Carbone','0700000001','Stockholm'),
('19750505-0002','Leif','Linbäck','0700000002','Stockholm'),
('19900101-0003','Niharika','Gauraha','0700000003','Stockholm'),
('19950505-0004','Brian','Student','0700000004','Stockholm'),
('20000101-0005','Adam','Assistant','0700000005','Stockholm');

-- Employees (employment_id är PK)
INSERT INTO employee(employment_id, skill_set, salary, supervisor_id, person_id, department_id, job_title_id) VALUES
(500001,'Databases, Data warehousing',60000, NULL, 1, 1, 1),
(500004,'Teaching, Systems',          55000, 500001, 2, 1, 2),
(500009,'SQL, Analytics',             52000, 500001, 3, 1, 2),
(500010,'Labs, Support',              35000, 500009, 4, 1, 3),
(500011,'Tutoring',                   25000, 500009, 5, 1, 4);

-- Sätt managers
UPDATE department SET manager_id = 500001 WHERE department_id = 1;
UPDATE department SET manager_id = 500001 WHERE department_id = 2;

-- Teaching activities (+ factor)
INSERT INTO teaching_activity(activity_name, factor) VALUES
('Lecture',        3.60),
('Lab',            2.40),
('Tutorial',       2.40),
('Seminar',        1.80),
('Other',          1.00),
('Administration', 1.00),
('Examination',    1.00);

-- Course layouts
INSERT INTO course_layout(course_code, course_name, min_students, max_students, hp) VALUES
('IV1351','Data Storage Paradigms', 50, 250, 7.5),
('IX1500','Discrete Mathematics',  50, 150, 7.5),
('ID2214','Networking Basics',     30, 200, 7.5),
('IV1350','Intro to Databases',    50, 250, 7.5);

-- Course instances (2025)
INSERT INTO course_instance(num_students, study_period, study_year, course_layout_id) VALUES
(200,'P2',2025, 1), -- IV1351
(150,'P1',2025, 2), -- IX1500
(120,'P2',2025, 3), -- ID2214
(180,'P1',2025, 4); -- IV1350

-- Planned activities (admin/exam lagras inte – de räknas i queries)
-- Instance 1 (IV1351)
INSERT INTO planned_activity(course_instance_id, teaching_activity_id, planned_hours) VALUES
(1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lecture'),  20),
(1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Tutorial'), 80),
(1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lab'),      40),
(1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Seminar'),  80),
(1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Other'),   650);

-- Instance 2 (IX1500)
INSERT INTO planned_activity(course_instance_id, teaching_activity_id, planned_hours) VALUES
(2, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lecture'), 44),
(2, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Seminar'), 64),
(2, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Other'),  200);

-- Instance 3 (ID2214)
INSERT INTO planned_activity(course_instance_id, teaching_activity_id, planned_hours) VALUES
(3, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lecture'), 30),
(3, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Tutorial'), 15),
(3, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Other'),  40);

-- Instance 4 (IV1350)
INSERT INTO planned_activity(course_instance_id, teaching_activity_id, planned_hours) VALUES
(4, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lab'),   20),
(4, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Other'), 100);

-- Allocations (inkl admin/exam som verkliga tilldelningar)
-- Course instance 1 (IV1351, P2)
INSERT INTO allocation(employment_id, course_instance_id, teaching_activity_id, allocated_hours) VALUES
(500001, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lecture'),        20),
(500001, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Other'),         100),
(500001, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Administration'), 43),
(500001, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Examination'),    61),

(500004, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Seminar'),        40),
(500004, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Other'),         100),
(500004, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Examination'),    62),

(500009, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Seminar'),        40),
(500009, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Other'),         100),
(500009, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Administration'), 43),
(500009, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Examination'),    61),

(500010, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lab'),            21),
(500010, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Other'),         100),

(500011, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lab'),            21),
(500011, 1, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Seminar'),        10);

-- Course instance 2 (IX1500, P1) -> Niharika
INSERT INTO allocation(employment_id, course_instance_id, teaching_activity_id, allocated_hours) VALUES
(500009, 2, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Lecture'),        44),
(500009, 2, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Administration'), 50),
(500009, 2, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Examination'),    30),
(500009, 2, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Other'),         100);

-- Course instance 4 (IV1350, P1) -> Niharika (så query 4 kan hitta >1 kurs i samma period)
INSERT INTO allocation(employment_id, course_instance_id, teaching_activity_id, allocated_hours) VALUES
(500009, 4, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name='Other'), 40);

COMMIT;
