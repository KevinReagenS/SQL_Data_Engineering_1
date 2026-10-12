-- Create Table
.read "2 - Data Warehouse/1_create_tables.sql"

-- Load Contents into Tables
.read "2 - Data Warehouse/2_load_schemas.sql"

-- Create Flat Marts
.read "2 - Data Warehouse/3_create_flat_mart.sql"

-- Create Skill Marts
.read "2 - Data Warehouse/4_create_skill_mart.sql"

-- Create Priority Marts
.read "2 - Data Warehouse/5_create_priority_mart.sql"

-- Update Priority Marts (Incremental Update)
.read "2 - Data Warehouse/6_incremental_update.sql"