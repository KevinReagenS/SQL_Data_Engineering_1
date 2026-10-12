DROP SCHEMA IF EXISTS skill_mart CASCADE;
CREATE SCHEMA skill_mart;

SELECT '| Loading Skill Mart Table |' AS info;

CREATE TABLE skill_mart.skills_dimension (
    skill_id    INTEGER     PRIMARY KEY,
    skill_name  VARCHAR,
    type        VARCHAR
);

INSERT INTO skill_mart.skills_dimension (
    skill_id,
    skill_name,
    type
)
SELECT
    skill_id,
    skills,
    type
FROM skills_dim;


CREATE TABLE skill_mart.date_month_dimension (
    month_start_date    DATE    PRIMARY KEY,
    year                INTEGER,
    month               INTEGER,
    quarter             INTEGER,
    quarter_name        VARCHAR,
    year_and_quarter    VARCHAR
);

INSERT INTO skill_mart.date_month_dimension (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_and_quarter
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date)::DATE AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter_number,
    'Q-' || EXTRACT(QUARTER FROM job_posted_date) AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date) || ' Q-' || EXTRACT(QUARTER FROM job_posted_date) AS year_and_quarter
FROM
    job_postings_fact
ORDER BY
    month_start_date;

CREATE TABLE skill_mart.fact_skill_demand_monthly (
    skill_id            INTEGER,
    month_start_date    DATE,
    job_title_short     VARCHAR,
    job_count           INTEGER,
    degree_postings     INTEGER,
    health_postings     INTEGER,
    remote_postings     INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skill_mart.skills_dimension(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skill_mart.date_month_dimension(month_start_date)
);

INSERT INTO skill_mart.fact_skill_demand_monthly (
    skill_id,
    month_start_date,
    job_title_short,
    job_count,
    degree_postings,
    health_postings,
    remote_postings
)

WITH job_postings_preparation AS (
    SELECT
        sjd.skill_id,
        DATE_TRUNC('month', jpf.job_posted_date)::DATE AS month_start_date,
        jpf.job_title_short,
        CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_required,
        CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
        CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote
    FROM
        job_postings_fact AS jpf
    INNER JOIN skills_job_dim AS sjd
        ON jpf.job_id = sjd.job_id
)

SELECT
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS job_count,
    SUM(no_degree_required) AS degree_postings,
    SUM(has_health_insurance) AS health_postings,
    SUM(is_remote) AS remote_postings
FROM
    job_postings_preparation
GROUP BY
    ALL
ORDER BY
    skill_id,
    month_start_date,
    job_title_short;

SELECT '----------------------------------------------------------------------------------' AS info;

SELECT 'Skill Dimension' AS table_name, COUNT(*) AS record_count FROM skill_mart.skills_dimension
UNION ALL
SELECT 'Date Dimension' AS table_name, COUNT(*) AS record_count FROM skill_mart.date_month_dimension
UNION ALL
SELECT 'Skill Mart' AS table_name, COUNT(*) AS record_count FROM skill_mart.fact_skill_demand_monthly;