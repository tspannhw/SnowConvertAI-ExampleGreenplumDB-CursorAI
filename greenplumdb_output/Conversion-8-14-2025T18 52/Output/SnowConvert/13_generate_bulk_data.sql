-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '4' COLUMN '1' OF THE SOURCE CODE STARTING AT '\'. EXPECTED 'STATEMENT' GRAMMAR. **
---- Bulk Data Generation Script
---- Generates 1000+ records per table with realistic financial data

--\c financial_system
                   ;
--** SSC-FDM-PG0006 - SET SEARCH PATH WITH MULTIPLE SCHEMAS IS NOT SUPPORTED IN SNOWFLAKE **
USE SCHEMA core /*, trading, loans, risk, compliance, analytics, payment, cards, treasury, audit, public*/;
-- Function to generate random names
!!!RESOLVE EWI!!! /*** SSC-EWI-0068 - USER DEFINED FUNCTION WAS TRANSFORMED TO SNOWFLAKE PROCEDURE ***/!!!
CREATE OR REPLACE PROCEDURE core.random_first_name ()
RETURNS VARCHAR(100)
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS $$
        DECLARE
            names ARRAY /*** SSC-FDM-PG0016 - STRONGLY TYPED ARRAY 'TEXT[]' TRANSFORMED TO ARRAY WITHOUT TYPE CHECKING ***/ := ARRAY_CONSTRUCT('John', 'Jane', 'Michael', 'Sarah', 'David', 'Emily', 'Robert', 'Lisa', 'William', 'Jennifer',
            'James', 'Mary', 'Christopher', 'Patricia', 'Daniel', 'Linda', 'Matthew', 'Elizabeth', 'Anthony', 'Barbara',
            'Mark', 'Susan', 'Donald', 'Jessica', 'Steven', 'Karen', 'Paul', 'Nancy', 'Andrew', 'Lisa',
            'Joshua', 'Betty', 'Kenneth', 'Helen', 'Kevin', 'Sandra', 'Brian', 'Donna', 'George', 'Carol',
            'Timothy', 'Ruth', 'Ronald', 'Sharon', 'Edward', 'Michelle', 'Jason', 'Laura', 'Jeffrey', 'Sarah');
        BEGIN
            RETURN GET(names, 1 + FLOOR(RANDOM() * array_length(names, 1) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'array_length' NODE ***/!!!) - 1);
        END;
        $$;
!!!RESOLVE EWI!!! /*** SSC-EWI-0068 - USER DEFINED FUNCTION WAS TRANSFORMED TO SNOWFLAKE PROCEDURE ***/!!!
CREATE OR REPLACE PROCEDURE core.random_last_name ()
RETURNS VARCHAR(100)
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS $$
        DECLARE
            names ARRAY /*** SSC-FDM-PG0016 - STRONGLY TYPED ARRAY 'TEXT[]' TRANSFORMED TO ARRAY WITHOUT TYPE CHECKING ***/ := ARRAY_CONSTRUCT('Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
            'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
            'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson',
            'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores',
            'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts');
        BEGIN
            RETURN GET(names, 1 + FLOOR(RANDOM() * array_length(names, 1) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'array_length' NODE ***/!!!) - 1);
        END;
        $$;
        -- Function to generate random email
