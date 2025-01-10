-- Create enums for retirement accounts
CREATE TYPE metrics.account_type AS ENUM (
    'traditional_401k',
    'roth_401k',
    'traditional_ira',
    'roth_ira',
    'sep_ira',
    'simple_ira',
    'pension',
    'hsa',
    '403b'
);

-- Retirement accounts
CREATE TABLE metrics.raw_retirement_accounts (
    account_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL,
    website_url VARCHAR(255),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    account_type metrics.account_type NOT NULL,
    account_number VARCHAR(50),
    opened_date DATE,
    employer_name VARCHAR(100),
    employer_sponsored BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Monthly statements/balances
CREATE TABLE metrics.raw_retirement_statements (
    statement_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    account_id UUID NOT NULL REFERENCES metrics.raw_retirement_accounts(account_id),
    statement_date DATE NOT NULL DEFAULT CURRENT_DATE,
    period_start_date DATE NOT NULL,
    period_end_date DATE NOT NULL,
    beginning_balance NUMERIC (12,2) NOT NULL,
    employee_contribution NUMERIC(10,2),
    employer_contribution NUMERIC(10,2),
    fees NUMERIC(12,2),
    change_in_account_balance NUMERIC(12,2),
    ending_balance NUMERIC(12,2),
    dividends_and_interest NUMERIC(12,2) NOT NULL,
    captured_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_balance CHECK (ending_balance >= 0)
);

-- Indexes
CREATE INDEX idx_retirement_balances_date 
    ON metrics.raw_retirement_statements(statement_date);
CREATE INDEX idx_retirement_balances_account 
    ON metrics.raw_retirement_statements(account_id);

-- Add triggers for updated_at
CREATE TRIGGER update_investment_providers_updated_at
    BEFORE UPDATE ON metrics.raw_retirement_accounts
    FOR EACH ROW
    EXECUTE FUNCTION metrics.update_updated_at_column();

CREATE TRIGGER update_retirement_accounts_updated_at
    BEFORE UPDATE ON metrics.raw_retirement_statements
    FOR EACH ROW
    EXECUTE FUNCTION metrics.update_updated_at_column();

-- Comments
COMMENT ON TABLE metrics.raw_retirement_accounts 
    IS 'Individual retirement accounts';
COMMENT ON TABLE metrics.raw_retirement_statements 
    IS 'Monthly retirement account balance snapshots';