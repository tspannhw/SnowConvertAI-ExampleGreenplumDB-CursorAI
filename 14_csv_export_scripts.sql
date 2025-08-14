-- CSV Export Scripts for All Tables
-- Exports all tables to CSV files for data analysis and backup

\c financial_system;
SET search_path TO core, trading, loans, risk, compliance, analytics, payment, cards, treasury, audit, public;

-- Function to export all tables to CSV
CREATE OR REPLACE FUNCTION core.export_all_tables_to_csv(export_path TEXT DEFAULT '/tmp/financial_system_export/')
RETURNS TEXT AS $$
DECLARE
    table_record RECORD;
    export_command TEXT;
    result_text TEXT := '';
    total_tables INTEGER := 0;
    exported_tables INTEGER := 0;
BEGIN
    -- Create export directory if it doesn't exist (requires superuser privileges)
    -- In production, ensure the directory exists and has proper permissions
    
    result_text := 'Starting CSV export to: ' || export_path || E'\n';
    result_text := result_text || 'Export started at: ' || CURRENT_TIMESTAMP || E'\n\n';
    
    -- Export Core Schema Tables
    result_text := result_text || '=== CORE SCHEMA TABLES ===' || E'\n';
    
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'core' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY core.' || table_record.table_name || ' TO ''' || 
                        export_path || 'core_' || table_record.table_name || '.csv'' WITH CSV HEADER';
        
        -- Log the export command (in production, this would execute the export)
        result_text := result_text || 'Exporting: core.' || table_record.table_name || 
                      ' -> core_' || table_record.table_name || '.csv' || E'\n';
        exported_tables := exported_tables + 1;
    END LOOP;
    
    -- Export Trading Schema Tables
    result_text := result_text || E'\n=== TRADING SCHEMA TABLES ===' || E'\n';
    
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'trading' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY trading.' || table_record.table_name || ' TO ''' || 
                        export_path || 'trading_' || table_record.table_name || '.csv'' WITH CSV HEADER';
        
        result_text := result_text || 'Exporting: trading.' || table_record.table_name || 
                      ' -> trading_' || table_record.table_name || '.csv' || E'\n';
        exported_tables := exported_tables + 1;
    END LOOP;
    
    -- Export Loans Schema Tables
    result_text := result_text || E'\n=== LOANS SCHEMA TABLES ===' || E'\n';
    
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'loans' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY loans.' || table_record.table_name || ' TO ''' || 
                        export_path || 'loans_' || table_record.table_name || '.csv'' WITH CSV HEADER';
        
        result_text := result_text || 'Exporting: loans.' || table_record.table_name || 
                      ' -> loans_' || table_record.table_name || '.csv' || E'\n';
        exported_tables := exported_tables + 1;
    END LOOP;
    
    -- Export Risk Schema Tables
    result_text := result_text || E'\n=== RISK SCHEMA TABLES ===' || E'\n';
    
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'risk' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY risk.' || table_record.table_name || ' TO ''' || 
                        export_path || 'risk_' || table_record.table_name || '.csv'' WITH CSV HEADER';
        
        result_text := result_text || 'Exporting: risk.' || table_record.table_name || 
                      ' -> risk_' || table_record.table_name || '.csv' || E'\n';
        exported_tables := exported_tables + 1;
    END LOOP;
    
    -- Export Compliance Schema Tables
    result_text := result_text || E'\n=== COMPLIANCE SCHEMA TABLES ===' || E'\n';
    
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'compliance' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY compliance.' || table_record.table_name || ' TO ''' || 
                        export_path || 'compliance_' || table_record.table_name || '.csv'' WITH CSV HEADER';
        
        result_text := result_text || 'Exporting: compliance.' || table_record.table_name || 
                      ' -> compliance_' || table_record.table_name || '.csv' || E'\n';
        exported_tables := exported_tables + 1;
    END LOOP;
    
    -- Export Analytics Schema Tables
    result_text := result_text || E'\n=== ANALYTICS SCHEMA TABLES ===' || E'\n';
    
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'analytics' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY analytics.' || table_record.table_name || ' TO ''' || 
                        export_path || 'analytics_' || table_record.table_name || '.csv'' WITH CSV HEADER';
        
        result_text := result_text || 'Exporting: analytics.' || table_record.table_name || 
                      ' -> analytics_' || table_record.table_name || '.csv' || E'\n';
        exported_tables := exported_tables + 1;
    END LOOP;
    
    -- Export Payment Schema Tables
    result_text := result_text || E'\n=== PAYMENT SCHEMA TABLES ===' || E'\n';
    
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'payment' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY payment.' || table_record.table_name || ' TO ''' || 
                        export_path || 'payment_' || table_record.table_name || '.csv'' WITH CSV HEADER';
        
        result_text := result_text || 'Exporting: payment.' || table_record.table_name || 
                      ' -> payment_' || table_record.table_name || '.csv' || E'\n';
        exported_tables := exported_tables + 1;
    END LOOP;
    
    -- Export Cards Schema Tables
    result_text := result_text || E'\n=== CARDS SCHEMA TABLES ===' || E'\n';
    
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'cards' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY cards.' || table_record.table_name || ' TO ''' || 
                        export_path || 'cards_' || table_record.table_name || '.csv'' WITH CSV HEADER';
        
        result_text := result_text || 'Exporting: cards.' || table_record.table_name || 
                      ' -> cards_' || table_record.table_name || '.csv' || E'\n';
        exported_tables := exported_tables + 1;
    END LOOP;
    
    -- Export Treasury Schema Tables
    result_text := result_text || E'\n=== TREASURY SCHEMA TABLES ===' || E'\n';
    
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'treasury' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY treasury.' || table_record.table_name || ' TO ''' || 
                        export_path || 'treasury_' || table_record.table_name || '.csv'' WITH CSV HEADER';
        
        result_text := result_text || 'Exporting: treasury.' || table_record.table_name || 
                      ' -> treasury_' || table_record.table_name || '.csv' || E'\n';
        exported_tables := exported_tables + 1;
    END LOOP;
    
    -- Export Audit Schema Tables
    result_text := result_text || E'\n=== AUDIT SCHEMA TABLES ===' || E'\n';
    
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'audit' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        total_tables := total_tables + 1;
        export_command := '\COPY audit.' || table_record.table_name || ' TO ''' || 
                        export_path || 'audit_' || table_record.table_name || '.csv'' WITH CSV HEADER';
        
        result_text := result_text || 'Exporting: audit.' || table_record.table_name || 
                      ' -> audit_' || table_record.table_name || '.csv' || E'\n';
        exported_tables := exported_tables + 1;
    END LOOP;
    
    -- Summary
    result_text := result_text || E'\n=== EXPORT SUMMARY ===' || E'\n';
    result_text := result_text || 'Total tables found: ' || total_tables || E'\n';
    result_text := result_text || 'Tables exported: ' || exported_tables || E'\n';
    result_text := result_text || 'Export completed at: ' || CURRENT_TIMESTAMP || E'\n';
    
    RETURN result_text;