!!!RESOLVE EWI!!! /*** SSC-EWI-0068 - USER DEFINED FUNCTION WAS TRANSFORMED TO SNOWFLAKE PROCEDURE ***/!!!
CREATE OR REPLACE PROCEDURE core.random_email (first_name VARCHAR, last_name VARCHAR)
RETURNS VARCHAR(255)
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS $$
        DECLARE
            domains ARRAY /*** SSC-FDM-PG0016 - STRONGLY TYPED ARRAY 'TEXT[]' TRANSFORMED TO ARRAY WITHOUT TYPE CHECKING ***/ := ARRAY_CONSTRUCT('gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'aol.com', 'icloud.com');
        BEGIN
            RETURN LOWER(first_name || '.' || last_name || FLOOR(RANDOM() * 1000)::TEXT || '@' || GET(domains, 1 + FLOOR(RANDOM() * array_length(domains, 1) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'array_length' NODE ***/!!!) - 1));
        END;
        $$;

        -- Function to generate random phone number
        CREATE OR REPLACE FUNCTION core.random_phone ()
RETURNS VARCHAR(20)
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS
        $$
        SELECT
            '+1-' || (200 + FLOOR(RANDOM() * 800))::TEXT || '-' ||
                   (200 + FLOOR(RANDOM() * 800))::TEXT || '-' ||
                   (1000 + FLOOR(RANDOM() * 9000))::TEXT
        $$
;

        -- Function to generate random SSN (encrypted)
        CREATE OR REPLACE FUNCTION core.random_ssn ()
RETURNS VARCHAR(11)
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS
        $$
        SELECT
            (100 + FLOOR(RANDOM() * 900))::TEXT || '-' ||
                   (10 + FLOOR(RANDOM() * 90))::TEXT || '-' ||
                   (1000 + FLOOR(RANDOM() * 9000))::TEXT
        $$
;

        -- Generate 1000 customers
        INSERT INTO core.customers (customer_number, customer_type_id, first_name, last_name, date_of_birth, gender, email, phone, mobile, status_id, kyc_status, risk_rating, created_by)
        SELECT
            'CUST' || LPAD((10 + generate_series)::TEXT, 8, '0'),
            (1 + FLOOR(RANDOM() * 5))::INTEGER, -- Random customer type 1-5
            core.random_first_name(),
            core.random_last_name(),
            (CURRENT_DATE() - INTERVAL '18 years' - (RANDOM() * INTERVAL '50 years'))::DATE,
            CASE WHEN RANDOM() < 0.5 THEN 'M' ELSE 'F' END,
            NULL, -- Will update with email after generating
            core.random_phone(),
            core.random_phone(),
            CASE WHEN RANDOM() < 0.95 THEN 1 ELSE 2 END, -- 95% active
            CASE WHEN RANDOM() < 0.8 THEN 'COMPLETED' WHEN RANDOM() < 0.9 THEN 'PENDING' ELSE 'IN_PROGRESS' END,
            CASE WHEN RANDOM() < 0.6 THEN 'LOW' WHEN RANDOM() < 0.9 THEN 'MEDIUM' ELSE 'HIGH' END,
            (1 + FLOOR(RANDOM() * 10))::INTEGER -- Random employee 1-10
        FROM generate_series(1, 1000) AS generate_series !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!;

        -- Update emails with proper format
        UPDATE core.customers
        SET email = core.random_email(first_name, last_name)
        WHERE customer_id > 10; -- Keep original test data

        -- Generate customer addresses
        INSERT INTO core.customer_addresses (customer_id, address_type, address_line1, address_line2, city_id, postal_code, is_primary)
        SELECT
            c.customer_id,
            CASE WHEN RANDOM() < 0.8 THEN 'HOME' ELSE 'BUSINESS' END,
            (100 + FLOOR(RANDOM() * 9900))::TEXT || ' ' || GET((ARRAY_CONSTRUCT('Main St', 'Oak Ave', 'First St', 'Park Ave', 'Elm St', 'Second St', 'Third St', 'Fourth St', 'Fifth St', 'Sixth St')), 1 + FLOOR(RANDOM() * 10) - 1),
            CASE WHEN RANDOM() < 0.3 THEN 'Apt ' || (1 + FLOOR(RANDOM() * 999))::TEXT ELSE NULL END,
            (1 + FLOOR(RANDOM() * 13))::INTEGER, -- Random city 1-13
            (10000 + FLOOR(RANDOM() * 90000))::TEXT,
            TRUE
        FROM
        core.customers c
        WHERE c.customer_id > 10;

        -- Generate 2500 accounts (average 2.5 accounts per customer)
        INSERT INTO core.accounts (account_number, customer_id, account_type_id, branch_id, currency_code, opening_date, current_balance, available_balance, overdraft_limit, status_id)
        SELECT
            b.branch_id::TEXT || LPAD((1000000 + generate_series)::TEXT, 10, '0'),
            (11 + FLOOR(RANDOM() * 1000))::INTEGER, -- Random customer from our generated set
            (1 + FLOOR(RANDOM() * 6))::INTEGER, -- Random account type 1-6
            (1 + FLOOR(RANDOM() * 5))::INTEGER, -- Random branch 1-5
            'USD',
            (CURRENT_DATE() - (RANDOM() * INTERVAL '5 years'))::DATE,
            (RANDOM() * 100000)::DECIMAL(18,2),
            0, -- Will calculate
            CASE WHEN RANDOM() < 0.3 THEN (500 + RANDOM() * 4500)::DECIMAL(15,2) ELSE 0 END,
            CASE WHEN RANDOM() < 0.98 THEN 1 ELSE 2 END -- 98% active
        FROM generate_series(1, 2500) AS generate_series !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
        CROSS JOIN core.branches b
        WHERE b.branch_id = (1 + FLOOR(RANDOM() * 5))::INTEGER;

        -- Update available balance
        UPDATE core.accounts
        SET available_balance = current_balance + overdraft_limit
        WHERE account_id > 10;

        -- Generate 10000 transactions
        INSERT INTO core.transactions (transaction_number, account_id, transaction_type_id, amount, currency_code, balance_after, transaction_date, value_date, description, status_id, channel, reference_number)
        SELECT
            'TXN' || EXTRACT(YEAR FROM transaction_date) ::TEXT || LPAD(generate_series::TEXT, 12, '0'),
            a.account_id,
            (1 + FLOOR(RANDOM() * 8))::INTEGER, -- Random transaction type 1-8
            (1 + RANDOM() * 5000)::DECIMAL(18,2),
            'USD',
            0, -- Will calculate later
            (CURRENT_DATE() - (RANDOM() * INTERVAL '2 years'))::TIMESTAMP,
            (CURRENT_DATE() - (RANDOM() * INTERVAL '2 years'))::DATE,
        GET(
            (ARRAY_CONSTRUCT('ATM Withdrawal', 'Deposit', 'Online Purchase', 'Bill Payment', 'Transfer', 'Check Deposit', 'Interest Payment', 'Fee Charge')), 1 + FLOOR(RANDOM() * 8) - 1),
            CASE WHEN RANDOM() < 0.98 THEN 3 ELSE 4 END, -- 98% completed
        GET(
            (ARRAY_CONSTRUCT('ATM', 'ONLINE', 'BRANCH', 'MOBILE', 'PHONE')), 1 + FLOOR(RANDOM() * 5) - 1),
            'REF' || generate_series::TEXT
        FROM generate_series(1, 10000) AS generate_series !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
        CROSS JOIN (
            SELECT account_id FROM
            core.accounts
            WHERE account_id > 10
            ORDER BY
            RANDOM()
            LIMIT 1
        ) a;

        -- Generate 1000 loan applications
        INSERT INTO loans.loan_applications (application_number, customer_id, loan_product_id, requested_amount, requested_term_months, loan_purpose, application_date, application_status, decision, decision_amount, decision_term_months, decision_rate)
        SELECT
            'LA' || EXTRACT(YEAR FROM application_date) ::TEXT || LPAD(generate_series::TEXT, 8, '0'),
            (11 + FLOOR(RANDOM() * 1000))::INTEGER,
            (1 + FLOOR(RANDOM() * 6))::INTEGER,
            (1000 + RANDOM() * 199000)::DECIMAL(15,2),
            (12 + FLOOR(RANDOM() * 108))::INTEGER, -- 12-120 months
        GET(
            (ARRAY_CONSTRUCT('Home Purchase', 'Auto Purchase', 'Debt Consolidation', 'Home Improvement', 'Business Expansion', 'Education')), 1 + FLOOR(RANDOM() * 6) - 1),
            (CURRENT_DATE() - (RANDOM() * INTERVAL '1 year'))::DATE,
        GET(
            (ARRAY_CONSTRUCT('SUBMITTED', 'PROCESSING', 'APPROVED', 'DECLINED')), 1 + FLOOR(RANDOM() * 4) - 1),
            CASE WHEN RANDOM() < 0.7 THEN 'APPROVED' WHEN RANDOM() < 0.9 THEN 'DECLINED' ELSE NULL END,
            CASE WHEN RANDOM() < 0.7 THEN (1000 + RANDOM() * 199000)::DECIMAL(15,2) ELSE NULL END,
            CASE WHEN RANDOM() < 0.7 THEN (12 + FLOOR(RANDOM() * 108))::INTEGER ELSE NULL END,
            CASE WHEN RANDOM() < 0.7 THEN (0.03 + RANDOM() * 0.15)::DECIMAL(8,4) ELSE NULL END
        FROM generate_series(1, 1000) AS generate_series !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
        CROSS JOIN (VALUES (CURRENT_DATE() - (RANDOM() * INTERVAL '1 year'):: VARCHAR !!!RESOLVE EWI!!! /*** SSC-EWI-0036 - INTERVAL DATA TYPE CONVERTED TO VARCHAR ***/!!!)) AS dates(application_date) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'AsColumnDefinition' NODE ***/!!!;

        -- Generate 700 loans (70% approval rate)
        INSERT INTO loans.loans (loan_number, application_id, customer_id, loan_product_id, principal_amount, interest_rate, term_months, payment_amount, disbursement_date, first_payment_date, maturity_date, current_balance, principal_balance, originated_by, branch_id)
        SELECT
            'LN' || EXTRACT(YEAR FROM la.application_date) ::TEXT || LPAD(la.application_id::TEXT, 8, '0'),
            la.application_id,
            la.customer_id,
            la.loan_product_id,
            la.decision_amount,
            la.decision_rate,
            la.decision_term_months,
            -- Calculate PMT: P * (r * (1+r)^n) / ((1+r)^n - 1)
            (la.decision_amount * (la.decision_rate/12) * POWER(1 + la.decision_rate/12, la.decision_term_months)) /
            (POWER(1 + la.decision_rate/12, la.decision_term_months) - 1),
            la.application_date + INTERVAL '7 days' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'INTERVAL FORMAT' NODE ***/!!!,
            la.application_date + INTERVAL '37 days' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'INTERVAL FORMAT' NODE ***/!!!,
            la.application_date + (la.decision_term_months::TEXT || ' months'):: VARCHAR !!!RESOLVE EWI!!! /*** SSC-EWI-0036 - INTERVAL DATA TYPE CONVERTED TO VARCHAR ***/!!!,
            la.decision_amount * (0.8 + RANDOM() * 0.2), -- 80-100% of original balance
            la.decision_amount * (0.8 + RANDOM() * 0.2),
            (1 + FLOOR(RANDOM() * 10))::INTEGER,
            (1 + FLOOR(RANDOM() * 5))::INTEGER
        FROM
        loans.loan_applications la
        WHERE la.decision = 'APPROVED'
        AND la.application_id <= 700;

        -- Generate trading accounts for high-value customers
        INSERT INTO trading.trading_accounts (account_number, customer_id, account_type, base_currency, buying_power, opening_date)
        SELECT
            'TRD' || LPAD(generate_series::TEXT, 10, '0'),
            c.customer_id,
            CASE WHEN RANDOM() < 0.7 THEN 'CASH' ELSE 'MARGIN' END,
            'USD',
            (10000 + RANDOM() * 490000)::DECIMAL(18,2),
            (CURRENT_DATE() - (RANDOM() * INTERVAL '3 years'))::DATE
        FROM generate_series(1, 300) AS generate_series !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
        CROSS JOIN (
            SELECT customer_id FROM
            core.customers
            WHERE customer_id > 10
            ORDER BY
            RANDOM()
            LIMIT 1
        ) c;

        -- Generate portfolios
        INSERT INTO trading.portfolios (portfolio_name, customer_id, trading_account_id, portfolio_type, investment_objective, risk_tolerance, base_currency, inception_date, total_value, total_cost)
        SELECT
        GET(
            (ARRAY_CONSTRUCT('Growth Portfolio', 'Income Portfolio', 'Balanced Portfolio', 'Conservative Portfolio', 'Aggressive Portfolio')), 1 + FLOOR(RANDOM() * 5) - 1) || ' ' || ta.trading_account_id::TEXT,
            ta.customer_id,
            ta.trading_account_id,
            'INDIVIDUAL',
        GET(
            (ARRAY_CONSTRUCT('Capital Appreciation', 'Income Generation', 'Capital Preservation', 'Balanced Growth')), 1 + FLOOR(RANDOM() * 4) - 1),
        GET(
            (ARRAY_CONSTRUCT('CONSERVATIVE', 'MODERATE', 'AGGRESSIVE')), 1 + FLOOR(RANDOM() * 3) - 1),
            'USD',
            ta.opening_date,
            (5000 + RANDOM() * 95000)::DECIMAL(18,2),
            (5000 + RANDOM() * 95000)::DECIMAL(18,2)
        FROM
        trading.trading_accounts ta;

        -- Generate 2000 holdings
        INSERT INTO trading.holdings (portfolio_id, security_id, quantity, average_cost, current_price, market_value, unrealized_pnl)
        SELECT
            p.portfolio_id,
            (1 + FLOOR(RANDOM() * 7))::INTEGER, -- Random security 1-7
            (10 + FLOOR(RANDOM() * 1000))::DECIMAL(18,6),
            (10 + RANDOM() * 990)::DECIMAL(15,4),
            (10 + RANDOM() * 990)::DECIMAL(15,4),
            0, -- Will calculate
            0  -- Will calculate
        FROM generate_series(1, 2000) AS generate_series !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
        CROSS JOIN (
            SELECT portfolio_id FROM
            trading.portfolios
            ORDER BY
            RANDOM()
            LIMIT 1
        ) p;

        -- Update market values and PnL
        UPDATE trading.holdings
        SET market_value = quantity * current_price,
            unrealized_pnl = (current_price - average_cost) * quantity;

        -- Generate 5000 orders
        INSERT INTO trading.orders (order_number, portfolio_id, security_id, order_type_id, side, quantity, price, order_date, status_id, remaining_quantity)
        SELECT
            'ORD' || EXTRACT(YEAR FROM order_date) ::TEXT || LPAD(generate_series::TEXT, 10, '0'),
            p.portfolio_id,
            (1 + FLOOR(RANDOM() * 7))::INTEGER,
            (1 + FLOOR(RANDOM() * 5))::INTEGER,
            CASE WHEN RANDOM() < 0.5 THEN 'BUY' ELSE 'SELL' END,
            (1 + FLOOR(RANDOM() * 1000))::DECIMAL(18,6),
            (10 + RANDOM() * 990)::DECIMAL(15,4),
            (CURRENT_DATE() - (RANDOM() * INTERVAL '6 months'))::TIMESTAMP,
            CASE WHEN RANDOM() < 0.8 THEN 3 WHEN RANDOM() < 0.95 THEN 2 ELSE 1 END, -- 80% filled, 15% partial, 5% pending
            CASE WHEN RANDOM() < 0.8 THEN 0 ELSE (1 + FLOOR(RANDOM() * 100))::DECIMAL(18,6) END
        FROM generate_series(1, 5000) AS generate_series !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
        CROSS JOIN (
            SELECT portfolio_id FROM
            trading.portfolios
            ORDER BY
            RANDOM()
            LIMIT 1
        ) p
        CROSS JOIN (VALUES (CURRENT_DATE() - (RANDOM() * INTERVAL '6 months'):: VARCHAR !!!RESOLVE EWI!!! /*** SSC-EWI-0036 - INTERVAL DATA TYPE CONVERTED TO VARCHAR ***/!!!)) AS dates(order_date) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'AsColumnDefinition' NODE ***/!!!;

        -- Generate 1000 cards
--** SSC-FDM-0007 - MISSING DEPENDENT OBJECTS "gen_salt", "crypt", "md5" **
        INSERT INTO cards.cards (card_number_encrypted, card_number_hash, customer_id, account_id, card_type_id, issue_date, expiry_date, cvv_encrypted, card_status, daily_limit, monthly_limit, credit_limit, available_credit)
        SELECT
            crypt('**** **** **** ' || (1000 + floor(random() * 9000))::TEXT, gen_salt('bf')) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'crypt' NODE ***/!!!,
            md5('**** **** **** ' || (1000 + floor(random() * 9000))::TEXT) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'md5' NODE ***/!!!,
            c.customer_id,
            a.account_id,
            (1 + FLOOR(RANDOM() * 3))::INTEGER,
            (CURRENT_DATE() - (RANDOM() * INTERVAL '3 years'))::DATE,
            (CURRENT_DATE() + INTERVAL '3 years')::DATE,
            crypt((100 + floor(random() * 900))::TEXT, gen_salt('bf')) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'crypt' NODE ***/!!!,
            CASE WHEN RANDOM() < 0.95 THEN 'ACTIVE' ELSE 'BLOCKED' END,
            (500 + RANDOM() * 4500)::DECIMAL(12,2),
            (10000 + RANDOM() * 40000)::DECIMAL(15,2),
            (1000 + RANDOM() * 49000)::DECIMAL(15,2),
            0 -- Will calculate
        FROM generate_series(1, 1000) AS generate_series !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
        CROSS JOIN (
            SELECT customer_id FROM
            core.customers
            WHERE customer_id > 10
            ORDER BY
            RANDOM()
            LIMIT 1
        ) c
        CROSS JOIN (
            SELECT account_id FROM
            core.accounts
            WHERE customer_id = c.customer_id
            ORDER BY
            RANDOM()
            LIMIT 1
        ) a;

        -- Update available credit
        UPDATE cards.cards
        SET available_credit = credit_limit;

        -- Generate 10000 card transactions
        INSERT INTO cards.card_transactions (card_id, transaction_date, amount, currency_code, merchant_name, merchant_category_code, transaction_type, authorization_code, response_code, settlement_date)
        SELECT
            card.card_id,
            (CURRENT_DATE() - (RANDOM() * INTERVAL '1 year'))::TIMESTAMP,
            (1 + RANDOM() * 2000)::DECIMAL(15,2),
            'USD',
        GET(
            (ARRAY_CONSTRUCT('Amazon', 'Walmart', 'Target', 'Starbucks', 'McDonalds', 'Shell', 'Exxon', 'Best Buy', 'Home Depot', 'Costco')), 1 + FLOOR(RANDOM() * 10) - 1),
        GET(
            (ARRAY_CONSTRUCT('5411', '5812', '5541', '5999', '7011', '4900', '5310')), 1 + FLOOR(RANDOM() * 7) - 1),
            CASE WHEN RANDOM() < 0.95 THEN 'PURCHASE' WHEN RANDOM() < 0.98 THEN 'WITHDRAWAL' ELSE 'REFUND' END,
            'AUTH' || (100000 + FLOOR(RANDOM() * 900000))::TEXT,
            CASE WHEN RANDOM() < 0.98 THEN '00' ELSE '05' END,
            (CURRENT_DATE() - (RANDOM() * INTERVAL '1 year') + INTERVAL '2 days' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'INTERVAL FORMAT' NODE ***/!!!)::DATE
        FROM generate_series(1, 10000) AS generate_series !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
        CROSS JOIN (
            SELECT card_id FROM
            cards.cards
            ORDER BY
            RANDOM()
            LIMIT 1
        ) card;

        -- Generate risk measurements
        INSERT INTO risk.risk_measurements (entity_type, entity_id, risk_factor_id, measurement_date, measurement_value, confidence_level, time_horizon)
        SELECT
            entity_type,
            entity_id,
            (1 + FLOOR(RANDOM() * 5))::INTEGER,
            measurement_date,
            (RANDOM() * 1000000)::DECIMAL(18,6),
            (0.90 + RANDOM() * 0.09)::DECIMAL(5,4),
            CASE WHEN RANDOM() < 0.5 THEN 1 ELSE 30 END
        FROM (
            SELECT 'CUSTOMER'::TEXT AS entity_type, customer_id AS entity_id,
                   (CURRENT_DATE() - (generate_series * INTERVAL '1 day'))::DATE AS measurement_date
            FROM
            core.customers
            CROSS JOIN generate_series(0, 30) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
            WHERE customer_id <= 100 -- Limit to first 100 customers
            UNION ALL
            SELECT 'PORTFOLIO'::TEXT AS entity_type, portfolio_id AS entity_id,
                   (CURRENT_DATE() - (generate_series * INTERVAL '1 day'))::DATE AS measurement_date
            FROM
            trading.portfolios
            CROSS JOIN generate_series(0, 30) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
            WHERE portfolio_id <= 50 -- Limit to first 50 portfolios
        ) risk_entities;

        -- Generate AML alerts
        INSERT INTO compliance.aml_alerts (customer_id, account_id, transaction_id, alert_type, alert_priority, alert_date, description, amount, currency_code, pattern_detected, status, assigned_to)
        SELECT
            t.account_id, -- Use account_id as customer reference
            a.account_id,
            t.transaction_id,
        GET(
            (ARRAY_CONSTRUCT('LARGE_CASH', 'FREQUENT_SMALL', 'UNUSUAL_PATTERN', 'GEOGRAPHIC_RISK', 'VELOCITY_CHECK')), 1 + FLOOR(RANDOM() * 5) - 1),
        GET(
            (ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH')), 1 + FLOOR(RANDOM() * 3) - 1),
            t.transaction_date::DATE,
            'Automated alert generated for unusual transaction pattern',
            t.amount,
            'USD',
            'Pattern ' || (1000 + FLOOR(RANDOM() * 9000))::TEXT,
            CASE WHEN RANDOM() < 0.3 THEN 'OPEN' WHEN RANDOM() < 0.8 THEN 'INVESTIGATING' ELSE 'CLOSED' END,
            (1 + FLOOR(RANDOM() * 10))::INTEGER
        FROM
        core.transactions t
        JOIN
        core.accounts a ON t.account_id = a.account_id
        WHERE t.amount > 5000 -- Only large transactions
        AND RANDOM() < 0.1 -- 10% of large transactions generate alerts
        LIMIT 1000;

        -- Generate compliance monitoring records
        INSERT INTO compliance.compliance_monitoring (requirement_id, entity_type, entity_id, monitoring_date, due_date, status, compliance_percentage, monitored_by)
        SELECT
            (1 + FLOOR(RANDOM() * 5))::INTEGER,
            'CUSTOMER',
            customer_id,
            (CURRENT_DATE() - (RANDOM() * INTERVAL '30 days' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'INTERVAL FORMAT' NODE ***/!!!))::DATE,
            (CURRENT_DATE() + (RANDOM() * INTERVAL '30 days' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'INTERVAL FORMAT' NODE ***/!!!))::DATE,
        GET(
            (ARRAY_CONSTRUCT('PENDING', 'COMPLIANT', 'NON_COMPLIANT')), 1 + FLOOR(RANDOM() * 3) - 1),
            (50 + RANDOM() * 50)::DECIMAL(5,2),
            (1 + FLOOR(RANDOM() * 10))::INTEGER
        FROM
        core.customers
        WHERE customer_id <= 500 -- Monitor first 500 customers
        AND RANDOM() < 0.5; -- 50% of customers have monitoring records

        -- Generate payment instructions
        INSERT INTO payment.payment_instructions (customer_id, account_id, payment_method_id, instruction_type, amount, currency_code, beneficiary_name, beneficiary_account, payment_reference, execution_date, status)
        SELECT
            a.customer_id,
            a.account_id,
            (1 + FLOOR(RANDOM() * 3))::INTEGER,
            CASE WHEN RANDOM() < 0.8 THEN 'ONE_TIME' ELSE 'RECURRING' END,
            (10 + RANDOM() * 9990)::DECIMAL(15,2),
            'USD',
            core.random_first_name() || ' ' || core.random_last_name(),
            (1000000000 + FLOOR(RANDOM() * 9000000000))::TEXT,
            'Payment ' || generate_series::TEXT,
            (CURRENT_DATE() + (RANDOM() * INTERVAL '30 days' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'INTERVAL FORMAT' NODE ***/!!!))::DATE,
        GET(
            (ARRAY_CONSTRUCT('PENDING', 'SCHEDULED', 'COMPLETED', 'FAILED')), 1 + FLOOR(RANDOM() * 4) - 1)
        FROM generate_series(1, 1000) AS generate_series !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
        CROSS JOIN (
            SELECT customer_id, account_id FROM
            core.accounts
            WHERE account_id > 10
            ORDER BY
            RANDOM()
            LIMIT 1
        ) a;

        -- Generate wire transfers
        INSERT INTO payment.wire_transfers (transfer_number, customer_id, account_id, transfer_type, amount, currency_code, fees, sender_name, beneficiary_name, beneficiary_account, beneficiary_bank_name, value_date, status)
        SELECT
            'WIRE' || EXTRACT(YEAR FROM value_date) ::TEXT || LPAD(generate_series::TEXT, 8, '0'),
            a.customer_id,
            a.account_id,
            CASE WHEN RANDOM() < 0.7 THEN 'DOMESTIC' ELSE 'INTERNATIONAL' END,
            (1000 + RANDOM() * 99000)::DECIMAL(15,2),
            'USD',
            CASE WHEN RANDOM() < 0.7 THEN 15.00 ELSE 45.00 END,
            c.first_name || ' ' || c.last_name,
            core.random_first_name() || ' ' || core.random_last_name(),
            (1000000000 + FLOOR(RANDOM() * 9000000000))::TEXT,
        GET(
            (ARRAY_CONSTRUCT('Chase Bank', 'Bank of America', 'Wells Fargo', 'Citibank', 'US Bank')), 1 + FLOOR(RANDOM() * 5) - 1),
            (CURRENT_DATE() - (RANDOM() * INTERVAL '60 days' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'INTERVAL FORMAT' NODE ***/!!!))::DATE,
            CASE WHEN RANDOM() < 0.95 THEN 'COMPLETED' WHEN RANDOM() < 0.98 THEN 'PENDING' ELSE 'FAILED' END
        FROM generate_series(1, 1000) AS generate_series !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
        CROSS JOIN (
            SELECT customer_id, account_id FROM
            core.accounts
            WHERE account_id > 10
            ORDER BY
            RANDOM()
            LIMIT 1
        ) a
        JOIN
        core.customers c ON a.customer_id = c.customer_id
        CROSS JOIN (VALUES (CURRENT_DATE() - (RANDOM() * INTERVAL '60 days' !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'INTERVAL FORMAT' NODE ***/!!!):: VARCHAR !!!RESOLVE EWI!!! /*** SSC-EWI-0036 - INTERVAL DATA TYPE CONVERTED TO VARCHAR ***/!!!)) AS dates(value_date) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'AsColumnDefinition' NODE ***/!!!;

        -- Generate analytics data
        INSERT INTO analytics.customer_analytics (customer_id, analysis_date, total_relationship_value, product_count, average_balance, transaction_frequency, lifetime_value, churn_probability, cross_sell_propensity, risk_score, profitability_tier, segment)
        SELECT
            c.customer_id,
            (CURRENT_DATE() - (generate_series * INTERVAL '1 month'))::DATE,
            (5000 + RANDOM() * 495000)::DECIMAL(18,2),
            (1 + FLOOR(RANDOM() * 8))::INTEGER,
            (1000 + RANDOM() * 99000)::DECIMAL(18,2),
            (1 + RANDOM() * 50)::DECIMAL(8,2),
            (10000 + RANDOM() * 990000)::DECIMAL(18,2),
            (RANDOM() * 0.5)::DECIMAL(5,4),
            (RANDOM())::DECIMAL(5,4),
            (300 + FLOOR(RANDOM() * 550))::INTEGER,
        GET(
            (ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH')), 1 + FLOOR(RANDOM() * 3) - 1),
        GET(
            (ARRAY_CONSTRUCT('MASS_MARKET', 'AFFLUENT', 'PREMIUM', 'PRIVATE_BANKING')), 1 + FLOOR(RANDOM() * 4) - 1)
        FROM
        core.customers c
        CROSS JOIN generate_series(0, 11) -- 12 months of data
        !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!
        WHERE c.customer_id <= 200; -- First 200 customers

        -- Generate product performance data
        INSERT INTO analytics.product_performance (product_id, analysis_date, active_customers, new_customers, total_balance, transaction_volume, transaction_amount, fee_income, interest_income, net_income)
        SELECT
            p.product_id,
            (CURRENT_DATE() - (generate_series * INTERVAL '1 month'))::DATE,
            (100 + FLOOR(RANDOM() * 900))::INTEGER,
            (5 + FLOOR(RANDOM() * 50))::INTEGER,
            (100000 + RANDOM() * 9900000)::DECIMAL(18,2),
            (1000 + FLOOR(RANDOM() * 9000))::BIGINT,
            (50000 + RANDOM() * 950000)::DECIMAL(18,2),
            (1000 + RANDOM() * 9000)::DECIMAL(15,2),
            (2000 + RANDOM() * 18000)::DECIMAL(15,2),
            (500 + RANDOM() * 4500)::DECIMAL(15,2)
        FROM
        core.products p
        CROSS JOIN generate_series(0, 11) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'TableValuedFunctionCall' NODE ***/!!!; -- 12 months of data

        -- Clean up temporary functions
        DROP FUNCTION IF EXISTS core.random_first_name() !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropFunction' NODE ***/!!!;
        DROP FUNCTION IF EXISTS core.random_last_name() !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropFunction' NODE ***/!!!;
        DROP FUNCTION IF EXISTS core.random_email(VARCHAR, VARCHAR) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropFunction' NODE ***/!!!;
        DROP FUNCTION IF EXISTS core.random_phone() !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropFunction' NODE ***/!!!;
        DROP FUNCTION IF EXISTS core.random_ssn() !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'DropFunction' NODE ***/!!!;

--        -- Update statistics
----** SSC-FDM-PG0018 - ANALYZE STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--        ANALYZE
               ;

        -- Report generation summary
        SELECT
            'Data Generation Complete' AS status,
            (SELECT
            COUNT(*) FROM
            core.customers
        ) AS customers,
            (SELECT
            COUNT(*) FROM
            core.accounts
        ) AS accounts,
            (SELECT
            COUNT(*) FROM
            core.transactions
        ) AS transactions,
            (SELECT
            COUNT(*) FROM
            loans.loans
        ) AS loans,
            (SELECT
            COUNT(*) FROM
            trading.portfolios
        ) AS portfolios,
            (SELECT
            COUNT(*) FROM
            cards.cards
        ) AS cards,
            (SELECT
            COUNT(*) FROM
            compliance.aml_alerts
        ) AS aml_alerts;

-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '477' COLUMN '1' OF THE SOURCE CODE STARTING AT 'COMMENT'. EXPECTED 'STATEMENT' GRAMMAR. LAST MATCHING TOKEN WAS ';' ON LINE '475' COLUMN '63'. **
--COMMENT ON SCRIPT IS 'Bulk data generation script creating 1000+ realistic records per table'
                                                                                             ;