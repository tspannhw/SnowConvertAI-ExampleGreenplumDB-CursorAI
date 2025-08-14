-- Greenplum Financial System Database Creation Script
-- This script creates a comprehensive financial system with 200+ tables

-- Create database
DROP DATABASE IF EXISTS financial_system;
CREATE DATABASE financial_system;

-- Connect to the database
\c financial_system;

-- Create schemas for different business domains
CREATE SCHEMA IF NOT EXISTS core;           -- Core banking tables
CREATE SCHEMA IF NOT EXISTS trading;        -- Trading and investments
CREATE SCHEMA IF NOT EXISTS risk;           -- Risk management
CREATE SCHEMA IF NOT EXISTS compliance;     -- Regulatory compliance
CREATE SCHEMA IF NOT EXISTS analytics;      -- Analytics and reporting
CREATE SCHEMA IF NOT EXISTS loans;          -- Loan management
CREATE SCHEMA IF NOT EXISTS cards;          -- Credit/debit cards
CREATE SCHEMA IF NOT EXISTS payment;        -- Payment processing
CREATE SCHEMA IF NOT EXISTS treasury;       -- Treasury operations
CREATE SCHEMA IF NOT EXISTS audit;          -- Audit and logging

-- Set search path
SET search_path TO core, trading, risk, compliance, analytics, loans, cards, payment, treasury, audit, public;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

COMMENT ON DATABASE financial_system IS 'Comprehensive Financial System Database for Greenplum';
