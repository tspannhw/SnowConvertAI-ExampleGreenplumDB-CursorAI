-- Views for Reporting and Analytics
-- Comprehensive set of views for business intelligence and operational reporting

\c financial_system;
SET search_path TO core, trading, loans, risk, compliance, analytics, payment, cards, treasury, audit, public;

-- Customer and Account Views
-- 1. Customer Summary View
CREATE OR REPLACE VIEW analytics.customer_summary AS
SELECT 
    c.customer_id,
    c.customer_number,
    c.first_name || ' ' || c.last_name AS full_name,
    c.email,
    c.phone,
    ct.type_name AS customer_type,
    cs.status_name AS customer_status,
    c.date_of_birth,
    EXTRACT(YEAR FROM AGE(c.date_of_birth)) AS age,
    c.kyc_status,
    c.risk_rating,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    SUM(a.current_balance) AS total_balance,
    AVG(a.current_balance) AS average_balance,
    MAX(a.opening_date) AS latest_account_date,
    c.created_at AS customer_since
FROM core.customers c
LEFT JOIN core.customer_types ct ON c.customer_type_id = ct.customer_type_id
LEFT JOIN core.customer_status cs ON c.status_id = cs.status_id
LEFT JOIN core.accounts a ON c.customer_id = a.customer_id AND a.status_id = 1
GROUP BY c.customer_id, c.customer_number, c.first_name, c.last_name, 
         c.email, c.phone, ct.type_name, cs.status_name, c.date_of_birth,
         c.kyc_status, c.risk_rating, c.created_at;

-- 2. Account Details View
CREATE OR REPLACE VIEW analytics.account_details AS
SELECT 
    a.account_id,
    a.account_number,
    c.customer_number,
    c.first_name || ' ' || c.last_name AS customer_name,
    at.type_name AS account_type,
    ast.status_name AS account_status,
    b.branch_name,
    a.currency_code,
    a.opening_date,
    a.current_balance,
    a.available_balance,
    a.overdraft_limit,
    a.is_dormant,
    CASE 
        WHEN a.is_dormant THEN 'Dormant'
        WHEN a.current_balance = 0 THEN 'Zero Balance'
        WHEN a.current_balance < 0 THEN 'Overdrawn'
        WHEN a.current_balance > 100000 THEN 'High Value'
        ELSE 'Normal'
    END AS balance_category,
    COUNT(t.transaction_id) AS transaction_count_last_30_days
FROM core.accounts a
JOIN core.customers c ON a.customer_id = c.customer_id
JOIN core.account_types at ON a.account_type_id = at.account_type_id
JOIN core.account_status ast ON a.status_id = ast.status_id
LEFT JOIN core.branches b ON a.branch_id = b.branch_id
LEFT JOIN core.transactions t ON a.account_id = t.account_id 
    AND t.transaction_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY a.account_id, a.account_number, c.customer_number, c.first_name, 
         c.last_name, at.type_name, ast.status_name, b.branch_name,
         a.currency_code, a.opening_date, a.current_balance, a.available_balance,
         a.overdraft_limit, a.is_dormant;

-- 3. Transaction Analysis View
CREATE OR REPLACE VIEW analytics.transaction_analysis AS
SELECT 
    DATE_TRUNC('month', t.transaction_date) AS transaction_month,
    tt.type_name AS transaction_type,
    COUNT(*) AS transaction_count,
    SUM(t.amount) AS total_amount,
    AVG(t.amount) AS average_amount,
    MIN(t.amount) AS min_amount,
    MAX(t.amount) AS max_amount,
    COUNT(DISTINCT t.account_id) AS unique_accounts,
    SUM(t.fee_amount) AS total_fees
FROM core.transactions t
JOIN core.transaction_types tt ON t.transaction_type_id = tt.transaction_type_id
WHERE t.transaction_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY DATE_TRUNC('month', t.transaction_date), tt.type_name
ORDER BY transaction_month DESC, transaction_count DESC;

