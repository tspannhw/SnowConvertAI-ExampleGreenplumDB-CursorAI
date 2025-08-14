#!/bin/bash

# Greenplum Financial System CSV Export Script
# Exports all tables to CSV format with logging and error handling

set -e  # Exit on any error

# Configuration
EXPORT_DIR="/tmp/financial_system_export"
DB_NAME="financial_system"
DB_HOST="localhost"
DB_PORT="5432"
DB_USER="postgres"
LOG_FILE="export_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    log "ERROR: $1"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if psql is available
    if ! command -v psql &> /dev/null; then
        error_exit "psql command not found. Please install PostgreSQL client."
    fi
    
    # Check database connectivity
    if ! psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" &> /dev/null; then
        error_exit "Cannot connect to database $DB_NAME at $DB_HOST:$DB_PORT"
    fi
    
    log "Prerequisites check passed"
}

# Create export directory
setup_export_directory() {
    log "Setting up export directory: $EXPORT_DIR"
    
    if [[ -d "$EXPORT_DIR" ]]; then
        read -p "Export directory already exists. Remove it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$EXPORT_DIR"
            log "Removed existing export directory"
        else
            log "Using existing export directory"
        fi
    fi
    
    mkdir -p "$EXPORT_DIR" || error_exit "Cannot create export directory"
    log "Export directory ready: $EXPORT_DIR"
}

# Get list of tables to export
get_tables() {
    log "Getting list of tables to export..."
    
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT table_schema || '.' || table_name
        FROM information_schema.tables
        WHERE table_schema IN ('core', 'trading', 'loans', 'risk', 'compliance', 
                              'analytics', 'payment', 'cards', 'treasury', 'audit')
        AND table_type = 'BASE TABLE'
        ORDER BY table_schema, table_name;
    " | sed '/^\s*$/d' | tr -d ' ' > "${EXPORT_DIR}/table_list.txt"
    
    local table_count=$(wc -l < "${EXPORT_DIR}/table_list.txt")
    log "Found $table_count tables to export"
}

# Export single table
export_table() {
    local table_name="$1"
    local schema_table="${table_name}"
    local file_name="${table_name//\./_}.csv"
    local file_path="${EXPORT_DIR}/${file_name}"
    
    echo -ne "${BLUE}Exporting ${schema_table}...${NC}"
    
    # Get row count
    local row_count=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM ${schema_table};" | tr -d ' ')
    
    # Export table
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "\\COPY ${schema_table} TO '${file_path}' WITH CSV HEADER;" &>> "$LOG_FILE"; then
        local file_size=$(du -h "$file_path" | cut -f1)
        echo -e " ${GREEN}✓${NC} ($row_count rows, $file_size)"
        log "Successfully exported $schema_table to $file_name ($row_count rows, $file_size)"
        return 0
    else
        echo -e " ${RED}✗${NC}"
        log "Failed to export $schema_table"
        return 1
    fi
}

# Export all tables
export_all_tables() {
    local table_list="${EXPORT_DIR}/table_list.txt"
    local total_tables=$(wc -l < "$table_list")
    local exported_count=0
    local error_count=0
    local current=0
    
    log "Starting export of $total_tables tables"
    echo -e "${YELLOW}Exporting $total_tables tables to CSV format...${NC}"
    
    while IFS= read -r table; do
        ((current++))
        echo -n "[$current/$total_tables] "
        
        if export_table "$table"; then
            ((exported_count++))
        else
            ((error_count++))
        fi
    done < "$table_list"
    
    echo
    log "Export completed: $exported_count successful, $error_count errors"
    
    return $error_count
}

# Generate export summary
generate_summary() {
    local summary_file="${EXPORT_DIR}/export_summary.txt"
    local total_size=$(du -sh "$EXPORT_DIR" | cut -f1)
    local csv_count=$(find "$EXPORT_DIR" -name "*.csv" | wc -l)
    
    {
        echo "Greenplum Financial System Export Summary"
        echo "========================================"
        echo "Export Date: $(date)"
        echo "Export Directory: $EXPORT_DIR"
        echo "Database: $DB_NAME at $DB_HOST:$DB_PORT"
        echo
        echo "Statistics:"
        echo "  CSV Files: $csv_count"
        echo "  Total Size: $total_size"
        echo
        echo "Files:"
        echo "------"
        find "$EXPORT_DIR" -name "*.csv" -printf "%f %s bytes\n" | sort
    } > "$summary_file"
    
    log "Export summary generated: $summary_file"
}

# Generate file manifest with checksums
generate_manifest() {
    local manifest_file="${EXPORT_DIR}/export_manifest.txt"
    
    log "Generating file manifest with checksums..."
    
    {
        echo "Greenplum Financial System Export Manifest"
        echo "==========================================="
        echo "Generated: $(date)"
        echo "Directory: $EXPORT_DIR"
        echo
        echo "Format: filename size(bytes) md5sum"
        echo "-----------------------------------"
        
        find "$EXPORT_DIR" -name "*.csv" | while read -r file; do
            local basename=$(basename "$file")
            local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
            local checksum=$(md5sum "$file" | cut -d' ' -f1)
            printf "%-40s %12s %s\n" "$basename" "$size" "$checksum"
        done
    } > "$manifest_file"
    
    log "File manifest generated: $manifest_file"
}

# Main execution
main() {
    echo -e "${BLUE}Greenplum Financial System CSV Export${NC}"
    echo "======================================"
    
    log "Starting export process"
    
    # Check prerequisites
    check_prerequisites
    
    # Setup
    setup_export_directory
    get_tables
    
    # Export data
    local start_time=$(date +%s)
    if export_all_tables; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        echo -e "${GREEN}Export completed successfully in ${duration}s${NC}"
        log "Export completed successfully in ${duration}s"
        
        # Generate reports
        generate_summary
        generate_manifest
        
        echo
        echo -e "${GREEN}Export Results:${NC}"
        echo "  Directory: $EXPORT_DIR"
        echo "  Log file: $LOG_FILE"
        echo "  Summary: ${EXPORT_DIR}/export_summary.txt"
        echo "  Manifest: ${EXPORT_DIR}/export_manifest.txt"
        
    else
        echo -e "${RED}Export completed with errors${NC}"
        log "Export completed with errors"
        exit 1
    fi
}

# Handle command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            DB_HOST="$2"
            shift 2
            ;;
        --port)
            DB_PORT="$2"
            shift 2
            ;;
        --user)
            DB_USER="$2"
            shift 2
            ;;
        --database)
            DB_NAME="$2"
            shift 2
            ;;
        --export-dir)
            EXPORT_DIR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --host HOST           Database host (default: localhost)"
            echo "  --port PORT           Database port (default: 5432)"
            echo "  --user USER           Database user (default: postgres)"
            echo "  --database DB         Database name (default: financial_system)"
            echo "  --export-dir DIR      Export directory (default: /tmp/financial_system_export)"
            echo "  --help                Show this help message"
            exit 0
            ;;
        *)
            error_exit "Unknown option: $1. Use --help for usage information."
            ;;
    esac
done

# Run main function
main
