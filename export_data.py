#!/usr/bin/env python3
"""
Greenplum Financial System CSV Export Script
Exports all tables to CSV files with progress tracking and error handling
"""

import psycopg2
import os
import sys
import logging
from datetime import datetime
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('export.log'),
        logging.StreamHandler()
    ]
)

def export_tables(host='localhost', port='5432', database='financial_system', 
                 user='greenplum', password='', export_dir='/tmp/financial_system_export'):
    """
    Export all tables from the financial system database to CSV files
    
    Args:
        host (str): Database host
        port (str): Database port
        database (str): Database name
        user (str): Database user
        password (str): Database password
        export_dir (str): Directory to save CSV files
    """
    
    # Create export directory
    Path(export_dir).mkdir(parents=True, exist_ok=True)
    
    # Database connection parameters
    conn_params = {
        "host": host,
        "port": port,
        "database": database,
        "user": user,
        "password": password
    }
    
    try:
        # Connect to database
        logging.info(f"Connecting to database {database} at {host}:{port}")
        conn = psycopg2.connect(**conn_params)
        cur = conn.cursor()
        
        # Get list of all tables to export
        cur.execute("""
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_schema IN ('core', 'trading', 'loans', 'risk', 'compliance', 
                                  'analytics', 'payment', 'cards', 'treasury', 'audit')
            AND table_type = 'BASE TABLE'
            ORDER BY table_schema, table_name
        """)
        
        tables = cur.fetchall()
        total_tables = len(tables)
        exported_count = 0
        error_count = 0
        
        logging.info(f"Found {total_tables} tables to export")
        logging.info(f"Export directory: {export_dir}")
        
        # Export each table
        for i, (schema, table) in enumerate(tables, 1):
            filename = f"{schema}_{table}.csv"
            filepath = os.path.join(export_dir, filename)
            
            logging.info(f"[{i}/{total_tables}] Exporting {schema}.{table}...")
            
            try:
                # Get row count for progress info
                cur.execute(f"SELECT COUNT(*) FROM {schema}.{table}")
                row_count = cur.fetchone()[0]
                
                # Export table to CSV
                with open(filepath, 'w', newline='', encoding='utf-8') as f:
                    cur.copy_expert(f"COPY {schema}.{table} TO STDOUT WITH CSV HEADER", f)
                
                # Get file size
                file_size = os.path.getsize(filepath)
                file_size_mb = file_size / (1024 * 1024)
                
                logging.info(f"    ✓ Exported {row_count:,} rows to {filename} ({file_size_mb:.2f} MB)")
                exported_count += 1
                
            except Exception as e:
                logging.error(f"    ✗ Error exporting {schema}.{table}: {e}")
                error_count += 1
                
                # Remove partial file if it exists
                if os.path.exists(filepath):
                    os.remove(filepath)
        
        # Summary
        logging.info(f"\nExport Summary:")
        logging.info(f"  Total tables: {total_tables}")
        logging.info(f"  Successfully exported: {exported_count}")
        logging.info(f"  Errors: {error_count}")
        logging.info(f"  Export directory: {export_dir}")
        
        # List all exported files
        csv_files = list(Path(export_dir).glob("*.csv"))
        total_size = sum(f.stat().st_size for f in csv_files)
        total_size_mb = total_size / (1024 * 1024)
        
        logging.info(f"  Total CSV files: {len(csv_files)}")
        logging.info(f"  Total size: {total_size_mb:.2f} MB")
        
        return exported_count, error_count
        
    except psycopg2.Error as e:
        logging.error(f"Database error: {e}")
        return 0, 1
        
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        return 0, 1
        
    finally:
        if 'conn' in locals() and conn:
            conn.close()
            logging.info("Database connection closed")

def generate_export_manifest(export_dir='/tmp/financial_system_export'):
    """
    Generate a manifest file listing all exported CSV files with metadata
    """
    manifest_path = os.path.join(export_dir, 'export_manifest.txt')
    
    try:
        with open(manifest_path, 'w') as f:
            f.write("Greenplum Financial System Export Manifest\n")
            f.write("=" * 50 + "\n")
            f.write(f"Export Date: {datetime.now()}\n")
            f.write(f"Export Directory: {export_dir}\n\n")
            
            csv_files = sorted(Path(export_dir).glob("*.csv"))
            
            f.write(f"Total Files: {len(csv_files)}\n\n")
            f.write("File Details:\n")
            f.write("-" * 50 + "\n")
            
            total_size = 0
            for csv_file in csv_files:
                size = csv_file.stat().st_size
                size_mb = size / (1024 * 1024)
                total_size += size
                
                f.write(f"{csv_file.name:40} {size_mb:8.2f} MB\n")
            
            total_size_mb = total_size / (1024 * 1024)
            f.write("-" * 50 + "\n")
            f.write(f"{'Total Size:':40} {total_size_mb:8.2f} MB\n")
        
        logging.info(f"Export manifest created: {manifest_path}")
        
    except Exception as e:
        logging.error(f"Error creating manifest: {e}")

def main():
    """
    Main function to handle command line arguments and execute export
    """
    import argparse
    
    parser = argparse.ArgumentParser(description='Export Greenplum Financial System to CSV')
    parser.add_argument('--host', default='localhost', help='Database host')
    parser.add_argument('--port', default='5432', help='Database port')
    parser.add_argument('--database', default='financial_system', help='Database name')
    parser.add_argument('--user', default='postgres', help='Database user')
    parser.add_argument('--password', default='', help='Database password')
    parser.add_argument('--export-dir', default='/tmp/financial_system_export', 
                       help='Export directory')
    parser.add_argument('--manifest', action='store_true', 
                       help='Generate export manifest file')
    
    args = parser.parse_args()
    
    # Start export
    start_time = datetime.now()
    logging.info(f"Starting export at {start_time}")
    
    exported, errors = export_tables(
        host=args.host,
        port=args.port,
        database=args.database,
        user=args.user,
        password=args.password,
        export_dir=args.export_dir
    )
    
    # Generate manifest if requested
    if args.manifest:
        generate_export_manifest(args.export_dir)
    
    # Final summary
    end_time = datetime.now()
    duration = end_time - start_time
    
    logging.info(f"Export completed at {end_time}")
    logging.info(f"Total duration: {duration}")
    
    if errors > 0:
        logging.warning(f"Export completed with {errors} errors")
        sys.exit(1)
    else:
        logging.info("Export completed successfully")
        sys.exit(0)

if __name__ == "__main__":
    main()