-- Loan and Credit Views
-- 4. Loan Portfolio View
CREATE OR REPLACE VIEW loans.loan_portfolio_summary AS
SELECT 
    lp.product_name,
    lp.loan_type,
    COUNT(l.loan_id) AS active_loans,
    SUM(l.principal_amount) AS total_originated,
    SUM(l.current_balance) AS outstanding_balance,
    SUM(l.principal_amount - l.current_balance) AS principal_paid,
    AVG(l.interest_rate) AS average_rate,
    AVG(l.term_months) AS average_term,
    COUNT(CASE WHEN l.delinquency_status != 'CURRENT' THEN 1 END) AS delinquent_loans,
    SUM(CASE WHEN l.delinquency_status != 'CURRENT' THEN l.current_balance ELSE 0 END) AS delinquent_balance,
    ROUND(
        COUNT(CASE WHEN l.delinquency_status != 'CURRENT' THEN 1 END)::DECIMAL / 
        NULLIF(COUNT(l.loan_id), 0) * 100, 2
    ) AS delinquency_rate_percent
FROM loans.loans l
JOIN loans.loan_products lp ON l.loan_product_id = lp.loan_product_id
WHERE l.loan_status = 'ACTIVE'
GROUP BY lp.product_name, lp.loan_type
ORDER BY outstanding_balance DESC;

-- 5. Delinquency Report View
CREATE OR REPLACE VIEW loans.delinquency_report AS
SELECT 
    l.loan_number,
    c.customer_number,
    c.first_name || ' ' || c.last_name AS customer_name,
    lp.product_name,
    l.current_balance,
    l.payment_amount,
    l.next_payment_date,
    l.days_past_due,
    l.delinquency_status,
    CASE 
        WHEN l.days_past_due BETWEEN 1 AND 30 THEN '1-30 Days'
        WHEN l.days_past_due BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN l.days_past_due BETWEEN 61 AND 90 THEN '61-90 Days'
        WHEN l.days_past_due > 90 THEN '90+ Days'
        ELSE 'Current'
    END AS delinquency_bucket,
    dt.collection_status,
    dt.last_contact_date,
    dt.next_contact_date
FROM loans.loans l
JOIN core.customers c ON l.customer_id = c.customer_id
JOIN loans.loan_products lp ON l.loan_product_id = lp.loan_product_id
LEFT JOIN loans.delinquency_tracking dt ON l.loan_id = dt.loan_id
WHERE l.delinquency_status != 'CURRENT'
ORDER BY l.days_past_due DESC, l.current_balance DESC;

-- Trading and Investment Views
-- 6. Portfolio Performance View
CREATE OR REPLACE VIEW trading.portfolio_performance AS
SELECT 
    p.portfolio_id,
    p.portfolio_name,
    c.customer_number,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.base_currency,
    p.total_value,
    p.total_cost,
    p.unrealized_pnl,
    p.realized_pnl,
    ROUND((p.total_value - p.total_cost) / NULLIF(p.total_cost, 0) * 100, 2) AS total_return_percent,
    COUNT(h.holding_id) AS number_of_holdings,
    AVG(h.market_value) AS average_holding_value,
    MAX(h.market_value) AS largest_holding_value,
    SUM(CASE WHEN h.unrealized_pnl > 0 THEN h.unrealized_pnl ELSE 0 END) AS gains,
    SUM(CASE WHEN h.unrealized_pnl < 0 THEN h.unrealized_pnl ELSE 0 END) AS losses
FROM trading.portfolios p
JOIN core.customers c ON p.customer_id = c.customer_id
LEFT JOIN trading.holdings h ON p.portfolio_id = h.portfolio_id
WHERE p.is_active = TRUE
GROUP BY p.portfolio_id, p.portfolio_name, c.customer_number, c.first_name, 
         c.last_name, p.base_currency, p.total_value, p.total_cost,
         p.unrealized_pnl, p.realized_pnl
ORDER BY p.total_value DESC;

-- 7. Trading Activity View
CREATE OR REPLACE VIEW trading.trading_activity AS
SELECT 
    DATE_TRUNC('day', t.trade_date) AS trade_date,
    s.symbol,
    s.security_name,
    st.type_name AS security_type,
    e.exchange_name,
    t.side,
    COUNT(*) AS trade_count,
    SUM(t.quantity) AS total_quantity,
    SUM(t.gross_amount) AS total_value,
    AVG(t.price) AS average_price,
    SUM(t.commission) AS total_commission,
    COUNT(DISTINCT t.portfolio_id) AS unique_portfolios
