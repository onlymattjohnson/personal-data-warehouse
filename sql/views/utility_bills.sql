-- Create view for utility bill analysis
CREATE OR REPLACE VIEW metrics.utility_bill_analysis AS
WITH bill_calculations AS (
    SELECT 
        b.bill_id,
        b.provider_id,
        b.service_date_start,
        b.service_date_end,
        b.due_date,
        b.amount,
        b.usage_amount,
        b.usage_unit,
        b.rate_per_unit,
        b.bill_status,
        b.payment_method,
        -- Calculate days in billing period
        (service_date_end - service_date_start + 1) as days_in_period,
        -- Calculate daily averages
        CASE 
            WHEN usage_amount IS NOT NULL 
            THEN usage_amount / NULLIF((service_date_end - service_date_start + 1), 0)
        END as avg_daily_usage,
        amount / NULLIF((service_date_end - service_date_start + 1), 0) as avg_daily_cost
    FROM metrics.raw_utility_bills b
)
SELECT 
    b.bill_id,
    p.provider_name,
    p.utility_type,
    b.service_date_start,
    b.service_date_end,
    b.days_in_period,
    b.due_date,
    b.amount,
    b.usage_amount,
    b.usage_unit,
    b.rate_per_unit,
    b.avg_daily_usage,
    b.avg_daily_cost,
    b.bill_status,
    b.payment_method,
    -- Add month and year for easy grouping
    DATE_TRUNC('month', b.service_date_start) as bill_month,
    EXTRACT(YEAR FROM b.service_date_start) as bill_year,
    p.autopay_enabled
FROM bill_calculations b
JOIN metrics.raw_utility_providers p ON b.provider_id = p.provider_id;

-- Monthly costs by utility type
CREATE OR REPLACE VIEW metrics.monthly_utility_costs AS
SELECT 
    bill_month,
    provider_name,
    utility_type,
    COUNT(*) as bill_count,
    SUM(amount) as total_amount,
    AVG(avg_daily_usage) as avg_daily_usage,
    AVG(amount) as avg_bill_amount
FROM metrics.utility_bill_analysis
GROUP BY bill_month, provider_name, utility_type
ORDER BY bill_month DESC, provider_name;