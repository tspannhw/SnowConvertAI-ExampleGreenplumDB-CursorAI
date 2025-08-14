-- Loan and Credit Management Tables (Schema: loans)
-- Tables for loan origination, servicing, and credit management

\c financial_system;
SET search_path TO loans, core, risk, public;

-- 76. Loan Products
CREATE TABLE loans.loan_products (
    loan_product_id SERIAL PRIMARY KEY,
    product_code VARCHAR(20) NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    loan_type VARCHAR(50) NOT NULL, -- PERSONAL, MORTGAGE, AUTO, BUSINESS, etc.
    description TEXT,
    min_amount DECIMAL(15,2) NOT NULL,
    max_amount DECIMAL(15,2) NOT NULL,
    min_term_months INTEGER NOT NULL,
    max_term_months INTEGER NOT NULL,
    base_interest_rate DECIMAL(8,4) NOT NULL,
    rate_type VARCHAR(20) DEFAULT 'FIXED', -- FIXED, VARIABLE
    compounding_frequency VARCHAR(20) DEFAULT 'MONTHLY',
    payment_frequency VARCHAR(20) DEFAULT 'MONTHLY',
    processing_fee DECIMAL(10,2) DEFAULT 0,
    prepayment_penalty DECIMAL(8,4) DEFAULT 0,
    collateral_required BOOLEAN DEFAULT FALSE,
    guarantor_required BOOLEAN DEFAULT FALSE,
    min_credit_score INTEGER,
    max_ltv_ratio DECIMAL(5,4), -- Loan to Value
    max_dti_ratio DECIMAL(5,4), -- Debt to Income
    is_active BOOLEAN DEFAULT TRUE,
    launch_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_product_id);