FROM trading.trades t
JOIN trading.securities s ON t.security_id = s.security_id
JOIN trading.security_types st ON s.security_type_id = st.security_type_id
JOIN trading.exchanges e ON s.exchange_id = e.exchange_id
WHERE t.trade_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY DATE_TRUNC('day', t.trade_date), s.symbol, s.security_name,
         st.type_name, e.exchange_name, t.side
ORDER BY trade_date DESC, total_value DESC;

-- Risk Management Views
-- 8. Risk Exposure View
CREATE OR REPLACE VIEW risk.risk_exposure_summary AS
SELECT 
    rm.entity_type,
    rf.factor_name,
    rc.category_name AS risk_category,
    COUNT(rm.measurement_id) AS measurement_count,
    AVG(rm.measurement_value) AS average_exposure,
    MAX(rm.measurement_value) AS maximum_exposure,
    MIN(rm.measurement_value) AS minimum_exposure,
    STDDEV(rm.measurement_value) AS exposure_volatility,
    MAX(rm.measurement_date) AS latest_measurement_date,
    COUNT(rlb.breach_id) AS breach_count
FROM risk.risk_measurements rm
JOIN risk.risk_factors rf ON rm.risk_factor_id = rf.risk_factor_id
JOIN risk.risk_categories rc ON rf.risk_category_id = rc.risk_category_id
LEFT JOIN risk.risk_limits rl ON rm.entity_type = rl.entity_type 
    AND rm.entity_id = rl.entity_id AND rm.risk_factor_id = rl.risk_factor_id
LEFT JOIN risk.risk_limit_breaches rlb ON rl.risk_limit_id = rlb.risk_limit_id
WHERE rm.measurement_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY rm.entity_type, rf.factor_name, rc.category_name
ORDER BY average_exposure DESC;

-- 9. Credit Risk Dashboard
CREATE OR REPLACE VIEW risk.credit_risk_dashboard AS
SELECT 
    cr.entity_type,
    COUNT(DISTINCT cr.entity_id) AS total_entities,
    AVG(CASE WHEN cr.probability_of_default IS NOT NULL 
        THEN cr.probability_of_default * 100 ELSE NULL END) AS avg_pd_percent,
    AVG(CASE WHEN cr.loss_given_default IS NOT NULL 
        THEN cr.loss_given_default * 100 ELSE NULL END) AS avg_lgd_percent,
    COUNT(CASE WHEN cr.current_rating IN ('AAA', 'AA+', 'AA', 'AA-') THEN 1 END) AS investment_grade,
    COUNT(CASE WHEN cr.current_rating NOT IN ('AAA', 'AA+', 'AA', 'AA-', 'A+', 'A', 'A-', 'BBB+', 'BBB', 'BBB-') THEN 1 END) AS speculative_grade,
    COUNT(CASE WHEN cr.outlook = 'NEGATIVE' THEN 1 END) AS negative_outlook,
    COUNT(CASE WHEN cr.watch_status = 'NEGATIVE' THEN 1 END) AS negative_watch
FROM risk.credit_ratings cr
WHERE cr.is_active = TRUE
GROUP BY cr.entity_type
ORDER BY total_entities DESC;

-- Compliance Views
-- 10. AML Alerts Dashboard
CREATE OR REPLACE VIEW compliance.aml_alerts_dashboard AS
SELECT 
    DATE_TRUNC('month', aa.alert_date) AS alert_month,
    aa.alert_type,
    aa.alert_priority,
    COUNT(*) AS alert_count,
    COUNT(CASE WHEN aa.status = 'OPEN' THEN 1 END) AS open_alerts,
    COUNT(CASE WHEN aa.status = 'CLOSED' THEN 1 END) AS closed_alerts,
    COUNT(CASE WHEN aa.false_positive = TRUE THEN 1 END) AS false_positives,
    ROUND(
        COUNT(CASE WHEN aa.false_positive = TRUE THEN 1 END)::DECIMAL / 
        NULLIF(COUNT(*), 0) * 100, 2
    ) AS false_positive_rate,
    AVG(EXTRACT(DAYS FROM aa.closed_date - aa.alert_date)) AS avg_resolution_days
FROM compliance.aml_alerts aa
WHERE aa.alert_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY DATE_TRUNC('month', aa.alert_date), aa.alert_type, aa.alert_priority
ORDER BY alert_month DESC, alert_count DESC;

