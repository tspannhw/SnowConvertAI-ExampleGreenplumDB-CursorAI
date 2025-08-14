#!/bin/bash

# Greenplum Financial System Database Deployment Script
# Automated deployment with error handling and logging

set -e  # Exit on any error

# Default configuration
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="financial_system"
DB_USER="postgres"
DB_PASSWORD=""
LOG_FILE="deployment_$(date +%Y%m%d_%H%M%S).log"
GENERATE_DATA="true"
EXPORT_CSV="false"
CLEAN_INSTALL="false"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

# Success message
success() {
    echo -e "${GREEN}✓ $1${NC}"
    log "SUCCESS: $1"
}

# Warning message
warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    log "WARNING: $1"
}

# Info message
info() {
    echo -e "${BLUE}ℹ $1${NC}"
    log "INFO: $1"
}

# Progress indicator
progress() {
    echo -e "${PURPLE}→ $1${NC}"
    log "PROGRESS: $1"
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Greenplum Financial System Database Deployment Script

OPTIONS:
    --host HOST           Database host (default: localhost)
    --port PORT           Database port (default: 5432)
    --user USER           Database user (default: postgres)
    --password PASS       Database password (default: empty)
    --database DB         Database name (default: financial_system)
    --no-data            Skip bulk data generation
    --export-csv         Export data to CSV after deployment
    --clean              Perform clean installation (drop existing database)
    --log-file FILE      Log file path (default: deployment_YYYYMMDD_HHMMSS.log)
    --help               Show this help message

EXAMPLES:
    # Basic deployment
    $0

    # Custom database settings
    $0 --host myserver --port 5433 --user myuser --password mypass

    # Clean installation with CSV export
    $0 --clean --export-csv

    # Skip bulk data generation
    $0 --no-data

EOF
}

# Parse command line arguments
parse_arguments() {
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
            --password)
                DB_PASSWORD="$2"
                shift 2
                ;;
            --database)
                DB_NAME="$2"
                shift 2
                ;;
            --no-data)
                GENERATE_DATA="false"
                shift
                ;;
            --export-csv)
                EXPORT_CSV="true"
                shift
                ;;
            --clean)
                CLEAN_INSTALL="true"
                shift
                ;;
            --log-file)
                LOG_FILE="$2"
                shift 2
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                error_exit "Unknown option: $1. Use --help for usage information."
                ;;
        esac
    done
}