-- 77. Loan Applications
CREATE TABLE loans.loan_applications (
    application_id SERIAL PRIMARY KEY,
    application_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INTEGER REFERENCES core.customers(customer_id),
    loan_product_id INTEGER REFERENCES loans.loan_products(loan_product_id),
    requested_amount DECIMAL(15,2) NOT NULL,
    requested_term_months INTEGER NOT NULL,
    loan_purpose TEXT,
    application_date DATE NOT NULL,
    application_status VARCHAR(20) DEFAULT 'SUBMITTED',
    current_stage VARCHAR(30) DEFAULT 'INITIAL_REVIEW',
    decision VARCHAR(20), -- APPROVED, DECLINED, REFERRED
    decision_date DATE,
    decision_amount DECIMAL(15,2),
    decision_term_months INTEGER,
    decision_rate DECIMAL(8,4),
    decline_reason TEXT,
    referred_to INTEGER REFERENCES core.employees(employee_id),
    assigned_underwriter INTEGER REFERENCES core.employees(employee_id),
    branch_id INTEGER REFERENCES core.branches(branch_id),
    channel VARCHAR(20) DEFAULT 'BRANCH', -- BRANCH, ONLINE, MOBILE, PHONE
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (customer_id);

-- 78. Loan Application Documents
CREATE TABLE loans.loan_application_documents (
    document_id SERIAL PRIMARY KEY,
    application_id INTEGER REFERENCES loans.loan_applications(application_id),
    document_type VARCHAR(50) NOT NULL,
    document_name VARCHAR(200) NOT NULL,
    file_path VARCHAR(500),
    file_size BIGINT,
    mime_type VARCHAR(100),
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    uploaded_by INTEGER,
    verification_status VARCHAR(20) DEFAULT 'PENDING',
    verified_by INTEGER REFERENCES core.employees(employee_id),
    verification_date TIMESTAMP,
    is_required BOOLEAN DEFAULT TRUE,
    expiry_date DATE
) DISTRIBUTED BY (application_id);

-- 79. Credit Scoring Models
CREATE TABLE loans.credit_scoring_models (
    model_id SERIAL PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    model_version VARCHAR(20) NOT NULL,
    model_type VARCHAR(50) NOT NULL, -- FICO, CUSTOM, BEHAVIORAL
    description TEXT,
    algorithm VARCHAR(50),
    variables_used TEXT[],
    score_range_min INTEGER NOT NULL,
    score_range_max INTEGER NOT NULL,
    approval_threshold INTEGER,
    created_by INTEGER REFERENCES core.employees(employee_id),
    approved_by INTEGER REFERENCES core.employees(employee_id),
    is_active BOOLEAN DEFAULT TRUE,
    effective_date DATE NOT NULL,
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(model_name, model_version)
) DISTRIBUTED BY (model_id);

-- 80. Credit Scores
CREATE TABLE loans.credit_scores (
    credit_score_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES core.customers(customer_id),
    application_id INTEGER REFERENCES loans.loan_applications(application_id),
    model_id INTEGER REFERENCES loans.credit_scoring_models(model_id),
    score_value INTEGER NOT NULL,
    score_date DATE NOT NULL,
    score_reason_codes TEXT[],
    bureau_name VARCHAR(50),
    bureau_reference VARCHAR(100),
    factors_affecting_score JSONB,
    calculated_by INTEGER REFERENCES core.employees(employee_id),
    is_latest BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (customer_id);

-- 81. Underwriting Criteria
CREATE TABLE loans.underwriting_criteria (
    criteria_id SERIAL PRIMARY KEY,
    loan_product_id INTEGER REFERENCES loans.loan_products(loan_product_id),
    criteria_name VARCHAR(100) NOT NULL,
    criteria_type VARCHAR(50) NOT NULL, -- INCOME, EMPLOYMENT, CREDIT, COLLATERAL
    operator VARCHAR(10) NOT NULL, -- >=, <=, =, IN, NOT_IN
    threshold_value VARCHAR(100) NOT NULL,
    weight_percentage DECIMAL(5,2),
    is_mandatory BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    effective_date DATE NOT NULL,
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_product_id);

-- 82. Underwriting Decisions
CREATE TABLE loans.underwriting_decisions (
    decision_id SERIAL PRIMARY KEY,
    application_id INTEGER REFERENCES loans.loan_applications(application_id),
    underwriter_id INTEGER REFERENCES core.employees(employee_id),
    decision_date DATE NOT NULL,
    decision VARCHAR(20) NOT NULL, -- APPROVE, DECLINE, REFER
    approved_amount DECIMAL(15,2),
    approved_term_months INTEGER,
    approved_rate DECIMAL(8,4),
    conditions TEXT[],
    decline_reasons TEXT[],
    risk_grade VARCHAR(10),
    probability_of_default DECIMAL(8,6),
    loss_given_default DECIMAL(5,4),
    expected_loss DECIMAL(15,2),
    comments TEXT,
    supervisor_approval_required BOOLEAN DEFAULT FALSE,
    approved_by INTEGER REFERENCES core.employees(employee_id),
    approval_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (application_id);

-- 83. Loans
CREATE TABLE loans.loans (
    loan_id SERIAL PRIMARY KEY,
    loan_number VARCHAR(30) NOT NULL UNIQUE,
    application_id INTEGER REFERENCES loans.loan_applications(application_id),
    customer_id INTEGER REFERENCES core.customers(customer_id),
    loan_product_id INTEGER REFERENCES loans.loan_products(loan_product_id),
    account_id INTEGER REFERENCES core.accounts(account_id),
    principal_amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(8,4) NOT NULL,
    term_months INTEGER NOT NULL,
    payment_amount DECIMAL(12,2) NOT NULL,
    payment_frequency VARCHAR(20) DEFAULT 'MONTHLY',
    loan_purpose TEXT,
    disbursement_date DATE NOT NULL,
    first_payment_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    current_balance DECIMAL(15,2) NOT NULL,
    principal_balance DECIMAL(15,2) NOT NULL,
    accrued_interest DECIMAL(12,2) DEFAULT 0,
    total_payments_made DECIMAL(15,2) DEFAULT 0,
    payments_made INTEGER DEFAULT 0,
    payments_remaining INTEGER,
    last_payment_date DATE,
    next_payment_date DATE,
    loan_status VARCHAR(20) DEFAULT 'ACTIVE',
    delinquency_status VARCHAR(20) DEFAULT 'CURRENT',
    days_past_due INTEGER DEFAULT 0,
    servicing_officer INTEGER REFERENCES core.employees(employee_id),
    originated_by INTEGER REFERENCES core.employees(employee_id),
    branch_id INTEGER REFERENCES core.branches(branch_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (customer_id);

-- 84. Loan Payments
CREATE TABLE loans.loan_payments (
    payment_id BIGSERIAL PRIMARY KEY,
    loan_id INTEGER REFERENCES loans.loans(loan_id),
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(12,2) NOT NULL,
    principal_amount DECIMAL(12,2) NOT NULL,
    interest_amount DECIMAL(12,2) NOT NULL,
    fees_amount DECIMAL(10,2) DEFAULT 0,
    penalty_amount DECIMAL(10,2) DEFAULT 0,
    payment_method VARCHAR(20) DEFAULT 'AUTO_DEBIT',
    payment_reference VARCHAR(100),
    payment_status VARCHAR(20) DEFAULT 'SUCCESSFUL',
    balance_after_payment DECIMAL(15,2),
    late_payment BOOLEAN DEFAULT FALSE,
    processed_by INTEGER REFERENCES core.employees(employee_id),
    transaction_id BIGINT REFERENCES core.transactions(transaction_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_id);

-- 85. Loan Schedules
CREATE TABLE loans.loan_schedules (
    schedule_id BIGSERIAL PRIMARY KEY,
    loan_id INTEGER REFERENCES loans.loans(loan_id),
    payment_number INTEGER NOT NULL,
    due_date DATE NOT NULL,
    payment_amount DECIMAL(12,2) NOT NULL,
    principal_amount DECIMAL(12,2) NOT NULL,
    interest_amount DECIMAL(12,2) NOT NULL,
    balance_after_payment DECIMAL(15,2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'SCHEDULED',
    actual_payment_date DATE,
    actual_payment_amount DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(loan_id, payment_number)
) DISTRIBUTED BY (loan_id);

-- 86. Collateral Types
CREATE TABLE loans.collateral_types (
    collateral_type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(20) NOT NULL UNIQUE,
    type_name VARCHAR(100) NOT NULL,
    description TEXT,
    valuation_frequency VARCHAR(20) DEFAULT 'ANNUAL',
    depreciation_rate DECIMAL(5,4) DEFAULT 0,
    margin_requirement DECIMAL(5,4) DEFAULT 0.2,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (collateral_type_id);

-- 87. Loan Collateral
CREATE TABLE loans.loan_collateral (
    collateral_id SERIAL PRIMARY KEY,
    loan_id INTEGER REFERENCES loans.loans(loan_id),
    collateral_type_id INTEGER REFERENCES loans.collateral_types(collateral_type_id),
    description TEXT NOT NULL,
    current_value DECIMAL(15,2) NOT NULL,
    appraised_value DECIMAL(15,2),
    ltv_ratio DECIMAL(5,4),
    appraisal_date DATE,
    next_appraisal_date DATE,
    appraiser_name VARCHAR(200),
    insurance_required BOOLEAN DEFAULT FALSE,
    insurance_policy_number VARCHAR(100),
    insurance_expiry_date DATE,
    collateral_status VARCHAR(20) DEFAULT 'ACTIVE',
    lien_position INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_id);

-- 88. Loan Guarantors
CREATE TABLE loans.loan_guarantors (
    guarantor_id SERIAL PRIMARY KEY,
    loan_id INTEGER REFERENCES loans.loans(loan_id),
    guarantor_customer_id INTEGER REFERENCES core.customers(customer_id),
    guarantee_amount DECIMAL(15,2) NOT NULL,
    guarantee_percentage DECIMAL(5,4) DEFAULT 100.00,
    guarantee_type VARCHAR(20) DEFAULT 'PERSONAL', -- PERSONAL, CORPORATE
    guarantee_start_date DATE NOT NULL,
    guarantee_end_date DATE,
    guarantor_status VARCHAR(20) DEFAULT 'ACTIVE',
    guarantee_document_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_id);

-- 89. Loan Modifications
CREATE TABLE loans.loan_modifications (
    modification_id SERIAL PRIMARY KEY,
    loan_id INTEGER REFERENCES loans.loans(loan_id),
    modification_type VARCHAR(50) NOT NULL, -- RATE_CHANGE, TERM_EXTENSION, PAYMENT_REDUCTION
    modification_date DATE NOT NULL,
    reason TEXT NOT NULL,
    old_interest_rate DECIMAL(8,4),
    new_interest_rate DECIMAL(8,4),
    old_term_months INTEGER,
    new_term_months INTEGER,
    old_payment_amount DECIMAL(12,2),
    new_payment_amount DECIMAL(12,2),
    old_maturity_date DATE,
    new_maturity_date DATE,
    modification_fee DECIMAL(10,2) DEFAULT 0,
    approved_by INTEGER REFERENCES core.employees(employee_id),
    effective_date DATE NOT NULL,
    modification_status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_id);

-- 90. Delinquency Tracking
CREATE TABLE loans.delinquency_tracking (
    delinquency_id SERIAL PRIMARY KEY,
    loan_id INTEGER REFERENCES loans.loans(loan_id),
    delinquency_date DATE NOT NULL,
    days_past_due INTEGER NOT NULL,
    delinquency_bucket VARCHAR(20) NOT NULL, -- 1-30, 31-60, 61-90, 90+
    outstanding_amount DECIMAL(15,2) NOT NULL,
    late_fees_assessed DECIMAL(10,2) DEFAULT 0,
    collection_status VARCHAR(30) DEFAULT 'INITIAL_CONTACT',
    last_contact_date DATE,
    next_contact_date DATE,
    contact_method VARCHAR(20),
    collection_notes TEXT,
    payment_plan_offered BOOLEAN DEFAULT FALSE,
    payment_plan_accepted BOOLEAN DEFAULT FALSE,
    assigned_collector INTEGER REFERENCES core.employees(employee_id),
    resolved_date DATE,
    resolution_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_id);

-- 91. Charge-offs
CREATE TABLE loans.charge_offs (
    charge_off_id SERIAL PRIMARY KEY,
    loan_id INTEGER REFERENCES loans.loans(loan_id),
    charge_off_date DATE NOT NULL,
    charge_off_amount DECIMAL(15,2) NOT NULL,
    outstanding_principal DECIMAL(15,2) NOT NULL,
    outstanding_interest DECIMAL(12,2) NOT NULL,
    outstanding_fees DECIMAL(10,2) NOT NULL,
    recovery_expected DECIMAL(15,2) DEFAULT 0,
    charge_off_reason TEXT,
    approved_by INTEGER REFERENCES core.employees(employee_id),
    gl_account_id INTEGER REFERENCES core.gl_accounts(gl_account_id),
    write_off_percentage DECIMAL(5,2) DEFAULT 100.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_id);

-- 92. Recovery Tracking
CREATE TABLE loans.recovery_tracking (
    recovery_id SERIAL PRIMARY KEY,
    charge_off_id INTEGER REFERENCES loans.charge_offs(charge_off_id),
    recovery_date DATE NOT NULL,
    recovery_amount DECIMAL(12,2) NOT NULL,
    recovery_method VARCHAR(50), -- PAYMENT, ASSET_SALE, LEGAL_SETTLEMENT
    recovery_description TEXT,
    recovery_costs DECIMAL(10,2) DEFAULT 0,
    net_recovery DECIMAL(12,2),
    collection_agency VARCHAR(200),
    legal_firm VARCHAR(200),
    processed_by INTEGER REFERENCES core.employees(employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (charge_off_id);

-- 93. Loan Provisions
CREATE TABLE loans.loan_provisions (
    provision_id SERIAL PRIMARY KEY,
    loan_id INTEGER REFERENCES loans.loans(loan_id),
    provision_date DATE NOT NULL,
    provision_type VARCHAR(30) NOT NULL, -- SPECIFIC, GENERAL, COLLECTIVE
    provision_amount DECIMAL(15,2) NOT NULL,
    provision_percentage DECIMAL(8,4) NOT NULL,
    outstanding_balance DECIMAL(15,2) NOT NULL,
    probability_of_default DECIMAL(8,6),
    loss_given_default DECIMAL(5,4),
    calculation_method VARCHAR(50),
    regulatory_requirement VARCHAR(100),
    approved_by INTEGER REFERENCES core.employees(employee_id),
    gl_account_id INTEGER REFERENCES core.gl_accounts(gl_account_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_id);

-- 94. Interest Rate Models
CREATE TABLE loans.interest_rate_models (
    model_id SERIAL PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    model_type VARCHAR(50) NOT NULL, -- PRIME_PLUS, LIBOR_PLUS, FIXED
    base_rate_source VARCHAR(50),
    margin DECIMAL(8,4) DEFAULT 0,
    floor_rate DECIMAL(8,4),
    ceiling_rate DECIMAL(8,4),
    reset_frequency VARCHAR(20), -- MONTHLY, QUARTERLY, ANNUALLY
    calculation_method TEXT,
    effective_date DATE NOT NULL,
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (model_id);

-- 95. Loan Pricing
CREATE TABLE loans.loan_pricing (
    pricing_id SERIAL PRIMARY KEY,
    loan_product_id INTEGER REFERENCES loans.loan_products(loan_product_id),
    customer_segment VARCHAR(50), -- PRIME, NEAR_PRIME, SUBPRIME
    credit_score_min INTEGER,
    credit_score_max INTEGER,
    ltv_ratio_min DECIMAL(5,4),
    ltv_ratio_max DECIMAL(5,4),
    dti_ratio_min DECIMAL(5,4),
    dti_ratio_max DECIMAL(5,4),
    base_rate DECIMAL(8,4) NOT NULL,
    margin DECIMAL(8,4) NOT NULL,
    final_rate DECIMAL(8,4) NOT NULL,
    processing_fee DECIMAL(10,2) DEFAULT 0,
    origination_fee DECIMAL(8,4) DEFAULT 0,
    effective_date DATE NOT NULL,
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_product_id);

-- 96. Servicing Rights
CREATE TABLE loans.servicing_rights (
    servicing_rights_id SERIAL PRIMARY KEY,
    loan_id INTEGER REFERENCES loans.loans(loan_id),
    servicer_name VARCHAR(200) NOT NULL,
    servicing_start_date DATE NOT NULL,
    servicing_end_date DATE,
    servicing_fee_rate DECIMAL(8,4) NOT NULL,
    servicing_type VARCHAR(20) DEFAULT 'FULL', -- FULL, SUB_SERVICING
    contact_information JSONB,
    servicing_agreement_path VARCHAR(500),
    transfer_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_id);

-- 97. Escrow Accounts
CREATE TABLE loans.escrow_accounts (
    escrow_account_id SERIAL PRIMARY KEY,
    loan_id INTEGER REFERENCES loans.loans(loan_id),
    account_id INTEGER REFERENCES core.accounts(account_id),
    escrow_type VARCHAR(50) NOT NULL, -- TAXES, INSURANCE, PMI
    monthly_payment DECIMAL(10,2) NOT NULL,
    current_balance DECIMAL(12,2) DEFAULT 0,
    target_balance DECIMAL(12,2),
    shortage_amount DECIMAL(10,2) DEFAULT 0,
    surplus_amount DECIMAL(10,2) DEFAULT 0,
    last_analysis_date DATE,
    next_analysis_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_id);

-- 98. Escrow Transactions
CREATE TABLE loans.escrow_transactions (
    escrow_transaction_id BIGSERIAL PRIMARY KEY,
    escrow_account_id INTEGER REFERENCES loans.escrow_accounts(escrow_account_id),
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(20) NOT NULL, -- DEPOSIT, PAYMENT, REFUND
    amount DECIMAL(10,2) NOT NULL,
    payee VARCHAR(200),
    description TEXT,
    balance_after DECIMAL(12,2),
    transaction_reference VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (escrow_account_id);

-- 99. Loan Performance Analytics
CREATE TABLE loans.loan_performance_analytics (
    analytics_id BIGSERIAL PRIMARY KEY,
    loan_id INTEGER REFERENCES loans.loans(loan_id),
    analysis_date DATE NOT NULL,
    payment_pattern VARCHAR(20), -- CONSISTENT, IRREGULAR, DECLINING
    payment_velocity DECIMAL(8,4), -- Days early/late on average
    credit_utilization DECIMAL(5,4),
    debt_service_coverage DECIMAL(8,4),
    probability_of_prepayment DECIMAL(8,6),
    probability_of_default DECIMAL(8,6),
    behavioral_score INTEGER,
    risk_migration VARCHAR(20), -- IMPROVING, STABLE, DETERIORATING
    early_warning_signals TEXT[],
    recommended_actions TEXT[],
    calculated_by INTEGER REFERENCES core.employees(employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (loan_id);

-- 100. Credit Lines
CREATE TABLE loans.credit_lines (
    credit_line_id SERIAL PRIMARY KEY,
    credit_line_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INTEGER REFERENCES core.customers(customer_id),
    account_id INTEGER REFERENCES core.accounts(account_id),
    credit_limit DECIMAL(15,2) NOT NULL,
    available_credit DECIMAL(15,2) NOT NULL,
    outstanding_balance DECIMAL(15,2) DEFAULT 0,
    interest_rate DECIMAL(8,4) NOT NULL,
    cash_advance_rate DECIMAL(8,4),
    cash_advance_limit DECIMAL(12,2),
    minimum_payment_percentage DECIMAL(5,4) DEFAULT 0.02,
    over_limit_fee DECIMAL(8,2) DEFAULT 0,
    annual_fee DECIMAL(10,2) DEFAULT 0,
    line_type VARCHAR(20) DEFAULT 'REVOLVING', -- REVOLVING, NON_REVOLVING
    security_type VARCHAR(20) DEFAULT 'UNSECURED', -- SECURED, UNSECURED
    approval_date DATE NOT NULL,
    expiry_date DATE,
    last_review_date DATE,
    next_review_date DATE,
    credit_line_status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (customer_id);

COMMENT ON SCHEMA loans IS 'Loan and credit management tables for origination, servicing, and risk management';
