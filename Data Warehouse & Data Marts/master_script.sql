-- Create Table
.read "Data Warehouse & Data Marts/1_create_tables.sql"

-- Load Contents into Tables
.read "Data Warehouse & Data Marts/2_load_schemas.sql"

-- Create Flat Marts
.read "Data Warehouse & Data Marts/3_create_flat_mart.sql"

-- Create Skill Marts
.read "Data Warehouse & Data Marts/4_create_skill_mart.sql"

-- Create Priority Marts
.read "Data Warehouse & Data Marts/5_create_priority_mart.sql"

-- Update Priority Marts (Incremental Update)
.read "Data Warehouse & Data Marts/6_incremental_update.sql"