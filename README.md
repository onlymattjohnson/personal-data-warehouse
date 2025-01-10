# My Personal Data Warehouse

This project is designed to store personal data. I've been interested in the quantiifed self movement for some time and I also work in data every day. I would like to have a system to universally store data about myself. I will document and store the code to make that possible here.

# Data Types

## Loans

### Lenders

The `metrics.raw_lenders` table stores information about loan providers.

Usage:

```sql
INSERT INTO metrics.raw_lenders 
    (lender_name, website_url, contact_phone, contact_email, notes)
VALUES 
    ('Evergreen Valley Credit Union', 'https://www.evcu.com', '1-800-555-1234', 
     'support@evcu.com', 'Primary bank lender');
```

### Loan Accounts
References `metrics.raw_lenders` table using `lender_id`. 

To insert a loan:

```sql
-- First get the lender_id
WITH lender_id_cte AS (
    SELECT lender_id 
    FROM metrics.raw_lenders 
    WHERE lender_name = 'Evergreen Valley Credit Union'
    LIMIT 1
)
INSERT INTO metrics.raw_loan_accounts (
    lender_id,
    loan_type,
    account_number,
    original_amount,
    interest_rate,
    start_date,
    term_months,
    minimum_payment,
    autopay_enabled
) 
SELECT 
    lender_id,
    'auto'::metrics.loan_type,
    'AUTO-12345',
    25000.00,
    4.25,
    '2025-01-01',
    60,
    100.00,
    true
FROM lender_id_cte;
```

### Loan balances

```sql
-- First get the loan_id from loan_accounts
WITH loan_ref AS (
    SELECT loan_id 
    FROM metrics.raw_loan_accounts 
    WHERE account_number = 'AUTO-12345'
    LIMIT 1
)
INSERT INTO metrics.raw_loan_balances (
    loan_id,
    statement_date,
    current_balance,
    remaining_term_months,
    next_payment_date,
    next_payment_amount
) 
SELECT 
    loan_id,
    CURRENT_DATE,        -- statement date
    23456.78,           -- current balance
    54,                 -- remaining months
    '2025-02-15',       -- next payment due
    436.82              -- next payment amount
FROM loan_ref;
```

Verify the insert
```sql
-- Query to verify the insert
SELECT 
    l.lender_name,
    la.account_number,
    lb.statement_date,
    lb.current_balance,
    lb.remaining_term_months,
    lb.next_payment_date,
    lb.next_payment_amount
FROM metrics.raw_loan_balances lb
JOIN metrics.raw_loan_accounts la ON lb.loan_id = la.loan_id
JOIN metrics.raw_lenders l ON la.lender_id = l.lender_id
WHERE lb.statement_date = CURRENT_DATE;
```

### Loan payments

```sql
-- First get the loan_id from loan_accounts
WITH loan_ref AS (
    SELECT loan_id 
    FROM metrics.raw_loan_accounts 
    WHERE account_number = 'AUTO-12345'
    LIMIT 1
)
INSERT INTO metrics.raw_loan_payments (
    loan_id,
    payment_date,
    payment_amount,
    principal_amount,
    interest_amount,
    extra_principal_amount,
    payment_method,
    payment_status
) 
SELECT 
    loan_id,
    '2025-01-15',       -- payment date
    436.82,             -- total payment amount
    386.82,             -- principal portion
    50.00,              -- interest portion
    100.00,             -- extra principal paid
    'credit_card',      -- payment method from enum
    'completed'         -- payment status
FROM loan_ref;
```

Verify the insert
```sql
-- Query to verify the insert
SELECT 
    l.lender_name,
    la.account_number,
    lp.payment_date,
    lp.payment_amount,
    lp.principal_amount,
    lp.interest_amount,
    lp.extra_principal_amount,
    lp.payment_method
FROM metrics.raw_loan_payments lp
JOIN metrics.raw_loan_accounts la ON lp.loan_id = la.loan_id
JOIN metrics.raw_lenders l ON la.lender_id = l.lender_id
ORDER BY lp.payment_date DESC;
```

## Retirement Accounts

### Accounts
```sql
-- Insert retirement account
INSERT INTO metrics.raw_retirement_accounts (
    provider_name,
    website_url,
    contact_phone,
    contact_email,
    account_type,
    account_number,
    opened_date,
    employer_name,
    employer_sponsored
) VALUES (
    'Evergreen Valley Investments',
    'https://www.evginvestments.com',
    '1-888-555-0123',
    'support@evginvestments.com',
    'traditional_401k',
    'EVG-401K-78901',
    '2024-01-01',
    'Summit Technologies',
    true
);
```

### Balances

```sql
-- Insert statement for this account
WITH account_ref AS (
    SELECT account_id 
    FROM metrics.raw_retirement_accounts 
    WHERE account_number = 'EVG-401K-78901'
    LIMIT 1
)
INSERT INTO metrics.raw_retirement_statements (
    account_id,
    statement_date,
    period_start_date,
    period_end_date,
    beginning_balance,
    employee_contribution,
    employer_contribution,
    fees,
    change_in_account_balance,
    ending_balance,
    dividends_and_interest
) 
SELECT 
    account_id,
    '2025-01-31',          -- statement date
    '2025-01-01',          -- period start
    '2025-01-31',          -- period end
    45678.92,              -- beginning balance
    750.00,                -- employee contribution
    375.00,                -- employer contribution
    -12.50,                -- fees
    1234.58,               -- change in balance
    47776.00,              -- ending balance
    85.75                  -- dividends and interest
FROM account_ref;
```