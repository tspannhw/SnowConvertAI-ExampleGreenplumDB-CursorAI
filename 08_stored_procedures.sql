-- Stored Procedures for Financial System Business Logic
-- Comprehensive set of procedures for core banking operations

\c financial_system;
SET search_path TO core, trading, loans, risk, compliance, analytics, payment, cards, treasury, audit, public;

-- Customer Management Procedures
-- 1. Create new customer with validation
CREATE OR REPLACE FUNCTION core.create_customer(
    p_customer_type_id INTEGER,
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_date_of_birth DATE,
    p_email VARCHAR(255),
    p_phone VARCHAR(20),
    p_ssn VARCHAR(11),
    p_address_line1 VARCHAR(255),
    p_city_id INTEGER
) RETURNS INTEGER AS $$
DECLARE
    v_customer_id INTEGER;
    v_customer_number VARCHAR(20);
BEGIN
    -- Generate customer number
    SELECT 'CUST' || LPAD(nextval('core.customers_customer_id_seq')::TEXT, 8, '0') INTO v_customer_number;
    
    -- Insert customer
    INSERT INTO core.customers (
        customer_number, customer_type_id, first_name, last_name, 
        date_of_birth, email, phone, ssn_encrypted, status_id
    ) VALUES (
        v_customer_number, p_customer_type_id, p_first_name, p_last_name,
        p_date_of_birth, p_email, p_phone, crypt(p_ssn, gen_salt('bf')), 1
    ) RETURNING customer_id INTO v_customer_id;
    
    -- Insert address
    INSERT INTO core.customer_addresses (
        customer_id, address_line1, city_id, is_primary
    ) VALUES (
        v_customer_id, p_address_line1, p_city_id, TRUE
    );
    
    RETURN v_customer_id;
END;
$$ LANGUAGE plpgsql;

-- 2. Account creation with automatic GL entries
CREATE OR REPLACE FUNCTION core.create_account(
    p_customer_id INTEGER,
    p_account_type_id INTEGER,
    p_branch_id INTEGER,
    p_currency_code CHAR(3),
    p_initial_deposit DECIMAL(18,2) DEFAULT 0
) RETURNS INTEGER AS $$
DECLARE
    v_account_id INTEGER;
    v_account_number VARCHAR(30);
    v_gl_transaction_id BIGINT;
BEGIN
    -- Generate account number
    SELECT p_branch_id::TEXT || LPAD(nextval('core.accounts_account_id_seq')::TEXT, 10, '0') INTO v_account_number;
    
    -- Create account
    INSERT INTO core.accounts (
        account_number, customer_id, account_type_id, branch_id,
        currency_code, opening_date, current_balance, available_balance, status_id
    ) VALUES (
        v_account_number, p_customer_id, p_account_type_id, p_branch_id,
        p_currency_code, CURRENT_DATE, p_initial_deposit, p_initial_deposit, 1
    ) RETURNING account_id INTO v_account_id;
    
    -- Create GL transaction for initial deposit if > 0
    IF p_initial_deposit > 0 THEN
        INSERT INTO core.gl_transactions (
            transaction_date, description, total_debit, total_credit, status
        ) VALUES (
            CURRENT_DATE, 'Account Opening - Initial Deposit', p_initial_deposit, p_initial_deposit, 'APPROVED'
        ) RETURNING gl_transaction_id INTO v_gl_transaction_id;
        
        -- Debit Cash GL Account
        INSERT INTO core.gl_transaction_details (
            gl_transaction_id, gl_account_id, debit_amount, description
        ) VALUES (
            v_gl_transaction_id, 1001, p_initial_deposit, 'Cash received for account opening'
        );
        
        -- Credit Customer Deposit GL Account
        INSERT INTO core.gl_transaction_details (
            gl_transaction_id, gl_account_id, credit_amount, description
        ) VALUES (
            v_gl_transaction_id, 2001, p_initial_deposit, 'Customer deposit liability'
        );
    END IF;
    
    RETURN v_account_id;
END;
$$ LANGUAGE plpgsql;