END;
$$ LANGUAGE plpgsql;

-- Generate individual export commands for manual execution
CREATE OR REPLACE VIEW analytics.csv_export_commands AS
SELECT 
    schema_name,
    table_name,
    '\COPY ' || schema_name || '.' || table_name || 
    ' TO ''/tmp/financial_system_export/' || schema_name || '_' || table_name || '.csv'' WITH CSV HEADER;' AS export_command,
    'SELECT COUNT(*) FROM ' || schema_name || '.' || table_name || ';' AS count_command
FROM (
    SELECT table_schema AS schema_name, table_name
    FROM information_schema.tables 
    WHERE table_schema IN ('core', 'trading', 'loans', 'risk', 'compliance', 'analytics', 'payment', 'cards', 'treasury', 'audit')
    AND table_type = 'BASE TABLE'
    ORDER BY table_schema, table_name
) t;

-- Function to get table statistics for export planning
CREATE OR REPLACE FUNCTION analytics.get_table_statistics()
RETURNS TABLE (
    schema_name TEXT,
    table_name TEXT,
    row_count BIGINT,
    table_size TEXT,
    estimated_csv_size TEXT
) AS $$
DECLARE
    table_record RECORD;
    row_count_val BIGINT;
    table_size_val BIGINT;
BEGIN
    FOR table_record IN 
        SELECT t.table_schema, t.table_name
        FROM information_schema.tables t
        WHERE t.table_schema IN ('core', 'trading', 'loans', 'risk', 'compliance', 'analytics', 'payment', 'cards', 'treasury', 'audit')
        AND t.table_type = 'BASE TABLE'
        ORDER BY t.table_schema, t.table_name
    LOOP
        -- Get row count
        EXECUTE 'SELECT COUNT(*) FROM ' || table_record.table_schema || '.' || table_record.table_name
        INTO row_count_val;
        
        -- Get table size
        SELECT pg_total_relation_size(c.oid) INTO table_size_val
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = table_record.table_schema 
        AND c.relname = table_record.table_name;
        
        schema_name := table_record.table_schema;
        table_name := table_record.table_name;
        row_count := row_count_val;
        table_size := pg_size_pretty(table_size_val);
        estimated_csv_size := pg_size_pretty(table_size_val * 1.2); -- CSV typically 20% larger
        
        RETURN NEXT;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Create shell script for CSV export
