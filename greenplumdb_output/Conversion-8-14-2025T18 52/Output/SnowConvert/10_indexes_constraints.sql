-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '4' COLUMN '1' OF THE SOURCE CODE STARTING AT '\'. EXPECTED 'STATEMENT' GRAMMAR. **
---- Indexes and Constraints for Financial System
---- Performance optimization and data integrity constraints

--\c financial_system
                   ;
--** SSC-FDM-PG0006 - SET SEARCH PATH WITH MULTIPLE SCHEMAS IS NOT SUPPORTED IN SNOWFLAKE **
USE SCHEMA core /*, trading, loans, risk, compliance, analytics, payment, cards, treasury, audit, public*/;

---- Core Banking Indexes
---- Customer indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customers_customer_number ON core.customers(customer_number)
                                                                             ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customers_email ON core.customers(email)
                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customers_ssn_hash ON core.customers(ssn_encrypted)
                                                                    ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customers_status_type ON core.customers(status_id, customer_type_id)
                                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customers_created_date ON core.customers(created_at)
                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customers_kyc_status ON core.customers(kyc_status)
                                                                   ;

---- Account indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_accounts_customer_id ON core.accounts(customer_id)
                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_accounts_account_number ON core.accounts(account_number)
                                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_accounts_branch_id ON core.accounts(branch_id)
                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_accounts_status_type ON core.accounts(status_id, account_type_id)
                                                                                  ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_accounts_opening_date ON core.accounts(opening_date)
                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_accounts_balance ON core.accounts(current_balance)
                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_accounts_currency ON core.accounts(currency_code)
                                                                  ;

---- Transaction indexes (critical for performance)
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_transactions_account_id_date ON core.transactions(account_id, transaction_date DESC)
                                                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_transactions_date_amount ON core.transactions(transaction_date, amount)
                                                                                        ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_transactions_reference ON core.transactions(reference_number)
                                                                              ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_transactions_type_status ON core.transactions(transaction_type_id, status_id)
                                                                                              ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_transactions_channel ON core.transactions(channel)
                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_transactions_counterparty ON core.transactions(counterparty_account)
                                                                                     ;

---- GL Account indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_gl_accounts_code ON core.gl_accounts(account_code)
                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_gl_accounts_type ON core.gl_accounts(account_type)
                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_gl_accounts_parent ON core.gl_accounts(parent_account_id)
                                                                          ;

---- GL Transaction indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_gl_transactions_date ON core.gl_transactions(transaction_date)
                                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_gl_transactions_status ON core.gl_transactions(status)
                                                                       ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_gl_transaction_details_gl_account ON core.gl_transaction_details(gl_account_id)
                                                                                                ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_gl_transaction_details_gl_txn ON core.gl_transaction_details(gl_transaction_id)
                                                                                                ;

---- Branch and Geography indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_branches_code ON core.branches(branch_code)
                                                            ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_branches_city ON core.branches(city_id)
                                                        ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customer_addresses_customer ON core.customer_addresses(customer_id)
                                                                                    ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_cities_state ON core.cities(state_id)
                                                      ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_states_country ON core.states(country_id)
                                                          ;

---- Employee indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_employees_number ON core.employees(employee_number)
                                                                    ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_employees_branch ON core.employees(branch_id)
                                                              ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_employees_manager ON core.employees(manager_id)
                                                                ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_employees_active ON core.employees(is_active)
                                                              ;

---- Loan Management Indexes
---- Loan application indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_applications_customer ON loans.loan_applications(customer_id)
                                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_applications_product ON loans.loan_applications(loan_product_id)
                                                                                      ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_applications_date ON loans.loan_applications(application_date)
                                                                                    ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_applications_status ON loans.loan_applications(application_status)
                                                                                        ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_applications_number ON loans.loan_applications(application_number)
                                                                                        ;