# Check prerequisites
check_prerequisites() {
    progress "Checking prerequisites..."
    
    # Check if psql is available
    if ! command -v psql &> /dev/null; then
        error_exit "psql command not found. Please install PostgreSQL client."
    fi
    
    # Check database connectivity
    local conn_test=""
    if [[ -n "$DB_PASSWORD" ]]; then
        export PGPASSWORD="$DB_PASSWORD"
        conn_test="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres"
    else
        conn_test="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres"
    fi
    
    if ! $conn_test -c "SELECT 1;" &> /dev/null; then
        error_exit "Cannot connect to database server at $DB_HOST:$DB_PORT with user $DB_USER"
    fi
    
    # Check for required SQL files
    local required_files=(
        "01_create_database.sql"
        "02_core_tables.sql"
        "03_trading_tables.sql"
        "04_risk_compliance_tables.sql"
        "05_loan_credit_tables.sql"
        "06_analytics_payment_tables.sql"
        "07_remaining_tables.sql"
        "08_stored_procedures.sql"
        "09_views.sql"
        "10_indexes_constraints.sql"
        "11_sample_data.sql"
        "12_deployment_setup.sql"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error_exit "Required file not found: $file"
        fi
    done
    
    success "Prerequisites check passed"
}

# Execute SQL file
execute_sql_file() {
    local sql_file="$1"
    local description="$2"
    local database="${3:-$DB_NAME}"
    
    progress "$description"
    
    local psql_cmd=""
    if [[ -n "$DB_PASSWORD" ]]; then
        export PGPASSWORD="$DB_PASSWORD"
        psql_cmd="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $database"
    else
        psql_cmd="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $database"
    fi
    
    if $psql_cmd -f "$sql_file" >> "$LOG_FILE" 2>&1; then
        success "$description completed"
        return 0
    else
        error_exit "$description failed. Check log file: $LOG_FILE"
    fi
}

# Clean installation
clean_installation() {
    if [[ "$CLEAN_INSTALL" == "true" ]]; then
        warning "Performing clean installation - this will drop the existing database!"
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            progress "Dropping existing database..."
            
            local psql_cmd=""
            if [[ -n "$DB_PASSWORD" ]]; then
                export PGPASSWORD="$DB_PASSWORD"
                psql_cmd="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres"
            else
                psql_cmd="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres"
            fi
            
            $psql_cmd -c "DROP DATABASE IF EXISTS $DB_NAME;" >> "$LOG_FILE" 2>&1
            success "Existing database dropped"
        else
            info "Clean installation cancelled"
            exit 0
        fi
    fi
}

# Deploy database schema
deploy_schema() {
    progress "Starting database schema deployment..."
    
    # 1. Create database and schemas
    execute_sql_file "01_create_database.sql" "Creating database and schemas" "postgres"
    
    # 2. Create core tables
    execute_sql_file "02_core_tables.sql" "Creating core banking tables"
    
    # 3. Create trading tables
    execute_sql_file "03_trading_tables.sql" "Creating trading and investment tables"
    
    # 4. Create risk and compliance tables
    execute_sql_file "04_risk_compliance_tables.sql" "Creating risk management and compliance tables"
    
    # 5. Create loan and credit tables
    execute_sql_file "05_loan_credit_tables.sql" "Creating loan and credit management tables"
    
    # 6. Create analytics and payment tables
    execute_sql_file "06_analytics_payment_tables.sql" "Creating analytics and payment tables"
    
    # 7. Create remaining specialized tables
    execute_sql_file "07_remaining_tables.sql" "Creating remaining specialized tables"
    
    # 8. Create stored procedures
    execute_sql_file "08_stored_procedures.sql" "Creating stored procedures and business logic"
    
    # 9. Create views
    execute_sql_file "09_views.sql" "Creating views for reporting and analytics"
    
    # 10. Create indexes and constraints
    execute_sql_file "10_indexes_constraints.sql" "Creating indexes and constraints"
    
    # 11. Insert sample data
    execute_sql_file "11_sample_data.sql" "Inserting sample data"
    
    # 12. Setup deployment functions
    execute_sql_file "12_deployment_setup.sql" "Setting up deployment and utility functions"
    
    success "Database schema deployment completed"
}

# Generate bulk data
generate_bulk_data() {
    if [[ "$GENERATE_DATA" == "true" ]]; then
        if [[ -f "13_generate_bulk_data.sql" ]]; then
            execute_sql_file "13_generate_bulk_data.sql" "Generating bulk data (1000+ records per table)"
        else
            warning "Bulk data generation file not found, skipping..."
        fi
    else
        info "Skipping bulk data generation (--no-data flag specified)"
    fi
}

# Setup CSV export
setup_csv_export() {
    if [[ -f "14_csv_export_scripts.sql" ]]; then
        execute_sql_file "14_csv_export_scripts.sql" "Setting up CSV export functionality"
    else
        warning "CSV export setup file not found, skipping..."
    fi
}

# Export to CSV
export_to_csv() {
    if [[ "$EXPORT_CSV" == "true" ]]; then
        info "Starting CSV export..."
        
        if [[ -f "export_data.py" ]]; then
            if command -v python3 &> /dev/null; then
                progress "Exporting data using Python script..."
                python3 export_data.py \
                    --host "$DB_HOST" \
                    --port "$DB_PORT" \
                    --user "$DB_USER" \
                    --database "$DB_NAME" \
                    --export-dir "./csv_export" \
                    --manifest
                success "CSV export completed using Python script"
            elif [[ -f "export_data.sh" && -x "export_data.sh" ]]; then
                progress "Exporting data using shell script..."
                ./export_data.sh \
                    --host "$DB_HOST" \
                    --port "$DB_PORT" \
                    --user "$DB_USER" \
                    --database "$DB_NAME" \
                    --export-dir "./csv_export"
                success "CSV export completed using shell script"
            else
                warning "No suitable export script found or executable"
            fi
        else
            warning "CSV export scripts not found, skipping..."
        fi
    fi
}

# Verify installation
verify_installation() {
    progress "Verifying installation..."
    
    local psql_cmd=""
    if [[ -n "$DB_PASSWORD" ]]; then
        export PGPASSWORD="$DB_PASSWORD"
        psql_cmd="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME"
    else
        psql_cmd="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME"
    fi
    
    # Run verification function
    local verification_result=$($psql_cmd -t -c "SELECT core.verify_installation();" 2>/dev/null || echo "VERIFICATION FAILED")
    
    if [[ "$verification_result" == *"INSTALLATION COMPLETE"* ]]; then
        success "Installation verification passed"
        echo "$verification_result"
    else
        warning "Installation verification had issues"
        echo "$verification_result"
    fi
    
    # Get data integrity check
    info "Running data integrity check..."
    $psql_cmd -c "SELECT * FROM core.check_data_integrity();" >> "$LOG_FILE" 2>&1
}

# Generate deployment summary
generate_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local duration_formatted=$(printf "%02d:%02d:%02d" $((duration/3600)) $((duration%3600/60)) $((duration%60)))
    
    cat << EOF

${GREEN}╔══════════════════════════════════════════════════════════════╗
║                    DEPLOYMENT COMPLETED                     ║
╚══════════════════════════════════════════════════════════════╝${NC}

${BLUE}Database Details:${NC}
  Host:     $DB_HOST:$DB_PORT
  Database: $DB_NAME
  User:     $DB_USER

${BLUE}Deployment Options:${NC}
  Clean Install:    $CLEAN_INSTALL
  Generate Data:    $GENERATE_DATA
  Export CSV:       $EXPORT_CSV

${BLUE}Results:${NC}
  Duration:         $duration_formatted
  Log File:         $LOG_FILE
  Status:           ${GREEN}SUCCESS${NC}

${BLUE}Next Steps:${NC}
  1. Connect to database: psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME
  2. Run health check:    SELECT core.health_check();
  3. View sample data:    SELECT * FROM analytics.customer_summary LIMIT 10;
  4. Export data:         python3 export_data.py (if needed)

EOF
}

# Main deployment function
main() {
    local start_time=$(date +%s)
    
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         Greenplum Financial System Database Deploy          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log "Starting deployment process"
    
    # Parse arguments
    parse_arguments "$@"
    
    # Show configuration
    info "Deployment Configuration:"
    info "  Host: $DB_HOST:$DB_PORT"
    info "  Database: $DB_NAME"
    info "  User: $DB_USER"
    info "  Log File: $LOG_FILE"
    info "  Generate Data: $GENERATE_DATA"
    info "  Export CSV: $EXPORT_CSV"
    info "  Clean Install: $CLEAN_INSTALL"
    echo
    
    # Execute deployment steps
    check_prerequisites
    clean_installation
    deploy_schema
    generate_bulk_data
    setup_csv_export
    export_to_csv
    verify_installation
    
    # Generate summary
    generate_summary
    
    log "Deployment completed successfully"
}

# Set global start time
start_time=$(date +%s)

# Run main function with all arguments
main "$@"
