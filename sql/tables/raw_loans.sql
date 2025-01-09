-- Enums for standardized values
CREATE TYPE metrics.loan_type AS ENUM (
    'mortgage',
    'auto',
    'personal',
    'student'
);

CREATE TYPE metrics.loan_status AS ENUM (
    'active',
    'paid_off',
    'defaulted',
    'refinanced',
    'in_forbearance'
);

CREATE TYPE metrics.payment_frequency AS ENUM (
    'monthly'
);

-- Lenders
CREATE TABLE metrics.raw_lenders (
    lender_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    lender_name VARCHAR(100) NOT NULL,
    website_url VARCHAR(255),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(lender_name)
);

-- Raw loans reference table
CREATE TABLE metrics.raw_loan_accounts (
    loan_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    loan_type metrics.loan_type NOT NULL,
    lender_id UUID NOT NULL REFERENCES metrics.raw_lenders(lender_id),
    account_number VARCHAR(50),
    original_amount NUMERIC(12,2) NOT NULL,
    interest_rate NUMERIC(5,3) NOT NULL,
    start_date DATE NOT NULL,
    term_months INTEGER,
    payment_frequency metrics.payment_frequency DEFAULT 'monthly',
    minimum_payment NUMERIC(10,2),
    autopay_enabled BOOLEAN DEFAULT false,
    loan_status metrics.loan_status DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Raw loan balances/snapshots
CREATE TABLE metrics.raw_loan_balances (
    balance_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    loan_id UUID NOT NULL REFERENCES metrics.raw_loan_accounts(loan_id),
    statement_date DATE NOT NULL DEFAULT CURRENT_DATE,
    current_balance NUMERIC(12,2) NOT NULL,
    remaining_term_months INTEGER,
    next_payment_date DATE,
    next_payment_amount NUMERIC(10,2),
    captured_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_next_payment CHECK (next_payment_date >= statement_date),
    CONSTRAINT valid_balance CHECK (current_balance >= 0)
);

-- Raw loan payments
CREATE TABLE metrics.raw_loan_payments (
    payment_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    loan_id UUID NOT NULL REFERENCES metrics.raw_loan_accounts(loan_id),
    payment_date DATE NOT NULL,
    payment_amount NUMERIC(10,2) NOT NULL,
    principal_amount NUMERIC(10,2) NOT NULL,
    interest_amount NUMERIC(10,2) NOT NULL,
    extra_principal_amount NUMERIC(10,2) DEFAULT 0,
    payment_method metrics.payment_method,
    payment_status VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_loan_balances_dates ON metrics.raw_loan_balances(snapshot_date);
CREATE INDEX idx_loan_balances_loan ON metrics.raw_loan_balances(loan_id);
CREATE INDEX idx_loan_payments_date ON metrics.raw_loan_payments(payment_date);
CREATE INDEX idx_loan_payments_loan ON metrics.raw_loan_payments(loan_id);

-- Add the updated_at trigger to loan_accounts
CREATE TRIGGER update_loan_accounts_updated_at
    BEFORE UPDATE ON metrics.raw_loan_accounts
    FOR EACH ROW
    EXECUTE FUNCTION metrics.update_updated_at_column();

COMMENT ON TABLE metrics.raw_loan_accounts IS 'Reference table for loan accounts and their terms';
COMMENT ON TABLE metrics.raw_loan_balances IS 'Historical snapshot of loan balances and status';
COMMENT ON TABLE metrics.raw_loan_payments IS 'Record of all loan payments made';