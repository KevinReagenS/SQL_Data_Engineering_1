CREATE OR REPLACE TEMP TABLE job_skills_struct_array AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(
        STRUCT_PACK(
            skill_name := sd.skills,
            skill_type := sd.type
        )
    ) AS skills_type
FROM
    job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
GROUP BY ALL;

WITH skills_group AS (
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_type).skill_type AS skill_type,
        UNNEST(skills_type).skill_name AS skill_name
    FROM
        job_skills_struct_array
)

SELECT
    skill_name,
    MEDIAN(salary_year_avg) AS median_salary
FROM
    skills_group
WHERE
    salary_year_avg IS NOT NULL
GROUP BY
    skill_name
ORDER BY
    median_salary DESC;