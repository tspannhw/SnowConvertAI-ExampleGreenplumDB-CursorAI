-- Bulk Data Generation Script
-- Generates 1000+ records per table with realistic financial data

\c financial_system;
SET search_path TO core, trading, loans, risk, compliance, analytics, payment, cards, treasury, audit, public;

-- Function to generate random names
CREATE OR REPLACE FUNCTION core.random_first_name() RETURNS VARCHAR(100) AS $$
DECLARE
    names TEXT[] := ARRAY['John', 'Jane', 'Michael', 'Sarah', 'David', 'Emily', 'Robert', 'Lisa', 'William', 'Jennifer', 
                          'James', 'Mary', 'Christopher', 'Patricia', 'Daniel', 'Linda', 'Matthew', 'Elizabeth', 'Anthony', 'Barbara',
                          'Mark', 'Susan', 'Donald', 'Jessica', 'Steven', 'Karen', 'Paul', 'Nancy', 'Andrew', 'Lisa',
                          'Joshua', 'Betty', 'Kenneth', 'Helen', 'Kevin', 'Sandra', 'Brian', 'Donna', 'George', 'Carol',
                          'Timothy', 'Ruth', 'Ronald', 'Sharon', 'Edward', 'Michelle', 'Jason', 'Laura', 'Jeffrey', 'Sarah'];
BEGIN
    RETURN names[1 + floor(random() * array_length(names, 1))];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION core.random_last_name() RETURNS VARCHAR(100) AS $$
DECLARE
    names TEXT[] := ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
                          'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
                          'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson',
                          'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores',
                          'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts'];
BEGIN
    RETURN names[1 + floor(random() * array_length(names, 1))];
END;
$$ LANGUAGE plpgsql;