-- 11. Regulatory Compliance Status
CREATE OR REPLACE VIEW compliance.compliance_status AS
SELECT 
    reg.regulation_name,
    ra.authority_name,
    cr.requirement_name,
    cm.entity_type,
    COUNT(cm.monitoring_id) AS total_checks,
    COUNT(CASE WHEN cm.status = 'COMPLIANT' THEN 1 END) AS compliant_count,
    COUNT(CASE WHEN cm.status = 'NON_COMPLIANT' THEN 1 END) AS non_compliant_count,
    COUNT(CASE WHEN cm.status = 'OVERDUE' THEN 1 END) AS overdue_count,
    ROUND(
        COUNT(CASE WHEN cm.status = 'COMPLIANT' THEN 1 END)::DECIMAL / 
        NULLIF(COUNT(cm.monitoring_id), 0) * 100, 2
    ) AS compliance_rate_percent,
    MAX(cm.monitoring_date) AS last_check_date,
    MIN(cm.due_date) AS next_due_date
FROM compliance.compliance_monitoring cm
JOIN compliance.compliance_requirements cr ON cm.requirement_id = cr.requirement_id
JOIN compliance.regulations reg ON cr.regulation_id = reg.regulation_id
JOIN compliance.regulatory_authorities ra ON reg.authority_id = ra.authority_id
WHERE cm.monitoring_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY reg.regulation_name, ra.authority_name, cr.requirement_name, cm.entity_type
ORDER BY compliance_rate_percent ASC, non_compliant_count DESC;

-- Analytics and Reporting Views
-- 12. Profitability Analysis
CREATE OR REPLACE VIEW analytics.profitability_analysis AS
SELECT 
    DATE_TRUNC('month', analysis_date) AS analysis_month,
    'Customer' AS entity_type,
    AVG(total_relationship_value) AS avg_relationship_value,
    AVG(lifetime_value) AS avg_lifetime_value,
    COUNT(CASE WHEN profitability_tier = 'HIGH' THEN 1 END) AS high_value_customers,
    COUNT(CASE WHEN profitability_tier = 'MEDIUM' THEN 1 END) AS medium_value_customers,
    COUNT(CASE WHEN profitability_tier = 'LOW' THEN 1 END) AS low_value_customers,
    AVG(churn_probability) AS avg_churn_probability,
    AVG(cross_sell_propensity) AS avg_cross_sell_propensity
FROM analytics.customer_analytics
WHERE analysis_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY DATE_TRUNC('month', analysis_date)
ORDER BY analysis_month DESC;

-- 13. Branch Performance View
CREATE OR REPLACE VIEW analytics.branch_performance AS
SELECT 
    b.branch_id,
    b.branch_code,
    b.branch_name,
    b.branch_type,
    c.city_name,
    s.state_name,
    COUNT(DISTINCT acc.customer_id) AS total_customers,
    COUNT(DISTINCT acc.account_id) AS total_accounts,
    SUM(acc.current_balance) AS total_deposits,
    AVG(acc.current_balance) AS average_balance,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    SUM(l.current_balance) AS total_loan_balance,
    COUNT(DISTINCT CASE WHEN acc.opening_date >= CURRENT_DATE - INTERVAL '30 days' 
          THEN acc.account_id END) AS new_accounts_last_30_days,
    COUNT(DISTINCT e.employee_id) AS employee_count
FROM core.branches b
LEFT JOIN core.cities c ON b.city_id = c.city_id
LEFT JOIN core.states s ON c.state_id = s.state_id
LEFT JOIN core.accounts acc ON b.branch_id = acc.branch_id AND acc.status_id = 1
LEFT JOIN loans.loans l ON b.branch_id = l.branch_id AND l.loan_status = 'ACTIVE'
LEFT JOIN core.employees e ON b.branch_id = e.branch_id AND e.is_active = TRUE
WHERE b.is_active = TRUE
GROUP BY b.branch_id, b.branch_code, b.branch_name, b.branch_type,
         c.city_name, s.state_name
ORDER BY total_deposits DESC;