-- 3. Process transaction with balance validation
CREATE OR REPLACE FUNCTION core.process_transaction(
    p_account_id INTEGER,
    p_transaction_type_id INTEGER,
    p_amount DECIMAL(18,2),
    p_description TEXT,
    p_reference_number VARCHAR(100) DEFAULT NULL
) RETURNS BIGINT AS $$
DECLARE
    v_transaction_id BIGINT;
    v_transaction_number VARCHAR(50);
    v_current_balance DECIMAL(18,2);
    v_available_balance DECIMAL(18,2);
    v_new_balance DECIMAL(18,2);
    v_is_debit BOOLEAN;
    v_overdraft_limit DECIMAL(15,2);
BEGIN
    -- Get current balances and overdraft limit
    SELECT current_balance, available_balance, overdraft_limit
    INTO v_current_balance, v_available_balance, v_overdraft_limit
    FROM core.accounts WHERE account_id = p_account_id;
    
    -- Get transaction type info
    SELECT is_debit INTO v_is_debit
    FROM core.transaction_types WHERE transaction_type_id = p_transaction_type_id;
    
    -- Calculate new balance
    IF v_is_debit THEN
        v_new_balance := v_current_balance - p_amount;
        -- Check for sufficient funds
        IF v_new_balance < (-1 * v_overdraft_limit) THEN
            RAISE EXCEPTION 'Insufficient funds. Available: %, Overdraft: %', v_available_balance, v_overdraft_limit;
        END IF;
    ELSE
        v_new_balance := v_current_balance + p_amount;
    END IF;
    
    -- Generate transaction number
    SELECT 'TXN' || EXTRACT(YEAR FROM CURRENT_DATE)::TEXT || 
           LPAD(nextval('core.transactions_transaction_id_seq')::TEXT, 12, '0') INTO v_transaction_number;
    
    -- Create transaction
    INSERT INTO core.transactions (
        transaction_number, account_id, transaction_type_id, amount,
        currency_code, balance_after, transaction_date, value_date,
        description, reference_number, status_id
    ) 
    SELECT 
        v_transaction_number, p_account_id, p_transaction_type_id, p_amount,
        currency_code, v_new_balance, CURRENT_TIMESTAMP, CURRENT_DATE,
        p_description, p_reference_number, 2 -- COMPLETED
    FROM core.accounts WHERE account_id = p_account_id
    RETURNING transaction_id INTO v_transaction_id;
    
    -- Update account balance
    UPDATE core.accounts 
    SET current_balance = v_new_balance,
        available_balance = v_new_balance + overdraft_limit,
        updated_at = CURRENT_TIMESTAMP
    WHERE account_id = p_account_id;
    
    RETURN v_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- 4. Money transfer between accounts
CREATE OR REPLACE FUNCTION core.transfer_funds(
    p_from_account_id INTEGER,
    p_to_account_id INTEGER,
    p_amount DECIMAL(18,2),
    p_description TEXT,
    p_reference_number VARCHAR(100) DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
    v_debit_txn_id BIGINT;
    v_credit_txn_id BIGINT;
    v_result JSONB;
BEGIN
    -- Validate accounts exist and are active
    IF NOT EXISTS (SELECT 1 FROM core.accounts WHERE account_id = p_from_account_id AND status_id = 1) THEN
        RAISE EXCEPTION 'Source account not found or inactive';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM core.accounts WHERE account_id = p_to_account_id AND status_id = 1) THEN
        RAISE EXCEPTION 'Destination account not found or inactive';
    END IF;
    
    -- Process debit transaction
    v_debit_txn_id := core.process_transaction(
        p_from_account_id, 2, p_amount, -- 2 = DEBIT transaction type
        'Transfer Out - ' || p_description, p_reference_number
    );
    
    -- Process credit transaction
    v_credit_txn_id := core.process_transaction(
        p_to_account_id, 1, p_amount, -- 1 = CREDIT transaction type
        'Transfer In - ' || p_description, p_reference_number
    );
    
    -- Return result
    SELECT jsonb_build_object(
        'debit_transaction_id', v_debit_txn_id,
        'credit_transaction_id', v_credit_txn_id,
        'status', 'SUCCESS',
        'amount', p_amount,
        'transfer_date', CURRENT_TIMESTAMP
    ) INTO v_result;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Loan Management Procedures
