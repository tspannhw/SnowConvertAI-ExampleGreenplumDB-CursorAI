-- Sample Data Insertion Scripts
-- Comprehensive sample data for testing and demonstration

\c financial_system;
SET search_path TO core, trading, loans, risk, compliance, analytics, payment, cards, treasury, audit, public;

-- Reference Data
-- Countries
INSERT INTO core.countries (country_code, country_name, currency_code, phone_code) VALUES
('US', 'United States', 'USD', '+1'),
('CA', 'Canada', 'CAD', '+1'),
('GB', 'United Kingdom', 'GBP', '+44'),
('DE', 'Germany', 'EUR', '+49'),
('JP', 'Japan', 'JPY', '+81'),
('AU', 'Australia', 'AUD', '+61'),
('CH', 'Switzerland', 'CHF', '+41'),
('SG', 'Singapore', 'SGD', '+65'),
('HK', 'Hong Kong', 'HKD', '+852'),
('IN', 'India', 'INR', '+91');

-- States
INSERT INTO core.states (country_id, state_code, state_name) VALUES
(1, 'NY', 'New York'),
(1, 'CA', 'California'),
(1, 'TX', 'Texas'),
(1, 'FL', 'Florida'),
(1, 'IL', 'Illinois'),
(2, 'ON', 'Ontario'),
(2, 'BC', 'British Columbia'),
(3, 'ENG', 'England'),
(3, 'SCT', 'Scotland');

-- Cities
INSERT INTO core.cities (state_id, city_name, postal_code) VALUES
(1, 'New York City', '10001'),
(1, 'Albany', '12201'),
(2, 'Los Angeles', '90001'),
(2, 'San Francisco', '94101'),
(3, 'Houston', '77001'),
(3, 'Dallas', '75201'),
(4, 'Miami', '33101'),
(4, 'Tampa', '33601'),
(5, 'Chicago', '60601'),
(6, 'Toronto', 'M5A'),
(7, 'Vancouver', 'V6B'),
(8, 'London', 'SW1A'),
(9, 'Edinburgh', 'EH1');

-- Currencies
INSERT INTO core.currencies (currency_code, currency_name, currency_symbol, decimal_places) VALUES
('USD', 'US Dollar', '$', 2),
('EUR', 'Euro', '€', 2),
('GBP', 'British Pound', '£', 2),
('JPY', 'Japanese Yen', '¥', 0),
('CAD', 'Canadian Dollar', 'C$', 2),
('AUD', 'Australian Dollar', 'A$', 2),
('CHF', 'Swiss Franc', 'CHF', 2),
('SGD', 'Singapore Dollar', 'S$', 2),
('HKD', 'Hong Kong Dollar', 'HK$', 2),
('INR', 'Indian Rupee', '₹', 2);

-- Exchange Rates
INSERT INTO core.exchange_rates (from_currency, to_currency, rate, effective_date) VALUES
('USD', 'EUR', 0.85, CURRENT_DATE),
('USD', 'GBP', 0.73, CURRENT_DATE),
('USD', 'JPY', 110.0, CURRENT_DATE),
('USD', 'CAD', 1.25, CURRENT_DATE),
('EUR', 'USD', 1.18, CURRENT_DATE),
('GBP', 'USD', 1.37, CURRENT_DATE),
('JPY', 'USD', 0.009, CURRENT_DATE);

-- Customer Types
INSERT INTO core.customer_types (type_name, description) VALUES
('Individual', 'Personal banking customers'),
('Business', 'Business and corporate customers'),
('Private Banking', 'High net worth individuals'),
('Institutional', 'Institutional investors'),
('Government', 'Government entities');

-- Customer Status
INSERT INTO core.customer_status (status_name, description) VALUES
('Active', 'Active customer'),
('Inactive', 'Inactive customer'),
('Suspended', 'Suspended customer'),
('Closed', 'Closed customer');

-- Account Types
INSERT INTO core.account_types (type_code, type_name, description, min_balance, interest_rate, is_interest_bearing) VALUES
('CHK', 'Checking', 'Standard checking account', 0.00, 0.0001, true),
('SAV', 'Savings', 'Standard savings account', 100.00, 0.0150, true),
('MMA', 'Money Market', 'Money market account', 2500.00, 0.0200, true),
('CD', 'Certificate of Deposit', 'Time deposit account', 1000.00, 0.0300, true),
('LOC', 'Line of Credit', 'Credit line account', 0.00, 0.0000, false),
('LOAN', 'Loan Account', 'Loan account', 0.00, 0.0000, false);