-- 14. Product Performance View
CREATE OR REPLACE VIEW analytics.product_performance_summary AS
SELECT 
    pp.product_id,
    p.product_name,
    pc.category_name,
    DATE_TRUNC('month', pp.analysis_date) AS performance_month,
    pp.active_customers,
    pp.new_customers,
    pp.closed_accounts,
    pp.total_balance,
    pp.fee_income,
    pp.interest_income,
    pp.net_income,
    pp.market_share,
    ROUND((pp.new_customers::DECIMAL / NULLIF(pp.active_customers, 0)) * 100, 2) AS growth_rate,
    ROUND((pp.net_income / NULLIF(pp.total_balance, 0)) * 100, 2) AS return_on_assets
FROM analytics.product_performance pp
JOIN core.products p ON pp.product_id = p.product_id
JOIN core.product_categories pc ON p.category_id = pc.category_id
WHERE pp.analysis_date >= CURRENT_DATE - INTERVAL '1 year'
ORDER BY performance_month DESC, pp.net_income DESC;

-- 15. Operational Metrics View
CREATE OR REPLACE VIEW analytics.operational_metrics AS
SELECT 
    measurement_date,
    'System Performance' AS metric_category,
    active_connections,
    transactions_per_second,
    query_response_time,
    cache_hit_ratio,
    deadlocks_detected,
    slow_queries,
    CASE 
        WHEN cpu_usage > 80 THEN 'HIGH'
        WHEN cpu_usage > 60 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS cpu_usage_level,
    CASE 
        WHEN memory_usage > 85 THEN 'HIGH'
        WHEN memory_usage > 70 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS memory_usage_level
FROM audit.database_performance
WHERE metric_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY measurement_date DESC;

-- 16. Customer Segmentation View
CREATE OR REPLACE VIEW analytics.customer_segmentation AS
SELECT 
    segment,
    COUNT(*) AS customer_count,
    AVG(total_relationship_value) AS avg_relationship_value,
    AVG(lifetime_value) AS avg_lifetime_value,
    AVG(product_count) AS avg_products_per_customer,
    AVG(average_balance) AS avg_account_balance,
    AVG(churn_probability) AS avg_churn_probability,
    AVG(cross_sell_propensity) AS avg_cross_sell_propensity,
    ROUND(COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM analytics.customer_analytics) * 100, 2) AS segment_percentage
FROM analytics.customer_analytics ca
WHERE analysis_date = (SELECT MAX(analysis_date) FROM analytics.customer_analytics)
GROUP BY segment
ORDER BY avg_relationship_value DESC;

-- 17. Transaction Monitoring View
CREATE OR REPLACE VIEW compliance.transaction_monitoring AS
SELECT 
    DATE_TRUNC('day', t.transaction_date) AS transaction_date,
    COUNT(*) AS total_transactions,
    SUM(t.amount) AS total_amount,
    COUNT(CASE WHEN t.amount >= 10000 THEN 1 END) AS large_transactions,
    COUNT(CASE WHEN t.amount >= 10000 THEN 1 END)::DECIMAL / COUNT(*) * 100 AS large_transaction_rate,
    COUNT(DISTINCT t.account_id) AS unique_accounts,
    COUNT(CASE WHEN ss.match_found = TRUE THEN 1 END) AS sanctions_matches,
    COUNT(CASE WHEN aa.alert_id IS NOT NULL THEN 1 END) AS aml_alerts_triggered
FROM core.transactions t
LEFT JOIN compliance.sanctions_screening ss ON ss.entity_type = 'TRANSACTION' 
    AND ss.entity_id = t.transaction_id
LEFT JOIN compliance.aml_alerts aa ON aa.transaction_id = t.transaction_id
WHERE t.transaction_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY DATE_TRUNC('day', t.transaction_date)
ORDER BY transaction_date DESC;

-- 18. Interest Rate Risk View
CREATE OR REPLACE VIEW treasury.interest_rate_risk_summary AS
SELECT 
    measurement_date,
    asset_duration,
    liability_duration,
    duration_gap,
    CASE 
        WHEN ABS(duration_gap) < 0.5 THEN 'LOW'
        WHEN ABS(duration_gap) < 1.0 THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS duration_risk_level,
    rate_shock_100bp,
    rate_shock_200bp,
    rate_shock_300bp,
    asset_liability_mismatch,
    interest_rate_sensitivity,
    hedge_effectiveness
FROM treasury.interest_rate_risk
WHERE measurement_date >= CURRENT_DATE - INTERVAL '1 year'
ORDER BY measurement_date DESC;