-- 5. Create loan application
CREATE OR REPLACE FUNCTION loans.create_loan_application(
    p_customer_id INTEGER,
    p_loan_product_id INTEGER,
    p_requested_amount DECIMAL(15,2),
    p_requested_term_months INTEGER,
    p_loan_purpose TEXT
) RETURNS INTEGER AS $$
DECLARE
    v_application_id INTEGER;
    v_application_number VARCHAR(30);
    v_min_amount DECIMAL(15,2);
    v_max_amount DECIMAL(15,2);
    v_min_term INTEGER;
    v_max_term INTEGER;
BEGIN
    -- Validate loan product limits
    SELECT min_amount, max_amount, min_term_months, max_term_months
    INTO v_min_amount, v_max_amount, v_min_term, v_max_term
    FROM loans.loan_products WHERE loan_product_id = p_loan_product_id AND is_active = TRUE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid or inactive loan product';
    END IF;
    
    IF p_requested_amount < v_min_amount OR p_requested_amount > v_max_amount THEN
        RAISE EXCEPTION 'Requested amount outside product limits: % to %', v_min_amount, v_max_amount;
    END IF;
    
    IF p_requested_term_months < v_min_term OR p_requested_term_months > v_max_term THEN
        RAISE EXCEPTION 'Requested term outside product limits: % to % months', v_min_term, v_max_term;
    END IF;
    
    -- Generate application number
    SELECT 'LA' || EXTRACT(YEAR FROM CURRENT_DATE)::TEXT || 
           LPAD(nextval('loans.loan_applications_application_id_seq')::TEXT, 8, '0') INTO v_application_number;
    
    -- Create application
    INSERT INTO loans.loan_applications (
        application_number, customer_id, loan_product_id,
        requested_amount, requested_term_months, loan_purpose,
        application_date, application_status
    ) VALUES (
        v_application_number, p_customer_id, p_loan_product_id,
        p_requested_amount, p_requested_term_months, p_loan_purpose,
        CURRENT_DATE, 'SUBMITTED'
    ) RETURNING application_id INTO v_application_id;
    
    RETURN v_application_id;
END;
$$ LANGUAGE plpgsql;

-- 6. Calculate loan payment schedule
CREATE OR REPLACE FUNCTION loans.calculate_payment_schedule(
    p_loan_id INTEGER
) RETURNS TABLE (
    payment_number INTEGER,
    due_date DATE,
    payment_amount DECIMAL(12,2),
    principal_amount DECIMAL(12,2),
    interest_amount DECIMAL(12,2),
    balance_after_payment DECIMAL(15,2)
) AS $$
DECLARE
    v_principal DECIMAL(15,2);
    v_rate DECIMAL(8,4);
    v_term INTEGER;
    v_payment DECIMAL(12,2);
    v_first_payment_date DATE;
    v_balance DECIMAL(15,2);
    v_interest DECIMAL(12,2);
    v_principal_payment DECIMAL(12,2);
    i INTEGER;
BEGIN
    -- Get loan details
    SELECT principal_amount, interest_rate, term_months, first_payment_date
    INTO v_principal, v_rate, v_term, v_first_payment_date
    FROM loans.loans WHERE loan_id = p_loan_id;
    
    -- Calculate monthly payment (PMT formula)
    v_payment := v_principal * (v_rate/12) * POWER(1 + v_rate/12, v_term) / 
                 (POWER(1 + v_rate/12, v_term) - 1);
    
    v_balance := v_principal;
    
    -- Generate payment schedule
    FOR i IN 1..v_term LOOP
        v_interest := v_balance * (v_rate / 12);
        v_principal_payment := v_payment - v_interest;
        v_balance := v_balance - v_principal_payment;
        
        payment_number := i;
        due_date := v_first_payment_date + INTERVAL '1 month' * (i - 1);
        payment_amount := v_payment;
        principal_amount := v_principal_payment;
        interest_amount := v_interest;
        balance_after_payment := v_balance;
        
        RETURN NEXT;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 7. Process loan payment