-- Account Status
INSERT INTO core.account_status (status_code, status_name, description) VALUES
('ACT', 'Active', 'Active account'),
('SUS', 'Suspended', 'Suspended account'),
('CLO', 'Closed', 'Closed account'),
('FRZ', 'Frozen', 'Frozen account');

-- Transaction Types
INSERT INTO core.transaction_types (type_code, type_name, description, is_debit, is_credit, fee_applicable) VALUES
('DEP', 'Deposit', 'Deposit transaction', false, true, false),
('WTH', 'Withdrawal', 'Withdrawal transaction', true, false, true),
('TRF', 'Transfer', 'Transfer transaction', true, false, true),
('FEE', 'Fee', 'Fee transaction', true, false, false),
('INT', 'Interest', 'Interest credit', false, true, false),
('CHK', 'Check', 'Check transaction', true, false, true),
('ATM', 'ATM', 'ATM transaction', true, false, true),
('POS', 'Point of Sale', 'POS transaction', true, false, false);

-- Transaction Status
INSERT INTO core.transaction_status (status_code, status_name, description, is_final) VALUES
('PEN', 'Pending', 'Pending transaction', false),
('PRO', 'Processing', 'Processing transaction', false),
('COM', 'Completed', 'Completed transaction', true),
('FAI', 'Failed', 'Failed transaction', true),
('CAN', 'Cancelled', 'Cancelled transaction', true);

-- Branches
INSERT INTO core.branches (branch_code, branch_name, branch_type, address_line1, city_id, phone, email, opening_date) VALUES
('BR001', 'Manhattan Main Branch', 'FULL_SERVICE', '123 Wall Street', 1, '+1-212-555-0001', 'manhattan@bank.com', '2020-01-01'),
('BR002', 'Los Angeles Branch', 'FULL_SERVICE', '456 Sunset Blvd', 3, '+1-213-555-0002', 'losangeles@bank.com', '2020-02-01'),
('BR003', 'Chicago Branch', 'FULL_SERVICE', '789 Michigan Ave', 9, '+1-312-555-0003', 'chicago@bank.com', '2020-03-01'),
('BR004', 'San Francisco Branch', 'FULL_SERVICE', '321 Market Street', 4, '+1-415-555-0004', 'sanfrancisco@bank.com', '2020-04-01'),
('BR005', 'Miami Branch', 'FULL_SERVICE', '654 Biscayne Blvd', 7, '+1-305-555-0005', 'miami@bank.com', '2020-05-01');

-- Employees
INSERT INTO core.employees (employee_number, first_name, last_name, email, phone, hire_date, branch_id, department, position, salary) VALUES
('EMP001', 'John', 'Smith', 'john.smith@bank.com', '+1-212-555-1001', '2020-01-15', 1, 'Customer Service', 'Branch Manager', 85000.00),
('EMP002', 'Sarah', 'Johnson', 'sarah.johnson@bank.com', '+1-213-555-1002', '2020-02-15', 2, 'Customer Service', 'Branch Manager', 82000.00),
('EMP003', 'Michael', 'Brown', 'michael.brown@bank.com', '+1-312-555-1003', '2020-03-15', 3, 'Customer Service', 'Branch Manager', 80000.00),
('EMP004', 'Emily', 'Davis', 'emily.davis@bank.com', '+1-415-555-1004', '2020-04-15', 4, 'Customer Service', 'Branch Manager', 88000.00),
('EMP005', 'David', 'Wilson', 'david.wilson@bank.com', '+1-305-555-1005', '2020-05-15', 5, 'Customer Service', 'Branch Manager', 78000.00),
('EMP006', 'Jennifer', 'Martinez', 'jennifer.martinez@bank.com', '+1-212-555-1006', '2020-06-01', 1, 'Lending', 'Loan Officer', 65000.00),
('EMP007', 'Robert', 'Garcia', 'robert.garcia@bank.com', '+1-213-555-1007', '2020-07-01', 2, 'Trading', 'Trader', 95000.00),
('EMP008', 'Lisa', 'Rodriguez', 'lisa.rodriguez@bank.com', '+1-312-555-1008', '2020-08-01', 3, 'Risk Management', 'Risk Analyst', 75000.00),
('EMP009', 'Christopher', 'Lee', 'christopher.lee@bank.com', '+1-415-555-1009', '2020-09-01', 4, 'Compliance', 'Compliance Officer', 70000.00),
('EMP010', 'Amanda', 'Taylor', 'amanda.taylor@bank.com', '+1-305-555-1010', '2020-10-01', 5, 'Operations', 'Operations Manager', 72000.00);