---- Loan indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loans_customer_id ON loans.loans(customer_id)
                                                              ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loans_loan_number ON loans.loans(loan_number)
                                                              ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loans_product_id ON loans.loans(loan_product_id)
                                                                 ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loans_status ON loans.loans(loan_status)
                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loans_delinquency ON loans.loans(delinquency_status)
                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loans_next_payment ON loans.loans(next_payment_date)
                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loans_maturity ON loans.loans(maturity_date)
                                                             ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loans_officer ON loans.loans(servicing_officer)
                                                                ;

---- Loan payment indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_payments_loan_id ON loans.loan_payments(loan_id)
                                                                      ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_payments_date ON loans.loan_payments(payment_date)
                                                                        ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_payments_status ON loans.loan_payments(payment_status)
                                                                            ;

---- Loan schedule indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_schedules_loan_due ON loans.loan_schedules(loan_id, due_date)
                                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_schedules_status ON loans.loan_schedules(payment_status)
                                                                              ;

---- Credit scoring indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_credit_scores_customer ON loans.credit_scores(customer_id)
                                                                           ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_credit_scores_application ON loans.credit_scores(application_id)
                                                                                 ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_credit_scores_date ON loans.credit_scores(score_date)
                                                                      ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_credit_scores_latest ON loans.credit_scores(is_latest)
                                                                       ;

---- Collateral indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_collateral_loan ON loans.loan_collateral(loan_id)
                                                                       ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_collateral_type ON loans.loan_collateral(collateral_type_id)
                                                                                  ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loan_collateral_status ON loans.loan_collateral(collateral_status)
                                                                                   ;

---- Trading and Investment Indexes
---- Securities indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_securities_symbol_exchange ON trading.securities(symbol, exchange_id)
                                                                                      ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_securities_type ON trading.securities(security_type_id)
                                                                        ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_securities_isin ON trading.securities(isin)
                                                            ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_securities_cusip ON trading.securities(cusip)
                                                              ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_securities_active ON trading.securities(is_active)
                                                                   ;

---- Market data indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_market_data_security_date ON trading.market_data(security_id, trade_date DESC)
                                                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_real_time_quotes_security ON trading.real_time_quotes(security_id)
                                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_real_time_quotes_timestamp ON trading.real_time_quotes(quote_timestamp DESC)
                                                                                             ;

---- Portfolio indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_portfolios_customer ON trading.portfolios(customer_id)
                                                                       ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_portfolios_account ON trading.portfolios(trading_account_id)
                                                                             ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_portfolios_manager ON trading.portfolios(manager_id)
                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_portfolios_active ON trading.portfolios(is_active)
                                                                   ;

---- Holdings indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_holdings_portfolio_security ON trading.holdings(portfolio_id, security_id)
                                                                                           ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_holdings_portfolio ON trading.holdings(portfolio_id)
                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_holdings_security ON trading.holdings(security_id)
                                                                   ;

---- Order indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_orders_portfolio ON trading.orders(portfolio_id)
                                                                 ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_orders_security ON trading.orders(security_id)
                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_orders_status ON trading.orders(status_id)
                                                           ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_orders_date ON trading.orders(order_date DESC)
                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_orders_side_status ON trading.orders(side, status_id)
                                                                      ;

---- Trade indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_trades_portfolio ON trading.trades(portfolio_id)
                                                                 ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_trades_security ON trading.trades(security_id)
                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_trades_date ON trading.trades(trade_date DESC)
                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_trades_settlement ON trading.trades(settlement_date)
                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_trades_trader ON trading.trades(trader_id)
                                                           ;

---- Order execution indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_order_executions_order ON trading.order_executions(order_id)
                                                                             ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_order_executions_time ON trading.order_executions(execution_time DESC)
                                                                                       ;

---- Risk Management Indexes
---- Risk measurement indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_measurements_entity ON risk.risk_measurements(entity_type, entity_id)
                                                                                           ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_measurements_factor ON risk.risk_measurements(risk_factor_id)
                                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_measurements_date ON risk.risk_measurements(measurement_date DESC)
                                                                                        ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_measurements_model ON risk.risk_measurements(risk_model_id)
                                                                                 ;

