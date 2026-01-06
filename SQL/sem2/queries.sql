-- =========================
-- IV1351 – Seminar 2 (Task 2 / 5.2)
-- OLAP views + Query 1–4 
-- "Current year" = MAX(study_year) in course_instance
-- =========================

-- ---------- Helpers ----------
CREATE OR REPLACE VIEW v_current_year AS
SELECT MAX(study_year) AS study_year
FROM course_instance;

-- Planned hours with multiplication factor
CREATE OR REPLACE VIEW v_planned_factored AS
SELECT
  ci.course_instance_id,
  cl.course_code,
  cl.hp,
  ci.study_year,
  ci.study_period,
  ci.num_students,
  ta.activity_name,
  pa.planned_hours,
  ta.factor,
  (pa.planned_hours * ta.factor) AS hours_factored
FROM planned_activity pa
JOIN teaching_activity ta ON ta.teaching_activity_id = pa.teaching_activity_id
JOIN course_instance ci ON ci.course_instance_id = pa.course_instance_id
JOIN course_layout cl ON cl.course_layout_id = ci.course_layout_id;

-- Allocated hours with multiplication factor (+ teacher info)
CREATE OR REPLACE VIEW v_alloc_factored AS
SELECT
  a.course_instance_id,
  cl.course_code,
  cl.hp,
  ci.study_year,
  ci.study_period,
  ci.num_students,

  e.employment_id,
  (p.first_name || ' ' || p.last_name) AS teacher_name,
  jt.job_title AS designation,

  ta.activity_name,
  a.allocated_hours,
  ta.factor,
  (a.allocated_hours * ta.factor) AS hours_factored
FROM allocation a
JOIN teaching_activity ta ON ta.teaching_activity_id = a.teaching_activity_id
JOIN employee e ON e.employment_id = a.employment_id
JOIN person p ON p.person_id = e.person_id
JOIN job_title jt ON jt.job_title_id = e.job_title_id
JOIN course_instance ci ON ci.course_instance_id = a.course_instance_id
JOIN course_layout cl ON cl.course_layout_id = ci.course_layout_id;


-- =========================================================
-- QUERY 1:
-- Planned total hours (factored) per course instance for current year
-- Includes derived Admin + Exam (from spec) + Total
-- =========================================================
WITH cy AS (SELECT study_year FROM v_current_year)
SELECT
  pf.course_code,
  pf.course_instance_id,
  pf.hp,
  pf.study_period,
  pf.num_students,

  COALESCE(SUM(CASE WHEN pf.activity_name='Lecture'  THEN pf.hours_factored END),0) AS lecture_hours,
  COALESCE(SUM(CASE WHEN pf.activity_name='Tutorial' THEN pf.hours_factored END),0) AS tutorial_hours,
  COALESCE(SUM(CASE WHEN pf.activity_name='Lab'      THEN pf.hours_factored END),0) AS lab_hours,
  COALESCE(SUM(CASE WHEN pf.activity_name='Seminar'  THEN pf.hours_factored END),0) AS seminar_hours,
  COALESCE(SUM(CASE WHEN pf.activity_name='Other'    THEN pf.hours_factored END),0) AS other_overhead_hours,

  ROUND(2*pf.hp + 28 + 0.2*pf.num_students, 2) AS admin_hours,
  ROUND(32 + 0.725*pf.num_students, 2)        AS exam_hours,

  ROUND(
    COALESCE(SUM(pf.hours_factored),0)
    + (2*pf.hp + 28 + 0.2*pf.num_students)
    + (32 + 0.725*pf.num_students)
  , 2) AS total_hours
FROM v_planned_factored pf
JOIN cy ON cy.study_year = pf.study_year
GROUP BY pf.course_code, pf.course_instance_id, pf.hp, pf.study_period, pf.num_students
ORDER BY pf.course_code, pf.course_instance_id;


-- =========================================================
-- QUERY 2:
-- Actual allocated hours (factored) per teacher for ONE course instance (current year)
-- Set course instance id in psql:  \set ci 1
-- =========================================================
-- Example usage:
-- \set ci 1

