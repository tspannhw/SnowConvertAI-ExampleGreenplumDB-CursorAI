-- Trading and Investment Tables (Schema: trading)
-- Tables for securities trading, portfolio management, and investment operations

\c financial_system;
SET search_path TO trading, core, public;

-- 26. Market Data Providers
CREATE TABLE trading.market_data_providers (
    provider_id SERIAL PRIMARY KEY,
    provider_code VARCHAR(10) NOT NULL UNIQUE,
    provider_name VARCHAR(100) NOT NULL,
    description TEXT,
    api_endpoint VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (provider_id);

-- 27. Exchanges
CREATE TABLE trading.exchanges (
    exchange_id SERIAL PRIMARY KEY,
    exchange_code VARCHAR(10) NOT NULL UNIQUE,
    exchange_name VARCHAR(100) NOT NULL,
    country_id INTEGER REFERENCES core.countries(country_id),
    timezone VARCHAR(50),
    trading_hours JSONB,
    settlement_days INTEGER DEFAULT 2,
    currency_code CHAR(3) REFERENCES core.currencies(currency_code),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (exchange_id);

-- 28. Security Types
CREATE TABLE trading.security_types (
    security_type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(10) NOT NULL UNIQUE,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    asset_class VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (security_type_id);

-- 29. Securities Master
CREATE TABLE trading.securities (
    security_id SERIAL PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL,
    exchange_id INTEGER REFERENCES trading.exchanges(exchange_id),
    security_type_id INTEGER REFERENCES trading.security_types(security_type_id),
    security_name VARCHAR(200) NOT NULL,
    isin VARCHAR(12),
    cusip VARCHAR(9),
    sedol VARCHAR(7),
    currency_code CHAR(3) REFERENCES core.currencies(currency_code),
    country_id INTEGER REFERENCES core.countries(country_id),
    sector VARCHAR(50),
    industry VARCHAR(50),
    market_cap DECIMAL(18,2),
    shares_outstanding BIGINT,
    ipo_date DATE,
    maturity_date DATE,
    coupon_rate DECIMAL(5,4),
    face_value DECIMAL(15,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(symbol, exchange_id)
) DISTRIBUTED BY (security_id);

-- 30. Market Data
CREATE TABLE trading.market_data (
    market_data_id BIGSERIAL PRIMARY KEY,
    security_id INTEGER REFERENCES trading.securities(security_id),
    trade_date DATE NOT NULL,
    open_price DECIMAL(15,4),
    high_price DECIMAL(15,4),
    low_price DECIMAL(15,4),
    close_price DECIMAL(15,4),
    volume BIGINT,
    adjusted_close DECIMAL(15,4),
    dividend_amount DECIMAL(10,4),
    split_ratio DECIMAL(10,4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(security_id, trade_date)
) DISTRIBUTED BY (security_id);

-- 31. Real-time Quotes
CREATE TABLE trading.real_time_quotes (
    quote_id BIGSERIAL PRIMARY KEY,
    security_id INTEGER REFERENCES trading.securities(security_id),
    bid_price DECIMAL(15,4),
    ask_price DECIMAL(15,4),
    bid_size INTEGER,
    ask_size INTEGER,
    last_price DECIMAL(15,4),
    last_size INTEGER,
    volume BIGINT,
    quote_timestamp TIMESTAMP NOT NULL,
    provider_id INTEGER REFERENCES trading.market_data_providers(provider_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (security_id);

-- 32. Trading Accounts
CREATE TABLE trading.trading_accounts (
    trading_account_id SERIAL PRIMARY KEY,
    account_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INTEGER REFERENCES core.customers(customer_id),
    account_type VARCHAR(20) DEFAULT 'CASH', -- CASH, MARGIN
    base_currency CHAR(3) REFERENCES core.currencies(currency_code),
    buying_power DECIMAL(18,2) DEFAULT 0,
    margin_requirement DECIMAL(18,2) DEFAULT 0,
    maintenance_margin DECIMAL(18,2) DEFAULT 0,
    day_trading_buying_power DECIMAL(18,2) DEFAULT 0,
    pattern_day_trader BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    opening_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (customer_id);

-- 33. Portfolio
CREATE TABLE trading.portfolios (
    portfolio_id SERIAL PRIMARY KEY,
    portfolio_name VARCHAR(100) NOT NULL,
    customer_id INTEGER REFERENCES core.customers(customer_id),
    trading_account_id INTEGER REFERENCES trading.trading_accounts(trading_account_id),
    manager_id INTEGER REFERENCES core.employees(employee_id),
    portfolio_type VARCHAR(20) DEFAULT 'INDIVIDUAL',
    investment_objective TEXT,
    risk_tolerance VARCHAR(20),
    benchmark_index VARCHAR(50),
    base_currency CHAR(3) REFERENCES core.currencies(currency_code),
    inception_date DATE NOT NULL,
    total_value DECIMAL(18,2) DEFAULT 0,
    total_cost DECIMAL(18,2) DEFAULT 0,
    unrealized_pnl DECIMAL(18,2) DEFAULT 0,
    realized_pnl DECIMAL(18,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (customer_id);

-- 34. Holdings
CREATE TABLE trading.holdings (
    holding_id SERIAL PRIMARY KEY,
    portfolio_id INTEGER REFERENCES trading.portfolios(portfolio_id),
    security_id INTEGER REFERENCES trading.securities(security_id),
    quantity DECIMAL(18,6) NOT NULL,
    average_cost DECIMAL(15,4),
    current_price DECIMAL(15,4),
    market_value DECIMAL(18,2),
    unrealized_pnl DECIMAL(18,2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(portfolio_id, security_id)
) DISTRIBUTED BY (portfolio_id);

-- 35. Order Types
CREATE TABLE trading.order_types (
    order_type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(10) NOT NULL UNIQUE,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (order_type_id);

-- 36. Order Status
CREATE TABLE trading.order_status (
    status_id SERIAL PRIMARY KEY,
    status_code VARCHAR(10) NOT NULL UNIQUE,
    status_name VARCHAR(50) NOT NULL,
    description TEXT,
    is_final BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (status_id);

-- 37. Orders
CREATE TABLE trading.orders (
    order_id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(30) NOT NULL UNIQUE,
    portfolio_id INTEGER REFERENCES trading.portfolios(portfolio_id),
    security_id INTEGER REFERENCES trading.securities(security_id),
    order_type_id INTEGER REFERENCES trading.order_types(order_type_id),
    status_id INTEGER REFERENCES trading.order_status(status_id),
    side VARCHAR(4) NOT NULL CHECK (side IN ('BUY', 'SELL')),
    quantity DECIMAL(18,6) NOT NULL,
    price DECIMAL(15,4),
    stop_price DECIMAL(15,4),
    time_in_force VARCHAR(10) DEFAULT 'DAY',
    order_date TIMESTAMP NOT NULL,
    expiry_date TIMESTAMP,
    filled_quantity DECIMAL(18,6) DEFAULT 0,
    remaining_quantity DECIMAL(18,6),
    average_fill_price DECIMAL(15,4),
    commission DECIMAL(10,2) DEFAULT 0,
    fees DECIMAL(10,2) DEFAULT 0,
    placed_by INTEGER REFERENCES core.employees(employee_id),
    cancelled_by INTEGER REFERENCES core.employees(employee_id),
    cancel_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (portfolio_id);

-- 38. Order Executions
CREATE TABLE trading.order_executions (
    execution_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES trading.orders(order_id),
    execution_price DECIMAL(15,4) NOT NULL,
    execution_quantity DECIMAL(18,6) NOT NULL,
    execution_time TIMESTAMP NOT NULL,
    execution_venue VARCHAR(50),
    trade_id VARCHAR(50),
    commission DECIMAL(10,2) DEFAULT 0,
    fees DECIMAL(10,2) DEFAULT 0,
    settlement_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (order_id);

-- 39. Trades
CREATE TABLE trading.trades (
    trade_id BIGSERIAL PRIMARY KEY,
    trade_number VARCHAR(30) NOT NULL UNIQUE,
    portfolio_id INTEGER REFERENCES trading.portfolios(portfolio_id),
    security_id INTEGER REFERENCES trading.securities(security_id),
    order_id BIGINT REFERENCES trading.orders(order_id),
    trade_date DATE NOT NULL,
    settlement_date DATE NOT NULL,
    side VARCHAR(4) NOT NULL CHECK (side IN ('BUY', 'SELL')),
    quantity DECIMAL(18,6) NOT NULL,
    price DECIMAL(15,4) NOT NULL,
    gross_amount DECIMAL(18,2) NOT NULL,
    commission DECIMAL(10,2) DEFAULT 0,
    fees DECIMAL(10,2) DEFAULT 0,
    taxes DECIMAL(10,2) DEFAULT 0,
    net_amount DECIMAL(18,2) NOT NULL,
    currency_code CHAR(3) REFERENCES core.currencies(currency_code),
    exchange_rate DECIMAL(18,8) DEFAULT 1,
    counterparty VARCHAR(100),
    trader_id INTEGER REFERENCES core.employees(employee_id),
    is_settled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (portfolio_id);

-- 40. Corporate Actions Types
CREATE TABLE trading.corporate_action_types (
    action_type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(10) NOT NULL UNIQUE,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    affects_quantity BOOLEAN DEFAULT FALSE,
    affects_price BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (action_type_id);

-- 41. Corporate Actions
CREATE TABLE trading.corporate_actions (
    corporate_action_id SERIAL PRIMARY KEY,
    security_id INTEGER REFERENCES trading.securities(security_id),
    action_type_id INTEGER REFERENCES trading.corporate_action_types(action_type_id),
    announcement_date DATE NOT NULL,
    ex_date DATE NOT NULL,
    record_date DATE,
    payment_date DATE,
    ratio_old DECIMAL(10,6),
    ratio_new DECIMAL(10,6),
    cash_amount DECIMAL(15,4),
    description TEXT,
    is_processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (security_id);

-- 42. Watchlists
CREATE TABLE trading.watchlists (
    watchlist_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES core.customers(customer_id),
    watchlist_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (customer_id);

-- 43. Watchlist Securities
CREATE TABLE trading.watchlist_securities (
    watchlist_security_id SERIAL PRIMARY KEY,
    watchlist_id INTEGER REFERENCES trading.watchlists(watchlist_id),
    security_id INTEGER REFERENCES trading.securities(security_id),
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    UNIQUE(watchlist_id, security_id)
) DISTRIBUTED BY (watchlist_id);

-- 44. Margin Requirements
CREATE TABLE trading.margin_requirements (
    margin_requirement_id SERIAL PRIMARY KEY,
    security_id INTEGER REFERENCES trading.securities(security_id),
    initial_margin DECIMAL(5,4) DEFAULT 0.5,
    maintenance_margin DECIMAL(5,4) DEFAULT 0.25,
    day_trading_margin DECIMAL(5,4) DEFAULT 0.25,
    effective_date DATE NOT NULL,
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (security_id);

-- 45. Position Valuations
CREATE TABLE trading.position_valuations (
    valuation_id BIGSERIAL PRIMARY KEY,
    portfolio_id INTEGER REFERENCES trading.portfolios(portfolio_id),
    security_id INTEGER REFERENCES trading.securities(security_id),
    valuation_date DATE NOT NULL,
    quantity DECIMAL(18,6) NOT NULL,
    unit_price DECIMAL(15,4) NOT NULL,
    market_value DECIMAL(18,2) NOT NULL,
    unrealized_pnl DECIMAL(18,2),
    currency_code CHAR(3) REFERENCES core.currencies(currency_code),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(portfolio_id, security_id, valuation_date)
) DISTRIBUTED BY (portfolio_id);

-- 46. Investment Research
CREATE TABLE trading.investment_research (
    research_id SERIAL PRIMARY KEY,
    security_id INTEGER REFERENCES trading.securities(security_id),
    analyst_id INTEGER REFERENCES core.employees(employee_id),
    research_date DATE NOT NULL,
    recommendation VARCHAR(20), -- BUY, SELL, HOLD, etc.
    target_price DECIMAL(15,4),
    rating VARCHAR(10),
    summary TEXT,
    research_note TEXT,
    published_date DATE,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (security_id);

-- 47. Broker Dealers
CREATE TABLE trading.broker_dealers (
    broker_dealer_id SERIAL PRIMARY KEY,
    firm_name VARCHAR(200) NOT NULL,
    firm_code VARCHAR(20) NOT NULL UNIQUE,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city_id INTEGER REFERENCES core.cities(city_id),
    phone VARCHAR(20),
    email VARCHAR(255),
    registration_number VARCHAR(50),
    regulatory_authority VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (broker_dealer_id);

-- 48. Prime Brokerage
CREATE TABLE trading.prime_brokerage (
    prime_brokerage_id SERIAL PRIMARY KEY,
    portfolio_id INTEGER REFERENCES trading.portfolios(portfolio_id),
    broker_dealer_id INTEGER REFERENCES trading.broker_dealers(broker_dealer_id),
    account_number VARCHAR(50),
    relationship_type VARCHAR(20), -- EXECUTING, CLEARING, CUSTODY
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (portfolio_id);

-- 49. Options
CREATE TABLE trading.options (
    option_id SERIAL PRIMARY KEY,
    underlying_security_id INTEGER REFERENCES trading.securities(security_id),
    option_symbol VARCHAR(20) NOT NULL UNIQUE,
    option_type VARCHAR(4) NOT NULL CHECK (option_type IN ('CALL', 'PUT')),
    strike_price DECIMAL(15,4) NOT NULL,
    expiration_date DATE NOT NULL,
    contract_size INTEGER DEFAULT 100,
    exercise_style VARCHAR(10) DEFAULT 'AMERICAN',
    currency_code CHAR(3) REFERENCES core.currencies(currency_code),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (underlying_security_id);

-- 50. Futures
CREATE TABLE trading.futures (
    future_id SERIAL PRIMARY KEY,
    future_symbol VARCHAR(20) NOT NULL UNIQUE,
    underlying_asset VARCHAR(100) NOT NULL,
    contract_month VARCHAR(7) NOT NULL, -- YYYY-MM format
    expiration_date DATE NOT NULL,
    contract_size DECIMAL(18,4) NOT NULL,
    tick_size DECIMAL(10,6) NOT NULL,
    currency_code CHAR(3) REFERENCES core.currencies(currency_code),
    exchange_id INTEGER REFERENCES trading.exchanges(exchange_id),
    settlement_type VARCHAR(20) DEFAULT 'CASH', -- CASH, PHYSICAL
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (future_id);

COMMENT ON SCHEMA trading IS 'Trading and investment tables for securities, portfolios, orders, and market data';
