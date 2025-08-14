-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '4' COLUMN '1' OF THE SOURCE CODE STARTING AT '\'. EXPECTED 'STATEMENT' GRAMMAR. **
---- Risk Management and Compliance Tables (Schema: risk, compliance)
---- Tables for risk assessment, monitoring, and regulatory compliance

--\c financial_system
                   ;
--** SSC-FDM-PG0006 - SET SEARCH PATH WITH MULTIPLE SCHEMAS IS NOT SUPPORTED IN SNOWFLAKE **
USE SCHEMA risk /*, compliance, core, trading, public*/;

-- Risk Management Tables
-- 51. Risk Categories
CREATE TABLE risk.risk_categories (
    risk_category_id INTEGER PRIMARY KEY IDENTITY,
    category_code VARCHAR(10) NOT NULL UNIQUE,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INTEGER REFERENCES risk.risk_categories (risk_category_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (risk_category_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 52. Risk Factors
CREATE TABLE risk.risk_factors (
    risk_factor_id INTEGER PRIMARY KEY IDENTITY,
    factor_code VARCHAR(20) NOT NULL UNIQUE,
    factor_name VARCHAR(100) NOT NULL,
    risk_category_id INTEGER REFERENCES risk.risk_categories (risk_category_id),
    description TEXT,
    measurement_unit VARCHAR(20),
    data_source VARCHAR(100),
    update_frequency VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (risk_factor_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 53. Risk Models
CREATE TABLE risk.risk_models (
    risk_model_id INTEGER PRIMARY KEY IDENTITY,
    model_name VARCHAR(100) NOT NULL,
    model_type VARCHAR(50) NOT NULL, -- VAR, STRESS_TEST, SCENARIO
    version VARCHAR(20) NOT NULL,
    description TEXT,
    methodology TEXT,
    confidence_level DECIMAL(5,4),
    time_horizon INTEGER, -- in days
    created_by INTEGER REFERENCES core.employees (employee_id),
    approved_by INTEGER REFERENCES core.employees (employee_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UNIQUE(model_name, version)
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (risk_model_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 54. Risk Limits
CREATE TABLE risk.risk_limits (
    risk_limit_id INTEGER PRIMARY KEY IDENTITY,
    limit_name VARCHAR(100) NOT NULL,
    limit_type VARCHAR(50) NOT NULL, -- EXPOSURE, VAR, CONCENTRATION
    entity_type VARCHAR(20) NOT NULL, -- CUSTOMER, PORTFOLIO, DESK, FIRM
    entity_id INTEGER NOT NULL,
    risk_factor_id INTEGER REFERENCES risk.risk_factors (risk_factor_id),
    limit_amount DECIMAL(18,2) NOT NULL,
    warning_threshold DECIMAL(5,4) DEFAULT 0.8,
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    effective_date DATE NOT NULL,
    expiry_date DATE,
    approved_by INTEGER REFERENCES core.employees (employee_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (entity_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 55. Risk Measurements
CREATE TABLE risk.risk_measurements (
    measurement_id INTEGER PRIMARY KEY IDENTITY,
    entity_type VARCHAR(20) NOT NULL,
    entity_id INTEGER NOT NULL,
    risk_factor_id INTEGER REFERENCES risk.risk_factors (risk_factor_id),
    risk_model_id INTEGER REFERENCES risk.risk_models (risk_model_id),
    measurement_date DATE NOT NULL,
    measurement_value DECIMAL(18,6) NOT NULL,
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    confidence_level DECIMAL(5,4),
    time_horizon INTEGER,
    calculated_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UNIQUE(entity_type, entity_id, risk_factor_id, measurement_date)
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (entity_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 56. Risk Limit Breaches
CREATE TABLE risk.risk_limit_breaches (
    breach_id INTEGER PRIMARY KEY IDENTITY,
    risk_limit_id INTEGER REFERENCES risk.risk_limits (risk_limit_id),
    measurement_id BIGINT REFERENCES risk.risk_measurements (measurement_id),
    breach_date DATE NOT NULL,
    breach_amount DECIMAL(18,2) NOT NULL,
    excess_amount DECIMAL(18,2) NOT NULL,
    severity VARCHAR(20) DEFAULT 'MEDIUM', -- LOW, MEDIUM, HIGH, CRITICAL
    status VARCHAR(20) DEFAULT 'OPEN', -- OPEN, ACKNOWLEDGED, RESOLVED
    reported_to VARCHAR(100),
    action_taken TEXT,
    resolved_date DATE,
    resolved_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (risk_limit_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 57. Stress Test Scenarios
CREATE TABLE risk.stress_test_scenarios (
    scenario_id INTEGER PRIMARY KEY IDENTITY,
    scenario_name VARCHAR(100) NOT NULL,
    scenario_type VARCHAR(50) NOT NULL, -- HISTORICAL, HYPOTHETICAL, REGULATORY
    description TEXT NOT NULL,
    effective_date DATE NOT NULL,
    expiry_date DATE,
    shock_parameters VARIANT,
    regulatory_requirement VARCHAR(100),
    created_by INTEGER REFERENCES core.employees (employee_id),
    approved_by INTEGER REFERENCES core.employees (employee_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (scenario_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 58. Stress Test Results
CREATE TABLE risk.stress_test_results (
    result_id INTEGER PRIMARY KEY IDENTITY,
    scenario_id INTEGER REFERENCES risk.stress_test_scenarios (scenario_id),
    portfolio_id INTEGER REFERENCES trading.portfolios (portfolio_id),
    test_date DATE NOT NULL,
    base_value DECIMAL(18,2) NOT NULL,
    stressed_value DECIMAL(18,2) NOT NULL,
    pnl_impact DECIMAL(18,2) NOT NULL,
    percentage_impact DECIMAL(8,4) NOT NULL,
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    calculated_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (portfolio_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 59. Credit Ratings
CREATE TABLE risk.credit_ratings (
    rating_id INTEGER PRIMARY KEY IDENTITY,
    entity_type VARCHAR(20) NOT NULL, -- CUSTOMER, ISSUER, COUNTERPARTY
    entity_id INTEGER NOT NULL,
    rating_agency VARCHAR(50) NOT NULL,
    rating_scale VARCHAR(20) NOT NULL,
    current_rating VARCHAR(10) NOT NULL,
    previous_rating VARCHAR(10),
    rating_date DATE NOT NULL,
    outlook VARCHAR(20), -- STABLE, POSITIVE, NEGATIVE, DEVELOPING
    watch_status VARCHAR(20), -- POSITIVE, NEGATIVE, DEVELOPING
    probability_of_default DECIMAL(8,6),
    loss_given_default DECIMAL(5,4),
    effective_date DATE NOT NULL,
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (entity_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 60. Counterparty Risk
CREATE TABLE risk.counterparty_risk (
    counterparty_risk_id INTEGER PRIMARY KEY IDENTITY,
    counterparty_id INTEGER NOT NULL,
    counterparty_type VARCHAR(20) NOT NULL, -- BANK, BROKER, CORPORATE
    exposure_amount DECIMAL(18,2) NOT NULL,
    collateral_amount DECIMAL(18,2) DEFAULT 0,
    net_exposure DECIMAL(18,2) NOT NULL,
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    measurement_date DATE NOT NULL,
    netting_agreement BOOLEAN DEFAULT FALSE,
    master_agreement VARCHAR(50),
    credit_limit DECIMAL(18,2),
    utilization_percentage DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (counterparty_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- Compliance Tables
-- 61. Regulatory Authorities
CREATE TABLE compliance.regulatory_authorities (
    authority_id INTEGER PRIMARY KEY IDENTITY,
    authority_code VARCHAR(10) NOT NULL UNIQUE,
    authority_name VARCHAR(100) NOT NULL,
    country_id INTEGER REFERENCES core.countries (country_id),
    website VARCHAR(255),
    contact_info VARIANT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (authority_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 62. Regulations
CREATE TABLE compliance.regulations (
    regulation_id INTEGER PRIMARY KEY IDENTITY,
    regulation_code VARCHAR(20) NOT NULL UNIQUE,
    regulation_name VARCHAR(200) NOT NULL,
    authority_id INTEGER REFERENCES compliance.regulatory_authorities (authority_id),
    description TEXT,
    effective_date DATE NOT NULL,
    expiry_date DATE,
    applicable_jurisdictions ARRAY /*** SSC-FDM-PG0016 - STRONGLY TYPED ARRAY 'TEXT[]' TRANSFORMED TO ARRAY WITHOUT TYPE CHECKING ***/,
    regulation_type VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (regulation_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 63. Compliance Requirements
CREATE TABLE compliance.compliance_requirements (
    requirement_id INTEGER PRIMARY KEY IDENTITY,
    regulation_id INTEGER REFERENCES compliance.regulations (regulation_id),
    requirement_code VARCHAR(30) NOT NULL,
    requirement_name VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    compliance_frequency VARCHAR(20), -- DAILY, WEEKLY, MONTHLY, QUARTERLY, ANNUAL
    due_date_calculation TEXT,
    penalty_description TEXT,
    is_mandatory BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (requirement_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 64. Compliance Monitoring
CREATE TABLE compliance.compliance_monitoring (
    monitoring_id INTEGER PRIMARY KEY IDENTITY,
    requirement_id INTEGER REFERENCES compliance.compliance_requirements (requirement_id),
    entity_type VARCHAR(20) NOT NULL,
    entity_id INTEGER NOT NULL,
    monitoring_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, COMPLIANT, NON_COMPLIANT, OVERDUE
    compliance_percentage DECIMAL(5,2),
    findings TEXT,
    remediation_required BOOLEAN DEFAULT FALSE,
    remediation_deadline DATE,
    monitored_by INTEGER REFERENCES core.employees (employee_id),
    reviewed_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (entity_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 65. AML Alerts
CREATE TABLE compliance.aml_alerts (
    alert_id INTEGER PRIMARY KEY IDENTITY,
    customer_id INTEGER REFERENCES core.customers (customer_id),
    account_id INTEGER REFERENCES core.accounts (account_id),
    transaction_id BIGINT REFERENCES core.transactions (transaction_id),
    alert_type VARCHAR(50) NOT NULL,
    alert_priority VARCHAR(20) DEFAULT 'MEDIUM',
    alert_date TIMESTAMP NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(18,2),
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    pattern_detected VARCHAR(100),
    rule_triggered VARCHAR(100),
    false_positive BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'OPEN', -- OPEN, INVESTIGATING, CLOSED, ESCALATED
    assigned_to INTEGER REFERENCES core.employees (employee_id),
    investigation_notes TEXT,
    resolution TEXT,
    closed_date TIMESTAMP,
    closed_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (customer_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 66. KYC Documents
CREATE TABLE compliance.kyc_documents (
    document_id INTEGER PRIMARY KEY IDENTITY,
    customer_id INTEGER REFERENCES core.customers (customer_id),
    document_type VARCHAR(50) NOT NULL,
    document_number VARCHAR(100),
    issuing_authority VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    document_path VARCHAR(500),
    verification_status VARCHAR(20) DEFAULT 'PENDING',
    verified_by INTEGER REFERENCES core.employees (employee_id),
    verification_date TIMESTAMP,
    verification_notes TEXT,
    is_valid BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (customer_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 67. Sanctions Lists
CREATE TABLE compliance.sanctions_lists (
    sanctions_list_id INTEGER PRIMARY KEY IDENTITY,
    list_name VARCHAR(100) NOT NULL,
    list_type VARCHAR(50) NOT NULL, -- SDN, PEP, OFAC, etc.
    authority_id INTEGER REFERENCES compliance.regulatory_authorities (authority_id),
    description TEXT,
    update_frequency VARCHAR(20),
    last_updated DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (sanctions_list_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 68. Sanctions Entries
CREATE TABLE compliance.sanctions_entries (
    entry_id INTEGER PRIMARY KEY IDENTITY,
    sanctions_list_id INTEGER REFERENCES compliance.sanctions_lists (sanctions_list_id),
    entity_name VARCHAR(200) NOT NULL,
    entity_type VARCHAR(20), -- INDIVIDUAL, ENTITY, VESSEL, AIRCRAFT
    aliases ARRAY /*** SSC-FDM-PG0016 - STRONGLY TYPED ARRAY 'TEXT[]' TRANSFORMED TO ARRAY WITHOUT TYPE CHECKING ***/,
    identification_numbers ARRAY /*** SSC-FDM-PG0016 - STRONGLY TYPED ARRAY 'TEXT[]' TRANSFORMED TO ARRAY WITHOUT TYPE CHECKING ***/,
    addresses ARRAY /*** SSC-FDM-PG0016 - STRONGLY TYPED ARRAY 'TEXT[]' TRANSFORMED TO ARRAY WITHOUT TYPE CHECKING ***/,
    birth_date DATE,
    nationality VARCHAR(100),
    designation TEXT,
    listing_date DATE,
    delisting_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (entry_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 69. Sanctions Screening
CREATE TABLE compliance.sanctions_screening (
    screening_id INTEGER PRIMARY KEY IDENTITY,
    entity_type VARCHAR(20) NOT NULL, -- CUSTOMER, TRANSACTION, WIRE
    entity_id BIGINT NOT NULL,
    screening_date TIMESTAMP NOT NULL,
    screening_system VARCHAR(50),
    match_found BOOLEAN DEFAULT FALSE,
    match_score DECIMAL(5,2),
    matched_entry_id INTEGER REFERENCES compliance.sanctions_entries (entry_id),
    false_positive BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, CLEARED, BLOCKED
    reviewed_by INTEGER REFERENCES core.employees (employee_id),
    review_date TIMESTAMP,
    review_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (entity_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 70. Regulatory Reports
CREATE TABLE compliance.regulatory_reports (
    report_id INTEGER PRIMARY KEY IDENTITY,
    regulation_id INTEGER REFERENCES compliance.regulations (regulation_id),
    report_name VARCHAR(200) NOT NULL,
    reporting_period_start DATE NOT NULL,
    reporting_period_end DATE NOT NULL,
    submission_deadline DATE NOT NULL,
    report_format VARCHAR(20), -- XML, JSON, CSV, PDF
    report_status VARCHAR(20) DEFAULT 'DRAFT',
    report_data VARIANT,
    file_path VARCHAR(500),
    submitted_date TIMESTAMP,
    submitted_by INTEGER REFERENCES core.employees (employee_id),
    acknowledgment_number VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (report_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 71. Market Abuse Monitoring
CREATE TABLE compliance.market_abuse_monitoring (
    monitoring_id INTEGER PRIMARY KEY IDENTITY,
    security_id INTEGER REFERENCES trading.securities (security_id),
    customer_id INTEGER REFERENCES core.customers (customer_id),
    employee_id INTEGER REFERENCES core.employees (employee_id),
    monitoring_date DATE NOT NULL,
    alert_type VARCHAR(50) NOT NULL, -- INSIDER_TRADING, FRONT_RUNNING, LAYERING
    description TEXT,
    transactions_involved ARRAY /*** SSC-FDM-PG0016 - STRONGLY TYPED ARRAY 'BIGINT[]' TRANSFORMED TO ARRAY WITHOUT TYPE CHECKING ***/,
    suspected_profit DECIMAL(18,2),
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    evidence_collected TEXT,
    investigation_status VARCHAR(20) DEFAULT 'OPEN',
    assigned_investigator INTEGER REFERENCES core.employees (employee_id),
    resolution TEXT,
    closed_date DATE,
    regulatory_reporting_required BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (customer_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 72. Trade Surveillance Rules
CREATE TABLE compliance.trade_surveillance_rules (
    rule_id INTEGER PRIMARY KEY IDENTITY,
    rule_name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    rule_logic TEXT NOT NULL,
    parameters VARIANT,
    threshold_values VARIANT,
    applicable_securities ARRAY /*** SSC-FDM-PG0016 - STRONGLY TYPED ARRAY 'TEXT[]' TRANSFORMED TO ARRAY WITHOUT TYPE CHECKING ***/, -- Asset classes or specific securities
    is_active BOOLEAN DEFAULT TRUE,
    created_by INTEGER REFERENCES core.employees (employee_id),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (rule_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 73. Operational Risk Events
CREATE TABLE risk.operational_risk_events (
    event_id INTEGER PRIMARY KEY IDENTITY,
    event_date DATE NOT NULL,
    discovery_date DATE NOT NULL,
    event_type VARCHAR(50) NOT NULL, -- FRAUD, SYSTEM_FAILURE, HUMAN_ERROR
    business_line VARCHAR(50),
    department VARCHAR(50),
    description TEXT NOT NULL,
    root_cause TEXT,
    gross_loss DECIMAL(18,2) DEFAULT 0,
    recovery_amount DECIMAL(18,2) DEFAULT 0,
    net_loss DECIMAL(18,2) DEFAULT 0,
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    severity VARCHAR(20) DEFAULT 'MEDIUM',
    impact_assessment TEXT,
    corrective_actions TEXT,
    status VARCHAR(20) DEFAULT 'OPEN',
    reported_by INTEGER REFERENCES core.employees (employee_id),
    assigned_to INTEGER REFERENCES core.employees (employee_id),
    closed_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (event_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 74. Basel Requirements
CREATE TABLE compliance.basel_requirements (
    basel_requirement_id INTEGER PRIMARY KEY IDENTITY,
    requirement_code VARCHAR(20) NOT NULL UNIQUE,
    requirement_name VARCHAR(200) NOT NULL,
    basel_version VARCHAR(10), -- BASEL_I, BASEL_II, BASEL_III
    pillar INTEGER
                   !!!RESOLVE EWI!!! /*** SSC-EWI-0035 - CHECK STATEMENT NOT SUPPORTED ***/!!! CHECK (pillar IN (1, 2, 3)),
    description TEXT,
    calculation_methodology TEXT,
    minimum_ratio DECIMAL(8,4),
    target_ratio DECIMAL(8,4),
    effective_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (basel_requirement_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;

-- 75. Capital Adequacy
CREATE TABLE risk.capital_adequacy (
    capital_adequacy_id INTEGER PRIMARY KEY IDENTITY,
    calculation_date DATE NOT NULL,
    tier1_capital DECIMAL(18,2) NOT NULL,
    tier2_capital DECIMAL(18,2) NOT NULL,
    total_capital DECIMAL(18,2) NOT NULL,
    risk_weighted_assets DECIMAL(18,2) NOT NULL,
    leverage_exposure DECIMAL(18,2) NOT NULL,
    cet1_ratio DECIMAL(8,4) NOT NULL,
    tier1_ratio DECIMAL(8,4) NOT NULL,
    total_capital_ratio DECIMAL(8,4) NOT NULL,
    leverage_ratio DECIMAL(8,4) NOT NULL,
    currency_code CHAR(3) REFERENCES core.currencies (currency_code),
    calculated_by INTEGER REFERENCES core.employees (employee_id),
    approved_by INTEGER REFERENCES core.employees (employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
--** SSC-FDM-GP0001 - THE PERFORMANCE OF THE CLUSTER BY MAY VARY COMPARED TO THE PERFORMANCE OF DISTRIBUTED BY **
CLUSTER BY (capital_adequacy_id)
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
;
COMMENT ON SCHEMA risk IS 'Risk management tables for measuring, monitoring and managing various types of financial risks';
COMMENT ON SCHEMA compliance IS 'Compliance and regulatory tables for AML, KYC, sanctions screening, and regulatory reporting';