---- Risk limit indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_limits_entity ON risk.risk_limits(entity_type, entity_id)
                                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_limits_factor ON risk.risk_limits(risk_factor_id)
                                                                       ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_limits_active ON risk.risk_limits(is_active)
                                                                  ;

---- Risk limit breach indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_limit_breaches_limit ON risk.risk_limit_breaches(risk_limit_id)
                                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_limit_breaches_date ON risk.risk_limit_breaches(breach_date)
                                                                                  ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_limit_breaches_status ON risk.risk_limit_breaches(status)
                                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_limit_breaches_severity ON risk.risk_limit_breaches(severity)
                                                                                   ;

---- Credit rating indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_credit_ratings_entity ON risk.credit_ratings(entity_type, entity_id)
                                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_credit_ratings_agency ON risk.credit_ratings(rating_agency)
                                                                            ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_credit_ratings_date ON risk.credit_ratings(rating_date DESC)
                                                                             ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_credit_ratings_active ON risk.credit_ratings(is_active)
                                                                        ;

---- Stress test indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_stress_test_results_scenario ON risk.stress_test_results(scenario_id)
                                                                                      ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_stress_test_results_portfolio ON risk.stress_test_results(portfolio_id)
                                                                                        ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_stress_test_results_date ON risk.stress_test_results(test_date DESC)
                                                                                     ;

---- Compliance Indexes
---- AML alert indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_aml_alerts_customer ON compliance.aml_alerts(customer_id)
                                                                          ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_aml_alerts_account ON compliance.aml_alerts(account_id)
                                                                        ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_aml_alerts_transaction ON compliance.aml_alerts(transaction_id)
                                                                                ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_aml_alerts_type_priority ON compliance.aml_alerts(alert_type, alert_priority)
                                                                                              ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_aml_alerts_status ON compliance.aml_alerts(status)
                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_aml_alerts_date ON compliance.aml_alerts(alert_date DESC)
                                                                          ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_aml_alerts_assigned ON compliance.aml_alerts(assigned_to)
                                                                          ;

---- KYC document indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_kyc_documents_customer ON compliance.kyc_documents(customer_id)
                                                                                ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_kyc_documents_type ON compliance.kyc_documents(document_type)
                                                                              ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_kyc_documents_status ON compliance.kyc_documents(verification_status)
                                                                                      ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_kyc_documents_expiry ON compliance.kyc_documents(expiry_date)
                                                                              ;

---- Sanctions screening indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_sanctions_screening_entity ON compliance.sanctions_screening(entity_type, entity_id)
                                                                                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_sanctions_screening_date ON compliance.sanctions_screening(screening_date DESC)
                                                                                                ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_sanctions_screening_match ON compliance.sanctions_screening(match_found)
                                                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_sanctions_screening_status ON compliance.sanctions_screening(status)
                                                                                     ;

---- Sanctions entries indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_sanctions_entries_list ON compliance.sanctions_entries(sanctions_list_id)
                                                                                          ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_sanctions_entries_name ON compliance.sanctions_entries(entity_name)
                                                                                    ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_sanctions_entries_type ON compliance.sanctions_entries(entity_type)
                                                                                    ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_sanctions_entries_active ON compliance.sanctions_entries(is_active)
                                                                                    ;

---- Compliance monitoring indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_compliance_monitoring_requirement ON compliance.compliance_monitoring(requirement_id)
                                                                                                      ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_compliance_monitoring_entity ON compliance.compliance_monitoring(entity_type, entity_id)
                                                                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_compliance_monitoring_date ON compliance.compliance_monitoring(monitoring_date)
                                                                                                ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_compliance_monitoring_status ON compliance.compliance_monitoring(status)
                                                                                         ;

