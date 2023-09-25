SELECT
    e.emp_no,
    e.from_date,
    e.to_date,
    e.hire_date,
    e.first_name,
    e.last_name,
    e.dept_name,
    e.gender,
    s.salary,
    DATE_PART('year', e.to_date) - DATE_PART('year', e.from_date) AS years_worked
FROM
    (SELECT
        de.emp_no,
        de.from_date,
        de.to_date,
        de.dept_no,
        e.hire_date,
        e.first_name,
        e.last_name,
        d.dept_name,
        e.gender
    FROM
        t_dept_emp de
    JOIN
        t_employees e ON de.emp_no = e.emp_no
    JOIN
        t_departments d ON de.dept_no = d.dept_no) e
JOIN
    t_salaries s ON e.emp_no = s.emp_no AND e.from_date = s.from_date
ORDER BY
    e.emp_no, e.from_date;


--The code above indicates that we need to clean inconsistencies in the data because there are inconsistencies in hire_date, to_date, and end_date columns. 
--Additionally, there are dates recorded as 9999 within the date data. 
--I believe these should be interpreted as 1999. Therefore, we will update the ones with 9999 to 1999.

-- t_employees
UPDATE t_employees
SET
    hire_date = TO_DATE(REPLACE(TO_CHAR(hire_date, 'YYYY-MM-DD'), '9999', '1999'), 'YYYY-MM-DD')
WHERE
    TO_CHAR(hire_date, 'YYYY-MM-DD') LIKE '9999%';


-- t_dept_manager
UPDATE t_dept_manager
SET
    from_date = TO_DATE(REPLACE(TO_CHAR(from_date, 'YYYY-MM-DD'), '9999', '1999'), 'YYYY-MM-DD'),
    to_date = TO_DATE(REPLACE(TO_CHAR(to_date, 'YYYY-MM-DD'), '9999', '1999'), 'YYYY-MM-DD')
WHERE
    TO_CHAR(from_date, 'YYYY-MM-DD') LIKE '9999%' OR TO_CHAR(to_date, 'YYYY-MM-DD') LIKE '9999%';

-- t_dept_emp 
UPDATE t_dept_emp
SET
    from_date = TO_DATE(REPLACE(TO_CHAR(from_date, 'YYYY-MM-DD'), '9999', '1999'), 'YYYY-MM-DD'),
    to_date = TO_DATE(REPLACE(TO_CHAR(to_date, 'YYYY-MM-DD'), '9999', '1999'), 'YYYY-MM-DD')
WHERE
    TO_CHAR(from_date, 'YYYY-MM-DD') LIKE '9999%' OR TO_CHAR(to_date, 'YYYY-MM-DD') LIKE '9999%';

-- t_salaries 
UPDATE t_salaries
SET
    from_date = TO_DATE(REPLACE(TO_CHAR(from_date, 'YYYY-MM-DD'), '9999', '1999'), 'YYYY-MM-DD'),
    to_date = TO_DATE(REPLACE(TO_CHAR(to_date, 'YYYY-MM-DD'), '9999', '1999'), 'YYYY-MM-DD')
WHERE
    TO_CHAR(from_date, 'YYYY-MM-DD') LIKE '9999%' OR TO_CHAR(to_date, 'YYYY-MM-DD') LIKE '9999%';


---lets work on from_date, end_date and hire_date
--we extract someone whose hire_date between from_date and end_date
-- we marked them active =1, if not marked 0.



SELECT 
    d.dept_name,
    ee.gender,
    ee.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    s.salary, 
    CASE
        WHEN EXTRACT(YEAR FROM dm.to_date) >= e.calendar_year AND EXTRACT(YEAR FROM dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
    END AS active
FROM
    (SELECT 
        EXTRACT(YEAR FROM hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY EXTRACT(YEAR FROM hire_date)) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN 
    t_employees ee ON dm.emp_no = ee.emp_no
        JOIN
    t_salaries s ON ee.emp_no = s.emp_no
ORDER BY dm.emp_no, calendar_year;