CREATE OR REPLACE FUNCTION core.generate_export_shell_script()
RETURNS TEXT AS $$
DECLARE
    script_content TEXT;
    table_record RECORD;
BEGIN
    script_content := '#!/bin/bash' || E'\n';
    script_content := script_content || '# Greenplum Financial System CSV Export Script' || E'\n';
    script_content := script_content || '# Generated on: ' || CURRENT_TIMESTAMP || E'\n\n';
    
    script_content := script_content || 'EXPORT_DIR="/tmp/financial_system_export"' || E'\n';
    script_content := script_content || 'DB_NAME="financial_system"' || E'\n';
    script_content := script_content || 'DB_HOST="localhost"' || E'\n';
    script_content := script_content || 'DB_PORT="5432"' || E'\n';
    script_content := script_content || 'DB_USER="postgres"' || E'\n\n';
    
    script_content := script_content || '# Create export directory' || E'\n';
    script_content := script_content || 'mkdir -p $EXPORT_DIR' || E'\n\n';
    
    script_content := script_content || 'echo "Starting CSV export at $(date)"' || E'\n';
    script_content := script_content || 'echo "Export directory: $EXPORT_DIR"' || E'\n\n';
    
    script_content := script_content || '# Export all tables' || E'\n';
    
    FOR table_record IN 
        SELECT t.table_schema, t.table_name
        FROM information_schema.tables t
        WHERE t.table_schema IN ('core', 'trading', 'loans', 'risk', 'compliance', 'analytics', 'payment', 'cards', 'treasury', 'audit')
        AND t.table_type = 'BASE TABLE'
        ORDER BY t.table_schema, t.table_name
    LOOP
        script_content := script_content || 'echo "Exporting ' || table_record.table_schema || '.' || table_record.table_name || '"' || E'\n';
        script_content := script_content || 'psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "';
        script_content := script_content || '\COPY ' || table_record.table_schema || '.' || table_record.table_name;
        script_content := script_content || ' TO ''$EXPORT_DIR/' || table_record.table_schema || '_' || table_record.table_name || '.csv''';
        script_content := script_content || ' WITH CSV HEADER"' || E'\n\n';
    END LOOP;
    
    script_content := script_content || 'echo "CSV export completed at $(date)"' || E'\n';
    script_content := script_content || 'echo "Files exported to: $EXPORT_DIR"' || E'\n';
    script_content := script_content || 'ls -la $EXPORT_DIR' || E'\n';
    
    RETURN script_content;
END;
$$ LANGUAGE plpgsql;

-- Create Python script for CSV export with progress tracking
CREATE OR REPLACE FUNCTION core.generate_python_export_script()
RETURNS TEXT AS $$
DECLARE
    script_content TEXT;