---- Payment Processing Indexes
---- Wire transfer indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_wire_transfers_customer ON payment.wire_transfers(customer_id)
                                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_wire_transfers_account ON payment.wire_transfers(account_id)
                                                                             ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_wire_transfers_date ON payment.wire_transfers(value_date)
                                                                          ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_wire_transfers_status ON payment.wire_transfers(status)
                                                                        ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_wire_transfers_type ON payment.wire_transfers(transfer_type)
                                                                             ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_wire_transfers_number ON payment.wire_transfers(transfer_number)
                                                                                 ;

---- ACH transaction indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_ach_transactions_customer ON payment.ach_transactions(customer_id)
                                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_ach_transactions_account ON payment.ach_transactions(account_id)
                                                                                 ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_ach_transactions_date ON payment.ach_transactions(effective_date)
                                                                                  ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_ach_transactions_status ON payment.ach_transactions(status)
                                                                            ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_ach_transactions_type ON payment.ach_transactions(transaction_type)
                                                                                    ;

---- Payment instruction indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_payment_instructions_customer ON payment.payment_instructions(customer_id)
                                                                                           ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_payment_instructions_account ON payment.payment_instructions(account_id)
                                                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_payment_instructions_date ON payment.payment_instructions(execution_date)
                                                                                          ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_payment_instructions_status ON payment.payment_instructions(status)
                                                                                    ;

---- Card Management Indexes
---- Card indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_cards_customer ON cards.cards(customer_id)
                                                           ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_cards_account ON cards.cards(account_id)
                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_cards_number_hash ON cards.cards(card_number_hash)
                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_cards_status ON cards.cards(card_status)
                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_cards_expiry ON cards.cards(expiry_date)
                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_cards_type ON cards.cards(card_type_id)
                                                        ;

---- Card transaction indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_card_transactions_card ON cards.card_transactions(card_id)
                                                                           ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_card_transactions_date ON cards.card_transactions(transaction_date DESC)
                                                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_card_transactions_merchant ON cards.card_transactions(merchant_id)
                                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_card_transactions_type ON cards.card_transactions(transaction_type)
                                                                                    ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_card_transactions_auth ON cards.card_transactions(authorization_code)
                                                                                      ;

---- Card reward indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_card_rewards_card ON cards.card_rewards(card_id)
                                                                 ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_card_rewards_transaction ON cards.card_rewards(transaction_id)
                                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_card_rewards_posting ON cards.card_rewards(posting_date)
                                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_card_rewards_redeemed ON cards.card_rewards(is_redeemed)
                                                                         ;

---- Analytics Indexes
---- Customer analytics indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customer_analytics_customer ON analytics.customer_analytics(customer_id)
                                                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customer_analytics_date ON analytics.customer_analytics(analysis_date DESC)
                                                                                            ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customer_analytics_segment ON analytics.customer_analytics(segment)
                                                                                    ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customer_analytics_tier ON analytics.customer_analytics(profitability_tier)
                                                                                            ;

---- Product performance indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_product_performance_product ON analytics.product_performance(product_id)
                                                                                         ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_product_performance_date ON analytics.product_performance(analysis_date DESC)
                                                                                              ;

---- KPI value indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_kpi_values_kpi ON analytics.kpi_values(kpi_id)
                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_kpi_values_date ON analytics.kpi_values(measurement_date DESC)
                                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_kpi_values_status ON analytics.kpi_values(status)
                                                                  ;

---- Report execution indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_report_executions_report ON analytics.report_executions(report_id)
                                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_report_executions_date ON analytics.report_executions(execution_date DESC)
                                                                                           ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_report_executions_status ON analytics.report_executions(execution_status)
                                                                                          ;

---- Audit Indexes
---- Audit trail indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_audit_trails_table_record ON audit.audit_trails(table_name, record_id)
                                                                                       ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_audit_trails_changed_by ON audit.audit_trails(changed_by)
                                                                          ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_audit_trails_changed_at ON audit.audit_trails(changed_at DESC)
                                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_audit_trails_operation ON audit.audit_trails(operation)
                                                                        ;