-- Sample Customers
INSERT INTO core.customers (customer_number, customer_type_id, first_name, last_name, date_of_birth, gender, email, phone, mobile, status_id, kyc_status, risk_rating, created_by) VALUES
('CUST00000001', 1, 'Alice', 'Anderson', '1985-03-15', 'F', 'alice.anderson@email.com', '+1-212-555-2001', '+1-917-555-2001', 1, 'COMPLETED', 'LOW', 1),
('CUST00000002', 1, 'Bob', 'Baker', '1978-07-22', 'M', 'bob.baker@email.com', '+1-213-555-2002', '+1-323-555-2002', 1, 'COMPLETED', 'LOW', 2),
('CUST00000003', 1, 'Carol', 'Chen', '1990-11-08', 'F', 'carol.chen@email.com', '+1-312-555-2003', '+1-773-555-2003', 1, 'COMPLETED', 'MEDIUM', 3),
('CUST00000004', 1, 'Daniel', 'Davis', '1982-05-14', 'M', 'daniel.davis@email.com', '+1-415-555-2004', '+1-628-555-2004', 1, 'COMPLETED', 'LOW', 4),
('CUST00000005', 1, 'Emma', 'Evans', '1975-09-30', 'F', 'emma.evans@email.com', '+1-305-555-2005', '+1-786-555-2005', 1, 'COMPLETED', 'HIGH', 5),
('CUST00000006', 2, 'Tech Solutions Inc', '', '2015-01-01', 'O', 'admin@techsolutions.com', '+1-212-555-3001', '+1-212-555-3001', 1, 'COMPLETED', 'MEDIUM', 1),
('CUST00000007', 3, 'Frank', 'Foster', '1965-12-05', 'M', 'frank.foster@email.com', '+1-213-555-2007', '+1-310-555-2007', 1, 'COMPLETED', 'LOW', 2),
('CUST00000008', 1, 'Grace', 'Garcia', '1988-04-18', 'F', 'grace.garcia@email.com', '+1-312-555-2008', '+1-872-555-2008', 1, 'COMPLETED', 'MEDIUM', 3),
('CUST00000009', 1, 'Henry', 'Harris', '1983-08-25', 'M', 'henry.harris@email.com', '+1-415-555-2009', '+1-650-555-2009', 1, 'COMPLETED', 'LOW', 4),
('CUST00000010', 1, 'Isabel', 'Jackson', '1992-02-12', 'F', 'isabel.jackson@email.com', '+1-305-555-2010', '+1-954-555-2010', 1, 'COMPLETED', 'MEDIUM', 5);

-- Customer Addresses
INSERT INTO core.customer_addresses (customer_id, address_type, address_line1, address_line2, city_id, postal_code, is_primary) VALUES
(1, 'HOME', '100 Park Avenue', 'Apt 15B', 1, '10016', true),
(2, 'HOME', '200 Beverly Drive', '', 3, '90210', true),
(3, 'HOME', '300 Lake Shore Drive', 'Unit 25A', 9, '60611', true),
(4, 'HOME', '400 Union Square', '', 4, '94108', true),
(5, 'HOME', '500 Ocean Drive', 'Penthouse', 7, '33139', true),
(6, 'BUSINESS', '600 Broadway', 'Suite 1200', 1, '10012', true),
(7, 'HOME', '700 Rodeo Drive', '', 3, '90212', true),
(8, 'HOME', '800 North Shore', 'Apt 8C', 9, '60614', true),
(9, 'HOME', '900 Lombard Street', '', 4, '94109', true),
(10, 'HOME', '1000 Collins Avenue', 'Unit 501', 7, '33141', true);

