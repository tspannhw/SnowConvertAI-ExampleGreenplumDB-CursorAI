-- Core Banking Tables (Schema: core)
-- These tables form the foundation of the financial system

\c financial_system;
SET search_path TO core, public;

-- 1. Countries
CREATE TABLE core.countries (
    country_id SERIAL PRIMARY KEY,
    country_code CHAR(2) NOT NULL UNIQUE,
    country_name VARCHAR(100) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    phone_code VARCHAR(10),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (country_id);

-- 2. States/Provinces
CREATE TABLE core.states (
    state_id SERIAL PRIMARY KEY,
    country_id INTEGER REFERENCES core.countries(country_id),
    state_code VARCHAR(10) NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (state_id);

-- 3. Cities
CREATE TABLE core.cities (
    city_id SERIAL PRIMARY KEY,
    state_id INTEGER REFERENCES core.states(state_id),
    city_name VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (city_id);

-- 4. Currency Master
CREATE TABLE core.currencies (
    currency_code CHAR(3) PRIMARY KEY,
    currency_name VARCHAR(50) NOT NULL,
    currency_symbol VARCHAR(5),
    decimal_places INTEGER DEFAULT 2,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (currency_code);

-- 5. Exchange Rates
CREATE TABLE core.exchange_rates (
    exchange_rate_id SERIAL PRIMARY KEY,
    from_currency CHAR(3) REFERENCES core.currencies(currency_code),
    to_currency CHAR(3) REFERENCES core.currencies(currency_code),
    rate DECIMAL(18,8) NOT NULL,
    effective_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(from_currency, to_currency, effective_date)
) DISTRIBUTED BY (exchange_rate_id);

-- 6. Customer Types
CREATE TABLE core.customer_types (
    customer_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (customer_type_id);

-- 7. Customer Status
CREATE TABLE core.customer_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (status_id);

-- 8. Customers
CREATE TABLE core.customers (
    customer_id SERIAL PRIMARY KEY,
    customer_number VARCHAR(20) NOT NULL UNIQUE,
    customer_type_id INTEGER REFERENCES core.customer_types(customer_type_id),
    status_id INTEGER REFERENCES core.customer_status(status_id),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    middle_name VARCHAR(100),
    date_of_birth DATE,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
    ssn_encrypted TEXT,
    tax_id VARCHAR(50),
    email VARCHAR(255),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    preferred_language VARCHAR(10) DEFAULT 'EN',
    kyc_status VARCHAR(20) DEFAULT 'PENDING',
    risk_rating VARCHAR(20) DEFAULT 'LOW',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER
) DISTRIBUTED BY (customer_id);

-- 9. Customer Addresses
CREATE TABLE core.customer_addresses (
    address_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES core.customers(customer_id),
    address_type VARCHAR(20) DEFAULT 'HOME',
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city_id INTEGER REFERENCES core.cities(city_id),
    postal_code VARCHAR(20),
    is_primary BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (customer_id);

-- 10. Branch Master
CREATE TABLE core.branches (
    branch_id SERIAL PRIMARY KEY,
    branch_code VARCHAR(20) NOT NULL UNIQUE,
    branch_name VARCHAR(100) NOT NULL,
    branch_type VARCHAR(20) DEFAULT 'FULL_SERVICE',
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city_id INTEGER REFERENCES core.cities(city_id),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(255),
    manager_employee_id INTEGER,
    opening_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (branch_id);

-- 11. Account Types
CREATE TABLE core.account_types (
    account_type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(10) NOT NULL UNIQUE,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    min_balance DECIMAL(15,2) DEFAULT 0,
    interest_rate DECIMAL(5,4) DEFAULT 0,
    maintenance_fee DECIMAL(10,2) DEFAULT 0,
    is_interest_bearing BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (account_type_id);

-- 12. Account Status
CREATE TABLE core.account_status (
    status_id SERIAL PRIMARY KEY,
    status_code VARCHAR(10) NOT NULL UNIQUE,
    status_name VARCHAR(50) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (status_id);

-- 13. Accounts
CREATE TABLE core.accounts (
    account_id SERIAL PRIMARY KEY,
    account_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INTEGER REFERENCES core.customers(customer_id),
    account_type_id INTEGER REFERENCES core.account_types(account_type_id),
    branch_id INTEGER REFERENCES core.branches(branch_id),
    status_id INTEGER REFERENCES core.account_status(status_id),
    currency_code CHAR(3) REFERENCES core.currencies(currency_code),
    opening_date DATE NOT NULL,
    closing_date DATE,
    current_balance DECIMAL(18,2) DEFAULT 0,
    available_balance DECIMAL(18,2) DEFAULT 0,
    overdraft_limit DECIMAL(15,2) DEFAULT 0,
    interest_rate DECIMAL(5,4),
    last_statement_date DATE,
    is_dormant BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (customer_id);

-- 14. Account Joint Holders
CREATE TABLE core.account_joint_holders (
    joint_holder_id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES core.accounts(account_id),
    customer_id INTEGER REFERENCES core.customers(customer_id),
    relationship_type VARCHAR(20),
    authority_level VARCHAR(20) DEFAULT 'FULL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(account_id, customer_id)
) DISTRIBUTED BY (account_id);

-- 15. Transaction Types
CREATE TABLE core.transaction_types (
    transaction_type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(10) NOT NULL UNIQUE,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    is_debit BOOLEAN NOT NULL,
    is_credit BOOLEAN NOT NULL,
    fee_applicable BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (transaction_type_id);

-- 16. Transaction Status
CREATE TABLE core.transaction_status (
    status_id SERIAL PRIMARY KEY,
    status_code VARCHAR(10) NOT NULL UNIQUE,
    status_name VARCHAR(50) NOT NULL,
    description TEXT,
    is_final BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (status_id);

-- 17. Transactions
CREATE TABLE core.transactions (
    transaction_id BIGSERIAL PRIMARY KEY,
    transaction_number VARCHAR(50) NOT NULL UNIQUE,
    account_id INTEGER REFERENCES core.accounts(account_id),
    transaction_type_id INTEGER REFERENCES core.transaction_types(transaction_type_id),
    status_id INTEGER REFERENCES core.transaction_status(status_id),
    amount DECIMAL(18,2) NOT NULL,
    currency_code CHAR(3) REFERENCES core.currencies(currency_code),
    exchange_rate DECIMAL(18,8) DEFAULT 1,
    local_amount DECIMAL(18,2),
    balance_after DECIMAL(18,2),
    transaction_date TIMESTAMP NOT NULL,
    value_date DATE,
    description TEXT,
    reference_number VARCHAR(100),
    channel VARCHAR(20),
    location VARCHAR(100),
    counterparty_account VARCHAR(30),
    counterparty_name VARCHAR(200),
    fee_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_by INTEGER
) DISTRIBUTED BY (account_id);

-- 18. Transaction Legs (for double entry)
CREATE TABLE core.transaction_legs (
    leg_id BIGSERIAL PRIMARY KEY,
    transaction_id BIGINT REFERENCES core.transactions(transaction_id),
    account_id INTEGER REFERENCES core.accounts(account_id),
    debit_amount DECIMAL(18,2) DEFAULT 0,
    credit_amount DECIMAL(18,2) DEFAULT 0,
    currency_code CHAR(3) REFERENCES core.currencies(currency_code),
    narrative TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (transaction_id);

-- 19. General Ledger Accounts
CREATE TABLE core.gl_accounts (
    gl_account_id SERIAL PRIMARY KEY,
    account_code VARCHAR(20) NOT NULL UNIQUE,
    account_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE')),
    parent_account_id INTEGER REFERENCES core.gl_accounts(gl_account_id),
    level INTEGER DEFAULT 1,
    is_leaf BOOLEAN DEFAULT TRUE,
    normal_balance VARCHAR(10) CHECK (normal_balance IN ('DEBIT', 'CREDIT')),
    current_balance DECIMAL(18,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (gl_account_id);

-- 20. GL Transactions
CREATE TABLE core.gl_transactions (
    gl_transaction_id BIGSERIAL PRIMARY KEY,
    transaction_date DATE NOT NULL,
    reference_number VARCHAR(100),
    description TEXT,
    total_debit DECIMAL(18,2) NOT NULL,
    total_credit DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    approved_at TIMESTAMP,
    approved_by INTEGER
) DISTRIBUTED BY (gl_transaction_id);

-- 21. GL Transaction Details
CREATE TABLE core.gl_transaction_details (
    detail_id BIGSERIAL PRIMARY KEY,
    gl_transaction_id BIGINT REFERENCES core.gl_transactions(gl_transaction_id),
    gl_account_id INTEGER REFERENCES core.gl_accounts(gl_account_id),
    debit_amount DECIMAL(18,2) DEFAULT 0,
    credit_amount DECIMAL(18,2) DEFAULT 0,
    description TEXT,
    reference_number VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (gl_transaction_id);

-- 22. Product Categories
CREATE TABLE core.product_categories (
    category_id SERIAL PRIMARY KEY,
    category_code VARCHAR(10) NOT NULL UNIQUE,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    parent_category_id INTEGER REFERENCES core.product_categories(category_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (category_id);

-- 23. Products
CREATE TABLE core.products (
    product_id SERIAL PRIMARY KEY,
    product_code VARCHAR(20) NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    category_id INTEGER REFERENCES core.product_categories(category_id),
    description TEXT,
    min_amount DECIMAL(15,2),
    max_amount DECIMAL(15,2),
    interest_rate DECIMAL(5,4),
    fee_structure JSONB,
    terms_and_conditions TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    launch_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (product_id);

-- 24. Customer Products
CREATE TABLE core.customer_products (
    customer_product_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES core.customers(customer_id),
    product_id INTEGER REFERENCES core.products(product_id),
    account_id INTEGER REFERENCES core.accounts(account_id),
    enrollment_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (customer_id);

-- 25. Employees
CREATE TABLE core.employees (
    employee_id SERIAL PRIMARY KEY,
    employee_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    termination_date DATE,
    branch_id INTEGER REFERENCES core.branches(branch_id),
    department VARCHAR(50),
    position VARCHAR(100),
    manager_id INTEGER REFERENCES core.employees(employee_id),
    salary DECIMAL(12,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (employee_id);

COMMENT ON SCHEMA core IS 'Core banking tables containing fundamental entities like customers, accounts, transactions';