---- Error log indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_error_logs_occurred_at ON audit.error_logs(occurred_at DESC)
                                                                             ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_error_logs_severity ON audit.error_logs(severity)
                                                                  ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_error_logs_module ON audit.error_logs(module)
                                                              ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_error_logs_user ON audit.error_logs(user_id)
                                                             ;

---- User session indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_user_sessions_user ON audit.user_sessions(user_id)
                                                                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_user_sessions_login ON audit.user_sessions(login_time DESC)
                                                                            ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_user_sessions_active ON audit.user_sessions(is_active)
                                                                       ;

---- System parameter indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_system_parameters_name ON core.system_parameters(parameter_name)
                                                                                 ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_system_parameters_category ON core.system_parameters(category)
                                                                               ;

---- Business calendar indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_business_calendar_date ON core.business_calendar(calendar_date)
                                                                                ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_business_calendar_business_day ON core.business_calendar(is_business_day)
                                                                                          ;
-- Constraint Definitions
-- Foreign Key Constraints (Additional critical ones)
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE core.customer_addresses
ADD CONSTRAINT fk_customer_addresses_customer
FOREIGN KEY (customer_id) REFERENCES core.customers (customer_id) ON DELETE CASCADE ;
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE core.accounts
ADD CONSTRAINT fk_accounts_customer
FOREIGN KEY (customer_id) REFERENCES core.customers (customer_id) ;
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE core.transactions
ADD CONSTRAINT fk_transactions_account
FOREIGN KEY (account_id) REFERENCES core.accounts (account_id) ;
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE loans.loans
ADD CONSTRAINT fk_loans_customer
FOREIGN KEY (customer_id) REFERENCES core.customers (customer_id) ;
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE loans.loan_payments
ADD CONSTRAINT fk_loan_payments_loan
FOREIGN KEY (loan_id) REFERENCES loans.loans (loan_id) ;
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE trading.portfolios
ADD CONSTRAINT fk_portfolios_customer
FOREIGN KEY (customer_id) REFERENCES core.customers (customer_id) ;
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE trading.holdings
ADD CONSTRAINT fk_holdings_portfolio
FOREIGN KEY (portfolio_id) REFERENCES trading.portfolios (portfolio_id) ;
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE trading.orders
ADD CONSTRAINT fk_orders_portfolio
FOREIGN KEY (portfolio_id) REFERENCES trading.portfolios (portfolio_id) ;

-- Check Constraints
!!!RESOLVE EWI!!! /*** SSC-EWI-0035 - CHECK STATEMENT NOT SUPPORTED ***/!!!
ALTER TABLE core.accounts
ADD CONSTRAINT chk_accounts_balance_positive
CHECK (current_balance >= -overdraft_limit);
!!!RESOLVE EWI!!! /*** SSC-EWI-0035 - CHECK STATEMENT NOT SUPPORTED ***/!!!

ALTER TABLE core.transactions
ADD CONSTRAINT chk_transactions_amount_positive
CHECK (amount > 0);
!!!RESOLVE EWI!!! /*** SSC-EWI-0035 - CHECK STATEMENT NOT SUPPORTED ***/!!!

ALTER TABLE loans.loans
ADD CONSTRAINT chk_loans_amounts_positive
CHECK (principal_amount > 0 AND current_balance >= 0);
!!!RESOLVE EWI!!! /*** SSC-EWI-0035 - CHECK STATEMENT NOT SUPPORTED ***/!!!

ALTER TABLE loans.loan_payments
ADD CONSTRAINT chk_loan_payments_amounts_positive
CHECK (payment_amount > 0 AND principal_amount >= 0 AND interest_amount >= 0);
!!!RESOLVE EWI!!! /*** SSC-EWI-0035 - CHECK STATEMENT NOT SUPPORTED ***/!!!

