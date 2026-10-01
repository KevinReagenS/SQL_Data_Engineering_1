CREATE OR REPLACE TABLE staging.priority_roles (
    role_id         INTEGER PRIMARY KEY,
    role_name       VARCHAR (100),
    priority_lvl    INTEGER
);

INSERT INTO staging.priority_roles (role_id, role_name, priority_lvl)
VALUES
    (1, 'Senior Data Engineer',     1),
    (2, 'Software Engineer',        3),
    (3, 'Senior Data Analyst',      2),
    (4, 'Data Scientist',           2);

SELECT *
FROM staging.priority_roles;