-- Sample Accounts
INSERT INTO core.accounts (account_number, customer_id, account_type_id, branch_id, currency_code, opening_date, current_balance, available_balance, status_id) VALUES
('10010000000001', 1, 1, 1, 'USD', '2023-01-15', 5250.75, 5250.75, 1),
('10010000000002', 1, 2, 1, 'USD', '2023-01-15', 15000.00, 15000.00, 1),
('20020000000003', 2, 1, 2, 'USD', '2023-02-20', 3750.25, 3750.25, 1),
('20020000000004', 2, 3, 2, 'USD', '2023-02-20', 25000.00, 25000.00, 1),
('30030000000005', 3, 1, 3, 'USD', '2023-03-10', 2180.50, 2180.50, 1),
('30030000000006', 3, 2, 3, 'USD', '2023-03-10', 8500.00, 8500.00, 1),
('40040000000007', 4, 1, 4, 'USD', '2023-04-05', 7825.30, 7825.30, 1),
('40040000000008', 4, 4, 4, 'USD', '2023-04-05', 50000.00, 50000.00, 1),
('50050000000009', 5, 1, 5, 'USD', '2023-05-12', 12675.85, 12675.85, 1),
('50050000000010', 5, 3, 5, 'USD', '2023-05-12', 150000.00, 150000.00, 1);

-- Sample Transactions
INSERT INTO core.transactions (transaction_number, account_id, transaction_type_id, amount, currency_code, balance_after, transaction_date, value_date, description, status_id, channel) VALUES
('TXN202301150000001', 1, 1, 5000.00, 'USD', 5000.00, '2023-01-15 10:30:00', '2023-01-15', 'Initial deposit', 3, 'BRANCH'),
('TXN202301160000002', 1, 1, 250.75, 'USD', 5250.75, '2023-01-16 14:22:00', '2023-01-16', 'Payroll deposit', 3, 'ACH'),
('TXN202301170000003', 1, 2, 100.00, 'USD', 5150.75, '2023-01-17 09:15:00', '2023-01-17', 'ATM withdrawal', 3, 'ATM'),
('TXN202301180000004', 1, 8, 45.25, 'USD', 5105.50, '2023-01-18 16:45:00', '2023-01-18', 'Grocery store purchase', 3, 'POS'),
('TXN202301190000005', 1, 2, 200.00, 'USD', 4905.50, '2023-01-19 11:30:00', '2023-01-19', 'Online purchase', 3, 'ONLINE'),
('TXN202301200000006', 2, 1, 25000.00, 'USD', 25000.00, '2023-02-20 11:00:00', '2023-02-20', 'Initial deposit', 3, 'BRANCH'),
('TXN202301210000007', 3, 1, 3000.00, 'USD', 3000.00, '2023-03-10 15:30:00', '2023-03-10', 'Initial deposit', 3, 'BRANCH'),
('TXN202301220000008', 4, 1, 50000.00, 'USD', 50000.00, '2023-04-05 10:15:00', '2023-04-05', 'Certificate of Deposit', 3, 'BRANCH'),
('TXN202301230000009', 5, 1, 150000.00, 'USD', 150000.00, '2023-05-12 14:45:00', '2023-05-12', 'Large deposit', 3, 'WIRE'),
('TXN202301240000010', 1, 5, 2.15, 'USD', 4907.65, '2023-01-31 23:59:00', '2023-01-31', 'Monthly interest', 3, 'SYSTEM');

-- Trading Data
-- Exchanges
INSERT INTO trading.exchanges (exchange_code, exchange_name, country_id, timezone, currency_code) VALUES
('NYSE', 'New York Stock Exchange', 1, 'America/New_York', 'USD'),
('NASDAQ', 'NASDAQ', 1, 'America/New_York', 'USD'),
('LSE', 'London Stock Exchange', 3, 'Europe/London', 'GBP'),
('TSE', 'Tokyo Stock Exchange', 5, 'Asia/Tokyo', 'JPY'),
('TSX', 'Toronto Stock Exchange', 2, 'America/Toronto', 'CAD');

-- Security Types
INSERT INTO trading.security_types (type_code, type_name, description, asset_class) VALUES
('STK', 'Stock', 'Common stock', 'EQUITY'),
('BND', 'Bond', 'Corporate or government bond', 'FIXED_INCOME'),
('ETF', 'ETF', 'Exchange traded fund', 'EQUITY'),
('OPT', 'Option', 'Stock option', 'DERIVATIVES'),
('FUT', 'Future', 'Futures contract', 'DERIVATIVES');