CREATE OR REPLACE FUNCTION loans.process_loan_payment(
    p_loan_id INTEGER,
    p_payment_amount DECIMAL(12,2),
    p_payment_date DATE DEFAULT CURRENT_DATE,
    p_payment_method VARCHAR(20) DEFAULT 'AUTO_DEBIT'
) RETURNS BIGINT AS $$
DECLARE
    v_payment_id BIGINT;
    v_current_balance DECIMAL(15,2);
    v_interest_rate DECIMAL(8,4);
    v_last_payment_date DATE;
    v_days_interest INTEGER;
    v_interest_amount DECIMAL(12,2);
    v_principal_amount DECIMAL(12,2);
    v_new_balance DECIMAL(15,2);
    v_account_id INTEGER;
BEGIN
    -- Get loan details
    SELECT principal_balance, interest_rate, last_payment_date, account_id
    INTO v_current_balance, v_interest_rate, v_last_payment_date, v_account_id
    FROM loans.loans WHERE loan_id = p_loan_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Loan not found';
    END IF;
    
    -- Calculate interest for the period
    v_days_interest := p_payment_date - COALESCE(v_last_payment_date, 
                      (SELECT disbursement_date FROM loans.loans WHERE loan_id = p_loan_id));
    v_interest_amount := v_current_balance * v_interest_rate * v_days_interest / 365;
    
    -- Calculate principal payment
    v_principal_amount := LEAST(p_payment_amount - v_interest_amount, v_current_balance);
    v_new_balance := v_current_balance - v_principal_amount;
    
    -- Create payment record
    INSERT INTO loans.loan_payments (
        loan_id, payment_date, payment_amount, principal_amount,
        interest_amount, payment_method, balance_after_payment
    ) VALUES (
        p_loan_id, p_payment_date, p_payment_amount, v_principal_amount,
        v_interest_amount, p_payment_method, v_new_balance
    ) RETURNING payment_id INTO v_payment_id;
    
    -- Update loan balance
    UPDATE loans.loans 
    SET principal_balance = v_new_balance,
        current_balance = v_new_balance,
        last_payment_date = p_payment_date,
        payments_made = payments_made + 1,
        total_payments_made = total_payments_made + p_payment_amount,
        updated_at = CURRENT_TIMESTAMP
    WHERE loan_id = p_loan_id;
    
    -- Process account transaction if account linked
    IF v_account_id IS NOT NULL THEN
        PERFORM core.process_transaction(
            v_account_id, 2, p_payment_amount, -- 2 = DEBIT
            'Loan Payment - Loan ID: ' || p_loan_id,
            'LOAN_PMT_' || v_payment_id::TEXT
        );
    END IF;
    
    RETURN v_payment_id;
END;
$$ LANGUAGE plpgsql;

-- Trading Procedures
-- 8. Place trading order
CREATE OR REPLACE FUNCTION trading.place_order(
    p_portfolio_id INTEGER,
    p_security_id INTEGER,
    p_order_type_id INTEGER,
    p_side VARCHAR(4),
    p_quantity DECIMAL(18,6),
    p_price DECIMAL(15,4) DEFAULT NULL,
    p_stop_price DECIMAL(15,4) DEFAULT NULL
) RETURNS BIGINT AS $$
DECLARE
    v_order_id BIGINT;
    v_order_number VARCHAR(30);
    v_buying_power DECIMAL(18,2);
    v_order_value DECIMAL(18,2);
