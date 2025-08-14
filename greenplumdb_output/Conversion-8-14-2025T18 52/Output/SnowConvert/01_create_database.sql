-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '5' COLUMN '0' OF THE SOURCE CODE STARTING AT 'DROP'. EXPECTED 'Drop Statement' GRAMMAR. LAST MATCHING TOKEN WAS 'DROP' ON LINE '5' COLUMN '0'. FAILED TOKEN WAS 'DATABASE' ON LINE '5' COLUMN '5'. **
---- Greenplum Financial System Database Creation Script
---- This script creates a comprehensive financial system with 200+ tables

---- Create database
--DROP DATABASE IF EXISTS financial_system
                                        ;
CREATE DATABASE financial_system !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateDatabase' NODE ***/!!!;

-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '9' COLUMN '1' OF THE SOURCE CODE STARTING AT '\'. EXPECTED 'STATEMENT' GRAMMAR. LAST MATCHING TOKEN WAS ';' ON LINE '6' COLUMN '32'. **
---- Connect to the database
--\c financial_system
                   ;

-- Create schemas for different business domains
CREATE SCHEMA IF NOT EXISTS core !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateSchema' NODE ***/!!!;           -- Core banking tables
CREATE SCHEMA IF NOT EXISTS trading !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateSchema' NODE ***/!!!;        -- Trading and investments
CREATE SCHEMA IF NOT EXISTS risk !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateSchema' NODE ***/!!!;           -- Risk management
CREATE SCHEMA IF NOT EXISTS compliance !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateSchema' NODE ***/!!!;     -- Regulatory compliance
CREATE SCHEMA IF NOT EXISTS analytics !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateSchema' NODE ***/!!!;      -- Analytics and reporting
CREATE SCHEMA IF NOT EXISTS loans !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateSchema' NODE ***/!!!;          -- Loan management
CREATE SCHEMA IF NOT EXISTS cards !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateSchema' NODE ***/!!!;          -- Credit/debit cards
CREATE SCHEMA IF NOT EXISTS payment !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateSchema' NODE ***/!!!;        -- Payment processing
CREATE SCHEMA IF NOT EXISTS treasury !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateSchema' NODE ***/!!!;       -- Treasury operations
CREATE SCHEMA IF NOT EXISTS audit !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateSchema' NODE ***/!!!;          -- Audit and logging
-- Set search path
--** SSC-FDM-PG0006 - SET SEARCH PATH WITH MULTIPLE SCHEMAS IS NOT SUPPORTED IN SNOWFLAKE **
USE SCHEMA core /*, trading, risk, compliance, analytics, loans, cards, payment, treasury, audit, public*/;

-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '27' COLUMN '1' OF THE SOURCE CODE STARTING AT 'CREATE'. EXPECTED 'STATEMENT' GRAMMAR. LAST MATCHING TOKEN WAS ';' ON LINE '24' COLUMN '109'. **
---- Enable required extensions
--CREATE EXTENSION IF NOT EXISTS "uuid-ossp"
                                          ;
-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '28' COLUMN '1' OF THE SOURCE CODE STARTING AT 'CREATE'. EXPECTED 'STATEMENT' GRAMMAR. LAST MATCHING TOKEN WAS ';' ON LINE '27' COLUMN '43'. **
--CREATE EXTENSION IF NOT EXISTS "pgcrypto"
                                         ;
COMMENT ON DATABASE financial_system IS 'Comprehensive Financial System Database for Greenplum';