-- Sample Securities
INSERT INTO trading.securities (symbol, exchange_id, security_type_id, security_name, isin, currency_code, country_id, sector, industry, market_cap, shares_outstanding) VALUES
('AAPL', 2, 1, 'Apple Inc.', 'US0378331005', 'USD', 1, 'Technology', 'Consumer Electronics', 2800000000000, 16000000000),
('GOOGL', 2, 1, 'Alphabet Inc.', 'US02079K3059', 'USD', 1, 'Technology', 'Internet Services', 1800000000000, 13000000000),
('MSFT', 2, 1, 'Microsoft Corporation', 'US5949181045', 'USD', 1, 'Technology', 'Software', 2500000000000, 7500000000),
('TSLA', 2, 1, 'Tesla Inc.', 'US88160R1014', 'USD', 1, 'Consumer Cyclical', 'Auto Manufacturers', 800000000000, 3000000000),
('AMZN', 2, 1, 'Amazon.com Inc.', 'US0231351067', 'USD', 1, 'Consumer Cyclical', 'Internet Retail', 1600000000000, 10000000000),
('SPY', 1, 3, 'SPDR S&P 500 ETF Trust', 'US78462F1030', 'USD', 1, 'ETF', 'Broad Market', 400000000000, 900000000),
('QQQ', 2, 3, 'Invesco QQQ Trust', 'US46090E1038', 'USD', 1, 'ETF', 'Technology', 200000000000, 500000000);

-- Market Data
INSERT INTO trading.market_data (security_id, trade_date, open_price, high_price, low_price, close_price, volume, adjusted_close) VALUES
(1, '2024-01-15', 182.50, 185.20, 181.80, 184.75, 45000000, 184.75),
(1, '2024-01-16', 184.80, 186.50, 183.90, 185.25, 42000000, 185.25),
(2, '2024-01-15', 142.30, 144.80, 141.75, 143.90, 28000000, 143.90),
(2, '2024-01-16', 144.00, 145.25, 143.10, 144.50, 26000000, 144.50),
(3, '2024-01-15', 375.20, 378.90, 374.50, 377.25, 22000000, 377.25),
(3, '2024-01-16', 377.50, 379.80, 376.20, 378.90, 20000000, 378.90),
(4, '2024-01-15', 238.50, 242.10, 236.80, 241.25, 35000000, 241.25),
(4, '2024-01-16', 241.80, 243.50, 240.20, 242.75, 33000000, 242.75),
(5, '2024-01-15', 148.90, 151.20, 147.50, 150.80, 31000000, 150.80),
(5, '2024-01-16', 151.00, 152.75, 149.90, 151.50, 29000000, 151.50);

-- Trading Accounts
INSERT INTO trading.trading_accounts (account_number, customer_id, account_type, base_currency, buying_power, opening_date) VALUES
('TRD0000000001', 5, 'MARGIN', 'USD', 300000.00, '2023-05-15'),
('TRD0000000002', 7, 'CASH', 'USD', 150000.00, '2023-06-20'),
('TRD0000000003', 1, 'CASH', 'USD', 25000.00, '2023-07-10'),
('TRD0000000004', 4, 'MARGIN', 'USD', 100000.00, '2023-08-05');

-- Portfolios
INSERT INTO trading.portfolios (portfolio_name, customer_id, trading_account_id, portfolio_type, investment_objective, risk_tolerance, base_currency, inception_date, total_value, total_cost) VALUES
('Growth Portfolio', 5, 1, 'INDIVIDUAL', 'Long-term capital appreciation', 'AGGRESSIVE', 'USD', '2023-05-15', 285000.00, 250000.00),
('Conservative Portfolio', 7, 2, 'INDIVIDUAL', 'Capital preservation with income', 'CONSERVATIVE', 'USD', '2023-06-20', 148500.00, 150000.00),
('Starter Portfolio', 1, 3, 'INDIVIDUAL', 'Learning and growth', 'MODERATE', 'USD', '2023-07-10', 24750.00, 25000.00),
('Balanced Portfolio', 4, 4, 'INDIVIDUAL', 'Balanced growth and income', 'MODERATE', 'USD', '2023-08-05', 98200.00, 100000.00);