BEGIN
    -- Validate portfolio exists
    IF NOT EXISTS (SELECT 1 FROM trading.portfolios WHERE portfolio_id = p_portfolio_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Portfolio not found or inactive';
    END IF;
    
    -- Validate security exists
    IF NOT EXISTS (SELECT 1 FROM trading.securities WHERE security_id = p_security_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Security not found or inactive';
    END IF;
    
    -- For buy orders, check buying power
    IF p_side = 'BUY' AND p_price IS NOT NULL THEN
        v_order_value := p_quantity * p_price;
        
        SELECT ta.buying_power INTO v_buying_power
        FROM trading.trading_accounts ta
        JOIN trading.portfolios p ON ta.trading_account_id = p.trading_account_id
        WHERE p.portfolio_id = p_portfolio_id;
        
        IF v_order_value > v_buying_power THEN
            RAISE EXCEPTION 'Insufficient buying power. Required: %, Available: %', v_order_value, v_buying_power;
        END IF;
    END IF;
    
    -- Generate order number
    SELECT 'ORD' || EXTRACT(YEAR FROM CURRENT_DATE)::TEXT ||
           LPAD(nextval('trading.orders_order_id_seq')::TEXT, 10, '0') INTO v_order_number;
    
    -- Create order
    INSERT INTO trading.orders (
        order_number, portfolio_id, security_id, order_type_id,
        side, quantity, price, stop_price, remaining_quantity,
        order_date, status_id
    ) VALUES (
        v_order_number, p_portfolio_id, p_security_id, p_order_type_id,
        p_side, p_quantity, p_price, p_stop_price, p_quantity,
        CURRENT_TIMESTAMP, 1 -- PENDING
    ) RETURNING order_id INTO v_order_id;
    
    RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;

-- 9. Execute trading order
CREATE OR REPLACE FUNCTION trading.execute_order(
    p_order_id BIGINT,
    p_execution_price DECIMAL(15,4),
    p_execution_quantity DECIMAL(18,6),
    p_execution_venue VARCHAR(50) DEFAULT 'INTERNAL'
) RETURNS BIGINT AS $$
DECLARE
    v_execution_id BIGINT;
    v_trade_id BIGINT;
    v_portfolio_id INTEGER;
    v_security_id INTEGER;
    v_side VARCHAR(4);
    v_remaining_qty DECIMAL(18,6);
    v_commission DECIMAL(10,2) := 9.99; -- Default commission
    v_gross_amount DECIMAL(18,2);
    v_net_amount DECIMAL(18,2);
    v_holding_id INTEGER;
    v_current_qty DECIMAL(18,6) := 0;
    v_new_qty DECIMAL(18,6);
BEGIN
    -- Get order details
    SELECT portfolio_id, security_id, side, remaining_quantity
    INTO v_portfolio_id, v_security_id, v_side, v_remaining_qty
    FROM trading.orders WHERE order_id = p_order_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order not found';
    END IF;
    
    IF p_execution_quantity > v_remaining_qty THEN
        RAISE EXCEPTION 'Execution quantity exceeds remaining order quantity';
    END IF;
    
    -- Calculate amounts
    v_gross_amount := p_execution_quantity * p_execution_price;
    v_net_amount := CASE WHEN v_side = 'BUY' THEN v_gross_amount + v_commission 
                         ELSE v_gross_amount - v_commission END;
    
    -- Create execution record
    INSERT INTO trading.order_executions (
        order_id, execution_price, execution_quantity,
        execution_time, execution_venue, commission
    ) VALUES (
        p_order_id, p_execution_price, p_execution_quantity,
        CURRENT_TIMESTAMP, p_execution_venue, v_commission
    ) RETURNING execution_id INTO v_execution_id;
    
    -- Create trade record
    INSERT INTO trading.trades (
        trade_number, portfolio_id, security_id, order_id,
        trade_date, settlement_date, side, quantity, price,
        gross_amount, commission, net_amount
    ) VALUES (
        'TRD' || EXTRACT(YEAR FROM CURRENT_DATE)::TEXT || 
        LPAD(nextval('trading.trades_trade_id_seq')::TEXT, 10, '0'),
        v_portfolio_id, v_security_id, p_order_id,
        CURRENT_DATE, CURRENT_DATE + INTERVAL '2 days', v_side,
        p_execution_quantity, p_execution_price, v_gross_amount,
        v_commission, v_net_amount
    ) RETURNING trade_id INTO v_trade_id;
    
    -- Update holdings
    SELECT holding_id, quantity INTO v_holding_id, v_current_qty
    FROM trading.holdings 
    WHERE portfolio_id = v_portfolio_id AND security_id = v_security_id;
    
    IF v_side = 'BUY' THEN
        v_new_qty := v_current_qty + p_execution_quantity;
    ELSE
        v_new_qty := v_current_qty - p_execution_quantity;
    END IF;
    
    IF v_holding_id IS NULL THEN
        -- Create new holding
        INSERT INTO trading.holdings (
            portfolio_id, security_id, quantity, average_cost
        ) VALUES (
            v_portfolio_id, v_security_id, v_new_qty, p_execution_price
        );
    ELSE
        -- Update existing holding
        UPDATE trading.holdings 
        SET quantity = v_new_qty,
            last_updated = CURRENT_TIMESTAMP
        WHERE holding_id = v_holding_id;
    END IF;
    
    -- Update order
    UPDATE trading.orders
    SET filled_quantity = filled_quantity + p_execution_quantity,
        remaining_quantity = remaining_quantity - p_execution_quantity,
        status_id = CASE WHEN remaining_quantity - p_execution_quantity = 0 THEN 3 ELSE 2 END, -- FILLED or PARTIAL_FILL
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id;
    
    RETURN v_execution_id;
END;
$$ LANGUAGE plpgsql;

-- Risk Management Procedures
-- 10. Calculate Value at Risk (VaR)
CREATE OR REPLACE FUNCTION risk.calculate_var(
    p_portfolio_id INTEGER,
    p_confidence_level DECIMAL(5,4) DEFAULT 0.95,
    p_time_horizon INTEGER DEFAULT 1
) RETURNS DECIMAL(18,2) AS $$
DECLARE
    v_portfolio_value DECIMAL(18,2);
    v_volatility DECIMAL(8,4);
    v_var DECIMAL(18,2);
    v_z_score DECIMAL(8,4);
BEGIN
    -- Get portfolio value
    SELECT total_value INTO v_portfolio_value
    FROM trading.portfolios WHERE portfolio_id = p_portfolio_id;
    
    -- Calculate portfolio volatility (simplified - would use more complex calculation in reality)
    SELECT AVG(
        CASE WHEN h.market_value > 0 
        THEN 0.20 * (h.market_value / v_portfolio_value) -- Weighted average volatility
        ELSE 0 END
    ) INTO v_volatility
    FROM trading.holdings h
    WHERE h.portfolio_id = p_portfolio_id;
    
    -- Get Z-score for confidence level (simplified lookup)
    v_z_score := CASE 
        WHEN p_confidence_level = 0.95 THEN 1.645
        WHEN p_confidence_level = 0.99 THEN 2.326
        ELSE 1.96 -- Default to 95%
    END;
    
    -- Calculate VaR: Portfolio Value * Volatility * Z-score * sqrt(time_horizon)
    v_var := v_portfolio_value * v_volatility * v_z_score * SQRT(p_time_horizon);
    
    -- Store calculation
    INSERT INTO risk.risk_measurements (
        entity_type, entity_id, risk_factor_id, measurement_date,
        measurement_value, confidence_level, time_horizon
    ) VALUES (
        'PORTFOLIO', p_portfolio_id, 1, CURRENT_DATE, -- Assuming risk_factor_id 1 is VaR
        v_var, p_confidence_level, p_time_horizon
    );
    
    RETURN v_var;
END;
$$ LANGUAGE plpgsql;

-- Analytics Procedures
-- 11. Calculate customer profitability
CREATE OR REPLACE FUNCTION analytics.calculate_customer_profitability(
    p_customer_id INTEGER,
    p_start_date DATE,
    p_end_date DATE
) RETURNS JSONB AS $$
DECLARE
    v_fee_income DECIMAL(15,2) := 0;
    v_interest_income DECIMAL(15,2) := 0;
    v_interest_expense DECIMAL(15,2) := 0;
    v_operational_cost DECIMAL(15,2) := 0;
    v_provision_expense DECIMAL(15,2) := 0;
    v_net_profit DECIMAL(15,2);
    v_result JSONB;
BEGIN
    -- Calculate fee income from transactions
    SELECT COALESCE(SUM(fee_amount), 0) INTO v_fee_income
    FROM core.transactions t
    JOIN core.accounts a ON t.account_id = a.account_id
    WHERE a.customer_id = p_customer_id
    AND t.transaction_date BETWEEN p_start_date AND p_end_date;
    
    -- Calculate interest income from loans
    SELECT COALESCE(SUM(lp.interest_amount), 0) INTO v_interest_income
    FROM loans.loan_payments lp
    JOIN loans.loans l ON lp.loan_id = l.loan_id
    WHERE l.customer_id = p_customer_id
    AND lp.payment_date BETWEEN p_start_date AND p_end_date;
    
    -- Calculate interest expense on deposits (simplified)
    SELECT COALESCE(SUM(current_balance * 0.01 / 365 * (p_end_date - p_start_date)), 0) INTO v_interest_expense
    FROM core.accounts
    WHERE customer_id = p_customer_id
    AND account_type_id IN (SELECT account_type_id FROM core.account_types WHERE is_interest_bearing = TRUE);
    
    -- Operational cost (simplified allocation)
    v_operational_cost := 50.00; -- Fixed monthly cost per customer
    
    -- Calculate net profit
    v_net_profit := v_fee_income + v_interest_income - v_interest_expense - v_operational_cost - v_provision_expense;
    
    -- Build result JSON
    SELECT jsonb_build_object(
        'customer_id', p_customer_id,
        'period_start', p_start_date,
        'period_end', p_end_date,
        'fee_income', v_fee_income,
        'interest_income', v_interest_income,
        'interest_expense', v_interest_expense,
        'operational_cost', v_operational_cost,
        'provision_expense', v_provision_expense,
        'net_profit', v_net_profit,
        'calculated_at', CURRENT_TIMESTAMP
    ) INTO v_result;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- 12. Daily batch processing
CREATE OR REPLACE FUNCTION core.run_daily_batch()
RETURNS TEXT AS $$
DECLARE
    v_processed_accounts INTEGER := 0;
    v_calculated_interests INTEGER := 0;
    v_result TEXT;
BEGIN
    -- Calculate daily interest for all accounts
    INSERT INTO core.interest_calculations (
        account_id, calculation_date, principal_amount, interest_rate,
        days_in_period, interest_earned, accrued_interest
    )
    SELECT 
        a.account_id,
        CURRENT_DATE,
        a.current_balance,
        at.interest_rate,
        1, -- Daily calculation
        a.current_balance * at.interest_rate / 365,
        COALESCE(ic.accrued_interest, 0) + (a.current_balance * at.interest_rate / 365)
    FROM core.accounts a
    JOIN core.account_types at ON a.account_type_id = at.account_type_id
    LEFT JOIN core.interest_calculations ic ON a.account_id = ic.account_id 
        AND ic.calculation_date = CURRENT_DATE - INTERVAL '1 day'
    WHERE at.is_interest_bearing = TRUE
    AND a.status_id = 1 -- Active accounts only
    AND NOT EXISTS (
        SELECT 1 FROM core.interest_calculations 
        WHERE account_id = a.account_id AND calculation_date = CURRENT_DATE
    );
    
    GET DIAGNOSTICS v_calculated_interests = ROW_COUNT;
    
    -- Update account balances for dormancy check
    UPDATE core.accounts 
    SET is_dormant = TRUE
    WHERE account_id IN (
        SELECT account_id FROM core.accounts a
        WHERE NOT EXISTS (
            SELECT 1 FROM core.transactions t
            WHERE t.account_id = a.account_id
            AND t.transaction_date > CURRENT_DATE - INTERVAL '12 months'
        )
        AND is_dormant = FALSE
    );
    
    GET DIAGNOSTICS v_processed_accounts = ROW_COUNT;
    
    v_result := 'Daily batch completed. ' ||
                'Interest calculated for ' || v_calculated_interests || ' accounts. ' ||
                'Marked ' || v_processed_accounts || ' accounts as dormant.';
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION core.create_customer IS 'Creates a new customer with validation and address';
COMMENT ON FUNCTION core.create_account IS 'Creates a new account with automatic GL entries';
COMMENT ON FUNCTION core.process_transaction IS 'Processes a transaction with balance validation';
COMMENT ON FUNCTION core.transfer_funds IS 'Transfers funds between two accounts';
COMMENT ON FUNCTION loans.create_loan_application IS 'Creates a new loan application with validation';
COMMENT ON FUNCTION loans.calculate_payment_schedule IS 'Calculates amortization schedule for a loan';
COMMENT ON FUNCTION loans.process_loan_payment IS 'Processes a loan payment and updates balances';
COMMENT ON FUNCTION trading.place_order IS 'Places a new trading order with validation';
COMMENT ON FUNCTION trading.execute_order IS 'Executes a trading order and updates holdings';
COMMENT ON FUNCTION risk.calculate_var IS 'Calculates Value at Risk for a portfolio';
COMMENT ON FUNCTION analytics.calculate_customer_profitability IS 'Calculates customer profitability for a period';
COMMENT ON FUNCTION core.run_daily_batch IS 'Runs daily batch processing for interest and dormancy';
