DROP SCHEMA IF EXISTS priority_mart CASCADE;
CREATE SCHEMA priority_mart;

SELECT '| Loading Priority Mart Table |' AS info;

-- Priority Roles Table ELT
CREATE TABLE priority_mart.priority_roles (
    role_id         INTEGER     PRIMARY KEY,
    role_name       VARCHAR,
    priority_lvl    INTEGER
);

INSERT INTO priority_mart.priority_roles (role_id, role_name, priority_lvl)
VALUES
    (1, 'Data Engineer', 1),
    (2, 'Senior Data Engineer', 2),
    (3, 'Data Scientist', 1),
    (4, 'Senior Data Scientist', 2),
    (5, 'Software Engineer', 2);

SELECT * FROM priority_mart.priority_roles;


-- Priority Job Snapshot Table ELT
CREATE OR REPLACE TABLE priority_mart.priority_job_snapshot (
    job_id              INTEGER PRIMARY KEY,
    job_title_short     VARCHAR,
    company_name        VARCHAR,
    job_posted_date     TIMESTAMP,
    salary_year_avg     DOUBLE,
    priority_lvl        INTEGER,
    updated_at          TIMESTAMP
);

INSERT INTO priority_mart.priority_job_snapshot (
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    pr.priority_lvl,
    CURRENT_TIMESTAMP
FROM
    job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles AS pr
    ON jpf.job_title_short = pr.role_name;

-- Data Validation for Job Snapshot
SELECT
    job_title_short,
    COUNT(*) AS job_count,
    MAX(priority_lvl) AS priority_lvl,
    MAX(updated_at) AS updated_at
FROM priority_mart.priority_job_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;