-- Holdings
INSERT INTO trading.holdings (portfolio_id, security_id, quantity, average_cost, current_price, market_value, unrealized_pnl) VALUES
(1, 1, 500, 180.00, 185.25, 92625.00, 2625.00),
(1, 2, 300, 140.00, 144.50, 43350.00, 1350.00),
(1, 3, 200, 370.00, 378.90, 75780.00, 1780.00),
(1, 4, 150, 235.00, 242.75, 36412.50, 1162.50),
(2, 6, 400, 375.00, 372.50, 149000.00, -1000.00),
(3, 1, 50, 182.00, 185.25, 9262.50, 162.50),
(3, 6, 40, 380.00, 372.50, 14900.00, -300.00),
(4, 1, 200, 185.00, 185.25, 37050.00, 50.00),
(4, 3, 100, 375.00, 378.90, 37890.00, 390.00),
(4, 7, 75, 315.00, 312.00, 23400.00, -225.00);

-- Loan Products
INSERT INTO loans.loan_products (product_code, product_name, loan_type, description, min_amount, max_amount, min_term_months, max_term_months, base_interest_rate, processing_fee) VALUES
('PL001', 'Personal Loan Standard', 'PERSONAL', 'Standard personal loan for general purposes', 1000.00, 50000.00, 12, 60, 0.1250, 99.00),
('PL002', 'Personal Loan Premium', 'PERSONAL', 'Premium personal loan for qualified borrowers', 5000.00, 100000.00, 12, 84, 0.0950, 149.00),
('AL001', 'Auto Loan New', 'AUTO', 'Auto loan for new vehicles', 5000.00, 75000.00, 24, 72, 0.0450, 0.00),
('AL002', 'Auto Loan Used', 'AUTO', 'Auto loan for used vehicles', 3000.00, 50000.00, 24, 60, 0.0650, 0.00),
('HL001', 'Home Mortgage 30Y', 'MORTGAGE', '30-year fixed rate mortgage', 50000.00, 2000000.00, 360, 360, 0.0650, 500.00),
('BL001', 'Business Term Loan', 'BUSINESS', 'Term loan for business expansion', 10000.00, 500000.00, 12, 120, 0.0850, 250.00);

-- Sample Loan Applications
INSERT INTO loans.loan_applications (application_number, customer_id, loan_product_id, requested_amount, requested_term_months, loan_purpose, application_date, application_status, decision, decision_amount, decision_term_months, decision_rate) VALUES
('LA2024010001', 2, 1, 15000.00, 36, 'Debt consolidation', '2024-01-10', 'APPROVED', 'APPROVED', 15000.00, 36, 0.1250),
('LA2024010002', 3, 3, 25000.00, 60, 'Vehicle purchase', '2024-01-15', 'APPROVED', 'APPROVED', 25000.00, 60, 0.0450),
('LA2024010003', 4, 5, 350000.00, 360, 'Home purchase', '2024-01-20', 'PROCESSING', NULL, NULL, NULL, NULL),
('LA2024010004', 8, 2, 30000.00, 48, 'Home improvement', '2024-01-25', 'APPROVED', 'APPROVED', 28000.00, 48, 0.0950),
('LA2024010005', 9, 6, 75000.00, 60, 'Business expansion', '2024-02-01', 'PENDING', NULL, NULL, NULL, NULL);

-- Sample Loans
INSERT INTO loans.loans (loan_number, application_id, customer_id, loan_product_id, principal_amount, interest_rate, term_months, payment_amount, disbursement_date, first_payment_date, maturity_date, current_balance, principal_balance, originated_by, branch_id) VALUES
('LN2024010001', 1, 2, 1, 15000.00, 0.1250, 36, 509.18, '2024-01-15', '2024-02-15', '2027-01-15', 14750.00, 14750.00, 6, 2),
('LN2024010002', 2, 3, 3, 25000.00, 0.0450, 60, 465.51, '2024-01-20', '2024-02-20', '2029-01-20', 24800.00, 24800.00, 6, 3),
('LN2024010003', 4, 8, 2, 28000.00, 0.0950, 48, 715.32, '2024-02-01', '2024-03-01', '2028-02-01', 28000.00, 28000.00, 6, 3);

-- Loan Payments
INSERT INTO loans.loan_payments (loan_id, payment_date, payment_amount, principal_amount, interest_amount, payment_method, balance_after_payment) VALUES
(1, '2024-02-15', 509.18, 353.18, 156.00, 'AUTO_DEBIT', 14396.82),
(1, '2024-03-15', 509.18, 356.85, 152.33, 'AUTO_DEBIT', 14039.97),
(2, '2024-02-20', 465.51, 372.26, 93.25, 'AUTO_DEBIT', 24427.74),
(2, '2024-03-20', 465.51, 373.65, 91.86, 'AUTO_DEBIT', 24054.09),
(3, '2024-03-01', 715.32, 492.99, 222.33, 'AUTO_DEBIT', 27507.01);