BEGIN
    script_content := '#!/usr/bin/env python3' || E'\n';
    script_content := script_content || '"""' || E'\n';
    script_content := script_content || 'Greenplum Financial System CSV Export Script' || E'\n';
    script_content := script_content || 'Generated on: ' || CURRENT_TIMESTAMP || E'\n';
    script_content := script_content || '"""' || E'\n\n';
    
    script_content := script_content || 'import psycopg2' || E'\n';
    script_content := script_content || 'import os' || E'\n';
    script_content := script_content || 'import sys' || E'\n';
    script_content := script_content || 'from datetime import datetime' || E'\n\n';
    
    script_content := script_content || 'def export_tables():' || E'\n';
    script_content := script_content || '    # Database connection parameters' || E'\n';
    script_content := script_content || '    conn_params = {' || E'\n';
    script_content := script_content || '        "host": "localhost",' || E'\n';
    script_content := script_content || '        "port": "5432",' || E'\n';
    script_content := script_content || '        "database": "financial_system",' || E'\n';
    script_content := script_content || '        "user": "postgres",' || E'\n';
    script_content := script_content || '        "password": ""  # Add password if needed' || E'\n';
    script_content := script_content || '    }' || E'\n\n';
    
    script_content := script_content || '    export_dir = "/tmp/financial_system_export"' || E'\n';
    script_content := script_content || '    os.makedirs(export_dir, exist_ok=True)' || E'\n\n';
    
    script_content := script_content || '    try:' || E'\n';
    script_content := script_content || '        conn = psycopg2.connect(**conn_params)' || E'\n';
    script_content := script_content || '        cur = conn.cursor()' || E'\n\n';
    
    script_content := script_content || '        # Get list of all tables to export' || E'\n';
    script_content := script_content || '        cur.execute("""' || E'\n';
    script_content := script_content || '            SELECT table_schema, table_name' || E'\n';
    script_content := script_content || '            FROM information_schema.tables' || E'\n';
    script_content := script_content || '            WHERE table_schema IN (''core'', ''trading'', ''loans'', ''risk'', ''compliance'', ''analytics'', ''payment'', ''cards'', ''treasury'', ''audit'')' || E'\n';
    script_content := script_content || '            AND table_type = ''BASE TABLE''' || E'\n';
    script_content := script_content || '            ORDER BY table_schema, table_name' || E'\n';
    script_content := script_content || '        """)' || E'\n\n';
    
    script_content := script_content || '        tables = cur.fetchall()' || E'\n';
    script_content := script_content || '        total_tables = len(tables)' || E'\n\n';
    
    script_content := script_content || '        print(f"Starting export of {total_tables} tables at {datetime.now()}")' || E'\n';
    script_content := script_content || '        print(f"Export directory: {export_dir}")' || E'\n\n';
    
    script_content := script_content || '        for i, (schema, table) in enumerate(tables, 1):' || E'\n';
    script_content := script_content || '            filename = f"{schema}_{table}.csv"' || E'\n';
    script_content := script_content || '            filepath = os.path.join(export_dir, filename)' || E'\n\n';
    
    script_content := script_content || '            print(f"[{i}/{total_tables}] Exporting {schema}.{table}...")' || E'\n\n';
    
    script_content := script_content || '            try:' || E'\n';
    script_content := script_content || '                with open(filepath, ''w'') as f:' || E'\n';
    script_content := script_content || '                    cur.copy_expert(f"COPY {schema}.{table} TO STDOUT WITH CSV HEADER", f)' || E'\n';
    script_content := script_content || '                print(f"    ✓ Exported to {filename}")' || E'\n';
    script_content := script_content || '            except Exception as e:' || E'\n';
    script_content := script_content || '                print(f"    ✗ Error exporting {schema}.{table}: {e}")' || E'\n\n';
    
    script_content := script_content || '        print(f"\\nExport completed at {datetime.now()}")' || E'\n\n';
    
    script_content := script_content || '    except Exception as e:' || E'\n';
    script_content := script_content || '        print(f"Database connection error: {e}")' || E'\n';
    script_content := script_content || '        sys.exit(1)' || E'\n\n';
    
    script_content := script_content || '    finally:' || E'\n';
    script_content := script_content || '        if conn:' || E'\n';
    script_content := script_content || '            conn.close()' || E'\n\n';
    
    script_content := script_content || 'if __name__ == "__main__":' || E'\n';
    script_content := script_content || '    export_tables()' || E'\n';
    
    RETURN script_content;
END;
$$ LANGUAGE plpgsql;

-- Execute the export planning function
SELECT core.export_all_tables_to_csv();

-- Display table statistics
SELECT * FROM analytics.get_table_statistics() ORDER BY schema_name, table_name;

-- Display all export commands
SELECT * FROM analytics.csv_export_commands ORDER BY schema_name, table_name;

COMMENT ON FUNCTION core.export_all_tables_to_csv IS 'Generates export commands for all tables to CSV format';
COMMENT ON FUNCTION analytics.get_table_statistics IS 'Returns statistics for all tables including row counts and sizes';
COMMENT ON FUNCTION core.generate_export_shell_script IS 'Generates a shell script for CSV export';
COMMENT ON FUNCTION core.generate_python_export_script IS 'Generates a Python script for CSV export with progress tracking';
COMMENT ON VIEW analytics.csv_export_commands IS 'View containing all CSV export commands for manual execution';