-- Function to generate random email
CREATE OR REPLACE FUNCTION core.random_email(first_name VARCHAR, last_name VARCHAR) RETURNS VARCHAR(255) AS $$
DECLARE
    domains TEXT[] := ARRAY['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'aol.com', 'icloud.com'];
BEGIN
    RETURN lower(first_name || '.' || last_name || floor(random() * 1000)::TEXT || '@' || 
                 domains[1 + floor(random() * array_length(domains, 1))]);
END;
$$ LANGUAGE plpgsql;

-- Function to generate random phone number
CREATE OR REPLACE FUNCTION core.random_phone() RETURNS VARCHAR(20) AS $$
BEGIN
    RETURN '+1-' || (200 + floor(random() * 800))::TEXT || '-' || 
           (200 + floor(random() * 800))::TEXT || '-' || 
           (1000 + floor(random() * 9000))::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Function to generate random SSN (encrypted)
CREATE OR REPLACE FUNCTION core.random_ssn() RETURNS VARCHAR(11) AS $$
BEGIN
    RETURN (100 + floor(random() * 900))::TEXT || '-' ||
           (10 + floor(random() * 90))::TEXT || '-' ||
           (1000 + floor(random() * 9000))::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Generate 1000 customers
INSERT INTO core.customers (customer_number, customer_type_id, first_name, last_name, date_of_birth, gender, email, phone, mobile, status_id, kyc_status, risk_rating, created_by)
SELECT 
    'CUST' || LPAD((10 + generate_series)::TEXT, 8, '0'),
    (1 + floor(random() * 5))::INTEGER, -- Random customer type 1-5
    core.random_first_name(),
    core.random_last_name(),
    (CURRENT_DATE - INTERVAL '18 years' - (random() * INTERVAL '50 years'))::DATE,
    CASE WHEN random() < 0.5 THEN 'M' ELSE 'F' END,
    NULL, -- Will update with email after generating
    core.random_phone(),
    core.random_phone(),
    CASE WHEN random() < 0.95 THEN 1 ELSE 2 END, -- 95% active
    CASE WHEN random() < 0.8 THEN 'COMPLETED' WHEN random() < 0.9 THEN 'PENDING' ELSE 'IN_PROGRESS' END,
    CASE WHEN random() < 0.6 THEN 'LOW' WHEN random() < 0.9 THEN 'MEDIUM' ELSE 'HIGH' END,
    (1 + floor(random() * 10))::INTEGER -- Random employee 1-10
FROM generate_series(1, 1000) AS generate_series;

-- Update emails with proper format
UPDATE core.customers 
SET email = core.random_email(first_name, last_name)
WHERE customer_id > 10; -- Keep original test data

-- Generate customer addresses
INSERT INTO core.customer_addresses (customer_id, address_type, address_line1, address_line2, city_id, postal_code, is_primary)
SELECT 
    c.customer_id,
    CASE WHEN random() < 0.8 THEN 'HOME' ELSE 'BUSINESS' END,
    (100 + floor(random() * 9900))::TEXT || ' ' || 
    (ARRAY['Main St', 'Oak Ave', 'First St', 'Park Ave', 'Elm St', 'Second St', 'Third St', 'Fourth St', 'Fifth St', 'Sixth St'])[1 + floor(random() * 10)],
    CASE WHEN random() < 0.3 THEN 'Apt ' || (1 + floor(random() * 999))::TEXT ELSE NULL END,
    (1 + floor(random() * 13))::INTEGER, -- Random city 1-13
    (10000 + floor(random() * 90000))::TEXT,
    TRUE
FROM core.customers c
WHERE c.customer_id > 10;

-- Generate 2500 accounts (average 2.5 accounts per customer)
INSERT INTO core.accounts (account_number, customer_id, account_type_id, branch_id, currency_code, opening_date, current_balance, available_balance, overdraft_limit, status_id)
SELECT 
    b.branch_id::TEXT || LPAD((1000000 + generate_series)::TEXT, 10, '0'),
    (11 + floor(random() * 1000))::INTEGER, -- Random customer from our generated set
    (1 + floor(random() * 6))::INTEGER, -- Random account type 1-6
    (1 + floor(random() * 5))::INTEGER, -- Random branch 1-5
    'USD',
    (CURRENT_DATE - (random() * INTERVAL '5 years'))::DATE,
    (random() * 100000)::DECIMAL(18,2),
    0, -- Will calculate
    CASE WHEN random() < 0.3 THEN (500 + random() * 4500)::DECIMAL(15,2) ELSE 0 END,
    CASE WHEN random() < 0.98 THEN 1 ELSE 2 END -- 98% active
FROM generate_series(1, 2500) AS generate_series
CROSS JOIN core.branches b
WHERE b.branch_id = (1 + floor(random() * 5))::INTEGER;

-- Update available balance
UPDATE core.accounts 
SET available_balance = current_balance + overdraft_limit
WHERE account_id > 10;

-- Generate 10000 transactions
INSERT INTO core.transactions (transaction_number, account_id, transaction_type_id, amount, currency_code, balance_after, transaction_date, value_date, description, status_id, channel, reference_number)
SELECT 
    'TXN' || EXTRACT(YEAR FROM transaction_date)::TEXT || LPAD(generate_series::TEXT, 12, '0'),
    a.account_id,
    (1 + floor(random() * 8))::INTEGER, -- Random transaction type 1-8
    (1 + random() * 5000)::DECIMAL(18,2),
    'USD',
    0, -- Will calculate later
    (CURRENT_DATE - (random() * INTERVAL '2 years'))::TIMESTAMP,
    (CURRENT_DATE - (random() * INTERVAL '2 years'))::DATE,
    (ARRAY['ATM Withdrawal', 'Deposit', 'Online Purchase', 'Bill Payment', 'Transfer', 'Check Deposit', 'Interest Payment', 'Fee Charge'])[1 + floor(random() * 8)],
    CASE WHEN random() < 0.98 THEN 3 ELSE 4 END, -- 98% completed
    (ARRAY['ATM', 'ONLINE', 'BRANCH', 'MOBILE', 'PHONE'])[1 + floor(random() * 5)],
    'REF' || generate_series::TEXT
FROM generate_series(1, 10000) AS generate_series
CROSS JOIN (
    SELECT account_id FROM core.accounts 
    WHERE account_id > 10 
    ORDER BY random() 
    LIMIT 1
) a;

-- Generate 1000 loan applications
INSERT INTO loans.loan_applications (application_number, customer_id, loan_product_id, requested_amount, requested_term_months, loan_purpose, application_date, application_status, decision, decision_amount, decision_term_months, decision_rate)
SELECT 
    'LA' || EXTRACT(YEAR FROM application_date)::TEXT || LPAD(generate_series::TEXT, 8, '0'),
    (11 + floor(random() * 1000))::INTEGER,
    (1 + floor(random() * 6))::INTEGER,
    (1000 + random() * 199000)::DECIMAL(15,2),
    (12 + floor(random() * 108))::INTEGER, -- 12-120 months
    (ARRAY['Home Purchase', 'Auto Purchase', 'Debt Consolidation', 'Home Improvement', 'Business Expansion', 'Education'])[1 + floor(random() * 6)],
    (CURRENT_DATE - (random() * INTERVAL '1 year'))::DATE,
    (ARRAY['SUBMITTED', 'PROCESSING', 'APPROVED', 'DECLINED'])[1 + floor(random() * 4)],
    CASE WHEN random() < 0.7 THEN 'APPROVED' WHEN random() < 0.9 THEN 'DECLINED' ELSE NULL END,
    CASE WHEN random() < 0.7 THEN (1000 + random() * 199000)::DECIMAL(15,2) ELSE NULL END,
    CASE WHEN random() < 0.7 THEN (12 + floor(random() * 108))::INTEGER ELSE NULL END,
    CASE WHEN random() < 0.7 THEN (0.03 + random() * 0.15)::DECIMAL(8,4) ELSE NULL END
FROM generate_series(1, 1000) AS generate_series
CROSS JOIN (VALUES (CURRENT_DATE - (random() * INTERVAL '1 year')::INTERVAL)) AS dates(application_date);

-- Generate 700 loans (70% approval rate)
INSERT INTO loans.loans (loan_number, application_id, customer_id, loan_product_id, principal_amount, interest_rate, term_months, payment_amount, disbursement_date, first_payment_date, maturity_date, current_balance, principal_balance, originated_by, branch_id)
SELECT 
    'LN' || EXTRACT(YEAR FROM la.application_date)::TEXT || LPAD(la.application_id::TEXT, 8, '0'),
    la.application_id,
    la.customer_id,
    la.loan_product_id,
    la.decision_amount,
    la.decision_rate,
    la.decision_term_months,
    -- Calculate PMT: P * (r * (1+r)^n) / ((1+r)^n - 1)
    (la.decision_amount * (la.decision_rate/12) * POWER(1 + la.decision_rate/12, la.decision_term_months)) / 
    (POWER(1 + la.decision_rate/12, la.decision_term_months) - 1),
    la.application_date + INTERVAL '7 days',
    la.application_date + INTERVAL '37 days',
    la.application_date + (la.decision_term_months::TEXT || ' months')::INTERVAL,
    la.decision_amount * (0.8 + random() * 0.2), -- 80-100% of original balance
    la.decision_amount * (0.8 + random() * 0.2),
    (1 + floor(random() * 10))::INTEGER,
    (1 + floor(random() * 5))::INTEGER
FROM loans.loan_applications la
WHERE la.decision = 'APPROVED'
AND la.application_id <= 700;

-- Generate trading accounts for high-value customers
INSERT INTO trading.trading_accounts (account_number, customer_id, account_type, base_currency, buying_power, opening_date)
SELECT 
    'TRD' || LPAD(generate_series::TEXT, 10, '0'),
    c.customer_id,
    CASE WHEN random() < 0.7 THEN 'CASH' ELSE 'MARGIN' END,
    'USD',
    (10000 + random() * 490000)::DECIMAL(18,2),
    (CURRENT_DATE - (random() * INTERVAL '3 years'))::DATE
FROM generate_series(1, 300) AS generate_series
CROSS JOIN (
    SELECT customer_id FROM core.customers 
    WHERE customer_id > 10 
    ORDER BY random() 
    LIMIT 1
) c;

-- Generate portfolios
INSERT INTO trading.portfolios (portfolio_name, customer_id, trading_account_id, portfolio_type, investment_objective, risk_tolerance, base_currency, inception_date, total_value, total_cost)
SELECT 
    (ARRAY['Growth Portfolio', 'Income Portfolio', 'Balanced Portfolio', 'Conservative Portfolio', 'Aggressive Portfolio'])[1 + floor(random() * 5)] || ' ' || ta.trading_account_id::TEXT,
    ta.customer_id,
    ta.trading_account_id,
    'INDIVIDUAL',
    (ARRAY['Capital Appreciation', 'Income Generation', 'Capital Preservation', 'Balanced Growth'])[1 + floor(random() * 4)],
    (ARRAY['CONSERVATIVE', 'MODERATE', 'AGGRESSIVE'])[1 + floor(random() * 3)],
    'USD',
    ta.opening_date,
    (5000 + random() * 95000)::DECIMAL(18,2),
    (5000 + random() * 95000)::DECIMAL(18,2)
FROM trading.trading_accounts ta;

-- Generate 2000 holdings
INSERT INTO trading.holdings (portfolio_id, security_id, quantity, average_cost, current_price, market_value, unrealized_pnl)
SELECT 
    p.portfolio_id,
    (1 + floor(random() * 7))::INTEGER, -- Random security 1-7
    (10 + floor(random() * 1000))::DECIMAL(18,6),
    (10 + random() * 990)::DECIMAL(15,4),
    (10 + random() * 990)::DECIMAL(15,4),
    0, -- Will calculate
    0  -- Will calculate
FROM generate_series(1, 2000) AS generate_series
CROSS JOIN (
    SELECT portfolio_id FROM trading.portfolios 
    ORDER BY random() 
    LIMIT 1
) p;

-- Update market values and PnL
UPDATE trading.holdings 
SET market_value = quantity * current_price,
    unrealized_pnl = (current_price - average_cost) * quantity;

-- Generate 5000 orders
INSERT INTO trading.orders (order_number, portfolio_id, security_id, order_type_id, side, quantity, price, order_date, status_id, remaining_quantity)
SELECT 
    'ORD' || EXTRACT(YEAR FROM order_date)::TEXT || LPAD(generate_series::TEXT, 10, '0'),
    p.portfolio_id,
    (1 + floor(random() * 7))::INTEGER,
    (1 + floor(random() * 5))::INTEGER,
    CASE WHEN random() < 0.5 THEN 'BUY' ELSE 'SELL' END,
    (1 + floor(random() * 1000))::DECIMAL(18,6),
    (10 + random() * 990)::DECIMAL(15,4),
    (CURRENT_DATE - (random() * INTERVAL '6 months'))::TIMESTAMP,
    CASE WHEN random() < 0.8 THEN 3 WHEN random() < 0.95 THEN 2 ELSE 1 END, -- 80% filled, 15% partial, 5% pending
    CASE WHEN random() < 0.8 THEN 0 ELSE (1 + floor(random() * 100))::DECIMAL(18,6) END
FROM generate_series(1, 5000) AS generate_series
CROSS JOIN (
    SELECT portfolio_id FROM trading.portfolios 
    ORDER BY random() 
    LIMIT 1
) p
CROSS JOIN (VALUES (CURRENT_DATE - (random() * INTERVAL '6 months')::INTERVAL)) AS dates(order_date);

-- Generate 1000 cards
INSERT INTO cards.cards (card_number_encrypted, card_number_hash, customer_id, account_id, card_type_id, issue_date, expiry_date, cvv_encrypted, card_status, daily_limit, monthly_limit, credit_limit, available_credit)
SELECT 
    crypt('**** **** **** ' || (1000 + floor(random() * 9000))::TEXT, gen_salt('bf')),
    md5('**** **** **** ' || (1000 + floor(random() * 9000))::TEXT),
    c.customer_id,
    a.account_id,
    (1 + floor(random() * 3))::INTEGER,
    (CURRENT_DATE - (random() * INTERVAL '3 years'))::DATE,
    (CURRENT_DATE + INTERVAL '3 years')::DATE,
    crypt((100 + floor(random() * 900))::TEXT, gen_salt('bf')),
    CASE WHEN random() < 0.95 THEN 'ACTIVE' ELSE 'BLOCKED' END,
    (500 + random() * 4500)::DECIMAL(12,2),
    (10000 + random() * 40000)::DECIMAL(15,2),
    (1000 + random() * 49000)::DECIMAL(15,2),
    0 -- Will calculate
FROM generate_series(1, 1000) AS generate_series
CROSS JOIN (
    SELECT customer_id FROM core.customers 
    WHERE customer_id > 10 
    ORDER BY random() 
    LIMIT 1
) c
CROSS JOIN (
    SELECT account_id FROM core.accounts 
    WHERE customer_id = c.customer_id 
    ORDER BY random() 
    LIMIT 1
) a;

-- Update available credit
UPDATE cards.cards 
SET available_credit = credit_limit;

-- Generate 10000 card transactions
INSERT INTO cards.card_transactions (card_id, transaction_date, amount, currency_code, merchant_name, merchant_category_code, transaction_type, authorization_code, response_code, settlement_date)
SELECT 
    card.card_id,
    (CURRENT_DATE - (random() * INTERVAL '1 year'))::TIMESTAMP,
    (1 + random() * 2000)::DECIMAL(15,2),
    'USD',
    (ARRAY['Amazon', 'Walmart', 'Target', 'Starbucks', 'McDonalds', 'Shell', 'Exxon', 'Best Buy', 'Home Depot', 'Costco'])[1 + floor(random() * 10)],
    (ARRAY['5411', '5812', '5541', '5999', '7011', '4900', '5310'])[1 + floor(random() * 7)],
    CASE WHEN random() < 0.95 THEN 'PURCHASE' WHEN random() < 0.98 THEN 'WITHDRAWAL' ELSE 'REFUND' END,
    'AUTH' || (100000 + floor(random() * 900000))::TEXT,
    CASE WHEN random() < 0.98 THEN '00' ELSE '05' END,
    (CURRENT_DATE - (random() * INTERVAL '1 year') + INTERVAL '2 days')::DATE
FROM generate_series(1, 10000) AS generate_series
CROSS JOIN (
    SELECT card_id FROM cards.cards 
    ORDER BY random() 
    LIMIT 1
) card;

-- Generate risk measurements
INSERT INTO risk.risk_measurements (entity_type, entity_id, risk_factor_id, measurement_date, measurement_value, confidence_level, time_horizon)
SELECT 
    entity_type,
    entity_id,
    (1 + floor(random() * 5))::INTEGER,
    measurement_date,
    (random() * 1000000)::DECIMAL(18,6),
    (0.90 + random() * 0.09)::DECIMAL(5,4),
    CASE WHEN random() < 0.5 THEN 1 ELSE 30 END
FROM (
    SELECT 'CUSTOMER'::TEXT AS entity_type, customer_id AS entity_id, 
           (CURRENT_DATE - (generate_series * INTERVAL '1 day'))::DATE AS measurement_date
    FROM core.customers 
    CROSS JOIN generate_series(0, 30)
    WHERE customer_id <= 100 -- Limit to first 100 customers
    UNION ALL
    SELECT 'PORTFOLIO'::TEXT AS entity_type, portfolio_id AS entity_id,
           (CURRENT_DATE - (generate_series * INTERVAL '1 day'))::DATE AS measurement_date
    FROM trading.portfolios 
    CROSS JOIN generate_series(0, 30)
    WHERE portfolio_id <= 50 -- Limit to first 50 portfolios
) risk_entities;

-- Generate AML alerts
INSERT INTO compliance.aml_alerts (customer_id, account_id, transaction_id, alert_type, alert_priority, alert_date, description, amount, currency_code, pattern_detected, status, assigned_to)
SELECT 
    t.account_id, -- Use account_id as customer reference
    a.account_id,
    t.transaction_id,
    (ARRAY['LARGE_CASH', 'FREQUENT_SMALL', 'UNUSUAL_PATTERN', 'GEOGRAPHIC_RISK', 'VELOCITY_CHECK'])[1 + floor(random() * 5)],
    (ARRAY['LOW', 'MEDIUM', 'HIGH'])[1 + floor(random() * 3)],
    t.transaction_date::DATE,
    'Automated alert generated for unusual transaction pattern',
    t.amount,
    'USD',
    'Pattern ' || (1000 + floor(random() * 9000))::TEXT,
    CASE WHEN random() < 0.3 THEN 'OPEN' WHEN random() < 0.8 THEN 'INVESTIGATING' ELSE 'CLOSED' END,
    (1 + floor(random() * 10))::INTEGER
FROM core.transactions t
JOIN core.accounts a ON t.account_id = a.account_id
WHERE t.amount > 5000 -- Only large transactions
AND random() < 0.1 -- 10% of large transactions generate alerts
LIMIT 1000;

-- Generate compliance monitoring records
INSERT INTO compliance.compliance_monitoring (requirement_id, entity_type, entity_id, monitoring_date, due_date, status, compliance_percentage, monitored_by)
SELECT 
    (1 + floor(random() * 5))::INTEGER,
    'CUSTOMER',
    customer_id,
    (CURRENT_DATE - (random() * INTERVAL '30 days'))::DATE,
    (CURRENT_DATE + (random() * INTERVAL '30 days'))::DATE,
    (ARRAY['PENDING', 'COMPLIANT', 'NON_COMPLIANT'])[1 + floor(random() * 3)],
    (50 + random() * 50)::DECIMAL(5,2),
    (1 + floor(random() * 10))::INTEGER
FROM core.customers
WHERE customer_id <= 500 -- Monitor first 500 customers
AND random() < 0.5; -- 50% of customers have monitoring records

-- Generate payment instructions
INSERT INTO payment.payment_instructions (customer_id, account_id, payment_method_id, instruction_type, amount, currency_code, beneficiary_name, beneficiary_account, payment_reference, execution_date, status)
SELECT 
    a.customer_id,
    a.account_id,
    (1 + floor(random() * 3))::INTEGER,
    CASE WHEN random() < 0.8 THEN 'ONE_TIME' ELSE 'RECURRING' END,
    (10 + random() * 9990)::DECIMAL(15,2),
    'USD',
    core.random_first_name() || ' ' || core.random_last_name(),
    (1000000000 + floor(random() * 9000000000))::TEXT,
    'Payment ' || generate_series::TEXT,
    (CURRENT_DATE + (random() * INTERVAL '30 days'))::DATE,
    (ARRAY['PENDING', 'SCHEDULED', 'COMPLETED', 'FAILED'])[1 + floor(random() * 4)]
FROM generate_series(1, 1000) AS generate_series
CROSS JOIN (
    SELECT customer_id, account_id FROM core.accounts 
    WHERE account_id > 10 
    ORDER BY random() 
    LIMIT 1
) a;

-- Generate wire transfers
INSERT INTO payment.wire_transfers (transfer_number, customer_id, account_id, transfer_type, amount, currency_code, fees, sender_name, beneficiary_name, beneficiary_account, beneficiary_bank_name, value_date, status)
SELECT 
    'WIRE' || EXTRACT(YEAR FROM value_date)::TEXT || LPAD(generate_series::TEXT, 8, '0'),
    a.customer_id,
    a.account_id,
    CASE WHEN random() < 0.7 THEN 'DOMESTIC' ELSE 'INTERNATIONAL' END,
    (1000 + random() * 99000)::DECIMAL(15,2),
    'USD',
    CASE WHEN random() < 0.7 THEN 15.00 ELSE 45.00 END,
    c.first_name || ' ' || c.last_name,
    core.random_first_name() || ' ' || core.random_last_name(),
    (1000000000 + floor(random() * 9000000000))::TEXT,
    (ARRAY['Chase Bank', 'Bank of America', 'Wells Fargo', 'Citibank', 'US Bank'])[1 + floor(random() * 5)],
    (CURRENT_DATE - (random() * INTERVAL '60 days'))::DATE,
    CASE WHEN random() < 0.95 THEN 'COMPLETED' WHEN random() < 0.98 THEN 'PENDING' ELSE 'FAILED' END
FROM generate_series(1, 1000) AS generate_series
CROSS JOIN (
    SELECT customer_id, account_id FROM core.accounts 
    WHERE account_id > 10 
    ORDER BY random() 
    LIMIT 1
) a
JOIN core.customers c ON a.customer_id = c.customer_id
CROSS JOIN (VALUES (CURRENT_DATE - (random() * INTERVAL '60 days')::INTERVAL)) AS dates(value_date);

-- Generate analytics data
INSERT INTO analytics.customer_analytics (customer_id, analysis_date, total_relationship_value, product_count, average_balance, transaction_frequency, lifetime_value, churn_probability, cross_sell_propensity, risk_score, profitability_tier, segment)
SELECT 
    c.customer_id,
    (CURRENT_DATE - (generate_series * INTERVAL '1 month'))::DATE,
    (5000 + random() * 495000)::DECIMAL(18,2),
    (1 + floor(random() * 8))::INTEGER,
    (1000 + random() * 99000)::DECIMAL(18,2),
    (1 + random() * 50)::DECIMAL(8,2),
    (10000 + random() * 990000)::DECIMAL(18,2),
    (random() * 0.5)::DECIMAL(5,4),
    (random())::DECIMAL(5,4),
    (300 + floor(random() * 550))::INTEGER,
    (ARRAY['LOW', 'MEDIUM', 'HIGH'])[1 + floor(random() * 3)],
    (ARRAY['MASS_MARKET', 'AFFLUENT', 'PREMIUM', 'PRIVATE_BANKING'])[1 + floor(random() * 4)]
FROM core.customers c
CROSS JOIN generate_series(0, 11) -- 12 months of data
WHERE c.customer_id <= 200; -- First 200 customers

-- Generate product performance data
INSERT INTO analytics.product_performance (product_id, analysis_date, active_customers, new_customers, total_balance, transaction_volume, transaction_amount, fee_income, interest_income, net_income)
SELECT 
    p.product_id,
    (CURRENT_DATE - (generate_series * INTERVAL '1 month'))::DATE,
    (100 + floor(random() * 900))::INTEGER,
    (5 + floor(random() * 50))::INTEGER,
    (100000 + random() * 9900000)::DECIMAL(18,2),
    (1000 + floor(random() * 9000))::BIGINT,
    (50000 + random() * 950000)::DECIMAL(18,2),
    (1000 + random() * 9000)::DECIMAL(15,2),
    (2000 + random() * 18000)::DECIMAL(15,2),
    (500 + random() * 4500)::DECIMAL(15,2)
FROM core.products p
CROSS JOIN generate_series(0, 11); -- 12 months of data

-- Clean up temporary functions
DROP FUNCTION IF EXISTS core.random_first_name();
DROP FUNCTION IF EXISTS core.random_last_name();
DROP FUNCTION IF EXISTS core.random_email(VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS core.random_phone();
DROP FUNCTION IF EXISTS core.random_ssn();

-- Update statistics
ANALYZE;

-- Report generation summary
SELECT 
    'Data Generation Complete' AS status,
    (SELECT COUNT(*) FROM core.customers) AS customers,
    (SELECT COUNT(*) FROM core.accounts) AS accounts,
    (SELECT COUNT(*) FROM core.transactions) AS transactions,
    (SELECT COUNT(*) FROM loans.loans) AS loans,
    (SELECT COUNT(*) FROM trading.portfolios) AS portfolios,
    (SELECT COUNT(*) FROM cards.cards) AS cards,
    (SELECT COUNT(*) FROM compliance.aml_alerts) AS aml_alerts;

COMMENT ON SCRIPT IS 'Bulk data generation script creating 1000+ realistic records per table';