-- Risk Categories
INSERT INTO risk.risk_categories (category_code, category_name, description) VALUES
('MKT', 'Market Risk', 'Risk from market price movements'),
('CRD', 'Credit Risk', 'Risk of borrower default'),
('LIQ', 'Liquidity Risk', 'Risk of insufficient liquidity'),
('OPR', 'Operational Risk', 'Risk from operational failures'),
('INT', 'Interest Rate Risk', 'Risk from interest rate changes');

-- Risk Factors
INSERT INTO risk.risk_factors (factor_code, factor_name, risk_category_id, description, measurement_unit) VALUES
('VAR_1D', '1-Day Value at Risk', 1, 'Value at Risk over 1 day horizon', 'USD'),
('PD', 'Probability of Default', 2, 'Probability of default over 1 year', 'Percentage'),
('LCR', 'Liquidity Coverage Ratio', 3, 'Basel III liquidity coverage ratio', 'Ratio'),
('OPER_LOSS', 'Operational Loss', 4, 'Operational loss events', 'USD'),
('DUR_GAP', 'Duration Gap', 5, 'Asset-liability duration mismatch', 'Years');

-- System Parameters
INSERT INTO core.system_parameters (parameter_name, parameter_value, parameter_type, description, category) VALUES
('MAX_DAILY_TRANSFER_LIMIT', '50000.00', 'DECIMAL', 'Maximum daily transfer limit per customer', 'LIMITS'),
('MIN_ACCOUNT_BALANCE', '0.00', 'DECIMAL', 'Minimum account balance to maintain', 'LIMITS'),
('OVERDRAFT_FEE', '35.00', 'DECIMAL', 'Fee charged for overdraft', 'FEES'),
('INTEREST_ACCRUAL_METHOD', 'DAILY', 'STRING', 'Method for accruing interest', 'CALCULATION'),
('BACKUP_RETENTION_DAYS', '90', 'INTEGER', 'Number of days to retain backups', 'SYSTEM'),
('SESSION_TIMEOUT_MINUTES', '30', 'INTEGER', 'Session timeout in minutes', 'SECURITY'),
('PASSWORD_MIN_LENGTH', '8', 'INTEGER', 'Minimum password length', 'SECURITY'),
('AML_TRANSACTION_THRESHOLD', '10000.00', 'DECIMAL', 'Transaction amount threshold for AML monitoring', 'COMPLIANCE');

-- Business Calendar (sample dates)
INSERT INTO core.business_calendar (calendar_date, is_business_day, is_banking_day, is_trading_day, day_of_week, month_end, quarter_end, year_end) VALUES
('2024-01-01', false, false, false, 1, false, false, true), -- New Year's Day
('2024-01-02', true, true, true, 2, false, false, false),
('2024-01-03', true, true, true, 3, false, false, false),
('2024-01-31', true, true, true, 3, true, false, false),
('2024-02-01', true, true, true, 4, false, false, false),
('2024-02-29', true, true, true, 4, true, false, false),
('2024-03-31', true, true, true, 7, true, true, false),
('2024-12-25', false, false, false, 3, false, false, false), -- Christmas
('2024-12-31', true, true, false, 2, true, true, true); -- New Year's Eve

-- Holidays
INSERT INTO core.holidays (holiday_name, holiday_date, country_id, is_banking_holiday, is_trading_holiday) VALUES
('New Year''s Day', '2024-01-01', 1, true, true),
('Martin Luther King Jr. Day', '2024-01-15', 1, true, true),
('Presidents Day', '2024-02-19', 1, true, true),
('Memorial Day', '2024-05-27', 1, true, true),
('Independence Day', '2024-07-04', 1, true, true),
('Labor Day', '2024-09-02', 1, true, true),
('Columbus Day', '2024-10-14', 1, true, false),
('Veterans Day', '2024-11-11', 1, true, true),
('Thanksgiving', '2024-11-28', 1, true, true),
('Christmas Day', '2024-12-25', 1, true, true);