ALTER TABLE trading.holdings
ADD CONSTRAINT chk_holdings_quantity_valid
CHECK (quantity != 0); -- Holdings can be positive (long) or negative (short)
!!!RESOLVE EWI!!! /*** SSC-EWI-0035 - CHECK STATEMENT NOT SUPPORTED ***/!!!
ALTER TABLE trading.orders
ADD CONSTRAINT chk_orders_quantity_positive
CHECK (quantity > 0);
!!!RESOLVE EWI!!! /*** SSC-EWI-0035 - CHECK STATEMENT NOT SUPPORTED ***/!!!

ALTER TABLE risk.risk_measurements
ADD CONSTRAINT chk_risk_measurements_confidence
CHECK (confidence_level > 0 AND confidence_level <= 1);

-- Unique Constraints (Additional ones for data integrity)
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE core.customers
ADD CONSTRAINT uk_customers_email
UNIQUE (email);
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE core.branches
ADD CONSTRAINT uk_branches_code
UNIQUE (branch_code);
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE loans.loan_applications
ADD CONSTRAINT uk_loan_applications_number
UNIQUE (application_number);
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE trading.securities
ADD CONSTRAINT uk_securities_isin
UNIQUE (isin);
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0003 - TABLE INHERITANCE IS NOT SUPPORTED IN SNOWFLAKE. ***/!!!
ALTER TABLE payment.wire_transfers
ADD CONSTRAINT uk_wire_transfers_number
UNIQUE (transfer_number);

---- Partial indexes for better performance on filtered queries
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_accounts_active_balance
--ON core.accounts(current_balance)
--WHERE status_id = 1
                   ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_transactions_recent_large
--ON core.transactions(transaction_date, amount)
--WHERE transaction_date >= CURRENT_DATE - INTERVAL '90 days' AND amount >= 10000
                                                                               ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loans_delinquent
--ON loans.loans(days_past_due, current_balance)
--WHERE delinquency_status != 'CURRENT'
                                     ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_aml_alerts_open_high_priority
--ON compliance.aml_alerts(alert_date)
--WHERE status = 'OPEN' AND alert_priority = 'HIGH'
                                                 ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_orders_pending_recent
--ON trading.orders(order_date)
--WHERE status_id = 1 AND order_date >= CURRENT_DATE - INTERVAL '30 days'
                                                                       ;

---- Composite indexes for common query patterns
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_transactions_customer_date_amount
--ON core.transactions(account_id, transaction_date DESC, amount DESC)
                                                                    ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_loans_customer_status_balance
--ON loans.loans(customer_id, loan_status, current_balance DESC)
                                                              ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_holdings_portfolio_value
--ON trading.holdings(portfolio_id, market_value DESC)
                                                    ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_risk_measurements_entity_date_factor
--ON risk.risk_measurements(entity_type, entity_id, measurement_date DESC, risk_factor_id)
                                                                                        ;

---- Function-based indexes
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_customers_full_name
--ON core.customers(LOWER(first_name || ' ' || last_name))
                                                        ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_transactions_month_year
--ON core.transactions(EXTRACT(YEAR FROM transaction_date), EXTRACT(MONTH FROM transaction_date))
                                                                                               ;

---- Text search indexes for compliance and monitoring
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_aml_alerts_description_gin
--ON compliance.aml_alerts USING GIN(to_tsvector('english', description))
                                                                       ;
----** SSC-FDM-0021 - CREATE INDEX IS NOT SUPPORTED BY SNOWFLAKE **
--CREATE INDEX idx_sanctions_entries_name_gin
--ON compliance.sanctions_entries USING GIN(to_tsvector('english', entity_name))
                                                                              ;