WITH cy AS (SELECT study_year FROM v_current_year)
SELECT
  af.course_code,
  af.course_instance_id,
  af.hp,
  af.teacher_name,
  af.designation,

  COALESCE(SUM(CASE WHEN af.activity_name='Lecture'        THEN af.hours_factored END),0) AS lecture_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Tutorial'       THEN af.hours_factored END),0) AS tutorial_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Lab'            THEN af.hours_factored END),0) AS lab_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Seminar'        THEN af.hours_factored END),0) AS seminar_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Other'          THEN af.hours_factored END),0) AS other_overhead_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Administration' THEN af.hours_factored END),0) AS admin_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Examination'    THEN af.hours_factored END),0) AS exam_hours,

  ROUND(COALESCE(SUM(af.hours_factored),0), 2) AS total_hours
FROM v_alloc_factored af
JOIN cy ON cy.study_year = af.study_year
WHERE af.course_instance_id = :'ci'
GROUP BY af.course_code, af.course_instance_id, af.hp, af.teacher_name, af.designation
ORDER BY af.teacher_name;


-- =========================================================
-- QUERY 3:
-- Actual allocated hours (factored) for ONE teacher (current year), per course instance
-- Set teacher in psql:  \set emp 500009
-- =========================================================
-- Example usage:
-- \set emp 500009

WITH cy AS (SELECT study_year FROM v_current_year)
SELECT
  af.course_code,
  af.course_instance_id,
  af.hp,
  af.study_period,
  af.teacher_name,

  COALESCE(SUM(CASE WHEN af.activity_name='Lecture'        THEN af.hours_factored END),0) AS lecture_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Tutorial'       THEN af.hours_factored END),0) AS tutorial_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Lab'            THEN af.hours_factored END),0) AS lab_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Seminar'        THEN af.hours_factored END),0) AS seminar_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Other'          THEN af.hours_factored END),0) AS other_overhead_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Administration' THEN af.hours_factored END),0) AS admin_hours,
  COALESCE(SUM(CASE WHEN af.activity_name='Examination'    THEN af.hours_factored END),0) AS exam_hours,

  ROUND(COALESCE(SUM(af.hours_factored),0), 2) AS total_hours
FROM v_alloc_factored af
JOIN cy ON cy.study_year = af.study_year
WHERE af.employment_id = :'emp'
GROUP BY af.course_code, af.course_instance_id, af.hp, af.study_period, af.teacher_name
ORDER BY af.study_period, af.course_code;


-- =========================================================
-- QUERY 4:
-- Teachers allocated in more than N course instances during a period (current year)
-- Set in psql:
--   \set period 'P1'
--   \set n 1
-- =========================================================
-- Example usage:
-- \set period 'P1'
-- \set n 1

WITH cy AS (SELECT study_year FROM v_current_year)
SELECT
  e.employment_id,
  (p.first_name || ' ' || p.last_name) AS teacher_name,
  ci.study_period,
  COUNT(DISTINCT a.course_instance_id) AS no_of_courses
FROM allocation a
JOIN employee e ON e.employment_id = a.employment_id
JOIN person p ON p.person_id = e.person_id
JOIN course_instance ci ON ci.course_instance_id = a.course_instance_id
JOIN cy ON cy.study_year = ci.study_year
WHERE ci.study_period = :'period'
GROUP BY e.employment_id, teacher_name, ci.study_period
HAVING COUNT(DISTINCT a.course_instance_id) > :'n'
ORDER BY no_of_courses DESC, teacher_name;


-- =========================================================
-- EXPLAIN ANALYZE (run separately in your report)
-- Use Query 4 (good OLAP-style aggregation)
-- =========================================================
-- EXPLAIN (ANALYZE, BUFFERS)
-- WITH cy AS (SELECT study_year FROM v_current_year)
-- SELECT
--   e.employment_id,
--   (p.first_name || ' ' || p.last_name) AS teacher_name,
--   ci.study_period,
--   COUNT(DISTINCT a.course_instance_id) AS no_of_courses
-- FROM allocation a
-- JOIN employee e ON e.employment_id = a.employment_id
-- JOIN person p ON p.person_id = e.person_id
-- JOIN course_instance ci ON ci.course_instance_id = a.course_instance_id
-- JOIN cy ON cy.study_year = ci.study_year
-- WHERE ci.study_period = :'period'
-- GROUP BY e.employment_id, teacher_name, ci.study_period
-- HAVING COUNT(DISTINCT a.course_instance_id) > :'n'
-- ORDER BY no_of_courses DESC, teacher_name;