-- 19. Loan Origination Pipeline
CREATE OR REPLACE VIEW loans.origination_pipeline AS
SELECT 
    DATE_TRUNC('month', la.application_date) AS application_month,
    lp.product_name,
    lp.loan_type,
    COUNT(*) AS total_applications,
    SUM(la.requested_amount) AS total_requested_amount,
    COUNT(CASE WHEN la.decision = 'APPROVED' THEN 1 END) AS approved_count,
    COUNT(CASE WHEN la.decision = 'DECLINED' THEN 1 END) AS declined_count,
    COUNT(CASE WHEN la.decision IS NULL THEN 1 END) AS pending_count,
    ROUND(
        COUNT(CASE WHEN la.decision = 'APPROVED' THEN 1 END)::DECIMAL / 
        NULLIF(COUNT(CASE WHEN la.decision IS NOT NULL THEN 1 END), 0) * 100, 2
    ) AS approval_rate,
    AVG(la.decision_date - la.application_date) AS avg_processing_days
FROM loans.loan_applications la
JOIN loans.loan_products lp ON la.loan_product_id = lp.loan_product_id
WHERE la.application_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY DATE_TRUNC('month', la.application_date), lp.product_name, lp.loan_type
ORDER BY application_month DESC, total_applications DESC;

-- 20. Executive Dashboard View
CREATE OR REPLACE VIEW analytics.executive_dashboard AS
SELECT 
    'Financial Metrics' AS category,
    jsonb_build_object(
        'total_assets', (SELECT SUM(current_balance) FROM core.accounts WHERE status_id = 1),
        'total_loans', (SELECT SUM(current_balance) FROM loans.loans WHERE loan_status = 'ACTIVE'),
        'total_deposits', (SELECT SUM(current_balance) FROM core.accounts a 
                          JOIN core.account_types at ON a.account_type_id = at.account_type_id 
                          WHERE at.type_name LIKE '%DEPOSIT%'),
        'net_income_ytd', (SELECT SUM(net_income) FROM analytics.product_performance 
                          WHERE analysis_date >= DATE_TRUNC('year', CURRENT_DATE)),
        'active_customers', (SELECT COUNT(DISTINCT customer_id) FROM core.customers 
                            WHERE status_id = 1),
        'loan_delinquency_rate', (SELECT COUNT(CASE WHEN delinquency_status != 'CURRENT' THEN 1 END)::DECIMAL /
                                 NULLIF(COUNT(*), 0) * 100 FROM loans.loans WHERE loan_status = 'ACTIVE')
    ) AS metrics
UNION ALL
SELECT 
    'Risk Metrics' AS category,
    jsonb_build_object(
        'var_portfolio', (SELECT AVG(measurement_value) FROM risk.risk_measurements 
                         WHERE measurement_date = CURRENT_DATE AND entity_type = 'PORTFOLIO'),
        'credit_loss_provisions', (SELECT SUM(provision_amount) FROM loans.loan_provisions 
                                  WHERE provision_date >= DATE_TRUNC('year', CURRENT_DATE)),
        'regulatory_breaches', (SELECT COUNT(*) FROM risk.risk_limit_breaches 
                               WHERE status = 'OPEN'),
        'aml_alerts_open', (SELECT COUNT(*) FROM compliance.aml_alerts WHERE status = 'OPEN')
    ) AS metrics;

COMMENT ON VIEW analytics.customer_summary IS 'Summary view of customer information with account statistics';
COMMENT ON VIEW analytics.account_details IS 'Detailed account information with customer and transaction data';
COMMENT ON VIEW analytics.transaction_analysis IS 'Monthly transaction analysis by type';
COMMENT ON VIEW loans.loan_portfolio_summary IS 'Loan portfolio summary by product type';
COMMENT ON VIEW trading.portfolio_performance IS 'Portfolio performance metrics and returns';
COMMENT ON VIEW risk.risk_exposure_summary IS 'Risk exposure summary across all risk factors';
COMMENT ON VIEW compliance.aml_alerts_dashboard IS 'AML alerts monitoring dashboard';
COMMENT ON VIEW analytics.branch_performance IS 'Branch performance metrics and statistics';
COMMENT ON VIEW analytics.executive_dashboard IS 'High-level metrics for executive reporting';
