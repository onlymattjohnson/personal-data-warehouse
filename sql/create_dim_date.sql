CREATE TABLE IF NOT EXISTS dim_date (
    date_key SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    quarter_name CHAR(2) NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(9) NOT NULL,
    day INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    day_name VARCHAR(9) NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_current_date BOOLEAN NOT NULL,
    is_current_year BOOLEAN NOT NULL
);