-- TEMP TABLE FOR SOURCE

CREATE OR REPLACE TEMP TABLE source_priority_roles AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    pr.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM
    data_jobs.main.job_postings_fact AS jpf
LEFT JOIN data_jobs.main.company_dim AS cd
    ON jpf.company_id = cd.company_id
INNER JOIN jobs_mart.staging.priority_roles AS pr
    ON jpf.job_title_short = pr.role_name;

-- -- UPDATE TARGET
-- UPDATE jobs_mart.main.priority_jobs_snapshot AS tgt
-- SET
--     priority_lvl = src.priority_lvl,
--     updated_at = src.updated_at
-- FROM source_priority_roles AS src
-- WHERE
--     tgt.job_id = src.job_id AND
--     tgt.priority_lvl IS DISTINCT FROM src.priority_lvl;

-- -- INSERT NEW ROWS
-- INSERT INTO jobs_mart.main.priority_jobs_snapshot (
--     job_id,
--     job_title_short,
--     company_name,
--     job_posted_date,
--     salary_year_avg,
--     priority_lvl,
--     updated_at
-- )
-- SELECT
--     src.job_id,
--     src.job_title_short,
--     src.company_name,
--     src.job_posted_date,
--     src.salary_year_avg,
--     src.priority_lvl,
--     src.updated_at
-- FROM
--     source_priority_roles AS src
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM jobs_mart.main.priority_jobs_snapshot AS tgt
--     WHERE src.job_id = tgt.job_id
-- );

-- -- DELETE
-- DELETE FROM jobs_mart.main.priority_jobs_snapshot AS tgt
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM source_priority_roles AS src
--     WHERE tgt.job_id = src.job_id
-- );

MERGE INTO main.priority_jobs_snapshot AS tgt
USING source_priority_roles AS src
ON src.job_id = tgt.job_id

WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
UPDATE SET
    priority_lvl = src.priority_lvl,
    updated_at = src.updated_at

WHEN NOT MATCHED THEN
    INSERT (
        job_id,
        job_title_short,
        company_name,
        job_posted_date,
        salary_year_avg,
        priority_lvl,
        updated_at
    )
    VALUES (
        src.job_id,
        src.job_title_short,
        src.company_name,
        src.job_posted_date,
        src.salary_year_avg,
        src.priority_lvl,
        src.updated_at
    )

WHEN NOT MATCHED BY SOURCE THEN DELETE;

-- DEBUG TO SHOW TABLES
SELECT
    job_title_short,
    COUNT(*) AS job_count,
    MIN(priority_lvl) AS priority_lvl,
    MIN(updated_at) AS updated_at
FROM
    jobs_mart.main.priority_jobs_snapshot
GROUP BY
    job_title_short
ORDER BY
    job_count DESC;