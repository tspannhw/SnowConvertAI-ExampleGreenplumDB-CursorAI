# Greenplum Financial System Database

A comprehensive financial system database architecture designed for Greenplum, featuring 200+ tables across multiple financial domains including core banking, trading, risk management, compliance, loans, payments, and analytics.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Data Export](#data-export)
- [Database Schema](#database-schema)
- [Sample Data](#sample-data)
- [Performance](#performance)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This project provides a complete financial system database designed for Greenplum with:

- **200+ Tables** across 10 schemas
- **Comprehensive Coverage** of financial operations
- **Sample Data Generation** with 1000+ records per table
- **Advanced Analytics** views and reports
- **Risk Management** and compliance features
- **Trading and Investment** management
- **Loan Origination** and servicing
- **Payment Processing** capabilities
- **CSV Export** functionality

## 🏗️ Architecture

### Schemas

The database is organized into 10 logical schemas:

| Schema | Purpose | Tables | Description |
|--------|---------|---------|-------------|
| `core` | Core Banking | 25+ | Customers, accounts, transactions, GL |
| `trading` | Trading & Investments | 25+ | Securities, portfolios, orders, trades |
| `loans` | Loan Management | 25+ | Applications, loans, payments, collateral |
| `risk` | Risk Management | 15+ | Risk measurements, limits, stress tests |
| `compliance` | Regulatory Compliance | 15+ | AML, KYC, sanctions, reporting |
| `analytics` | Analytics & BI | 10+ | Customer analytics, performance metrics |
| `payment` | Payment Processing | 10+ | Wire transfers, ACH, payment instructions |
| `cards` | Card Management | 5+ | Credit/debit cards, transactions, rewards |
| `treasury` | Treasury Operations | 5+ | Liquidity, funding, interest rate risk |
| `audit` | Audit & Logging | 5+ | Audit trails, error logs, performance |

### Key Features

- **Double-entry Accounting** with GL integration
- **Real-time Risk Management** with VaR calculations
- **AML/KYC Compliance** monitoring
- **Trading Operations** with portfolio management
- **Loan Lifecycle** from origination to collection
- **Payment Processing** with multiple channels
- **Comprehensive Reporting** and analytics
- **Audit Trail** for all operations

## 🚀 Installation

### Prerequisites

- Greenplum Database 6.0+ or PostgreSQL 12+
- psql client
- Python 3.7+ (for data export)
- 10GB+ available disk space

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd greenplumdatabase
   ```

2. **Run the installation scripts in order:**
   ```bash
   # 1. Create database and schemas
   psql -f 01_create_database.sql
   
   # 2. Create core tables
   psql -d financial_system -f 02_core_tables.sql
   
   # 3. Create trading tables
   psql -d financial_system -f 03_trading_tables.sql
   
   # 4. Create risk and compliance tables
   psql -d financial_system -f 04_risk_compliance_tables.sql
   
   # 5. Create loan and credit tables
   psql -d financial_system -f 05_loan_credit_tables.sql
   
   # 6. Create analytics and payment tables
   psql -d financial_system -f 06_analytics_payment_tables.sql
   
   # 7. Create remaining specialized tables
   psql -d financial_system -f 07_remaining_tables.sql
   
   # 8. Create stored procedures
   psql -d financial_system -f 08_stored_procedures.sql
   
   # 9. Create views
   psql -d financial_system -f 09_views.sql
   
   # 10. Create indexes and constraints
   psql -d financial_system -f 10_indexes_constraints.sql
   
   # 11. Insert sample data
   psql -d financial_system -f 11_sample_data.sql
   
   # 12. Setup deployment functions
   psql -d financial_system -f 12_deployment_setup.sql
   
   # 13. Generate bulk data (1000+ records per table)
   psql -d financial_system -f 13_generate_bulk_data.sql
   
   # 14. Setup CSV export functions
   psql -d financial_system -f 14_csv_export_scripts.sql
   ```

3. **Verify installation:**
   ```sql
   SELECT core.verify_installation();
   ```

### Automated Installation

Use the deployment script for automated installation:

```bash
./deploy.sh --host localhost --database financial_system --user postgres
```

## 💻 Usage

### Basic Operations

#### Customer Management
```sql
-- Create a new customer
SELECT core.create_customer(
    1,                          -- customer_type_id
    'John',                     -- first_name
    'Doe',                      -- last_name
    '1985-01-15',              -- date_of_birth
    'john.doe@email.com',      -- email
    '+1-555-123-4567',         -- phone
    '123-45-6789',             -- ssn
    '123 Main Street',         -- address
    1                          -- city_id
);

-- Create an account
SELECT core.create_account(
    1,          -- customer_id
    1,          -- account_type_id (checking)
    1,          -- branch_id
    'USD',      -- currency
    1000.00     -- initial_deposit
);
```

#### Transaction Processing
```sql
-- Process a transaction
SELECT core.process_transaction(
    1,              -- account_id
    1,              -- transaction_type_id (deposit)
    500.00,         -- amount
    'Payroll deposit',  -- description
    'PAY123'        -- reference_number
);

-- Transfer funds between accounts
SELECT core.transfer_funds(
    1,              -- from_account_id
    2,              -- to_account_id
    100.00,         -- amount
    'Transfer to savings',  -- description
    'TRF456'        -- reference_number
);
```

#### Loan Processing
```sql
-- Create loan application
SELECT loans.create_loan_application(
    1,              -- customer_id
    1,              -- loan_product_id
    15000.00,       -- requested_amount
    36,             -- term_months
    'Debt consolidation'  -- purpose
);

-- Process loan payment
SELECT loans.process_loan_payment(
    1,              -- loan_id
    500.00,         -- payment_amount
    CURRENT_DATE,   -- payment_date
    'AUTO_DEBIT'    -- payment_method
);
```

#### Trading Operations
```sql
-- Place a trading order
SELECT trading.place_order(
    1,              -- portfolio_id
    1,              -- security_id (AAPL)
    1,              -- order_type_id (market order)
    'BUY',          -- side
    100,            -- quantity
    185.50          -- price
);

-- Execute the order
SELECT trading.execute_order(
    1,              -- order_id
    185.25,         -- execution_price
    100,            -- execution_quantity
    'NYSE'          -- execution_venue
);
```

### Analytics and Reporting

#### Customer Analytics
```sql
-- Customer summary
SELECT * FROM analytics.customer_summary 
WHERE total_balance > 50000;

-- Customer profitability
SELECT analytics.calculate_customer_profitability(
    1,              -- customer_id
    '2024-01-01',   -- start_date
    '2024-12-31'    -- end_date
);
```

#### Risk Management
```sql
-- Calculate VaR
SELECT risk.calculate_var(
    1,              -- portfolio_id
    0.95,           -- confidence_level
    1               -- time_horizon_days
);

-- Risk exposure summary
SELECT * FROM risk.risk_exposure_summary;
```

#### Compliance Monitoring
```sql
-- AML alerts dashboard
SELECT * FROM compliance.aml_alerts_dashboard
WHERE alert_month >= '2024-01-01';

-- Compliance status
SELECT * FROM compliance.compliance_status;
```

## 📊 Data Export

### CSV Export Options

#### 1. Python Script (Recommended)
```bash
# Export all tables to CSV
python3 export_data.py --host localhost --database financial_system --export-dir ./csv_export

# With custom parameters
python3 export_data.py \
    --host localhost \
    --port 5432 \
    --user postgres \
    --password mypassword \
    --database financial_system \
    --export-dir /path/to/export \
    --manifest
```

#### 2. Shell Script
```bash
# Export using shell script
./export_data.sh --host localhost --database financial_system --export-dir ./csv_export
```

#### 3. SQL Functions
```sql
-- Generate export commands
SELECT * FROM analytics.csv_export_commands;

-- Get table statistics
SELECT * FROM analytics.get_table_statistics();

-- Export all tables (generates commands)
SELECT core.export_all_tables_to_csv('/path/to/export/');
```

### Export Output

The export process creates:
- **CSV files** for each table (e.g., `core_customers.csv`)
- **Export manifest** with file checksums
- **Summary report** with statistics
- **Log files** for troubleshooting

## 🗄️ Database Schema

### Core Tables (25+)
- `customers` - Customer master data
- `accounts` - Customer accounts
- `transactions` - All financial transactions
- `branches` - Branch information
- `employees` - Employee data
- `gl_accounts` - General ledger chart of accounts
- `products` - Financial products

### Trading Tables (25+)
- `securities` - Security master data
- `portfolios` - Investment portfolios
- `holdings` - Portfolio holdings
- `orders` - Trading orders
- `trades` - Executed trades
- `market_data` - Historical market data
- `exchanges` - Exchange information

### Loan Tables (25+)
- `loan_products` - Loan product definitions
- `loan_applications` - Loan applications
- `loans` - Active loans
- `loan_payments` - Payment history
- `loan_schedules` - Payment schedules
- `collateral` - Loan collateral
- `credit_scores` - Credit scoring data

### Risk Tables (15+)
- `risk_measurements` - Risk metrics
- `risk_limits` - Risk limit definitions
- `stress_test_scenarios` - Stress testing
- `credit_ratings` - Credit ratings
- `counterparty_risk` - Counterparty exposures

### Compliance Tables (15+)
- `aml_alerts` - AML monitoring alerts
- `kyc_documents` - KYC documentation
- `sanctions_screening` - Sanctions checks
- `regulatory_reports` - Regulatory filings
- `compliance_monitoring` - Compliance tracking

## 📈 Sample Data

The system includes comprehensive sample data generation:

- **1,000+ Customers** with realistic profiles
- **2,500+ Accounts** across different types
- **10,000+ Transactions** with various patterns
- **1,000+ Loan Applications** and active loans
- **300+ Trading Accounts** and portfolios
- **5,000+ Trading Orders** and executions
- **1,000+ Credit Cards** and transactions
- **Risk Measurements** and compliance data

### Data Generation
```sql
-- Run bulk data generation
\i 13_generate_bulk_data.sql

-- Verify data counts
SELECT 
    'Customers' as entity, COUNT(*) as count FROM core.customers
UNION ALL
SELECT 'Accounts', COUNT(*) FROM core.accounts
UNION ALL
SELECT 'Transactions', COUNT(*) FROM core.transactions
UNION ALL
SELECT 'Loans', COUNT(*) FROM loans.loans;
```

## ⚡ Performance

### Indexing Strategy
- **Primary keys** on all tables
- **Foreign key indexes** for relationships
- **Composite indexes** for common query patterns
- **Partial indexes** for filtered queries
- **GIN indexes** for text search

### Query Optimization
- **Materialized views** for complex analytics
- **Partitioning** by date for large tables
- **Compression** for historical data
- **Statistics** maintenance automation

### Monitoring
```sql
-- Performance monitoring
SELECT * FROM audit.database_performance
WHERE metric_date >= CURRENT_DATE - INTERVAL '1 day';

-- Health check
SELECT core.health_check();
```

## 🔒 Security

### Access Control
- **Role-based security** with predefined roles
- **Schema-level permissions**
- **Row-level security** for sensitive data
- **Audit trails** for all operations

### Data Protection
- **Encrypted sensitive fields** (SSN, card numbers)
- **Masked data** in non-production environments
- **Secure functions** for data access
- **Compliance monitoring**

### Roles
```sql
-- Application roles
GRANT financial_app_read TO myuser;      -- Read-only access
GRANT financial_app_write TO myuser;     -- Read-write access
GRANT financial_app_admin TO myuser;     -- Administrative access
```

## 🛠️ Maintenance

### Daily Operations
```sql
-- Run daily batch processing
SELECT core.run_daily_batch();

-- Performance maintenance
SELECT core.run_maintenance();

-- Security audit
SELECT * FROM audit.security_audit();
```

### Backup and Recovery
```sql
-- Check backup status
SELECT * FROM core.backup_status();

-- Data integrity check
SELECT * FROM core.check_data_integrity();
```

## 📋 File Structure

```
greenplumdatabase/
├── 01_create_database.sql      # Database and schema creation
├── 02_core_tables.sql          # Core banking tables
├── 03_trading_tables.sql       # Trading and investment tables
├── 04_risk_compliance_tables.sql # Risk and compliance tables
├── 05_loan_credit_tables.sql   # Loan management tables
├── 06_analytics_payment_tables.sql # Analytics and payment tables
├── 07_remaining_tables.sql     # Additional specialized tables
├── 08_stored_procedures.sql    # Business logic procedures
├── 09_views.sql               # Reporting and analytics views
├── 10_indexes_constraints.sql  # Performance and integrity
├── 11_sample_data.sql         # Sample data insertion
├── 12_deployment_setup.sql    # Deployment and utilities
├── 13_generate_bulk_data.sql  # Bulk data generation
├── 14_csv_export_scripts.sql  # CSV export functions
├── export_data.py             # Python export script
├── export_data.sh             # Shell export script
├── deploy.sh                  # Automated deployment
└── README.md                  # This documentation
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the sample queries
- Examine the audit logs for troubleshooting

## 🔄 Version History

- **v1.0.0** - Initial release with 200+ tables
- **v1.1.0** - Added bulk data generation
- **v1.2.0** - CSV export functionality
- **v1.3.0** - Enhanced analytics and reporting

---

**Note**: This is a demonstration database designed for Greenplum. Ensure proper security measures and compliance reviews before using in production environments.