-- GL Accounts
INSERT INTO core.gl_accounts (account_code, account_name, account_type, normal_balance, current_balance) VALUES
('1001', 'Cash and Cash Equivalents', 'ASSET', 'DEBIT', 500000.00),
('1101', 'Customer Loans', 'ASSET', 'DEBIT', 750000.00),
('1201', 'Securities Owned', 'ASSET', 'DEBIT', 250000.00),
('1301', 'Fixed Assets', 'ASSET', 'DEBIT', 1000000.00),
('2001', 'Customer Deposits', 'LIABILITY', 'CREDIT', 1200000.00),
('2101', 'Borrowed Funds', 'LIABILITY', 'CREDIT', 500000.00),
('3001', 'Shareholders Equity', 'EQUITY', 'CREDIT', 800000.00),
('4001', 'Interest Income', 'REVENUE', 'CREDIT', 0.00),
('4101', 'Fee Income', 'REVENUE', 'CREDIT', 0.00),
('5001', 'Interest Expense', 'EXPENSE', 'DEBIT', 0.00),
('5101', 'Operating Expenses', 'EXPENSE', 'DEBIT', 0.00),
('5201', 'Provision for Loan Losses', 'EXPENSE', 'DEBIT', 0.00);

-- Product Categories
INSERT INTO core.product_categories (category_code, category_name, description) VALUES
('DEP', 'Deposits', 'Deposit products'),
('LEN', 'Lending', 'Lending products'),
('INV', 'Investments', 'Investment products'),
('PAY', 'Payments', 'Payment services'),
('INS', 'Insurance', 'Insurance products');

-- Products
INSERT INTO core.products (product_code, product_name, category_id, description, min_amount, max_amount, interest_rate, is_active, launch_date) VALUES
('CHK001', 'Basic Checking', 1, 'Basic checking account with no minimum balance', 0.00, NULL, 0.0001, true, '2020-01-01'),
('SAV001', 'High Yield Savings', 1, 'High yield savings account', 100.00, NULL, 0.0450, true, '2020-01-01'),
('CD001', '12-Month CD', 1, '12-month certificate of deposit', 1000.00, NULL, 0.0500, true, '2020-01-01'),
('MF001', 'S&P 500 Index Fund', 3, 'Low-cost S&P 500 index mutual fund', 1000.00, NULL, NULL, true, '2020-01-01'),
('CC001', 'Rewards Credit Card', 4, 'Credit card with cash back rewards', NULL, 10000.00, 0.1999, true, '2020-01-01');

-- Sample compliance and risk data
INSERT INTO compliance.regulatory_authorities (authority_code, authority_name, country_id, website) VALUES
('FDIC', 'Federal Deposit Insurance Corporation', 1, 'https://www.fdic.gov'),
('FED', 'Federal Reserve', 1, 'https://www.federalreserve.gov'),
('OCC', 'Office of the Comptroller of the Currency', 1, 'https://www.occ.gov'),
('FINRA', 'Financial Industry Regulatory Authority', 1, 'https://www.finra.org'),
('SEC', 'Securities and Exchange Commission', 1, 'https://www.sec.gov');

INSERT INTO compliance.regulations (regulation_code, regulation_name, authority_id, description, effective_date) VALUES
('BSA', 'Bank Secrecy Act', 1, 'Anti-money laundering regulations', '1970-10-26'),
('FCRA', 'Fair Credit Reporting Act', 2, 'Consumer credit reporting regulations', '1970-10-26'),
('CRA', 'Community Reinvestment Act', 2, 'Community lending requirements', '1977-10-12'),
('BASEL_III', 'Basel III Capital Requirements', 2, 'International banking capital standards', '2010-12-16'),
('GDPR', 'General Data Protection Regulation', 1, 'Data privacy regulations', '2018-05-25');

COMMENT ON TABLE core.customers IS 'Customer master data with personal and business information';
COMMENT ON TABLE core.accounts IS 'Customer accounts including checking, savings, and loans';
COMMENT ON TABLE core.transactions IS 'All financial transactions across the system';
COMMENT ON TABLE loans.loans IS 'Active loans and their current status';
COMMENT ON TABLE trading.portfolios IS 'Investment portfolios and holdings';
COMMENT ON TABLE risk.risk_measurements IS 'Risk metrics and measurements';
COMMENT ON TABLE compliance.aml_alerts IS 'Anti-money laundering alerts and investigations';
