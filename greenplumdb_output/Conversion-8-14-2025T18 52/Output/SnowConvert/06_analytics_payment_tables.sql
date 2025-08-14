-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '4' COLUMN '1' OF THE SOURCE CODE STARTING AT '\'. EXPECTED 'STATEMENT' GRAMMAR. **
---- Analytics, Payment Processing, and Additional Tables
---- Schemas: analytics, payment, cards, treasury, audit

--\c financial_system
                   ;
--** SSC-FDM-PG0006 - SET SEARCH PATH WITH MULTIPLE SCHEMAS IS NOT SUPPORTED IN SNOWFLAKE **
USE SCHEMA analytics /*, payment, cards, treasury, audit, core, trading, loans, public*/;

-- Analytics Tables (Schema: analytics)
-- 101. Data Sources
CREATE TABLE analytics.data_sources (
    data_source_id INTEGER PRIMARY KEY IDENTITY,
    source_name VARCHAR(100) NOT NULL UNIQUE,
    source_type VARCHAR(50) NOT NULL, -- DATABASE, API, FILE, STREAM
    connection_string TEXT,
    description TEXT,
    update_frequency VARCHAR(20),
    last_updated TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (data_source_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 102. Reports
CREATE TABLE analytics.reports (
    report_id INTEGER PRIMARY KEY IDENTITY,
    report_name VARCHAR(200) NOT NULL,
    report_category VARCHAR(50),
    description TEXT,
    report_query TEXT,
    parameters VARIANT,
    schedule_expression VARCHAR(100), -- Cron expression
    output_format VARCHAR(20) DEFAULT 'PDF',
    recipients ARRAY /*** SSC-FDM-PG0016 - STRONGLY TYPED ARRAY 'TEXT[]' TRANSFORMED TO ARRAY WITHOUT TYPE CHECKING ***/,
    created_by INTEGER REFERENCES core.employees (employee_id),
    last_run_date TIMESTAMP,
    next_run_date TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (report_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 103. Report Executions
CREATE TABLE analytics.report_executions (
    execution_id INTEGER PRIMARY KEY IDENTITY,
    report_id INTEGER REFERENCES analytics.reports (report_id),
    execution_date TIMESTAMP NOT NULL,
    execution_status VARCHAR(20) DEFAULT 'RUNNING',
    execution_time_seconds INTEGER,
    records_processed BIGINT,
    output_file_path VARCHAR(500),
    error_message TEXT,
    executed_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (report_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 104. KPI Definitions
CREATE TABLE analytics.kpi_definitions (
    kpi_id INTEGER PRIMARY KEY IDENTITY,
    kpi_name VARCHAR(100) NOT NULL UNIQUE,
    kpi_category VARCHAR(50),
    description TEXT,
    calculation_formula TEXT NOT NULL,
    unit_of_measure VARCHAR(20),
    target_value DECIMAL(18,4),
    threshold_warning DECIMAL(18,4),
    threshold_critical DECIMAL(18,4),
    frequency VARCHAR(20) DEFAULT 'DAILY',
    is_active BOOLEAN DEFAULT TRUE,
    created_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (kpi_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 105. KPI Values
CREATE TABLE analytics.kpi_values (
    kpi_value_id INTEGER PRIMARY KEY IDENTITY,
    kpi_id INTEGER REFERENCES analytics.kpi_definitions (kpi_id),
    measurement_date DATE NOT NULL,
    actual_value DECIMAL(18,4) NOT NULL,
    target_value DECIMAL(18,4),
    variance_percentage DECIMAL(8,4),
    status VARCHAR(20), -- NORMAL, WARNING, CRITICAL
    calculation_details VARIANT,
    calculated_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UNIQUE(kpi_id, measurement_date)
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (kpi_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 106. Customer Analytics
CREATE TABLE analytics.customer_analytics (
    customer_analytics_id INTEGER PRIMARY KEY IDENTITY,
    customer_id INTEGER REFERENCES core.customers (customer_id),
    analysis_date DATE NOT NULL,
    total_relationship_value DECIMAL(18,2),
    product_count INTEGER,
    average_balance DECIMAL(18,2),
    transaction_frequency DECIMAL(8,2),
    channel_preference VARCHAR(20),
    lifetime_value DECIMAL(18,2),
    churn_probability DECIMAL(5,4),
    cross_sell_propensity DECIMAL(5,4),
    risk_score INTEGER,
    profitability_tier VARCHAR(20),
    segment VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UNIQUE(customer_id, analysis_date)
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (customer_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 107. Product Performance
CREATE TABLE analytics.product_performance (
    performance_id INTEGER PRIMARY KEY IDENTITY,
    product_id INTEGER REFERENCES core.products (product_id),
    analysis_date DATE NOT NULL,
    active_customers INTEGER,
    new_customers INTEGER,
    closed_accounts INTEGER,
    total_balance DECIMAL(18,2),
    transaction_volume BIGINT,
    transaction_amount DECIMAL(18,2),
    fee_income DECIMAL(15,2),
    interest_income DECIMAL(15,2),
    provision_expense DECIMAL(15,2),
    net_income DECIMAL(15,2),
    market_share DECIMAL(5,4),
    customer_satisfaction DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UNIQUE(product_id, analysis_date)
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (product_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- Payment Processing Tables (Schema: payment)
-- 108. Payment Methods
CREATE TABLE payment.payment_methods (
    payment_method_id INTEGER PRIMARY KEY IDENTITY,
    method_code VARCHAR(20) NOT NULL UNIQUE,
    method_name VARCHAR(100) NOT NULL,
    description TEXT,
    processing_fee DECIMAL(8,4) DEFAULT 0,
    min_amount DECIMAL(12,2),
    max_amount DECIMAL(12,2),
    settlement_time VARCHAR(50),
    is_real_time BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (payment_method_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 109. Payment Processors
CREATE TABLE payment.payment_processors (
    processor_id INTEGER PRIMARY KEY IDENTITY,
    processor_name VARCHAR(100) NOT NULL,
    processor_code VARCHAR(20) NOT NULL UNIQUE,
    api_endpoint VARCHAR(255),
    supported_methods ARRAY /*** SSC-FDM-PG0016 - STRONGLY TYPED ARRAY 'TEXT[]' TRANSFORMED TO ARRAY WITHOUT TYPE CHECKING ***/,
    transaction_fee DECIMAL(8,4),
    monthly_fee DECIMAL(10,2),
    settlement_period INTEGER, -- days
    contact_info VARIANT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (processor_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 110. Payment Instructions
CREATE TABLE payment.payment_instructions (
    instruction_id INTEGER PRIMARY KEY IDENTITY,
    customer_id INTEGER REFERENCES core.customers (customer_id),
    account_id INTEGER REFERENCES core.accounts (account_id),
    payment_method_id INTEGER REFERENCES payment.payment_methods (payment_method_id),
    processor_id INTEGER REFERENCES payment.payment_processors (processor_id),
    instruction_type VARCHAR(20) NOT NULL, -- ONE_TIME, RECURRING
    amount DECIMAL(15,2) NOT NULL,
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    beneficiary_name VARCHAR(200) NOT NULL,
    beneficiary_account VARCHAR(50) NOT NULL,
    beneficiary_bank VARCHAR(200),
    beneficiary_address TEXT,
    payment_reference VARCHAR(200),
    payment_purpose TEXT,
    execution_date DATE NOT NULL,
    recurring_frequency VARCHAR(20), -- WEEKLY, MONTHLY, QUARTERLY
    recurring_end_date DATE,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (customer_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 111. Wire Transfers
CREATE TABLE payment.wire_transfers (
    wire_transfer_id INTEGER PRIMARY KEY IDENTITY,
    transfer_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INTEGER REFERENCES core.customers (customer_id),
    account_id INTEGER REFERENCES core.accounts (account_id),
    transfer_type VARCHAR(20) NOT NULL, -- DOMESTIC, INTERNATIONAL
    amount DECIMAL(15,2) NOT NULL,
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    exchange_rate DECIMAL(18,8),
    fees DECIMAL(10,2) DEFAULT 0,
    sender_name VARCHAR(200) NOT NULL,
    sender_address TEXT,
    beneficiary_name VARCHAR(200) NOT NULL,
    beneficiary_account VARCHAR(50) NOT NULL,
    beneficiary_bank_name VARCHAR(200) NOT NULL,
    beneficiary_bank_code VARCHAR(20),
    beneficiary_bank_address TEXT,
    intermediary_bank_name VARCHAR(200),
    intermediary_bank_code VARCHAR(20),
    payment_purpose TEXT,
    regulatory_code VARCHAR(20),
    value_date DATE NOT NULL,
    execution_date DATE,
    status VARCHAR(20) DEFAULT 'PENDING',
    swift_message TEXT,
    confirmation_number VARCHAR(100),
    created_by INTEGER REFERENCES core.employees (employee_id),
    approved_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (customer_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 112. ACH Transactions
CREATE TABLE payment.ach_transactions (
    ach_transaction_id INTEGER PRIMARY KEY IDENTITY,
    transaction_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INTEGER REFERENCES core.customers (customer_id),
    account_id INTEGER REFERENCES core.accounts (account_id),
    transaction_type VARCHAR(10) NOT NULL, -- DEBIT, CREDIT
    sec_code VARCHAR(3) NOT NULL, -- PPD, CCD, WEB, TEL
    amount DECIMAL(15,2) NOT NULL,
    effective_date DATE NOT NULL,
    originator_name VARCHAR(200) NOT NULL,
    originator_id VARCHAR(10) NOT NULL,
    receiver_name VARCHAR(200) NOT NULL,
    receiver_account VARCHAR(20) NOT NULL,
    receiver_routing VARCHAR(9) NOT NULL,
    addenda_record TEXT,
    trace_number VARCHAR(15),
    batch_number INTEGER,
    status VARCHAR(20) DEFAULT 'PENDING',
    return_code VARCHAR(3),
    return_reason TEXT,
    settlement_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (customer_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- Card Management Tables (Schema: cards)
-- 113. Card Types
CREATE TABLE cards.card_types (
    card_type_id INTEGER PRIMARY KEY IDENTITY,
    type_code VARCHAR(10) NOT NULL UNIQUE,
    type_name VARCHAR(50) NOT NULL,
    card_category VARCHAR(20) NOT NULL, -- DEBIT, CREDIT, PREPAID
    annual_fee DECIMAL(8,2) DEFAULT 0,
    interest_rate DECIMAL(8,4),
    credit_limit_min DECIMAL(12,2),
    credit_limit_max DECIMAL(12,2),
    rewards_program BOOLEAN DEFAULT FALSE,
    cashback_rate DECIMAL(5,4),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (card_type_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 114. Cards
CREATE TABLE cards.cards (
    card_id INTEGER PRIMARY KEY IDENTITY,
    card_number_encrypted TEXT NOT NULL UNIQUE,
    card_number_hash VARCHAR(64) NOT NULL,
    customer_id INTEGER REFERENCES core.customers (customer_id),
    account_id INTEGER REFERENCES core.accounts (account_id),
    card_type_id INTEGER REFERENCES cards.card_types (card_type_id),
    issue_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    cvv_encrypted TEXT NOT NULL,
    pin_hash VARCHAR(128),
    card_status VARCHAR(20) DEFAULT 'ACTIVE',
    daily_limit DECIMAL(12,2),
    monthly_limit DECIMAL(15,2),
    credit_limit DECIMAL(15,2),
    available_credit DECIMAL(15,2),
    outstanding_balance DECIMAL(15,2) DEFAULT 0,
    last_used_date DATE,
    blocked_reason TEXT,
    replacement_card_id INTEGER REFERENCES cards.cards (card_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (customer_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 115. Card Transactions
CREATE TABLE cards.card_transactions (
    card_transaction_id INTEGER PRIMARY KEY IDENTITY,
    card_id INTEGER REFERENCES cards.cards (card_id),
    transaction_date TIMESTAMP NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    merchant_name VARCHAR(200),
    merchant_category_code VARCHAR(4),
    merchant_id VARCHAR(50),
    transaction_type VARCHAR(20), -- PURCHASE, WITHDRAWAL, REFUND
    authorization_code VARCHAR(20),
    response_code VARCHAR(4),
    settlement_date DATE,
    interchange_fee DECIMAL(8,2),
    processing_fee DECIMAL(8,2),
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    is_international BOOLEAN DEFAULT FALSE,
    is_contactless BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (card_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 116. Card Rewards
CREATE TABLE cards.card_rewards (
    reward_id INTEGER PRIMARY KEY IDENTITY,
    card_id INTEGER REFERENCES cards.cards (card_id),
    transaction_id BIGINT REFERENCES cards.card_transactions (card_transaction_id),
    points_earned DECIMAL(10,2),
    cashback_earned DECIMAL(8,2),
    reward_category VARCHAR(50),
    earning_rate DECIMAL(5,4),
    posting_date DATE,
    expiry_date DATE,
    is_redeemed BOOLEAN DEFAULT FALSE,
    redemption_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (card_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- Treasury Tables (Schema: treasury)
-- 117. Liquidity Management
CREATE TABLE treasury.liquidity_management (
    liquidity_id INTEGER PRIMARY KEY IDENTITY,
    measurement_date DATE NOT NULL UNIQUE,
    cash_position DECIMAL(18,2) NOT NULL,
    required_reserves DECIMAL(18,2),
    excess_reserves DECIMAL(18,2),
    overnight_deposits DECIMAL(18,2),
    short_term_investments DECIMAL(18,2),
    credit_facilities_available DECIMAL(18,2),
    credit_facilities_utilized DECIMAL(18,2),
    liquidity_ratio DECIMAL(8,4),
    funding_gap DECIMAL(18,2),
    stress_test_result DECIMAL(18,2),
    calculated_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (liquidity_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 118. Funding Sources
CREATE TABLE treasury.funding_sources (
    funding_source_id INTEGER PRIMARY KEY IDENTITY,
    source_name VARCHAR(100) NOT NULL,
    source_type VARCHAR(50) NOT NULL, -- DEPOSITS, BORROWING, EQUITY
    counterparty VARCHAR(200),
    amount DECIMAL(18,2) NOT NULL,
    cost_of_funds DECIMAL(8,4),
    maturity_date DATE,
    collateral_required BOOLEAN DEFAULT FALSE,
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    is_callable BOOLEAN DEFAULT FALSE,
    call_protection_end_date DATE,
    covenant_details TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (funding_source_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 119. Interest Rate Risk
CREATE TABLE treasury.interest_rate_risk (
    irr_id INTEGER PRIMARY KEY IDENTITY,
    measurement_date DATE NOT NULL,
    asset_duration DECIMAL(8,4),
    liability_duration DECIMAL(8,4),
    duration_gap DECIMAL(8,4),
    rate_shock_100bp DECIMAL(15,2),
    rate_shock_200bp DECIMAL(15,2),
    rate_shock_300bp DECIMAL(15,2),
    asset_liability_mismatch DECIMAL(18,2),
    interest_rate_sensitivity DECIMAL(15,2),
    hedge_effectiveness DECIMAL(5,4),
    calculated_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UNIQUE(measurement_date)
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (irr_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- Audit Tables (Schema: audit)
-- 120. Audit Trails
CREATE TABLE audit.audit_trails (
    audit_id INTEGER PRIMARY KEY IDENTITY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    operation VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    old_values VARIANT,
    new_values VARIANT,
    changed_by INTEGER REFERENCES core.employees (employee_id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    session_id VARCHAR(100),
    ip_address INET !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'SimpleDataType' NODE ***/!!!,
    user_agent TEXT
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (table_name)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- Additional Supporting Tables
-- 121. Holidays
CREATE TABLE core.holidays (
    holiday_id INTEGER PRIMARY KEY IDENTITY,
    holiday_name VARCHAR(100) NOT NULL,
    holiday_date DATE NOT NULL,
    country_id INTEGER REFERENCES core.countries (country_id),
    is_banking_holiday BOOLEAN DEFAULT TRUE,
    is_trading_holiday BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UNIQUE(holiday_date, country_id)
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (country_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 122. Business Calendar
CREATE TABLE core.business_calendar (
    calendar_date DATE PRIMARY KEY,
    is_business_day BOOLEAN NOT NULL,
    is_banking_day BOOLEAN NOT NULL,
    is_trading_day BOOLEAN NOT NULL,
    day_of_week INTEGER NOT NULL,
    month_end BOOLEAN DEFAULT FALSE,
    quarter_end BOOLEAN DEFAULT FALSE,
    year_end BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (calendar_date)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 123. System Parameters
CREATE TABLE core.system_parameters (
    parameter_id INTEGER PRIMARY KEY IDENTITY,
    parameter_name VARCHAR(100) NOT NULL UNIQUE,
    parameter_value TEXT NOT NULL,
    parameter_type VARCHAR(20) NOT NULL, -- STRING, INTEGER, DECIMAL, BOOLEAN
    description TEXT,
    category VARCHAR(50),
    is_encrypted BOOLEAN DEFAULT FALSE,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    modified_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (parameter_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 124. Error Logs
CREATE TABLE audit.error_logs (
    error_id INTEGER PRIMARY KEY IDENTITY,
    error_code VARCHAR(20),
    error_message TEXT NOT NULL,
    error_details TEXT,
    severity VARCHAR(20) DEFAULT 'ERROR', -- INFO, WARNING, ERROR, CRITICAL
    module VARCHAR(50),
    function_name VARCHAR(100),
    user_id INTEGER REFERENCES core.employees (employee_id),
    session_id VARCHAR(100),
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    resolved_at TIMESTAMP,
    resolved_by INTEGER REFERENCES core.employees (employee_id),
    resolution_notes TEXT
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (error_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 125. User Sessions
CREATE TABLE audit.user_sessions (
    session_id VARCHAR(100) PRIMARY KEY,
    user_id INTEGER REFERENCES core.employees (employee_id),
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    logout_time TIMESTAMP,
    ip_address INET !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'SimpleDataType' NODE ***/!!!,
    user_agent TEXT,
    session_duration INTEGER, -- in minutes
    is_active BOOLEAN DEFAULT TRUE,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (user_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 126. Batch Jobs
CREATE TABLE core.batch_jobs (
    job_id INTEGER PRIMARY KEY IDENTITY,
    job_name VARCHAR(100) NOT NULL,
    job_type VARCHAR(50) NOT NULL,
    schedule_expression VARCHAR(100),
    last_run_time TIMESTAMP,
    next_run_time TIMESTAMP,
    status VARCHAR(20) DEFAULT 'SCHEDULED',
    duration_seconds INTEGER,
    records_processed BIGINT,
    error_message TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (job_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 127. Notifications
CREATE TABLE core.notifications (
    notification_id INTEGER PRIMARY KEY IDENTITY,
    recipient_type VARCHAR(20) NOT NULL, -- USER, CUSTOMER, SYSTEM
    recipient_id INTEGER NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    priority VARCHAR(20) DEFAULT 'NORMAL',
    channel VARCHAR(20) DEFAULT 'EMAIL', -- EMAIL, SMS, PUSH, IN_APP
    status VARCHAR(20) DEFAULT 'PENDING',
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (recipient_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 128. Fee Structures
CREATE TABLE core.fee_structures (
    fee_structure_id INTEGER PRIMARY KEY IDENTITY,
    product_id INTEGER REFERENCES core.products (product_id),
    fee_type VARCHAR(50) NOT NULL,
    fee_name VARCHAR(100) NOT NULL,
    fee_amount DECIMAL(10,2),
    fee_percentage DECIMAL(8,4),
    minimum_fee DECIMAL(10,2),
    maximum_fee DECIMAL(10,2),
    frequency VARCHAR(20) DEFAULT 'PER_TRANSACTION',
    effective_date DATE NOT NULL,
    expiry_date DATE,
    is_waivable BOOLEAN DEFAULT FALSE,
    waiver_conditions TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (product_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 129. Customer Communications
CREATE TABLE core.customer_communications (
    communication_id INTEGER PRIMARY KEY IDENTITY,
    customer_id INTEGER REFERENCES core.customers (customer_id),
    communication_type VARCHAR(50) NOT NULL,
    subject VARCHAR(200),
    content TEXT NOT NULL,
    channel VARCHAR(20) NOT NULL,
    direction VARCHAR(10) NOT NULL, -- INBOUND, OUTBOUND
    status VARCHAR(20) DEFAULT 'SENT',
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    read_at TIMESTAMP,
    employee_id INTEGER REFERENCES core.employees (employee_id),
    template_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (customer_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 130. Interest Calculations
CREATE TABLE core.interest_calculations (
    calculation_id INTEGER PRIMARY KEY IDENTITY,
    account_id INTEGER REFERENCES core.accounts (account_id),
    calculation_date DATE NOT NULL,
    principal_amount DECIMAL(18,2) NOT NULL,
    interest_rate DECIMAL(8,4) NOT NULL,
    days_in_period INTEGER NOT NULL,
    interest_earned DECIMAL(12,4) NOT NULL,
    accrued_interest DECIMAL(12,4) NOT NULL,
    calculation_method VARCHAR(50),
    day_count_convention VARCHAR(20),
    calculated_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UNIQUE(account_id, calculation_date)
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (account_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;
COMMENT ON SCHEMA analytics IS 'Analytics and reporting tables for business intelligence and performance metrics';
COMMENT ON SCHEMA payment IS 'Payment processing tables for various payment methods and wire transfers';
COMMENT ON SCHEMA cards IS 'Card management tables for debit, credit, and prepaid cards';
COMMENT ON SCHEMA treasury IS 'Treasury management tables for liquidity and interest rate risk';
COMMENT ON SCHEMA audit IS 'Audit and logging tables for system monitoring and compliance';