-- Triggers for audit trail (example)
!!!RESOLVE EWI!!! /*** SSC-EWI-0068 - USER DEFINED FUNCTION WAS TRANSFORMED TO SNOWFLAKE PROCEDURE ***/!!!
CREATE OR REPLACE PROCEDURE audit.audit_trigger_function ()
RETURNS TRIGGER !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'PseudoTypes' NODE ***/!!!
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 1,  "minor": 16,  "patch": "1.0" }, "attributes": {  "component": "greenplum",  "convertedOn": "08/14/2025",  "domain": "snowflake" }}'
AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit.audit_trails (table_name, record_id, operation, new_values, changed_at)
        VALUES (TG_TABLE_NAME, NEW.customer_id, 'INSERT', row_to_json(NEW) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'row_to_json' NODE ***/!!!, CURRENT_TIMESTAMP());
        RETURN NEW;
    ELSEIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit.audit_trails (table_name, record_id, operation, old_values, new_values, changed_at)
        VALUES (TG_TABLE_NAME, NEW.customer_id, 'UPDATE', row_to_json(OLD) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'row_to_json' NODE ***/!!!, row_to_json(NEW) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'row_to_json' NODE ***/!!!, CURRENT_TIMESTAMP());
        RETURN NEW;
    ELSEIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit.audit_trails (table_name, record_id, operation, old_values, changed_at)
        VALUES (TG_TABLE_NAME, OLD.customer_id, 'DELETE', row_to_json(OLD) !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'row_to_json' NODE ***/!!!, CURRENT_TIMESTAMP());
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

---- Create audit triggers on key tables
----** SSC-OOS - OUT OF SCOPE CODE UNIT. CREATE TRIGGER IS OUT OF TRANSLATION SCOPE. **
--CREATE TRIGGER audit_customers_trigger
--    AFTER INSERT OR UPDATE OR DELETE ON core.customers
--    FOR EACH ROW EXECUTE FUNCTION audit.audit_trigger_function()
                                                                ;
----** SSC-OOS - OUT OF SCOPE CODE UNIT. CREATE TRIGGER IS OUT OF TRANSLATION SCOPE. **
--CREATE TRIGGER audit_accounts_trigger
--    AFTER INSERT OR UPDATE OR DELETE ON core.accounts
--    FOR EACH ROW EXECUTE FUNCTION audit.audit_trigger_function()
                                                                ;
----** SSC-OOS - OUT OF SCOPE CODE UNIT. CREATE TRIGGER IS OUT OF TRANSLATION SCOPE. **
--CREATE TRIGGER audit_transactions_trigger
--    AFTER INSERT OR UPDATE OR DELETE ON core.transactions
--    FOR EACH ROW EXECUTE FUNCTION audit.audit_trigger_function()
                                                                ;
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0009 - COMMENT ON 'INDEX' IS NOT SUPPORTED BY SNOWFLAKE. ***/!!!
COMMENT ON INDEX idx_customers_customer_number IS 'Index on customer number for fast customer lookup';
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0009 - COMMENT ON 'INDEX' IS NOT SUPPORTED BY SNOWFLAKE. ***/!!!
COMMENT ON INDEX idx_accounts_customer_id IS 'Index on customer_id for account queries by customer';
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0009 - COMMENT ON 'INDEX' IS NOT SUPPORTED BY SNOWFLAKE. ***/!!!
COMMENT ON INDEX idx_transactions_account_id_date IS 'Composite index for transaction history queries';
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0009 - COMMENT ON 'INDEX' IS NOT SUPPORTED BY SNOWFLAKE. ***/!!!
COMMENT ON INDEX idx_loans_customer_id IS 'Index on customer_id for loan queries by customer';
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0009 - COMMENT ON 'INDEX' IS NOT SUPPORTED BY SNOWFLAKE. ***/!!!
COMMENT ON INDEX idx_aml_alerts_customer IS 'Index on customer_id for AML alert queries';
!!!RESOLVE EWI!!! /*** SSC-EWI-PG0009 - COMMENT ON 'INDEX' IS NOT SUPPORTED BY SNOWFLAKE. ***/!!!
COMMENT ON INDEX idx_trading_orders_portfolio IS 'Index on portfolio_id for order queries by portfolio';