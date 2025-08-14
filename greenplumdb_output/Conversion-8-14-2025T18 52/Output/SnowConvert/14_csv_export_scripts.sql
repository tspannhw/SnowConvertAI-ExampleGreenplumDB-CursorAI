-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '4' COLUMN '1' OF THE SOURCE CODE STARTING AT '\'. EXPECTED 'STATEMENT' GRAMMAR. **
---- CSV Export Scripts for All Tables
---- Exports all tables to CSV files for data analysis and backup

--\c financial_system
                   ;
--** SSC-FDM-PG0006 - SET SEARCH PATH WITH MULTIPLE SCHEMAS IS NOT SUPPORTED IN SNOWFLAKE **
USE SCHEMA core /*, trading, loans, risk, compliance, analytics, payment, cards, treasury, audit, public*/;
-- Function to export all tables to CSV
!!!RESOLVE EWI!!! /*** SSC-EWI-0068 - USER DEFINED FUNCTION WAS TRANSFORMED TO SNOWFLAKE PROCEDURE ***/!!!
CREATE OR REPLACE PROCEDURE core.export_all_tables_to_csv (export_path TEXT DEFAULT '/tmp/financial_system_export/' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ParameterDefaultExpr' NODE ***/!!!)
RETURNS TEXT
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS $$
DECLARE
    !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'RECORD TYPE' NODE ***/!!!
    table_record RECORD !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'PseudoTypes' NODE ***/!!!;
    export_command TEXT;
    result_text TEXT := '';
    total_tables INTEGER := 0;
    exported_tables INTEGER := 0;
BEGIN
    -- Create export directory if it doesn't exist (requires superuser privileges)
    -- In production, ensure the directory exists and has proper permissions

    result_text := 'Starting CSV export to: ' || export_path || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    result_text := result_text || 'Export started at: ' || CURRENT_TIMESTAMP() || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    -- Export Core Schema Tables
    result_text := result_text || '=== CORE SCHEMA TABLES ===' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    FOR table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'core'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY core.' || table_record.table_name || ' TO ''' ||
                               export_path || 'core_' || table_record.table_name || '.csv'' WITH CSV HEADER';

        -- Log the export command (in production, this would execute the export)
        result_text := result_text || 'Exporting: core.' || table_record.table_name ||
                             ' -> core_' || table_record.table_name || '.csv' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
        exported_tables := exported_tables + 1;
    END LOOP;

    -- Export Trading Schema Tables
    result_text := result_text || E'\n=== TRADING SCHEMA TABLES ===' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!! || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    FOR table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'trading'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY trading.' || table_record.table_name || ' TO ''' ||
                               export_path || 'trading_' || table_record.table_name || '.csv'' WITH CSV HEADER';

        result_text := result_text || 'Exporting: trading.' || table_record.table_name ||
                             ' -> trading_' || table_record.table_name || '.csv' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
        exported_tables := exported_tables + 1;
    END LOOP;

    -- Export Loans Schema Tables
    result_text := result_text || E'\n=== LOANS SCHEMA TABLES ===' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!! || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    FOR table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'loans'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY loans.' || table_record.table_name || ' TO ''' ||
                               export_path || 'loans_' || table_record.table_name || '.csv'' WITH CSV HEADER';

        result_text := result_text || 'Exporting: loans.' || table_record.table_name ||
                             ' -> loans_' || table_record.table_name || '.csv' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
        exported_tables := exported_tables + 1;
    END LOOP;

    -- Export Risk Schema Tables
    result_text := result_text || E'\n=== RISK SCHEMA TABLES ===' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!! || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    FOR table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'risk'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY risk.' || table_record.table_name || ' TO ''' ||
                               export_path || 'risk_' || table_record.table_name || '.csv'' WITH CSV HEADER';

        result_text := result_text || 'Exporting: risk.' || table_record.table_name ||
                             ' -> risk_' || table_record.table_name || '.csv' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
        exported_tables := exported_tables + 1;
    END LOOP;

    -- Export Compliance Schema Tables
    result_text := result_text || E'\n=== COMPLIANCE SCHEMA TABLES ===' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!! || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    FOR table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'compliance'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY compliance.' || table_record.table_name || ' TO ''' ||
                               export_path || 'compliance_' || table_record.table_name || '.csv'' WITH CSV HEADER';

        result_text := result_text || 'Exporting: compliance.' || table_record.table_name ||
                             ' -> compliance_' || table_record.table_name || '.csv' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
        exported_tables := exported_tables + 1;
    END LOOP;

    -- Export Analytics Schema Tables
    result_text := result_text || E'\n=== ANALYTICS SCHEMA TABLES ===' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!! || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    FOR table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'analytics'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY analytics.' || table_record.table_name || ' TO ''' ||
                               export_path || 'analytics_' || table_record.table_name || '.csv'' WITH CSV HEADER';

        result_text := result_text || 'Exporting: analytics.' || table_record.table_name ||
                             ' -> analytics_' || table_record.table_name || '.csv' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
        exported_tables := exported_tables + 1;
    END LOOP;

    -- Export Payment Schema Tables
    result_text := result_text || E'\n=== PAYMENT SCHEMA TABLES ===' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!! || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    FOR table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'payment'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY payment.' || table_record.table_name || ' TO ''' ||
                               export_path || 'payment_' || table_record.table_name || '.csv'' WITH CSV HEADER';

        result_text := result_text || 'Exporting: payment.' || table_record.table_name ||
                             ' -> payment_' || table_record.table_name || '.csv' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
        exported_tables := exported_tables + 1;
    END LOOP;

    -- Export Cards Schema Tables
    result_text := result_text || E'\n=== CARDS SCHEMA TABLES ===' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!! || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    FOR table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'cards'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY cards.' || table_record.table_name || ' TO ''' ||
                               export_path || 'cards_' || table_record.table_name || '.csv'' WITH CSV HEADER';

        result_text := result_text || 'Exporting: cards.' || table_record.table_name ||
                             ' -> cards_' || table_record.table_name || '.csv' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
        exported_tables := exported_tables + 1;
    END LOOP;

    -- Export Treasury Schema Tables
    result_text := result_text || E'\n=== TREASURY SCHEMA TABLES ===' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!! || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    FOR table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'treasury'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY treasury.' || table_record.table_name || ' TO ''' ||
                               export_path || 'treasury_' || table_record.table_name || '.csv'' WITH CSV HEADER';

        result_text := result_text || 'Exporting: treasury.' || table_record.table_name ||
                             ' -> treasury_' || table_record.table_name || '.csv' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
        exported_tables := exported_tables + 1;
    END LOOP;

    -- Export Audit Schema Tables
    result_text := result_text || E'\n=== AUDIT SCHEMA TABLES ===' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!! || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    FOR table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'audit'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY audit.' || table_record.table_name || ' TO ''' ||
                               export_path || 'audit_' || table_record.table_name || '.csv'' WITH CSV HEADER';

        result_text := result_text || 'Exporting: audit.' || table_record.table_name ||
                             ' -> audit_' || table_record.table_name || '.csv' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
        exported_tables := exported_tables + 1;
    END LOOP;

    -- Summary
    result_text := result_text || E'\n=== EXPORT SUMMARY ===' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!! || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    result_text := result_text || 'Total tables found: ' || total_tables || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    result_text := result_text || 'Tables exported: ' || exported_tables || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    result_text := result_text || 'Export completed at: ' || CURRENT_TIMESTAMP() || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    RETURN result_text;
END;
$$;

-- Generate individual export commands for manual execution
CREATE OR REPLACE VIEW analytics.csv_export_commands
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS
SELECT
    schema_name,
    table_name,
    '\COPY ' || schema_name || '.' || table_name ||
    ' TO ''/tmp/financial_system_export/' || schema_name || '_' || table_name || '.csv'' WITH CSV HEADER;' AS export_command,
    'SELECT COUNT(*) FROM ' || schema_name || '.' || table_name || ';' AS count_command
FROM (
    SELECT table_schema AS schema_name, table_name
    FROM
    information_schema.tables
    WHERE table_schema IN ('core', 'trading', 'loans', 'risk', 'compliance', 'analytics', 'payment', 'cards', 'treasury', 'audit')
    AND table_type = 'BASE TABLE'
    ORDER BY table_schema, table_name
) t;
-- Function to get table statistics for export planning
!!!RESOLVE EWI!!! /*** SSC-EWI-0068 - USER DEFINED FUNCTION WAS TRANSFORMED TO SNOWFLAKE PROCEDURE ***/!!!
--** SSC-FDM-0007 - MISSING DEPENDENT OBJECTS "pg_class", "pg_namespace" **
CREATE OR REPLACE PROCEDURE analytics.get_table_statistics ()
RETURNS TABLE (
    schema_name TEXT,
    table_name TEXT,
    row_count BIGINT,
    table_size TEXT,
    estimated_csv_size TEXT
)
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS $$
DECLARE
    !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'RECORD TYPE' NODE ***/!!!
    table_record RECORD !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'PseudoTypes' NODE ***/!!!;
    row_count_val BIGINT;
    table_size_val BIGINT;
BEGIN
    FOR table_record IN
        SELECT t.table_schema, t.table_name
        FROM information_schema.tables t
        WHERE t.table_schema IN ('core', 'trading', 'loans', 'risk', 'compliance', 'analytics', 'payment', 'cards', 'treasury', 'audit')
        AND t.table_type = 'BASE TABLE'
        ORDER BY t.table_schema, t.table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        -- Get row count
        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || table_record.table_schema || '.' || table_record.table_name
        !!!RESOLVE EWI!!! /*** SSC-EWI-PG0007 - INTO CLAUSE IN DYNAMIC SQL IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
        INTO row_count_val;

        -- Get table size
        SELECT pg_total_relation_size(c.oid) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'pg_total_relation_size' NODE ***/!!! INTO
        : table_size_val
        FROM
        pg_class c
        JOIN
                        pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = table_record.table_schema
        AND c.relname = table_record.table_name;
        schema_name := table_record.table_schema;
        table_name := table_record.table_name;
        row_count := row_count_val;
        table_size := pg_size_pretty(table_size_val) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'pg_size_pretty' NODE ***/!!!;
        estimated_csv_size := pg_size_pretty(table_size_val * 1.2) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'pg_size_pretty' NODE ***/!!!; -- CSV typically 20% larger

        RETURN NEXT;
    END LOOP;
    RETURN NULL;
END;
$$;
-- Create shell script for CSV export
!!!RESOLVE EWI!!! /*** SSC-EWI-0068 - USER DEFINED FUNCTION WAS TRANSFORMED TO SNOWFLAKE PROCEDURE ***/!!!
CREATE OR REPLACE PROCEDURE core.generate_export_shell_script ()
RETURNS TEXT
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS $$
DECLARE
    script_content TEXT;
    !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'RECORD TYPE' NODE ***/!!!
    table_record RECORD !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'PseudoTypes' NODE ***/!!!;
BEGIN
    script_content := '#!/bin/bash' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '# Greenplum Financial System CSV Export Script' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '# Generated on: ' || CURRENT_TIMESTAMP() || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || 'EXPORT_DIR="/tmp/financial_system_export"' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'DB_NAME="financial_system"' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'DB_HOST="localhost"' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'DB_PORT="5432"' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'DB_USER="postgres"' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '# Create export directory' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'mkdir -p $EXPORT_DIR' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || 'echo "Starting CSV export at $(date)"' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'echo "Export directory: $EXPORT_DIR"' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '# Export all tables' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    FOR table_record IN
        SELECT t.table_schema, t.table_name
        FROM information_schema.tables t
        WHERE t.table_schema IN ('core', 'trading', 'loans', 'risk', 'compliance', 'analytics', 'payment', 'cards', 'treasury', 'audit')
        AND t.table_type = 'BASE TABLE'
        ORDER BY t.table_schema, t.table_name !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ForQueryBody' NODE ***/!!!
    --** SSC-PRF-0008 - PERFORMANCE REVIEW - LOOP USAGE **
    LOOP
        script_content := script_content || 'echo "Exporting ' || table_record.table_schema || '.' || table_record.table_name || '"' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
        script_content := script_content || 'psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "';
        script_content := script_content || '\COPY ' || table_record.table_schema || '.' || table_record.table_name;
        script_content := script_content || ' TO ''$EXPORT_DIR/' || table_record.table_schema || '_' || table_record.table_name || '.csv''';
        script_content := script_content || ' WITH CSV HEADER"' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    END LOOP;

    script_content := script_content || 'echo "CSV export completed at $(date)"' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'echo "Files exported to: $EXPORT_DIR"' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'ls -la $EXPORT_DIR' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    RETURN script_content;
END;
$$;
-- Create Python script for CSV export with progress tracking
!!!RESOLVE EWI!!! /*** SSC-EWI-0068 - USER DEFINED FUNCTION WAS TRANSFORMED TO SNOWFLAKE PROCEDURE ***/!!!
CREATE OR REPLACE PROCEDURE core.generate_python_export_script ()
RETURNS TEXT
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS $$
DECLARE
    script_content TEXT;
BEGIN
    script_content := '#!/usr/bin/env python3' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '"""' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'Greenplum Financial System CSV Export Script' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'Generated on: ' || CURRENT_TIMESTAMP() || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '"""' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || 'import psycopg2' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'import os' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'import sys' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || 'from datetime import datetime' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || 'def export_tables():' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '    # Database connection parameters' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '    conn_params = {' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        "host": "localhost",' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        "port": "5432",' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        "database": "financial_system",' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        "user": "postgres",' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        "password": ""  # Add password if needed' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '    }' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '    export_dir = "/tmp/financial_system_export"' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '    os.makedirs(export_dir, exist_ok=True)' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '    try:' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        conn = psycopg2.connect(**conn_params)' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        cur = conn.cursor()' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '        # Get list of all tables to export' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        cur.execute("""' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '            SELECT table_schema, table_name' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '            FROM information_schema.tables' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '            WHERE table_schema IN (''core'', ''trading'', ''loans'', ''risk'', ''compliance'', ''analytics'', ''payment'', ''cards'', ''treasury'', ''audit'')' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '            AND table_type = ''BASE TABLE''' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '            ORDER BY table_schema, table_name' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        """)' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '        tables = cur.fetchall()' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        total_tables = len(tables)' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '        print(f"Starting export of {total_tables} tables at {datetime.now()}")' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        print(f"Export directory: {export_dir}")' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '        for i, (schema, table) in enumerate(tables, 1):' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '            filename = f"{schema}_{table}.csv"' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '            filepath = os.path.join(export_dir, filename)' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '            print(f"[{i}/{total_tables}] Exporting {schema}.{table}...")' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '            try:' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '                with open(filepath, ''w'') as f:' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '                    cur.copy_expert(f"COPY {schema}.{table} TO STDOUT WITH CSV HEADER", f)' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '                print(f"    ✓ Exported to {filename}")' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '            except Exception as e:' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '                print(f"    ✗ Error exporting {schema}.{table}: {e}")' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '        print(f"\\nExport completed at {datetime.now()}")' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '    except Exception as e:' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        print(f"Database connection error: {e}")' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        sys.exit(1)' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || '    finally:' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '        if conn:' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '            conn.close()' || E'\n\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;

    script_content := script_content || 'if __name__ == "__main__":' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    script_content := script_content || '    export_tables()' || E'\n' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'EStringLiteralExpr' NODE ***/!!!;
    RETURN script_content;
END;
$$;

-- Execute the export planning function
SELECT core.export_all_tables_to_csv();

-- Display table statistics
SELECT * FROM analytics.get_table_statistics() !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!! ORDER BY schema_name, table_name;

-- Display all export commands
SELECT * FROM
analytics.csv_export_commands
ORDER BY schema_name, table_name;
COMMENT ON FUNCTION core.export_all_tables_to_csv () IS 'Generates export commands for all tables to CSV format';
COMMENT ON FUNCTION analytics.get_table_statistics () IS 'Returns statistics for all tables including row counts and sizes';
COMMENT ON FUNCTION core.generate_export_shell_script () IS 'Generates a shell script for CSV export';
COMMENT ON FUNCTION core.generate_python_export_script () IS 'Generates a Python script for CSV export with progress tracking';
COMMENT ON VIEW analytics.csv_export_commands IS 'View containing all CSV export commands for manual execution';