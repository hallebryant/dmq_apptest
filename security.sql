-- Analyst Role : This role can only SELECT data from tables, not change it.
CREATE ROLE analyst_role;

-- Grant the ability to connect to the database
GRANT CONNECT ON DATABASE fma_db TO analyst_role;

-- Grant usage on the public schema (where tables are)
GRANT USAGE ON SCHEMA public TO analyst_role;

-- Grant SELECT permission on all current tables in the schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst_role;

-- Ensure that any future tables also get these permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO analyst_role;

-- Create a sample user and assign them this role
CREATE USER analyst_phalguni WITH PASSWORD 'analystphalguni123';
GRANT analyst_role TO analyst_phalguni;

-- -----------------------------------------------------------------

-- Developer Role : This role can SELECT, INSERT, UPDATE, and DELETE data.
CREATE ROLE developer_role;

-- Grant connection and schema usage
GRANT CONNECT ON DATABASE fma_db TO developer_role;
GRANT USAGE ON SCHEMA public TO developer_role;

-- Grant all standard data manipulation privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO developer_role;

-- Also grant usage on sequences, which are used for SERIAL primary keys
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO developer_role;

-- Ensure future tables and sequences get these permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO developer_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO developer_role;

-- Create a sample application user and assign them this role
CREATE USER dev_halle WITH PASSWORD 'devhalle123';
GRANT developer_role TO dev_halle;
