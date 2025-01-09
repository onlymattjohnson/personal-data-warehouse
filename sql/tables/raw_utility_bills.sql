-- Create enums for standardized values
CREATE TYPE metrics.utility_type AS ENUM (
    'electricity', 
    'water', 
    'gas', 
    'internet', 
    'trash', 
    'telephone'
);

CREATE TYPE metrics.bill_status AS ENUM (
    'unpaid', 
    'paid', 
    'scheduled', 
    'autopay_scheduled', 
    'late'
);

CREATE TYPE metrics.payment_method AS ENUM (
    'ach', 
    'credit_card', 
    'check', 
    'autopay'
);

-- Providers reference table
CREATE TABLE metrics.raw_utility_providers (
    provider_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL,
    utility_type utility_type NOT NULL,
    account_number VARCHAR(50),
    website_url VARCHAR(255),
    autopay_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(provider_name, utility_type)
);

-- Raw bills table with foreign key to providers
CREATE TABLE metrics.raw_utility_bills (
    bill_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    provider_id UUID NOT NULL REFERENCES metrics.raw_utility_providers(provider_id),
    snapshot_date DATE NOT NULL DEFAULT CURRENT_DATE,
    service_date_start DATE NOT NULL,
    service_date_end DATE NOT NULL,
    due_date DATE NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    usage_amount NUMERIC(10,2),
    usage_unit VARCHAR(20),  -- kWh, gallons, therms
    rate_per_unit NUMERIC(10,4),
    bill_status bill_status NOT NULL DEFAULT 'unpaid',
    payment_date DATE,
    payment_method payment_method,
    captured_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_service_period CHECK (service_date_end >= service_date_start),
    CONSTRAINT valid_payment_date CHECK (payment_date >= service_date_start)
);

-- Loads tracking table
CREATE TABLE metrics.raw_utility_bill_loads (
    load_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    load_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    record_count INTEGER,
    load_status VARCHAR(50),
    error_message TEXT
);

-- Indexes
CREATE INDEX idx_raw_bills_dates ON metrics.raw_utility_bills(service_date_start, service_date_end);
CREATE INDEX idx_raw_bills_provider ON metrics.raw_utility_bills(provider_id);

-- Trigger update date
CREATE TRIGGER update_providers_updated_at
    BEFORE UPDATE ON metrics.raw_utility_providers
    FOR EACH ROW
    EXECUTE FUNCTION metrics.update_updated_at_column();

COMMENT ON TABLE metrics.raw_utility_providers IS 'Reference table for utility service providers';
COMMENT ON TABLE metrics.raw_utility_bills IS 'Raw utility bill data as captured from statements';
COMMENT ON TABLE metrics.raw_utility_bill_loads IS 'Tracking table for data load operations';

/* Example INSERT for providers

INSERT INTO metrics.raw_utility_providers 
    (provider_name, utility_type, account_number, website_url, autopay_enabled)
VALUES 
    ('Pacific Gas & Electric', 'electricity', '1234567890', 'https://www.pge.com', true);
*/

/* Example INSERT for bills

INSERT INTO metrics.raw_utility_bills (
    provider_id,
    snapshot_date,
    service_date_start,
    service_date_end,
    due_date,
    amount,
    usage_amount,
    usage_unit,
    rate_per_unit,
    bill_status,
    payment_method
) VALUES (
    'provider-uuid-here',  -- replace with actual UUID from providers table
    CURRENT_DATE,
    '2025-02-01',
    '2025-02-28',
    '2025-03-15',
    142.50,
    680.2,
    'kWh',
    0.21045,
    'unpaid',
    'credit_card'
);